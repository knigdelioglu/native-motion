import Foundation
import NativeMotion

/// Deterministic, opt-in microbenchmark for geometry/value-model work.
/// It is NOT a measurement of SwiftUI render time, GPU frame rate or latency.
@main
struct NativeMotionBenchmarkCLI {
    static func main() {
        let args = Array(CommandLine.arguments.dropFirst())
        let iterations: Int
        if args.count == 2, args[0] == "--iterations",
           let parsed = Int(args[1]), (1_000...2_000_000).contains(parsed) {
            iterations = parsed
        } else if args.isEmpty {
            iterations = 100_000
        } else {
            fputs("Usage: NativeMotionBenchmark [--iterations 100000]\n", stderr)
            exit(2)
        }

        let scale = MotionSliderScale(minimum: 5, maximum: 97, step: 0.5)
        var checksum = 0.0
        let start = DispatchTime.now().uptimeNanoseconds
        for index in 0..<iterations {
            let progress = Double(index % 1001) / 1000
            let value = scale.value(atProgress: progress)
            checksum += scale.progress(for: value)
        }
        let elapsedNs = DispatchTime.now().uptimeNanoseconds - start
        let averageUs = Double(elapsedNs) / Double(iterations) / 1000
        let report = """
        {
          "benchmark": "MotionSliderScale",
          "kind": "non_ui_value_model",
          "iterations": \(iterations),
          "elapsed_ms": \(String(format: "%.4f", Double(elapsedNs) / 1_000_000)),
          "average_microseconds": \(String(format: "%.6f", averageUs)),
          "checksum": \(String(format: "%.5f", checksum)),
          "release_note": "Do not infer UI frame rate or device responsiveness from this benchmark."
        }
        """
        print(report)
    }
}
