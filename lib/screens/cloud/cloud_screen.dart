import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/nx_card.dart';

class CloudScreen extends StatefulWidget {
  const CloudScreen({super.key});
  @override
  State<CloudScreen> createState() => _CloudScreenState();
}

class _CloudScreenState extends State<CloudScreen> {
  bool _configured = false;
  final double _usedGB = 2.3, _totalGB = 10.0;
  final _endCtrl = TextEditingController();
  final _bucketCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();
  bool _loading = false;
  final Map<String, bool> _syncFolders = {'Documents': true, 'Downloads': false, 'Desktop': true, 'Pictures': false};

  @override
  Widget build(BuildContext context) {
    final t  = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cloud sync')),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // ── Storage header ────────────────────────────────────
        NxCard(accent: AppTheme.cloudColor,
          selected: _configured,
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const NxIconBox(icon: Icons.cloud_rounded, color: AppTheme.cloudColor, size: 40),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Cloudflare R2', style: t.titleLarge),
                Text('10 GB free forever', style: t.bodySmall?.copyWith(color: AppTheme.cloudColor)),
              ])),
              if (_configured)
                const NxBadge(label: 'Connected', color: AppTheme.success),
            ]),
            if (_configured) ...[
              const SizedBox(height: 16),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${_usedGB.toStringAsFixed(1)} GB', style: t.headlineLarge),
                Text(' / ${_totalGB.toStringAsFixed(0)} GB',
                    style: t.bodyMedium?.copyWith(color: cs.onSurface.withOpacity(0.5))),
              ]),
              const SizedBox(height: 10),
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _usedGB / _totalGB,
                  backgroundColor: AppTheme.cloudColor.withOpacity(0.12),
                  valueColor: const AlwaysStoppedAnimation(AppTheme.cloudColor),
                  minHeight: 6,
                )),
              const SizedBox(height: 6),
              Text('${(_totalGB - _usedGB).toStringAsFixed(1)} GB remaining',
                  style: t.bodySmall),
            ],
          ]),
        ),
        const SizedBox(height: 20),

        if (!_configured) ...[
          NxSectionHeader('Connect Cloudflare R2'),
          NxCard(padding: const EdgeInsets.all(18), child: Column(children: [
            Text('Create a free account at dash.cloudflare.com → R2 → Create bucket',
                style: t.bodySmall),
            const SizedBox(height: 16),
            TextField(controller: _endCtrl,
                decoration: const InputDecoration(labelText: 'R2 endpoint URL',
                    hintText: 'https://<account>.r2.cloudflarestorage.com')),
            const SizedBox(height: 10),
            TextField(controller: _bucketCtrl,
                decoration: const InputDecoration(labelText: 'Bucket name')),
            const SizedBox(height: 10),
            TextField(controller: _keyCtrl,
                decoration: const InputDecoration(labelText: 'Access key ID')),
            const SizedBox(height: 10),
            TextField(controller: _secretCtrl, obscureText: true,
                decoration: const InputDecoration(labelText: 'Secret access key')),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _loading ? null : _connect,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.cloudColor,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _loading
                  ? const SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Connect'),
            ),
          ])),
        ] else ...[

          // ── Files ─────────────────────────────────────────────
          NxSectionHeader('Files'),
          NxCard(padding: EdgeInsets.zero, child: Column(children: [
            for (final (name, icon, size, color) in [
              ('project_docs/', Icons.folder_rounded,          '1.2 GB', AppTheme.cloudColor),
              ('photos_backup/',Icons.folder_rounded,          '890 MB', AppTheme.cloudColor),
              ('report_final.pdf',Icons.picture_as_pdf_rounded,'2.4 MB', AppTheme.danger),
              ('app_build.apk', Icons.android_rounded,         '48 MB',  AppTheme.success),
            ])
              ListTile(
                leading: NxIconBox(icon: icon, color: color, size: 36),
                title: Text(name, style: t.titleMedium),
                subtitle: Text(size, style: t.bodySmall),
                trailing: Icon(Icons.more_vert_rounded,
                    color: cs.onSurface.withOpacity(0.3), size: 18),
              ),
          ])),
          const SizedBox(height: 20),

          // ── Auto-sync folders ──────────────────────────────────
          NxSectionHeader('Auto-sync folders'),
          NxCard(padding: EdgeInsets.zero, child: Column(
            children: _syncFolders.entries.map((e) => SwitchListTile(
              title: Text(e.key, style: t.bodyMedium),
              value: e.value,
              onChanged: (v) => setState(() => _syncFolders[e.key] = v),
              activeColor: AppTheme.cloudColor,
            )).toList(),
          )),
        ],

        const SizedBox(height: 20),
        NxSectionHeader('Free providers supported'),
        NxCard(padding: EdgeInsets.zero, child: Column(children: [
          for (final (name, cap, color) in [
            ('Cloudflare R2', '10 GB free', AppTheme.cloudColor),
            ('Backblaze B2',  '10 GB free', const Color(0xFFE84C22)),
            ('MEGA',          '20 GB free', const Color(0xFFD9272E)),
          ])
            ListTile(
              leading: NxIconBox(icon: Icons.cloud_rounded, color: color, size: 34),
              title: Text(name, style: t.titleMedium),
              trailing: Text(cap, style: t.bodySmall?.copyWith(color: color)),
            ),
        ])),
        const SizedBox(height: 32),
      ]),
    );
  }

  Future<void> _connect() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    // TODO: validate against real R2 using minio package
    if (mounted) setState(() { _loading = false; _configured = true; });
  }
}
