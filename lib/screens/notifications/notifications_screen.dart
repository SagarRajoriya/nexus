import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/nx_card.dart';

class _Notif {
  final String app, title, body, device;
  final DateTime time;
  final bool unread;
  const _Notif(this.app, this.title, this.body, this.device, this.time, {this.unread = false});
}

final _notifs = [
  _Notif('WhatsApp','Ravi: "Meeting in 5 mins"','Sent from Android','Pixel 8 Pro',
      DateTime.now().subtract(const Duration(minutes: 3)), unread: true),
  _Notif('Gmail','Invoice #2341 received','Click to open in browser','Pixel 8 Pro',
      DateTime.now().subtract(const Duration(minutes: 10)), unread: true),
  _Notif('GitHub','Build passed: main branch','nexus-app #47 succeeded','Linux Laptop',
      DateTime.now().subtract(const Duration(minutes: 22))),
  _Notif('Spotify','Now playing: Dark Matter','Pearl Jam','Windows Laptop',
      DateTime.now().subtract(const Duration(hours: 1))),
];

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _enabled = true;
  final Set<String> _blocked = {};

  String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1)  return 'now';
    if (d.inMinutes < 60) return '${d.inMinutes}m';
    return '${d.inHours}h';
  }

  @override
  Widget build(BuildContext context) {
    final t  = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final unread = _notifs.where((n) => n.unread).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Switch(value: _enabled, onChanged: (v) => setState(() => _enabled = v),
              activeColor: AppTheme.notifColor),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        NxInfoBanner(
          icon: _enabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
          color: _enabled ? AppTheme.notifColor : cs.outline,
          title: _enabled ? 'Phone notifications mirrored here' : 'Mirroring paused',
          body: _enabled
              ? 'Notifications from Android devices appear here. Install the Nexus companion app on Android.'
              : 'Enable the toggle to start mirroring.',
        ),
        const SizedBox(height: 20),

        Row(children: [
          Text('Recent', style: t.titleLarge),
          const SizedBox(width: 8),
          if (unread > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.notifColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10)),
              child: Text('$unread new', style: TextStyle(
                  fontSize: 11, color: AppTheme.notifColor, fontWeight: FontWeight.w600)),
            ),
          const Spacer(),
          TextButton(onPressed: () {}, child: const Text('Clear all')),
        ]),
        const SizedBox(height: 8),

        ..._notifs.map((n) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: NxCard(
            accent: n.unread ? AppTheme.notifColor : null,
            selected: n.unread,
            padding: const EdgeInsets.all(14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (n.unread)
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 8),
                  child: Container(width: 7, height: 7,
                      decoration: const BoxDecoration(
                          color: AppTheme.notifColor, shape: BoxShape.circle)),
                ),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(n.app, style: t.labelLarge?.copyWith(color: AppTheme.notifColor)),
                  const SizedBox(width: 6),
                  Text('· ${n.device}', style: t.bodySmall),
                  const Spacer(),
                  Text(_timeAgo(n.time), style: t.bodySmall),
                ]),
                const SizedBox(height: 4),
                Text(n.title, style: t.titleMedium),
                if (n.body.isNotEmpty) Text(n.body, style: t.bodySmall),
              ])),
            ]),
          ),
        )),

        const SizedBox(height: 20),
        Text('App filters', style: t.titleLarge),
        const SizedBox(height: 4),
        Text('Choose which apps to mirror', style: t.bodySmall),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8,
          children: ['WhatsApp','Gmail','Calls','Spotify','Telegram','YouTube'].map((app) {
            final blocked = _blocked.contains(app);
            return FilterChip(
              label: Text(app),
              selected: !blocked,
              onSelected: (v) => setState(() => v ? _blocked.remove(app) : _blocked.add(app)),
              selectedColor: AppTheme.notifColor.withOpacity(0.15),
              checkmarkColor: AppTheme.notifColor,
            );
          }).toList()),
        const SizedBox(height: 32),
      ]),
    );
  }
}
