import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/app_text.dart';
import '../../../core/widgets/chunky_button.dart';
import '../../../core/widgets/illustration_card.dart';
import '../../../core/widgets/progress_ring.dart';
import '../../habits/domain/habit.dart';

/// Countdown timer for a single habit. Pops `true` when marked done.
class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key, required this.habit});

  final Habit habit;

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  static const _options = [5, 10, 25];

  Timer? _timer;
  int _minutes = 10;
  late int _remaining = _minutes * 60;

  bool get _running => _timer != null;
  bool get _finished => _remaining == 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _pickDuration(int minutes) {
    _timer?.cancel();
    setState(() {
      _timer = null;
      _minutes = minutes;
      _remaining = minutes * 60;
    });
  }

  void _toggleTimer() {
    if (_finished) return;
    if (_running) {
      _timer!.cancel();
      setState(() => _timer = null);
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        HapticFeedback.mediumImpact();
        setState(() {
          _remaining = 0;
          _timer = null;
        });
      } else {
        setState(() => _remaining--);
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final total = _minutes * 60;
    final mm = (_remaining ~/ 60).toString().padLeft(2, '0');
    final ss = (_remaining % 60).toString().padLeft(2, '0');
    final status = _finished
        ? "Time's up!"
        : _running
            ? 'Stay with it'
            : 'Ready?';

    return Scaffold(
      backgroundColor: widget.habit.color,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 28),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  Expanded(
                    child: Text(
                      widget.habit.title,
                      textAlign: TextAlign.center,
                      style: AppText.heavy(20),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Text(widget.habit.goal, style: AppText.heavy(15, weight: FontWeight.w600)),
              const SizedBox(height: 12),
              IllustrationCard(
                illustration: _finished ? AppAssets.celebrate : AppAssets.meditate,
                maxSize: 104,
                shadow: 4,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: chunkDecoration(radius: 999, shadow: 6),
                      child: ProgressRing(
                        progress: 1 - _remaining / total,
                        stroke: 14,
                        // Scales the time down on short screens instead of
                        // wrapping or overflowing the ring.
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('$mm:$ss', style: AppText.heavy(46)),
                                Text(
                                  status,
                                  style: AppText.heavy(14, weight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final m in _options)
                    GestureDetector(
                      onTap: () => _pickDuration(m),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                        decoration: chunkDecoration(
                          color: m == _minutes ? AppColors.ink : Colors.white,
                          radius: 14,
                          shadow: 0,
                        ),
                        child: Text(
                          '$m min',
                          style: AppText.heavy(
                            14,
                            color: m == _minutes ? Colors.white : AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              if (!_finished) ...[
                ChunkyButton(
                  label: _running ? 'Pause' : 'Start',
                  icon: _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  onPressed: _toggleTimer,
                ),
                const SizedBox(height: 12),
              ],
              ChunkyButton(
                label: 'Mark as done',
                icon: Icons.check_rounded,
                color: _finished ? AppColors.tangerine : Colors.white,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
