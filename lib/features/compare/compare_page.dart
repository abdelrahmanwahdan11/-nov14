import 'package:flutter/material.dart';

import '../../app/localization.dart';
import '../../data/models/catalog_item.dart';

class ComparePage extends StatelessWidget {
  const ComparePage({super.key, this.items = const []});

  static const route = '/compare';
  final List<CatalogItem> items;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.t('compare'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: items.isEmpty
            ? Center(child: Text(strings.t('emptyResults')))
            : Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        const DataColumn(label: Text('Metric')),
                        for (final item in items) DataColumn(label: Text(item.name)),
                      ],
                      rows: [
                        DataRow(cells: [
                          const DataCell(Text('kcal')),
                          for (final item in items) DataCell(Text(item.metrics.kcal.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(strings.t('minutes'))),
                          for (final item in items) DataCell(Text(item.metrics.timeMin.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(strings.t('level'))),
                          for (final item in items) DataCell(Text(item.metrics.level.toString())),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Muscles')),
                          for (final item in items) DataCell(Text(item.tags.join(', '))),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: () {}, child: Text(strings.t('startWorkout'))),
                ],
              ),
      ),
    );
  }
}
