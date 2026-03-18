import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/nx_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoDiscover = true;
  bool _keepAlive    = true;
  String _deviceName = 'My Device';

  @override
  Widget build(BuildContext context) {
    final t  = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsSection('This device', [
            _SettingRow(
              icon: Icons.badge_rounded, color: AppTheme.primary,
              title: 'Device name', subtitle: _deviceName,
              trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurface.withOpacity(0.3), size: 18),
              onTap: () => _editName(context),
            ),
            _SettingRow(
              icon: Icons.wifi_tethering_rounded, color: AppTheme.primary,
              title: 'Auto-discover on LAN', subtitle: 'Find devices automatically',
              trailing: Switch(value: _autoDiscover, activeColor: AppTheme.primary,
                  onChanged: (v) => setState(() => _autoDiscover = v)),
            ),
            _SettingRow(
              icon: Icons.battery_charging_full_rounded, color: AppTheme.primary,
              title: 'Stay connected in background', subtitle: 'Keeps sync active',
              trailing: Switch(value: _keepAlive, activeColor: AppTheme.primary,
                  onChanged: (v) => setState(() => _keepAlive = v)),
            ),
          ]),
          const SizedBox(height: 20),
          _SettingsSection('Desktop daemon', [
            _SettingRow(
              icon: Icons.laptop_windows_rounded, color: AppTheme.transferColor,
              title: 'Windows setup guide', subtitle: 'Install nexus-daemon on Windows',
              trailing: const Icon(Icons.open_in_new_rounded, size: 16),
              onTap: () {},
            ),
            _SettingRow(
              icon: Icons.computer_rounded, color: AppTheme.transferColor,
              title: 'Linux setup guide', subtitle: 'Install nexus-daemon on Linux',
              trailing: const Icon(Icons.open_in_new_rounded, size: 16),
              onTap: () {},
            ),
            _SettingRow(
              icon: Icons.code_rounded, color: AppTheme.transferColor,
              title: 'GitHub — nexus-daemon', subtitle: 'View source & releases',
              trailing: const Icon(Icons.open_in_new_rounded, size: 16),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 20),
          _SettingsSection('Security', [
            _SettingRow(
              icon: Icons.lock_rounded, color: AppTheme.warning,
              title: 'Require PIN to accept files', subtitle: 'Confirm before receiving',
              trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurface.withOpacity(0.3), size: 18),
              onTap: () {},
            ),
            _SettingRow(
              icon: Icons.vpn_key_rounded, color: AppTheme.warning,
              title: 'Trusted devices', subtitle: 'Manage always-allowed devices',
              trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurface.withOpacity(0.3), size: 18),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 20),
          _SettingsSection('About', [
            _SettingRow(
              icon: Icons.info_rounded, color: cs.onSurface.withOpacity(0.4),
              title: 'Nexus v1.0.0', subtitle: 'Built with Flutter',
              trailing: const SizedBox.shrink(),
            ),
            _SettingRow(
              icon: Icons.description_rounded, color: cs.onSurface.withOpacity(0.4),
              title: 'Open source licenses', subtitle: '',
              trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurface.withOpacity(0.3), size: 18),
              onTap: () => showLicensePage(context: context),
            ),
          ]),
          const SizedBox(height: 40),
          Text('Made with Flutter · LAN only · No tracking · Open source',
              textAlign: TextAlign.center, style: t.bodySmall),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _editName(BuildContext context) {
    final ctrl = TextEditingController(text: _deviceName);
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Device name'),
      content: TextField(controller: ctrl, autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter name')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: () {
          setState(() => _deviceName = ctrl.text.trim().isEmpty ? _deviceName : ctrl.text.trim());
          Navigator.pop(context);
        }, child: const Text('Save')),
      ],
    ));
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingRow> rows;
  const _SettingsSection(this.title, this.rows);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      NxSectionHeader(title),
      NxCard(
        padding: EdgeInsets.zero,
        child: Column(children: [
          for (int i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(height: 1, indent: 56,
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
          ],
        ]),
      ),
    ]);
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingRow({required this.icon, required this.color,
      required this.title, required this.subtitle,
      required this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t  = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            if (subtitle.isNotEmpty)
              Text(subtitle, style: t.bodySmall),
          ])),
          trailing,
        ]),
      ),
    );
  }
}
