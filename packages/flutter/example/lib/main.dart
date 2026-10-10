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
