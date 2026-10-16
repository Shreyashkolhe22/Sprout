import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';

/// Profile bottom sheet: who is signed in, a few totals and Log out.
class ProfileSheet extends StatelessWidget {
  const ProfileSheet({
    super.key,
    required this.userName,
    required this.habitCount,
    required this.dayStreak,
    required this.bestStreak,
    required this.onLogout,
  });

  final String userName;
  final int habitCount;
  final int dayStreak;
  final int bestStreak;
  final VoidCallback onLogout;

  static Future<void> show(
    BuildContext context, {
    required String userName,
    required int habitCount,
    required int dayStreak,
    required int bestStreak,
    required VoidCallback onLogout,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: AppColors.ink, width: 2.5),
      ),
      builder: (_) => ProfileSheet(
        userName: userName,
        habitCount: habitCount,
        dayStreak: dayStreak,
        bestStreak: bestStreak,
        onLogout: onLogout,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: chunkDecoration(radius: 24, shadow: 4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: Image.asset(AppAssets.logo, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 14),
            Text(userName, style: AppText.heavy(26), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              'Signed in on this device',
              style: AppText.heavy(14, weight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    value: '$habitCount',
                    label: habitCount == 1 ? 'habit' : 'habits',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _Stat(value: '$dayStreak', label: 'day streak')),
                const SizedBox(width: 10),
                Expanded(child: _Stat(value: '$bestStreak', label: 'best streak')),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Your habits stay saved on this device. Log back in with the '
              'same name to get them back.',
              textAlign: TextAlign.center,
              style: AppText.heavy(13, weight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            ChunkyButton(
              label: 'Log out',
              icon: Icons.logout_rounded,
              color: AppColors.coral,
              onPressed: () {
                Navigator.of(context).pop();
                onLogout();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: chunkDecoration(color: Colors.white, radius: 16, shadow: 3),
      child: Column(
        children: [
          Text(value, style: AppText.heavy(24)),
          const SizedBox(height: 2),
          Text(label, style: AppText.heavy(11, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}
