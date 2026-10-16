import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../domain/habit.dart';
import '../domain/habit_icons.dart';

/// Bottom sheet that returns a new [Habit], or null if dismissed.
class NewHabitSheet extends StatefulWidget {
  const NewHabitSheet({super.key, required this.today});

  /// Becomes the habit's first day.
  final DateTime today;

  static Future<Habit?> show(BuildContext context, {required DateTime today}) {
    return showModalBottomSheet<Habit>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: AppColors.ink, width: 2.5),
      ),
      builder: (_) => NewHabitSheet(today: today),
    );
  }

  @override
  State<NewHabitSheet> createState() => _NewHabitSheetState();
}

class _NewHabitSheetState extends State<NewHabitSheet> {
  final _title = TextEditingController();
  final _goal = TextEditingController();
  int _color = 0;
  int _icon = 0;
  bool _showError = false;

  @override
  void dispose() {
    _title.dispose();
    _goal.dispose();
    super.dispose();
  }

  void _create() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    final goal = _goal.text.trim();
    Navigator.of(context).pop(
      Habit.create(
        title: title,
        goal: goal.isEmpty ? 'Every day' : goal,
        iconIndex: _icon,
        color: AppColors.swatches[_color],
        today: widget.today,
      ),
    );
  }

  InputDecoration _field(String hint, {String? error}) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: 2.5),
        );
    return InputDecoration(
      hintText: hint,
      errorText: error,
      counterText: '',
      filled: true,
      fillColor: Colors.white,
      enabledBorder: border(AppColors.ink),
      focusedBorder: border(AppColors.tangerine),
      errorBorder: border(AppColors.coral),
      focusedErrorBorder: border(AppColors.coral),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plant a new habit', style: AppText.heavy(26)),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              autofocus: true,
              maxLength: 32,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_showError) setState(() => _showError = false);
              },
              decoration: _field(
                'Name, e.g. Meditate',
                error: _showError ? 'Give your habit a name' : null,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _goal,
              maxLength: 40,
              textCapitalization: TextCapitalization.sentences,
              decoration: _field('Goal, e.g. 10 minutes'),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < AppColors.swatches.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _color = i),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.swatches[i],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.ink,
                          width: i == _color ? 4 : 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < HabitIcons.all.length; i++)
                  GestureDetector(
                    onTap: () => setState(() => _icon = i),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: chunkDecoration(
                        color: i == _icon ? AppColors.ink : Colors.white,
                        radius: 14,
                        shadow: 0,
                      ),
                      child: Icon(
                        HabitIcons.all[i],
                        color: i == _icon ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            ChunkyButton(label: 'Create', onPressed: _create),
          ],
        ),
      ),
    );
  }
}
