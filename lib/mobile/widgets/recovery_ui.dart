import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import '../../theme/app_theme.dart';
import '../../widgets/animations.dart';

/// Shared building blocks for the Pro "Recovery" tools (Response Prevention,
/// Urge Surfing, and later trackers). Extracted here so each tool screen
/// doesn't re-declare them.

BoxDecoration recoverySoftDecoration(ThemeData theme, {double radius = 22}) {
  return BoxDecoration(
    color: theme.colorScheme.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: theme.dividerColor),
  );
}

class CircleBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const CircleBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PressScale(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: recoverySoftDecoration(theme, radius: 14),
        child: const Icon(LineIcons.angleLeft, size: 20),
      ),
    );
  }
}

class LabeledField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final int minLines;

  const LabeledField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.minLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: minLines + 2,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

/// A 0–[max] slider with a label and a live "n/max" readout.
class RatingSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final int max;

  const RatingSlider({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.max = 10,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ),
            Text(
              '${value.round()}/$max',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: max.toDouble(),
          divisions: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
