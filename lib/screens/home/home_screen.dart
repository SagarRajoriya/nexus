import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../services/devices_provider.dart';
import '../../services/discovery_service.dart';
import '../../models/device.dart';
import '../../widgets/nx_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Kick off LAN discovery when home loads
    Future.microtask(() => ref.read(discoveryServiceProvider).start());
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(devicesProvider);
    final online  = devices.where((d) => d.status == DeviceStatus.online).length;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 120,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            title: Column(mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Nexus', style: t.headlineMedium),
              Text('$online device${online == 1 ? '' : 's'} online',
                  style: t.bodySmall?.copyWith(color: AppTheme.accent)),
            ]),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.go('/settings')),
            const SizedBox(width: 8),
          ],
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(delegate: SliverChildListDelegate([

            // ── Device strip ──────────────────────────────────────
            SizedBox(
              height: 88,
              child: devices.isEmpty
                  ? Center(child: Text('Scanning for devices…', style: t.bodySmall))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: devices.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (ctx, i) => _DeviceChip(device: devices[i], index: i),
                    ),
            ),
            const SizedBox(height: 24),

            // ── Features ─────────────────────────────────────────
            Text('Features', style: t.titleLarge),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200, mainAxisSpacing: 12,
                crossAxisSpacing: 12, childAspectRatio: 1.1),
              itemCount: _features.length,
              itemBuilder: (ctx, i) {
                final f = _features[i];
                return GestureDetector(
                  onTap: () => context.go(f.path),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: f.color.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: f.color.withOpacity(0.22)),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      NxIconBox(icon: f.icon, color: f.color),
                      const Spacer(),
                      Text(f.label, style: t.titleMedium?.copyWith(color: f.color)),
                      const SizedBox(height: 2),
                      Text(f.subtitle, style: t.bodySmall, maxLines: 2),
                    ]),
                  ).animate(delay: (i * 55).ms).fadeIn(duration: 280.ms)
                      .scale(begin: const Offset(.95, .95), end: const Offset(1, 1)),
                );
              },
            ),
            const SizedBox(height: 24),

            // ── Quick actions ─────────────────────────────────────
            Text('Quick actions', style: t.titleLarge),
            const SizedBox(height: 12),
            ..._quickActions.map((qa) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: NxCard(
                accent: qa.color,
                onTap: () => context.go(qa.path),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(children: [
                  NxIconBox(icon: qa.icon, color: qa.color, size: 38),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(qa.label, style: t.titleMedium),
                    const SizedBox(height: 2),
                    Text(qa.subtitle, style: t.bodySmall),
                  ])),
                  Icon(Icons.chevron_right_rounded,
                      color: cs.onSurface.withOpacity(0.3), size: 20),
                ]),
              ),
            )),
            const SizedBox(height: 32),
          ])),
        ),
      ]),
    );
  }
}

class _DeviceChip extends StatelessWidget {
  final Device device;
  final int index;
  const _DeviceChip({required this.device, required this.index});

  @override
  Widget build(BuildContext context) {
    final isOnline = device.status == DeviceStatus.online;
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.go('/devices'),
      child: Container(
        width: 118, padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isOnline
              ? AppTheme.success.withOpacity(0.4)
              : cs.outline.withOpacity(0.5)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(device.icon, color: device.color.withOpacity(isOnline ? 1 : 0.4), size: 18),
            const Spacer(),
            Container(width: 7, height: 7,
              decoration: BoxDecoration(
                color: isOnline ? AppTheme.success : cs.outline,
                shape: BoxShape.circle),
            ),
          ]),
          const SizedBox(height: 8),
          Text(device.name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: t.labelLarge?.copyWith(
                  color: isOnline ? null : cs.onSurface.withOpacity(0.4))),
          Text(device.typeLabel, style: t.bodySmall),
        ]),
      ).animate(delay: (index * 70).ms).fadeIn(duration: 280.ms).slideX(begin: .15, end: 0),
    );
  }
}

class _F { final String label, subtitle, path; final IconData icon; final Color color;
  const _F(this.label, this.subtitle, this.path, this.icon, this.color); }

const _features = [
  _F('File transfer','Send to any device','/transfer',Icons.swap_horiz_rounded,AppTheme.transferColor),
  _F('App stream','Run apps remotely','/stream',Icons.cast_rounded,AppTheme.streamColor),
  _F('Mouse share','One mouse, all screens','/mouse',Icons.mouse_rounded,AppTheme.mouseColor),
  _F('Clipboard','Sync everywhere','/clipboard',Icons.content_paste_rounded,AppTheme.clipboardColor),
  _F('Notifications','Mirror phone alerts','/notifications',Icons.notifications_rounded,AppTheme.notifColor),
  _F('Cloud sync','10 GB free storage','/cloud',Icons.cloud_rounded,AppTheme.cloudColor),
];

class _QA { final String label, subtitle, path; final IconData icon; final Color color;
  const _QA(this.label, this.subtitle, this.path, this.icon, this.color); }

const _quickActions = [
  _QA('Send a file','Pick and send to a nearby device','/transfer',Icons.send_rounded,AppTheme.transferColor),
  _QA('Start streaming','Stream screen or app to another device','/stream',Icons.screen_share_rounded,AppTheme.streamColor),
  _QA('Upload to cloud','Sync files to free cloud storage','/cloud',Icons.cloud_upload_rounded,AppTheme.cloudColor),
];
