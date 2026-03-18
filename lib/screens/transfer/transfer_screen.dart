import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../models/device.dart';
import '../../services/devices_provider.dart';
import '../../services/transfer_service.dart';
import '../../widgets/nx_card.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});
  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  Device? _target;

  @override
  Widget build(BuildContext context) {
    final online    = ref.watch(onlineDevicesProvider);
    final transfers = ref.watch(transferProvider);
    final t  = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('File transfer')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        // ── Send card ──────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.transferColor.withOpacity(0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.transferColor.withOpacity(0.25)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.swap_horiz_rounded, color: AppTheme.transferColor, size: 20),
              const SizedBox(width: 8),
              Text('Send files', style: t.titleLarge?.copyWith(color: AppTheme.transferColor)),
            ]),
            const SizedBox(height: 14),
            Text('Send to', style: t.bodySmall),
            const SizedBox(height: 8),
            if (online.isEmpty)
              Text('No devices online — scan in Devices tab',
                  style: t.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.4)))
            else
              SizedBox(
                height: 60,
                child: ListView(scrollDirection: Axis.horizontal, children: online.map((d) {
                  final sel = _target?.id == d.id;
                  return GestureDetector(
                    onTap: () => setState(() => _target = sel ? null : d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.transferColor.withOpacity(0.18) : cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: sel ? AppTheme.transferColor : cs.outline,
                          width: sel ? 1.5 : 1,
                        ),
                      ),
                      child: Row(children: [
                        Icon(d.icon, color: d.color, size: 16),
                        const SizedBox(width: 8),
                        Text(d.name.split(' ').first, style: t.labelLarge),
                        if (sel) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.check_rounded, color: AppTheme.transferColor, size: 14),
                        ],
                      ]),
                    ),
                  );
                }).toList()),
              ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: FilledButton.icon(
                onPressed: _target == null ? null : _pickAndSend,
                icon: const Icon(Icons.folder_open_rounded, size: 18),
                label: const Text('Pick files'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.transferColor,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  disabledBackgroundColor: AppTheme.transferColor.withOpacity(0.3),
                ),
              )),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(
                onPressed: () => _showReceiveInfo(context),
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text('Receive'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  foregroundColor: AppTheme.transferColor,
                  side: BorderSide(color: AppTheme.transferColor.withOpacity(0.4)),
                ),
              )),
            ]),
          ]),
        ),
        const SizedBox(height: 24),

        // ── Transfer history ───────────────────────────────────
        if (transfers.isNotEmpty) ...[
          Text('Transfers', style: t.titleLarge),
          const SizedBox(height: 12),
          ...transfers.asMap().entries.map((e) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _TransferTile(item: e.value, index: e.key,
                    onRemove: () => ref.read(transferProvider.notifier).removeTransfer(e.value.id)),
              )),
          const SizedBox(height: 16),
        ],

        // ── Info banner ────────────────────────────────────────
        NxCard(
          accent: AppTheme.warning,
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Icon(Icons.info_outline_rounded, color: AppTheme.warning, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(
              'Install nexus-daemon on Windows/Linux to enable receiving. '
              'See Settings → Desktop daemon.',
              style: t.bodySmall?.copyWith(color: AppTheme.warning),
            )),
          ]),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Future<void> _pickAndSend() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null || result.files.isEmpty) return;
    for (final pf in result.files) {
      if (pf.path == null) continue;
      await ref.read(transferProvider.notifier).sendFile(File(pf.path!), _target!);
    }
  }

  void _showReceiveInfo(BuildContext context) {
    showModalBottomSheet(context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Receiving files', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text('This device is listening on port 5050. Other Nexus devices or the desktop daemon can send files directly to you.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _TransferTile extends StatelessWidget {
  final TransferItem item;
  final int index;
  final VoidCallback onRemove;
  const _TransferTile({required this.item, required this.index, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final t  = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final isActive = item.status == TransferStatus.active;
    final isDone   = item.status == TransferStatus.done;
    final isError  = item.status == TransferStatus.error;

    final statusColor = isError ? AppTheme.danger
        : isDone  ? AppTheme.success
        : AppTheme.transferColor;
    final statusLabel = isError ? 'Error' : isDone ? 'Done' : 'Sending';

    return NxCard(
      accent: statusColor,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(item.direction == TransferDirection.incoming
              ? Icons.download_rounded : Icons.upload_rounded,
              size: 15, color: statusColor),
          const SizedBox(width: 8),
          Expanded(child: Text(item.fileName, style: t.titleMedium,
              maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
            child: Text(statusLabel,
                style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 6),
          if (!isActive)
            GestureDetector(onTap: onRemove,
              child: Icon(Icons.close_rounded, size: 16, color: cs.onSurface.withOpacity(0.3))),
        ]),
        const SizedBox(height: 6),
        Text('${item.deviceName} · ${item.sizeLabel}', style: t.bodySmall),
        if (isActive) ...[
          const SizedBox(height: 10),
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: item.progress,
              backgroundColor: AppTheme.transferColor.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation(AppTheme.transferColor),
              minHeight: 5,
            )),
          const SizedBox(height: 4),
          Text('${(item.progress * 100).toStringAsFixed(0)}% · '
              '${(item.sentBytes / 1024 / 1024).toStringAsFixed(1)} / ${item.sizeLabel}',
              style: t.bodySmall),
        ],
        if (isError && item.error != null) ...[
          const SizedBox(height: 6),
          Text(item.error!, style: t.bodySmall?.copyWith(color: AppTheme.danger),
              maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ]),
    ).animate(delay: (index * 60).ms).fadeIn(duration: 250.ms);
  }
}
