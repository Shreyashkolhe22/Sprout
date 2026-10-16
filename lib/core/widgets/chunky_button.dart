import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../theme/app_text.dart';

/// Full-width button with a hard shadow that "presses" into the page on tap.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.tangerine,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final Color color;
  final IconData? icon;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 70),
        width: double.infinity,
        height: 58,
        transform: Matrix4.translationValues(_down ? 4 : 0, _down ? 4 : 0, 0),
        decoration: chunkDecoration(
          color: widget.color,
          radius: 18,
          shadow: _down ? 0 : 4,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: AppColors.ink),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.heavy(17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
