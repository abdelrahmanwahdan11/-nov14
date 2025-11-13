import 'dart:ui';

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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface.withOpacity(theme.brightness == Brightness.dark ? .82 : .9),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: scheme.outline.withOpacity(.28)),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withOpacity(.08),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              _ArrowButton(
                enabled: index != 0,
                icon: Icons.chevron_left_rounded,
                onTap: onPrev,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(length, (i) {
                    final isActive = i == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: isActive ? 18 : 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: isActive
                            ? scheme.primary
                            : scheme.onSurface.withOpacity(theme.brightness == Brightness.dark ? .25 : .18),
                      ),
                    );
                  }),
                ),
              ),
              _ArrowButton(
                enabled: index != length - 1,
                icon: Icons.chevron_right_rounded,
                onTap: onNext,
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: scheme.primary,
                  textStyle: theme.textTheme.labelLarge,
                ),
                child: Text(MaterialLocalizations.of(context).skipButtonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.enabled,
    required this.icon,
    required this.onTap,
  });

  final bool enabled;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background = enabled
        ? scheme.primaryContainer.withOpacity(.45)
        : scheme.onSurface.withOpacity(.07);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              icon,
              color: enabled ? scheme.onPrimaryContainer : scheme.onSurface.withOpacity(.4),
            ),
          ),
        ),
      ),
    );
  }
}
