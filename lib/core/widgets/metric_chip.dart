import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class MetricChip extends StatelessWidget {
  const MetricChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text(value, style: TextStyle(color: colorScheme.onPrimaryContainer.withOpacity(.8))),
        ],
      ),
    );
  }
}
