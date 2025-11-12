import 'package:flutter/material.dart';

import '../../../app/localization.dart';

class CatalogFiltersSheet extends StatefulWidget {
  const CatalogFiltersSheet({super.key, required this.initial});

  final Map<String, dynamic> initial;

  @override
  State<CatalogFiltersSheet> createState() => _CatalogFiltersSheetState();
}

class _CatalogFiltersSheetState extends State<CatalogFiltersSheet> {
  int? _level;
  String? _tag;

  @override
  void initState() {
    super.initState();
    _level = widget.initial['level'] as int?;
    _tag = widget.initial['tag'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(strings.t('filters'), style: Theme.of(context).textTheme.titleLarge)),
              TextButton(onPressed: () => setState(() {
                _level = null;
                _tag = null;
              }), child: Text(strings.t('reset'))),
            ],
          ),
          const SizedBox(height: 12),
          Text('${strings.t('level')}'),
          Wrap(
            spacing: 8,
            children: [
              for (final level in [1, 2, 3])
                ChoiceChip(
                  label: Text(level.toString()),
                  selected: _level == level,
                  onSelected: (value) => setState(() => _level = value ? level : null),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Tags'),
          Wrap(
            spacing: 8,
            children: [
              for (final tag in ['strength', 'cardio', 'mobility'])
                ChoiceChip(
                  label: Text(tag),
                  selected: _tag == tag,
                  onSelected: (value) => setState(() => _tag = value ? tag : null),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop({'level': _level, 'tag': _tag}),
              child: Text(strings.t('apply')),
            ),
          )
        ],
      ),
    );
  }
}
