#if os(macOS)
import AppKit
import Foundation
import ImageIO
import SwiftUI
import NativeMotion

private enum VisualAuditError: Error, CustomStringConvertible {
    case usage
    case rendering(String)
    case reference(String)
    case regression(String)

    var description: String {
        switch self {
        case .usage: return "Usage: swift run NativeMotionVisualAudit <output-directory> [--baseline <approved-reference-directory>]"
        case .rendering(let message), .reference(let message), .regression(let message): return message
        }
    }
}

private struct AuditScene: View {
    let scenario: MotionQualityScenario
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Native Motion").font(.largeTitle.bold())
                Text("Visual quality reference  ·  \(scenario.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 10) {
                MotionButton("Primary") {}
                MotionButton("Secondary", variant: .secondary) {}
                MotionButton("Destructive", variant: .destructive) {}
            }
            HStack(spacing: 10) {
                MotionButton("Loading", phase: .loading) {}
                MotionButton("Success", phase: .success) {}
                MotionButton("Failure", phase: .failure) {}
            }
            MotionSegmentedControl("Selection", segments: [
                MotionSegment("one", title: "Overview", systemImage: "square.grid.2x2"),
                MotionSegment("two", title: "Activity", systemImage: "chart.xyaxis.line"),
                MotionSegment("three", title: "Disabled", isEnabled: false)
            ], selection: .constant("two"))
            MotionExpandableCard(
                "Disclosure",
                subtitle: "An accessible, host-controlled surface",
                isExpanded: .constant(true)
            ) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Expanded details, retaining independent controls.")
                    MotionButton("Nested action", variant: .secondary) {}
                }
            }
            MotionElasticSlider(
                "Output level",
                value: .constant(65),
                scale: MotionSliderScale(minimum: 0, maximum: 100, step: 5),
                marks: [0, 25, 50, 75, 100]
            )
            VStack(spacing: 9) {
                MotionStatusIndicator("Completed task", status: .success)
                MotionStatusIndicator("Attention required", status: .warning)
                MotionStatusIndicator("Failed task", status: .failure)
            }
        }
        .padding(30)
        .frame(width: 720, height: 780, alignment: .topLeading)
        .background(NativeMotionTheme.color(.background, colorScheme: scheme))
    }
}

@MainActor
private enum VisualAudit {
    static func capture(_ scenario: MotionQualityScenario, to output: URL) throws -> CGImage {
        let appearance: ColorScheme = scenario == .dark ? .dark : .light
        let content = AuditScene(scenario: scenario)
            .nativeMotionOffscreenPreview()
            .environment(\.colorScheme, appearance)
            .nativeMotionPreviewReduceMotion(scenario == .reducedMotion)
            .environment(\.dynamicTypeSize, scenario == .largeText ? .accessibility1 : .large)
        let renderer = ImageRenderer(content: content)
        renderer.scale = 2
        guard let image = renderer.cgImage, image.width == 1440, image.height == 1560 else {
            throw VisualAuditError.rendering("Could not render 1440 x 1560 image for \(scenario.rawValue)")
        }
        guard let bytes = NSBitmapImageRep(cgImage: image)
                .representation(using: .png, properties: [:]), bytes.count > 15_000 else {
            throw VisualAuditError.rendering("PNG is missing or suspiciously small: \(scenario.rawValue)")
        }
        try bytes.write(to: output, options: Data.WritingOptions.atomic)
        return image
    }

    static func pixels(_ image: CGImage) throws -> [UInt8] {
        var output = [UInt8](repeating: 0, count: image.width * image.height * 4)
        let success = output.withUnsafeMutableBytes { bytes -> Bool in
            guard let ctx = CGContext(
                data: bytes.baseAddress,
                width: image.width,
                height: image.height,
                bitsPerComponent: 8,
                bytesPerRow: image.width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else { return false }
            ctx.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
            return true
        }
        guard success else { throw VisualAuditError.rendering("Could not access RGBA pixels") }
        return output
    }

    static func compare(_ fresh: CGImage, with approved: URL, name: String) throws {
        guard let source = CGImageSourceCreateWithURL(approved as CFURL, nil),
              let reference = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw VisualAuditError.reference("Missing approved baseline: \(approved.path)")
        }
        guard fresh.width == reference.width, fresh.height == reference.height else {
            throw VisualAuditError.regression("\(name): snapshot dimensions changed")
        }
        let a = try pixels(fresh)
        let b = try pixels(reference)
        var changed = 0
        let pixelCount = a.count / 4
        for i in 0..<pixelCount {
            let offset = i * 4
            if (0..<4).contains(where: { abs(Int(a[offset + $0]) - Int(b[offset + $0])) > 12 }) {
                changed += 1
            }
        }
        let ratio = Double(changed) / Double(pixelCount)
        // Minor native font rasterization variation is allowed.
        guard ratio <= 0.02 else {
            throw VisualAuditError.regression(
                "\(name): \(String(format: "%.2f", ratio * 100))% pixels changed (2% limit)"
            )
        }
        print("\(name): baseline match, \(String(format: "%.2f", ratio * 100))% pixels different")
    }
}

@main
private struct VisualAuditCLI {
    @MainActor
    static func main() throws {
        let args = Array(CommandLine.arguments.dropFirst())
        guard args.count == 1 || (args.count == 3 && args[1] == "--baseline") else {
            throw VisualAuditError.usage
        }
        let destination = URL(fileURLWithPath: args[0], isDirectory: true)
        try FileManager.default.createDirectory(at: destination, withIntermediateDirectories: true)
        let baseline = args.count == 3 ? URL(fileURLWithPath: args[2], isDirectory: true) : nil
        for scenario in MotionQualityContract.expectedScenarios {
            let name = scenario.rawValue + ".png"
            let image = try VisualAudit.capture(scenario, to: destination.appendingPathComponent(name))
            if let baseline {
                try VisualAudit.compare(image, with: baseline.appendingPathComponent(name), name: name)
            }
            print("Captured \(name) — \(image.width) x \(image.height)")
        }
        if baseline == nil {
            print("Visual artifacts captured. Pixel comparison is NOT enabled until approved baselines are supplied.")
        }
    }
}
#else
import Foundation

@main
private struct VisualAuditUnsupportedPlatform {
    static func main() {
        print("NativeMotionVisualAudit requires macOS and SwiftUI.")
    }
}
#endif
