import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../models/device.dart';
import '../../services/devices_provider.dart';
import '../../widgets/nx_card.dart';

class StreamScreen extends ConsumerStatefulWidget {
  const StreamScreen({super.key});
  @override
  ConsumerState<StreamScreen> createState() => _StreamScreenState();
}

class _StreamScreenState extends ConsumerState<StreamScreen> {
  Device? _host;
  String _quality = '1080p 60fps';
  bool _vsurround = false;

  @override
  Widget build(BuildContext context) {
    final capable = ref.watch(onlineDevicesProvider)
        .where((d) => d.capabilities['stream'] == true).toList();
    final t  = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('App streaming')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        NxInfoBanner(
          icon: Icons.cast_rounded, color: AppTheme.streamColor,
          title: 'Sunshine + Moonlight',
          body: 'Run any app on Windows or Linux and stream it here with near-zero latency.',
        ),
        const SizedBox(height: 20),
        Text('Host device', style: t.titleLarge),
        const SizedBox(height: 4),
        Text('Must have Sunshine installed and running', style: t.bodySmall),
        const SizedBox(height: 12),

        if (capable.isEmpty)
          NxCard(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(children: [
              Icon(Icons.cast_outlined, size: 36, color: cs.onSurface.withOpacity(0.2)),
              const SizedBox(height: 10),
              Text('No stream-capable hosts found', style: t.titleMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.4))),
              const SizedBox(height: 4),
              Text('Install Sunshine on Windows/Linux host', style: t.bodySmall, textAlign: TextAlign.center),
            ]),
          ))
        else
          ...capable.map((d) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NxCard(
              accent: AppTheme.streamColor,
              selected: _host?.id == d.id,
              onTap: () => setState(() => _host = _host?.id == d.id ? null : d),
              child: Row(children: [
                Icon(d.icon, color: d.color, size: 22),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d.name, style: t.titleMedium),
                  Text('${d.ip} · Sunshine ready', style: t.bodySmall),
                ])),
                if (_host?.id == d.id)
                  const Icon(Icons.check_circle_rounded, color: AppTheme.streamColor, size: 20),
              ]),
            ),
          )),

        const SizedBox(height: 20),
        Text('Stream settings', style: t.titleLarge),
        const SizedBox(height: 12),
        NxCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonFormField<String>(
                value: _quality,
                decoration: const InputDecoration(labelText: 'Quality', border: InputBorder.none),
                items: ['720p 30fps','720p 60fps','1080p 30fps','1080p 60fps','4K 30fps']
                    .map((q) => DropdownMenuItem(value: q, child: Text(q))).toList(),
                onChanged: (v) { if (v != null) setState(() => _quality = v); },
              ),
            ),
            const Divider(height: 1),
            SwitchListTile(
              title: Text('Virtual surround sound', style: t.bodyMedium),
              subtitle: Text('5.1 via headphones', style: t.bodySmall),
              value: _vsurround,
              onChanged: (v) => setState(() => _vsurround = v),
              activeColor: AppTheme.streamColor,
            ),
          ]),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: _host == null ? null : _launch,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(_host == null ? 'Select a host device' : 'Stream from ${_host!.name}'),
          style: FilledButton.styleFrom(
            backgroundColor: AppTheme.streamColor,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            disabledBackgroundColor: AppTheme.streamColor.withOpacity(0.3),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => _showSetup(context),
          icon: const Icon(Icons.help_outline_rounded, size: 18),
          label: const Text('How to set up Sunshine'),
          style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  void _launch() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Launching Moonlight stream from ${_host!.name} at $_quality…'),
      behavior: SnackBarBehavior.floating,
    ));
    // TODO: url_launcher → moonlight://${_host!.ip}
  }

  void _showSetup(BuildContext context) {
    showModalBottomSheet(context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Setting up Sunshine', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          for (final (n, s) in [
            ('1', 'Download Sunshine from github.com/LizardByte/Sunshine'),
            ('2', 'Install on your Windows or Linux host'),
            ('3', 'Open the web UI at localhost:47990 and add your apps'),
            ('4', 'Nexus detects Sunshine automatically on the LAN'),
          ]) _Step(n, s),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String n, text;
  const _Step(this.n, this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 24, height: 24,
        decoration: BoxDecoration(
          color: AppTheme.streamColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(6)),
        child: Center(child: Text(n, style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.streamColor))),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
    ]),
  );
}
