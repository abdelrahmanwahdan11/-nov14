import 'package:flutter/material.dart';

class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.label, required this.strength});

  final String label;
  final String strength;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = {
      'weak': scheme.error,
      'medium': scheme.secondary,
      'strong': scheme.primary,
    };
    final fill = colors[strength] ?? Theme.of(context).colorScheme.surfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          height: 8,
          decoration: BoxDecoration(
            color: fill.withOpacity(.25),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: strength == 'strong'
                  ? 1
                  : strength == 'medium'
                      ? .66
                      : .33,
              child: Container(
                decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
