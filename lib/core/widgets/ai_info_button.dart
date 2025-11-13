import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../app/localization.dart';

class AiInfoButton extends StatelessWidget {
  const AiInfoButton({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return IconButton(
      tooltip: strings.t('aiInfo'),
      icon: const Icon(IconlyLight.info_circle),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.t('aiInfo'), style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  Text(strings.t('aiInfoComingSoon')),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(strings.t('confirm')),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
