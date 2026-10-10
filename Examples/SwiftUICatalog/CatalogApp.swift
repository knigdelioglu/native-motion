#if canImport(SwiftUI)
import SwiftUI
import NativeMotion

@main
struct NativeMotionCatalogApp: App {
    var body: some Scene {
        WindowGroup("Native Motion Catalog") {
            CatalogView()
        }
    }
}

private struct CatalogView: View {
    @State private var phase: MotionButtonPhase = .idle
    @State private var actionCount = 0
    @State private var exportCount = 0
    @State private var deletionCount = 0
    @State private var chosenExport = "None"
    @State private var confirmationPhase: MotionButtonPhase = .idle
    @State private var selected = "overview"
    @State private var expanded = true
    @State private var secondExpanded = false
    @State private var sliderValue = 45.0
    @State private var sliderEditing = false
    @State private var sliderCommits = 0
    @State private var currentStatus: MotionStatus = .neutral
    @State private var appearanceOverride = "system"
    @State private var forceReducedMotion = false
    @State private var forceLargeText = false
    @State private var compactSelection = false
    @State private var selectionCheck: MotionCheckboxState = .mixed
    @State private var radioSelection = "all"
    @State private var backgroundSync = true
    @State private var fieldName = ""
    @State private var fieldSearch = ""
    @State private var fieldAmount = 12.5
    @State private var formSubmitted = 0
    @State private var pickerSelection = "all"
    @State private var menuAction = "None"
    @State private var dialogPresented = false
    @State private var dialogPhase: MotionButtonPhase = .idle
    @State private var dialogConfirmCount = 0
    @State private var dialogCancelCount = 0
    @State private var popoverPresented = false
    @State private var popoverClosedCount = 0
    @State private var tabsSelection = "overview"
    @State private var tabContentCounter = 0
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dynamicTypeSize) private var systemDynamicType

    private var requestedScheme: ColorScheme? {
        switch appearanceOverride {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Native Motion").font(.largeTitle.bold())
                    Text("Independent native controls, visual states and gestures")
                        .foregroundStyle(.secondary)
                }

                GroupBox("Quality inspection") {
                    VStack(alignment: .leading, spacing: 10) {
                        Picker("Appearance", selection: $appearanceOverride) {
                            Text("System").tag("system")
                            Text("Light").tag("light")
                            Text("Dark").tag("dark")
                        }
                        .pickerStyle(.segmented)
                        Toggle("Reduce Motion preview", isOn: $forceReducedMotion)
                        Toggle("Large text preview", isOn: $forceLargeText)
                        Text("These controls preview system accessibility preferences; use actual macOS settings for final testing.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionButton · variants").font(.title2.bold())
                    ForEach(MotionButtonVariant.allCases, id: \.self) { variant in
                        MotionButton("Perform action", variant: variant) {
                            actionCount += 1
                        }
                    }
                    Text("Actions: \(actionCount)")
                        .font(.footnote).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionButton · phases").font(.title2.bold())
                    Picker("State", selection: $phase) {
                        ForEach(MotionButtonPhase.allCases, id: \.self) { state in
                            Text(state.rawValue.capitalized).tag(state)
                        }
                    }
                    .pickerStyle(.segmented)
                    MotionButton("Continue", size: .large, phase: phase) {
                        actionCount += 1
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionButton · sizes").font(.title2.bold())
                    ForEach(MotionButtonSize.allCases, id: \.self) { size in
                        MotionButton("Example", variant: .secondary, size: size) {
                            actionCount += 1
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionIconButton").font(.title2.bold())
                    HStack(spacing: 12) {
                        ForEach(MotionButtonVariant.allCases, id: \.self) { variant in
                            MotionIconButton(
                                systemName: "square.and.arrow.up",
                                label: "Share",
                                variant: variant
                            ) { actionCount += 1 }
                        }
                    }
                    HStack(spacing: 12) {
                        MotionIconButton(
                            systemName: "arrow.clockwise",
                            label: "Refresh",
                            phase: phase
                        ) { actionCount += 1 }
                        MotionIconButton(
                            systemName: "trash",
                            label: "Unavailable",
                            variant: .destructive
                        ) { actionCount += 1 }
                            .disabled(true)
                    }
                    Text("Hover, focus, loading and accessibility-label checks")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionSplitButton").font(.title2.bold())
                    MotionSplitButton(
                        "Export",
                        actions: [
                            MotionSplitAction("pdf", title: "Export PDF", systemImage: "doc.richtext") {
                                chosenExport = "PDF"
                            },
                            MotionSplitAction("csv", title: "Export CSV", systemImage: "tablecells") {
                                chosenExport = "CSV"
                            },
                            MotionSplitAction("disabled", title: "Unavailable", isEnabled: false) {}
                        ]
                    ) {
                        exportCount += 1
                        chosenExport = "Default"
                    }
                    Text("Primary presses: \(exportCount) · Option: \(chosenExport)")
                        .font(.footnote).foregroundStyle(.secondary)

                    MotionSplitButton(
                        "Busy",
                        phase: .loading,
                        actions: [MotionSplitAction("copy", title: "Copy") {}],
                        primaryAction: {}
                    )
                    Text("Try separate primary and menu keyboard focus.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionConfirmButton").font(.title2.bold())
                    MotionConfirmButton(
                        "Delete item",
                        confirmationTitle: "Confirm deletion",
                        phase: confirmationPhase
                    ) {
                        deletionCount += 1
                        confirmationPhase = .success
                    }
                    MotionButton("Reset confirmation demo", variant: .secondary) {
                        confirmationPhase = .idle
                    }
                    Text("Completed confirmations: \(deletionCount)")
                        .font(.footnote).foregroundStyle(.secondary)
                    Text("First click arms; second confirms. Cancel or Escape disarms.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionToggle").font(.title2.bold())
                    MotionToggle("Compact selection", isOn: $compactSelection)
                    MotionToggle("Read-only toggle", isOn: .constant(true), isEnabled: false)
                    Text("Host selection: \(compactSelection ? "On" : "Off")")
                        .font(.footnote).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionCheckbox").font(.title2.bold())
                    MotionCheckbox("Select all", state: $selectionCheck)
                    MotionCheckbox("Disabled option", state: .constant(.checked), isEnabled: false)
                    MotionButton("Set partially checked", variant: .secondary) {
                        selectionCheck = .mixed
                    }
                    Text("Checkbox: \(selectionCheck.rawValue)")
                        .font(.footnote).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionRadioGroup").font(.title2.bold())
                    MotionRadioGroup(
                        "Choose a category",
                        options: [
                            MotionRadioOption("all", title: "All"),
                            MotionRadioOption("new", title: "New"),
                            MotionRadioOption("blocked", title: "Unavailable", isEnabled: false),
                            MotionRadioOption("old", title: "Archived")
                        ],
                        selection: $radioSelection
                    )
                    Text("Selection: \(radioSelection)")
                        .font(.footnote).foregroundStyle(.secondary)
                    Text("On macOS use keyboard arrows; disabled items are skipped.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionSwitch").font(.title2.bold())
                    MotionSwitch(
                        "Background synchronization",
                        detail: "Native platform switch with controlled state",
                        isOn: $backgroundSync
                    )
                    MotionSwitch("Read-only switch", isOn: .constant(false), isEnabled: false)
                    Text("Synchronization: \(backgroundSync ? "On" : "Off")")
                        .font(.footnote).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionTextField").font(.title2.bold())
                    MotionTextField(
                        "Display name",
                        placeholder: "Enter a name",
                        text: $fieldName,
                        feedback: fieldName.isEmpty
                            ? MotionFieldFeedback("A name is required", style: .error)
                            : MotionFieldFeedback("Looks good", style: .success)
                    ) { formSubmitted += 1 }
                    MotionTextField(
                        "Read only",
                        text: .constant("Unavailable"),
                        isEnabled: false
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionSearchField").font(.title2.bold())
                    MotionSearchField(
                        "Find components",
                        placeholder: "Search...",
                        query: $fieldSearch,
                        feedback: MotionFieldFeedback(
                            "Search only updates local host state",
                            style: .hint
                        )
                    ) { formSubmitted += 1 }
                    Text("Query: \(fieldSearch)")
                        .font(.footnote).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionNumberField").font(.title2.bold())
                    MotionNumberField(
                        "Quantity",
                        value: $fieldAmount,
                        scale: MotionSliderScale(minimum: 0, maximum: 95, step: 5),
                        feedback: MotionFieldFeedback(
                            "Uses the active system number locale",
                            style: .hint
                        )
                    ) { _ in formSubmitted += 1 }
                    Text("Committed value: \(fieldAmount) · submits: \(formSubmitted)")
                        .font(.footnote).foregroundStyle(.secondary)
                    Text("Try a comma decimal with the Turkish locale, invalid text, and +/- at the limits.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionSelect").font(.title2.bold())
                    MotionSelect(
                        "Category",
                        options: [
                            MotionSelectOption("all", title: "All"),
                            MotionSelectOption("recent", title: "Recent"),
                            MotionSelectOption("disabled", title: "Unavailable", isEnabled: false)
                        ],
                        selection: $pickerSelection,
                        feedback: MotionFieldFeedback("Host-controlled selection", style: .hint)
                    )
                    Text("Selected: \(pickerSelection)")
                        .font(.footnote).foregroundStyle(.secondary)
                    MotionSelect(
                        "Read-only",
                        options: [MotionSelectOption("all", title: "All")],
                        selection: .constant("all"),
                        isEnabled: false
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionMenu").font(.title2.bold())
                    MotionMenu(
                        "File actions",
                        actions: [
                            MotionMenuAction("share", title: "Share", systemImage: "square.and.arrow.up") {
                                menuAction = "Share"
                            },
                            MotionMenuAction("blocked", title: "Unavailable", isEnabled: false) {},
                            MotionMenuAction("delete", title: "Delete", systemImage: "trash", role: .destructive) {
                                menuAction = "Delete"
                            }
                        ]
                    )
                    Text("Last menu action: \(menuAction)")
                        .font(.footnote).foregroundStyle(.secondary)
                    MotionMenu(
                        "No available actions",
                        actions: [MotionMenuAction("off", title: "Disabled", isEnabled: false) {}]
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionDialog").font(.title2.bold())
                    Picker("Modal host phase", selection: $dialogPhase) {
                        ForEach(MotionButtonPhase.allCases, id: \.self) { state in
                            Text(state.rawValue.capitalized).tag(state)
                        }
                    }
                    .pickerStyle(.menu)
                    MotionDialog(
                        "Delete local example",
                        isPresented: $dialogPresented,
                        confirmTitle: "Delete",
                        phase: dialogPhase,
                        confirmationRole: .destructive,
                        onConfirm: {
                            dialogConfirmCount += 1
                            dialogPhase = .success
                        },
                        onCancel: { dialogCancelCount += 1 }
                    ) {
                        Text("Open confirmation dialog")
                    } content: {
                        Text("The host owns the operation and closes the modal explicitly.")
                        if dialogPhase == .success {
                            MotionButton("Close after completion", variant: .secondary) {
                                dialogPresented = false
                                dialogPhase = .idle
                            }
                        }
                    }
                    Text("Confirms: \(dialogConfirmCount) · cancels: \(dialogCancelCount)")
                        .font(.footnote).foregroundStyle(.secondary)
                    Text("Try keyboard focus, Escape, loading and reduced motion.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionPopover").font(.title2.bold())
                    MotionPopover(
                        "Options",
                        isPresented: $popoverPresented,
                        onDismiss: { popoverClosedCount += 1 }
                    ) {
                        Label("Open popover", systemImage: "rectangle.on.rectangle")
                    } content: {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Native anchored content can contain independent actions.")
                            MotionButton("Nested action", variant: .secondary) {
                                actionCount += 1
                            }
                        }
                    }
                    Text("Popover dismissed: \(popoverClosedCount) times")
                        .font(.footnote).foregroundStyle(.secondary)
                    Text("Try Escape, outside dismissal, keyboard focus and compact windows.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionTooltip").font(.title2.bold())
                    MotionTooltip(
                        "About this setting",
                        message: "Explanation is accessible on hover, focus or tap."
                    ) {
                        Label("Why?", systemImage: "questionmark.circle")
                    }
                    MotionTooltip(
                        "Unavailable hint", message: "The host has disabled this control.",
                        isEnabled: false
                    ) {
                        Image(systemName: "questionmark.circle")
                    }
                    Text("Hover on macOS for native help; tap to reveal a native popover.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionTabs").font(.title2.bold())
                    MotionTabs(
                        "Catalog sections",
                        tabs: [
                            MotionTabItem("overview", title: "Overview", systemImage: "square.grid.2x2"),
                            MotionTabItem("activity", title: "Activity", systemImage: "chart.bar"),
                            MotionTabItem("disabled", title: "Unavailable", isEnabled: false),
                            MotionTabItem("details", title: "Details", systemImage: "doc.text")
                        ],
                        selection: $tabsSelection
                    ) { tabID in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Visible tab: \(tabID)")
                            Text("Host count: \(tabContentCounter)")
                                .font(.footnote).foregroundStyle(.secondary)
                            MotionButton("Increment host state", variant: .secondary) {
                                tabContentCounter += 1
                            }
                        }
                        .padding(12)
                    }
                    Text("Keyboard arrows skip disabled tabs. Host state persists across tabs.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionSegmentedControl").font(.title2.bold())
                    MotionSegmentedControl(
                        "Catalog section",
                        segments: [
                            MotionSegment("overview", title: "Overview", systemImage: "square.grid.2x2"),
                            MotionSegment("activity", title: "Activity", systemImage: "chart.xyaxis.line"),
                            MotionSegment("disabled", title: "Unavailable", isEnabled: false),
                            MotionSegment("details", title: "Details", systemImage: "text.alignleft"),
                            MotionSegment("settings", title: "Settings", systemImage: "gearshape")
                        ],
                        selection: $selected
                    )
                    Text("Selection: \(selected)")
                        .font(.footnote).foregroundStyle(.secondary)
                    Text("Keyboard: tab to a segment, then use the arrow keys on macOS.")
                        .font(.caption).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionExpandableCard").font(.title2.bold())
                    MotionExpandableCard(
                        "Interaction details",
                        subtitle: "Tap or keyboard-activate to disclose",
                        isExpanded: $expanded
                    ) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Expanded content belongs to the host. Controls inside remain independently focusable.")
                            MotionButton("Nested action", variant: .secondary) {
                                actionCount += 1
                            }
                        }
                    }
                    MotionExpandableCard("Another disclosure", isExpanded: $secondExpanded) {
                        Text("Multiple cards may expand independently.")
                    }
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionElasticSlider").font(.title2.bold())
                    MotionElasticSlider(
                        "Output level",
                        value: $sliderValue,
                        scale: MotionSliderScale(minimum: 0, maximum: 100, step: 5),
                        marks: [0, 25, 50, 75, 100],
                        onEditingChanged: { sliderEditing = $0 },
                        onCommit: { _ in sliderCommits += 1 }
                    )
                    Text("Drag: \(sliderEditing ? "active" : "idle") · commits: \(sliderCommits)")
                        .font(.footnote).foregroundStyle(.secondary)
                    MotionElasticSlider(
                        "Disabled adjustment",
                        value: .constant(20),
                        isEnabled: false
                    )
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("MotionStatusIndicator").font(.title2.bold())
                    Picker("Status", selection: $currentStatus) {
                        ForEach(MotionStatus.allCases, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(status)
                        }
                    }
                    .pickerStyle(.menu)
                    MotionStatusIndicator(
                        "Sample operation",
                        status: currentStatus,
                        detail: "Controlled entirely by the host"
                    )
                }

                Text("Review light/dark appearance, Dynamic Type, VoiceOver, keyboard navigation and Reduce Motion.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .padding(32)
            .frame(maxWidth: 600, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(NativeMotionTheme.color(.background, colorScheme: requestedScheme ?? colorScheme))
        .preferredColorScheme(requestedScheme)
        .nativeMotionPreviewReduceMotion(forceReducedMotion)
        .environment(\.dynamicTypeSize, forceLargeText ? .accessibility1 : systemDynamicType)
    }
}
#else
@main
struct NativeMotionCatalogUnsupportedPlatform {
    static func main() {
        print("NativeMotionCatalog requires macOS 13+ with SwiftUI.")
    }
}
#endif
