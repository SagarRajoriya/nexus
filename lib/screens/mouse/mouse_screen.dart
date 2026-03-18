import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../services/devices_provider.dart';
import '../../models/device.dart';
import '../../widgets/nx_card.dart';

class MouseScreen extends ConsumerStatefulWidget {
  const MouseScreen({super.key});
  @override
  ConsumerState<MouseScreen> createState() => _MouseScreenState();
}

class _MouseScreenState extends ConsumerState<MouseScreen> {
  bool _active = false;
  String _mode = 'server';
  final _serverIpCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(onlineDevicesProvider);
    final t  = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Mouse & keyboard sharing')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        NxInfoBanner(
          icon: Icons.mouse_rounded, color: AppTheme.mouseColor,
          title: 'Barrier / Input Leap',
          body: 'Share one mouse and keyboard across all your Windows and Linux laptops. '
                'Move the cursor to the screen edge to switch devices.',
        ),
        const SizedBox(height: 20),

        Text('Mode', style: t.titleLarge),
        const SizedBox(height: 10),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'server', icon: Icon(Icons.hub_rounded, size: 16),
                label: Text('Server — I control others')),
            ButtonSegment(value: 'client', icon: Icon(Icons.computer_rounded, size: 16),
                label: Text('Client — controlled by server')),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => setState(() => _mode = s.first),
        ),
        const SizedBox(height: 20),

        if (_mode == 'server') ...[
          Text('Screen layout', style: t.titleLarge),
          const SizedBox(height: 4),
          Text('Visual arrangement — left to right across your desk', style: t.bodySmall),
          const SizedBox(height: 12),
          NxCard(
            accent: AppTheme.mouseColor,
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _ScreenBox('This device', AppTheme.mouseColor, true),
                const SizedBox(width: 6),
                ...devices.take(2).map((d) => Row(children: [
                  const SizedBox(width: 6),
                  _ScreenBox(d.name.split(' ').first, d.color, false),
                ])),
              ]),
              const SizedBox(height: 16),
              Text('Drag to rearrange screens', style: t.bodySmall),
            ]),
          ),
        ] else ...[
          Text('Server address', style: t.titleLarge),
          const SizedBox(height: 10),
          TextField(
            controller: _serverIpCtrl,
            decoration: const InputDecoration(
              labelText: 'Server IP address',
              hintText: '192.168.1.xxx',
              prefixIcon: Icon(Icons.dns_rounded),
            ),
          ),
        ],

        const SizedBox(height: 20),
        NxCard(
          accent: AppTheme.mouseColor,
          selected: _active,
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            AnimatedContainer(duration: const Duration(milliseconds: 250),
              width: 10, height: 10,
              decoration: BoxDecoration(
                color: _active ? AppTheme.mouseColor : Theme.of(context).colorScheme.outline,
                shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_mode == 'server' ? 'Start server' : 'Connect to server',
                  style: t.titleMedium),
              Text(_active ? 'Active — sharing mouse & keyboard' : 'Tap to start',
                  style: t.bodySmall?.copyWith(
                      color: _active ? AppTheme.mouseColor : null)),
            ])),
            Switch(value: _active,
                onChanged: (v) => setState(() => _active = v),
                activeColor: AppTheme.mouseColor),
          ]),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }
}

class _ScreenBox extends StatelessWidget {
  final String label;
  final Color color;
  final bool isThis;
  const _ScreenBox(this.label, this.color, this.isThis);
  @override
  Widget build(BuildContext context) => Container(
    width: 88, height: 56,
    decoration: BoxDecoration(
      color: color.withOpacity(isThis ? 0.2 : 0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.6), width: isThis ? 2 : 1),
    ),
    child: Center(child: Text(label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color))),
  );
}
