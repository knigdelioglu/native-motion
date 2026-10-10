import 'package:flutter/material.dart';
import 'package:native_motion/native_motion.dart';

void main() => runApp(const NativeMotionGallery());

class NativeMotionGallery extends StatefulWidget {
  const NativeMotionGallery({super.key});

  @override
  State<NativeMotionGallery> createState() => _NativeMotionGalleryState();
}

class _NativeMotionGalleryState extends State<NativeMotionGallery> {
  bool dark = false;
  bool reduced = false;
  int presses = 0;
  MotionButtonPhase phase = MotionButtonPhase.idle;
  MotionStatus status = MotionStatus.neutral;
  String section = 'overview';
  bool showCardDetails = false;
  bool showSecondCard = true;
  bool rtlPreview = false;
  double sliderValue = 45;
  bool sliderEditing = false;
  int sliderCommits = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.light, useMaterial3: true),
      darkTheme: ThemeData(brightness: Brightness.dark, useMaterial3: true),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: Builder(builder: (BuildContext context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
          child: Scaffold(
            appBar: AppBar(title: const Text('Native Motion · Flutter')),
            body: ListView(
              padding: const EdgeInsets.all(24),
              children: <Widget>[
                SwitchListTile(
                  title: const Text('Dark appearance'),
                  value: dark,
                  onChanged: (bool next) => setState(() { dark = next; }),
                ),
                SwitchListTile(
                  title: const Text('Reduced Motion preview'),
                  value: reduced,
                  onChanged: (bool next) => setState(() { reduced = next; }),
                ),
                const SizedBox(height: 16),
                const Text('MotionButton'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: <Widget>[
                    for (final MotionButtonVariant variant
                        in MotionButtonVariant.values)
                      MotionButton(
                        label: variant.name,
                        variant: variant,
                        onPressed: () => setState(() { presses++; }),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Actions: $presses'),
                const SizedBox(height: 12),
                DropdownButton<MotionButtonPhase>(
                  value: phase,
                  items: <DropdownMenuItem<MotionButtonPhase>>[
                    for (final MotionButtonPhase value in MotionButtonPhase.values)
                      DropdownMenuItem<MotionButtonPhase>(
                        value: value,
                        child: Text('Button phase: ${value.name}'),
                      ),
                  ],
                  onChanged: (MotionButtonPhase? next) {
                    if (next != null) setState(() { phase = next; });
                  },
                ),
                MotionButton(
                  label: 'Host-controlled action',
                  size: MotionButtonSize.large,
                  phase: phase,
                  onPressed: () => setState(() { presses++; }),
                ),
                const SizedBox(height: 28),
                const Text('MotionSegmentedControl'),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('RTL segmented-control preview'),
                  value: rtlPreview,
                  onChanged: (bool next) => setState(() { rtlPreview = next; }),
                ),
                Directionality(
                  textDirection: rtlPreview ? TextDirection.rtl : TextDirection.ltr,
                  child: MotionSegmentedControl(
                    label: 'Catalog section',
                    selection: section,
                    onChanged: (String next) => setState(() { section = next; }),
                    segments: const <MotionSegment>[
                      MotionSegment(id: 'overview', label: 'Overview', icon: Icons.dashboard_outlined),
                      MotionSegment(id: 'recent', label: 'Recent'),
                      MotionSegment(id: 'blocked', label: 'Disabled', enabled: false),
                      MotionSegment(id: 'details', label: 'Details', icon: Icons.tune),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text('Selected: $section'),
                const SizedBox(height: 24),
                const Text('MotionExpandableCard'),
                const SizedBox(height: 12),
                MotionExpandableCard(
                  title: 'Interaction details',
                  subtitle: 'Host-controlled expansion',
                  expanded: showCardDetails,
                  onChanged: (bool next) => setState(() { showCardDetails = next; }),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Expanded content keeps nested actions focusable.'),
                      const SizedBox(height: 12),
                      MotionButton(
                        label: 'Nested action',
                        variant: MotionButtonVariant.secondary,
                        onPressed: () => setState(() { presses++; }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                MotionExpandableCard(
                  title: 'Independent disclosure',
                  expanded: showSecondCard,
                  onChanged: (bool next) => setState(() { showSecondCard = next; }),
                  child: const Text('Expansion state is independent.'),
                ),
                const SizedBox(height: 28),
                const Text('MotionElasticSlider'),
                const SizedBox(height: 12),
                Directionality(
                  textDirection: rtlPreview ? TextDirection.rtl : TextDirection.ltr,
                  child: MotionElasticSlider(
                    label: 'Output level',
                    value: sliderValue,
                    scale: MotionSliderScale(minimum: 0, maximum: 100, step: 5),
                    marks: const <double>[0, 25, 50, 75, 100],
                    onChanged: (double next) => setState(() { sliderValue = next; }),
                    onEditingChanged: (bool editing) => setState(() { sliderEditing = editing; }),
                    onCommit: (double _) => setState(() { sliderCommits++; }),
                  ),
                ),
                Text('Drag: ${sliderEditing ? "active" : "idle"} · commits: $sliderCommits'),
                const SizedBox(height: 12),
                MotionElasticSlider(
                  label: 'Read-only',
                  value: 20,
                  onChanged: null,
                ),
                const SizedBox(height: 28),
                const Text('MotionStatusIndicator'),
                const SizedBox(height: 12),
                DropdownButton<MotionStatus>(
                  value: status,
                  items: <DropdownMenuItem<MotionStatus>>[
                    for (final MotionStatus value in MotionStatus.values)
                      DropdownMenuItem<MotionStatus>(
                        value: value,
                        child: Text('Status: ${value.name}'),
                      ),
                  ],
                  onChanged: (MotionStatus? next) {
                    if (next != null) setState(() { status = next; });
                  },
                ),
                MotionStatusIndicator(
                  label: 'Example operation',
                  status: status,
                  detail: 'All state changes are supplied by the host',
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
