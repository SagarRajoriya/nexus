import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Consistent card used across all screens.
/// [accent] draws a left border stripe in that colour.
class NxCard extends StatelessWidget {
  final Widget child;
  final Color? accent;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool selected;

  const NxCard({
    super.key,
    required this.child,
    this.accent,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final surface = cs.surface;
    final border   = accent != null && selected
        ? accent!
        : accent != null
            ? accent!.withOpacity(0.25)
            : cs.outline;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected && accent != null
              ? accent!.withOpacity(0.08)
              : surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: selected ? 1.5 : 1),
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Coloured icon box, used consistently for feature icons.
class NxIconBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;

  const NxIconBox({super.key, required this.icon, required this.color, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Status pill badge
class NxBadge extends StatelessWidget {
  final String label;
  final Color color;

  const NxBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

/// Section header used in list screens
class NxSectionHeader extends StatelessWidget {
  final String title;
  final Color? color;
  const NxSectionHeader(this.title, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8, top: 4),
      child: Text(title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color ?? AppTheme.primary, fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
    );
  }
}

/// Info/how-it-works banner at top of feature screens
class NxInfoBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const NxInfoBanner({super.key, required this.icon, required this.color,
      required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
        ]),
        const SizedBox(height: 8),
        Text(body, style: Theme.of(context).textTheme.bodyMedium),
      ]),
    );
  }
}
