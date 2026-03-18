import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/nx_card.dart';

class _Clip {
  final String content, type, source;
  final DateTime time;
  const _Clip(this.content, this.type, this.source, this.time);
}

final _clips = [
  _Clip('https://github.com/LizardByte/Sunshine','url','Windows Laptop',
      DateTime.now().subtract(const Duration(minutes: 2))),
  _Clip('flutter pub get && flutter run -d all','text','Linux Laptop',
      DateTime.now().subtract(const Duration(minutes: 8))),
  _Clip('nexus@192.168.1.101:~/Desktop','text','This device',
      DateTime.now().subtract(const Duration(minutes: 15))),
  _Clip('Meet at 3 PM for the standup','text','Pixel 8 Pro',
      DateTime.now().subtract(const Duration(hours: 1))),
];

class ClipboardScreen extends StatefulWidget {
  const ClipboardScreen({super.key});
  @override
  State<ClipboardScreen> createState() => _ClipboardScreenState();
}

class _ClipboardScreenState extends State<ClipboardScreen> {
  bool _syncEnabled = true;

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1)  return 'just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    return '${d.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    final t  = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clipboard sync'),
        actions: [
          Switch(value: _syncEnabled,
              onChanged: (v) => setState(() => _syncEnabled = v),
              activeColor: AppTheme.clipboardColor),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _syncEnabled
                ? AppTheme.clipboardColor.withOpacity(0.08)
                : cs.outline.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _syncEnabled
                ? AppTheme.clipboardColor.withOpacity(0.3)
                : cs.outline.withOpacity(0.2)),
          ),
          child: Row(children: [
            Icon(
              _syncEnabled ? Icons.sync_rounded : Icons.sync_disabled_rounded,
              color: _syncEnabled ? AppTheme.clipboardColor : cs.outline, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(
              _syncEnabled
                  ? 'Clipboard syncs instantly to all connected devices'
                  : 'Sync paused — clipboard stays local',
              style: t.bodyMedium?.copyWith(
                  color: _syncEnabled ? AppTheme.clipboardColor : cs.onSurface.withOpacity(0.4)),
            )),
          ]),
        ),
        const SizedBox(height: 20),

        Row(children: [
          Text('History', style: t.titleLarge),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text('Clear all')),
        ]),
        const SizedBox(height: 8),

        ..._clips.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: NxCard(
            accent: AppTheme.clipboardColor,
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(c.type == 'url' ? Icons.link_rounded : Icons.text_fields_rounded,
                    size: 13, color: AppTheme.clipboardColor),
                const SizedBox(width: 6),
                Text(c.source, style: t.bodySmall?.copyWith(color: AppTheme.clipboardColor)),
                const Spacer(),
                Text(_ago(c.time), style: t.bodySmall),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: c.content));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Copied'), behavior: SnackBarBehavior.floating));
                  },
                  child: Icon(Icons.copy_rounded, size: 15,
                      color: cs.onSurface.withOpacity(0.4)),
                ),
              ]),
              const SizedBox(height: 8),
              Text(c.content, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: t.bodyMedium?.copyWith(
                      fontFamily: c.type == 'url' ? 'monospace' : null,
                      color: c.type == 'url' ? AppTheme.primary : null)),
            ]),
          ),
        )),

        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () async {
            final data = await Clipboard.getData(Clipboard.kTextPlain);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(data?.text != null
                  ? 'Broadcast: "${data!.text!.substring(0, data.text!.length.clamp(0, 40))}…"'
                  : 'Clipboard is empty'),
              behavior: SnackBarBehavior.floating,
            ));
          },
          icon: const Icon(Icons.send_rounded, size: 18),
          label: const Text('Paste & broadcast to all devices'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            foregroundColor: AppTheme.clipboardColor,
            side: BorderSide(color: AppTheme.clipboardColor.withOpacity(0.4)),
          ),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }
}
