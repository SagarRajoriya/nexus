import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/device.dart';
import '../../services/devices_provider.dart';
import '../../services/discovery_service.dart';
import '../../widgets/nx_card.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});
  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  bool _scanning = false;

  Future<void> _scan() async {
    setState(() => _scanning = true);
    await ref.read(discoveryServiceProvider).scanNow();
    if (mounted) setState(() => _scanning = false);
  }

  @override
  Widget build(BuildContext context) {
    final devices = ref.watch(devicesProvider);
    final online  = devices.where((d) => d.status == DeviceStatus.online).toList();
    final offline = devices.where((d) => d.status != DeviceStatus.online).toList();
    final t  = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Devices'),
        actions: [
          _scanning
            ? const Padding(padding: EdgeInsets.all(14),
                child: SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)))
            : IconButton(
                icon: const Icon(Icons.radar_rounded),
                tooltip: 'Scan LAN',
                onPressed: _scan),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // Network status card
        NxCard(
          accent: AppTheme.success,
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            const NxIconBox(icon: Icons.wifi_rounded, color: AppTheme.success, size: 44),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Local network', style: t.titleMedium),
              Text('LAN — all features work without internet', style: t.bodySmall),
            ])),
            Container(width: 9, height: 9,
                decoration: const BoxDecoration(color: AppTheme.success, shape: BoxShape.circle)),
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
          NxSectionHeader('Offline (${offline.length})', color: cs.onSurface.withOpacity(0.4)),
          ...offline.asMap().entries.map((e) =>
              Padding(padding: const EdgeInsets.only(bottom: 10),
                  child: _DeviceCard(device: e.value, index: e.key, dimmed: true))),
          const SizedBox(height: 8),
        ],

        OutlinedButton.icon(
          onPressed: () => _showManualAdd(context),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add device manually'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }

  void _showManualAdd(BuildContext context) {
    final ipCtrl   = TextEditingController();
    final nameCtrl = TextEditingController();
    showModalBottomSheet(context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Add device manually', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          TextField(controller: ipCtrl,
              decoration: const InputDecoration(labelText: 'IP address', hintText: '192.168.1.xxx')),
          const SizedBox(height: 12),
          TextField(controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name (optional)')),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () {
              if (ipCtrl.text.isNotEmpty) {
                ref.read(devicesProvider.notifier).addOrUpdate(Device(
                  id: ipCtrl.text, name: nameCtrl.text.isEmpty ? ipCtrl.text : nameCtrl.text,
                  type: DeviceType.unknown, ip: ipCtrl.text, status: DeviceStatus.connecting,
                ));
              }
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
            child: const Text('Connect'),
          ),
        ]),
      ),
    );
  }
}

class _DeviceCard extends ConsumerWidget {
  final Device device;
  final int index;
  final bool dimmed;
  const _DeviceCard({required this.device, required this.index, this.dimmed = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            Text('${device.typeLabel} · ${device.ip}', style: t.bodySmall),
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
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _CapChip extends StatelessWidget {
  final String label;
  final Color color;
  const _CapChip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
    child: Text(label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
  );
}
