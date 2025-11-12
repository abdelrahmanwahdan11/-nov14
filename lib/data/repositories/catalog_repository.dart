import 'dart:math';

import '../models/catalog_item.dart';

class CatalogRepository {
  CatalogRepository();

  final Random _random = Random(42);

  List<CatalogItem> fetchPage(int page, int pageSize, {String? query, Map<String, dynamic>? filters}) {
    final start = page * pageSize;
    final items = List.generate(pageSize, (index) {
      final id = start + index;
      final level = _random.nextInt(3) + 1;
      final time = 20 + _random.nextInt(25);
      return CatalogItem(
        id: 'item-$id',
        name: 'Workout $id',
        imageUrl: _images[id % _images.length],
        tags: ['strength', if (id % 2 == 0) 'cardio', if (level > 2) 'advanced'],
        metrics: CatalogMetrics(kcal: 200 + _random.nextInt(200), level: level, timeMin: time),
        description: 'Dynamic session focusing on total body with intensity ${level}.',
      );
    });

    return items.where((item) {
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        final haystack = [
          item.name,
          item.description,
          ...item.tags,
          item.metrics.kcal.toString(),
          item.metrics.level.toString(),
          item.metrics.timeMin.toString(),
        ].join(' ').toLowerCase();
        if (!haystack.contains(q)) return false;
      }
      if (filters != null) {
        final levelFilter = filters['level'] as int?;
        if (levelFilter != null && item.metrics.level != levelFilter) return false;
        final tag = filters['tag'] as String?;
        if (tag != null && !item.tags.contains(tag)) return false;
      }
      return true;
    }).toList();
  }
}

const _images = [
  'https://images.unsplash.com/photo-1558611848-73f7eb4001a1',
  'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
  'https://images.unsplash.com/photo-1526403226-1d7b0aeaa2a1',
];
