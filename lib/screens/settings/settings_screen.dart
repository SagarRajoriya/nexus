import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/nx_card.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _autoDiscover = true;
  bool _keepAlive    = true;
  String _deviceName = 'My Device';

  @override
  Widget build(BuildContext context) {
    final t  = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.all(16), children: [

        // Account card
        if (user != null)
          NxCard(
            accent: AppTheme.primary, selected: true,
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: AppTheme.primary, borderRadius: BorderRadius.circular(23)),
                child: Center(child: Text(
                  (user.displayName ?? user.email ?? '?')[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 20,
                      fontWeight: FontWeight.w700),
                )),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.displayName ?? 'Nexus user', style: t.titleMedium),
                Text(user.email ?? '', style: t.bodySmall),
              ])),
            ]),
          ),
        const SizedBox(height: 16),

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
            title: 'Windows setup', subtitle: 'Install nexus-daemon on Windows',
            trailing: const Icon(Icons.open_in_new_rounded, size: 16),
            onTap: () {},
          ),
          _SettingRow(
            icon: Icons.computer_rounded, color: AppTheme.transferColor,
            title: 'Linux setup', subtitle: 'Install nexus-daemon on Linux',
            trailing: const Icon(Icons.open_in_new_rounded, size: 16),
            onTap: () {},
          ),
        ]),
        const SizedBox(height: 20),

        _SettingsSection('Account', [
          _SettingRow(
            icon: Icons.manage_accounts_rounded, color: AppTheme.primary,
            title: 'Account details', subtitle: user?.email ?? '',
            trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurface.withOpacity(0.3), size: 18),
            onTap: () {},
          ),
          _SettingRow(
            icon: Icons.logout_rounded, color: AppTheme.danger,
            title: 'Sign out', subtitle: 'Removes this device from your account',
            trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurface.withOpacity(0.3), size: 18),
            onTap: () => _signOut(context),
          ),
        ]),
        const SizedBox(height: 20),

        _SettingsSection('About', [
          _SettingRow(
            icon: Icons.info_rounded, color: cs.onSurface.withOpacity(0.4),
            title: 'Nexus v1.0.0', subtitle: 'Built with Flutter + Firebase',
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
        Text('Made with Flutter · LAN-first · Firebase for identity only',
            textAlign: TextAlign.center, style: t.bodySmall),
        const SizedBox(height: 24),
      ]),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('This device will go offline in your account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(authServiceProvider).signOut();
      if (mounted) context.go('/login');
    }
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
      NxCard(padding: EdgeInsets.zero, child: Column(children: [
        for (int i = 0; i < rows.length; i++) ...[
          rows[i],
          if (i < rows.length - 1)
            Divider(height: 1, indent: 56,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
        ],
      ])),
    ]);
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon; final Color color;
  final String title, subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  const _SettingRow({required this.icon, required this.color,
      required this.title, required this.subtitle,
      required this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
            if (subtitle.isNotEmpty) Text(subtitle, style: t.bodySmall),
          ])),
          trailing,
        ]),
      ),
    );
  }
}
