import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_decorations.dart';
import '../../../../core/theme/app_text.dart';

/// Bottom bar: Today, Notes, a context-aware + button, Stats and Profile.
class SproutBottomNav extends StatelessWidget {
  const SproutBottomNav({
    super.key,
    required this.currentIndex,
    required this.onSelected,
    required this.onAdd,
    required this.onProfile,
    this.addLabel = 'Add',
  });

  /// 0 = Today, 1 = Notes, 2 = Stats.
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;
  final VoidCallback onProfile;

  /// Accessibility label for the + button ("Add habit" / "Add note").
  final String addLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.ink, width: 2.5)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.today_rounded,
                label: 'Today',
                selected: currentIndex == 0,
                onTap: () => onSelected(0),
              ),
              _NavItem(
                icon: Icons.sticky_note_2_rounded,
                label: 'Notes',
                selected: currentIndex == 1,
                onTap: () => onSelected(1),
              ),
              Semantics(
                button: true,
                label: addLabel,
                child: GestureDetector(
                  key: const Key('nav-add'),
                  onTap: onAdd,
                  child: Container(
                    width: 58,
                    height: 52,
                    decoration: chunkDecoration(
                      color: AppColors.tangerine,
                      radius: 16,
                      shadow: 3,
                    ),
                    child: const Icon(Icons.add, size: 30),
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.bar_chart_rounded,
                label: 'Stats',
                selected: currentIndex == 2,
                onTap: () => onSelected(2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                selected: false,
                onTap: onProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.ink : AppColors.ink.withValues(alpha: 0.45);
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(height: 2),
            Text(label, style: AppText.heavy(11, color: color)),
          ],
        ),
      ),
    );
  }
}
