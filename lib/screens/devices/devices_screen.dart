import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/device.dart';
import '../../services/auth_service.dart';
import '../../widgets/nx_card.dart';

class DevicesScreen extends ConsumerWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final devicesAsync = ref.watch(devicesStreamProvider);
    final t  = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Devices')),
      body: devicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: t.bodyMedium)),
        data: (devices) {
          final online  = devices.where((d) => d.status == DeviceStatus.online).toList();
          final offline = devices.where((d) => d.status != DeviceStatus.online).toList();

          return ListView(padding: const EdgeInsets.all(16), children: [
            // Account banner
            NxCard(
              accent: AppTheme.primary,
              selected: true,
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primary, borderRadius: BorderRadius.circular(22)),
                  child: const Icon(Icons.hub_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Your Nexus account', style: t.titleMedium),
                  Text('${devices.length} device${devices.length == 1 ? '' : 's'} registered · '
                      '${online.length} online now', style: t.bodySmall),
                ])),
              ]),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.accent.withOpacity(0.25)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded, color: AppTheme.accent, size: 16),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  'Install Nexus on any device and sign in with the same account — it appears here automatically.',
                  style: t.bodySmall?.copyWith(color: AppTheme.accent),
                )),
              ]),
            ),
            const SizedBox(height: 20),

            if (online.isNotEmpty) ...[
              NxSectionHeader('Online (${online.length})', color: AppTheme.success),
              ...online.asMap().entries.map((e) =>
                  Padding(padding: const EdgeInsets.only(bottom: 10),
                      child: _DeviceCard(device: e.value, index: e.key))),
              const SizedBox(height: 8),
            ],

            if (offline.isNotEmpty) ...[
              NxSectionHeader('Offline (${offline.length})',
                  color: cs.onSurface.withOpacity(0.4)),
              ...offline.asMap().entries.map((e) =>
                  Padding(padding: const EdgeInsets.only(bottom: 10),
                      child: _DeviceCard(device: e.value, index: e.key, dimmed: true))),
            ],

            if (devices.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(children: [
                  Icon(Icons.devices_rounded, size: 48,
                      color: cs.onSurface.withOpacity(0.15)),
                  const SizedBox(height: 16),
                  Text('No devices yet', style: t.titleMedium?.copyWith(
                      color: cs.onSurface.withOpacity(0.4))),
                  const SizedBox(height: 8),
                  Text('Install Nexus on your other devices\nand sign in with this account',
                      style: t.bodySmall, textAlign: TextAlign.center),
                ]),
              )),
            const SizedBox(height: 24),
          ]);
        },
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final Device device;
  final int index;
  final bool dimmed;
  const _DeviceCard({required this.device, required this.index, this.dimmed = false});

  @override
  Widget build(BuildContext context) {
    final isOnline = device.status == DeviceStatus.online;
    final t  = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return NxCard(
      accent: isOnline ? device.color : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: device.color.withOpacity(dimmed ? 0.06 : 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(device.icon,
                color: device.color.withOpacity(dimmed ? 0.35 : 1), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(device.name,
                style: t.titleMedium?.copyWith(
                    color: dimmed ? cs.onSurface.withOpacity(0.4) : null)),
            Text('${device.typeLabel}${device.ip.isNotEmpty ? ' · ${device.ip}' : ''}',
                style: t.bodySmall),
          ])),
          _StatusBadge(device.status),
        ]),
        if (isOnline) ...[
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Wrap(spacing: 6, children: [
            if (device.capabilities['transfer'] == true)  _CapChip('Transfer',  AppTheme.transferColor),
            if (device.capabilities['stream'] == true)    _CapChip('Stream',    AppTheme.streamColor),
            if (device.capabilities['mouse'] == true)     _CapChip('Mouse',     AppTheme.mouseColor),
            if (device.capabilities['clipboard'] == true) _CapChip('Clipboard', AppTheme.clipboardColor),
          ]),
        ],
      ]),
    ).animate(delay: (index * 55).ms).fadeIn(duration: 270.ms).slideY(begin: .08, end: 0);
  }
}

class _StatusBadge extends StatelessWidget {
  final DeviceStatus status;
  const _StatusBadge(this.status);
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      DeviceStatus.online     => ('Online',     AppTheme.success),
      DeviceStatus.connecting => ('Connecting', AppTheme.warning),
      DeviceStatus.offline    => ('Offline',    Theme.of(context).colorScheme.outline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _CapChip extends StatelessWidget {
  final String label; final Color color;
  const _CapChip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6)),
    child: Text(label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
  );
}
