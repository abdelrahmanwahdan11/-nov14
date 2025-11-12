import 'package:flutter/material.dart';

class PinnedControllerBar extends StatelessWidget {
  const PinnedControllerBar({
    super.key,
    required this.onNext,
    required this.onPrev,
    required this.onSkip,
    required this.length,
    required this.index,
  });

  final VoidCallback onNext;
  final VoidCallback onPrev;
  final VoidCallback onSkip;
  final int length;
  final int index;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(.95),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  onPressed: index == 0 ? null : onPrev,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(length, (i) {
                      final isActive = i == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 16 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                ),
                IconButton(
                  onPressed: index == length - 1 ? null : onNext,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
                TextButton(onPressed: onSkip, child: Text(MaterialLocalizations.of(context).skipButtonLabel)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
