class CatalogItem {
  CatalogItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.tags,
    required this.metrics,
    required this.description,
  });

  final String id;
  final String name;
  final String imageUrl;
  final List<String> tags;
  final CatalogMetrics metrics;
  final String description;
}

class CatalogMetrics {
  const CatalogMetrics({required this.kcal, required this.level, required this.timeMin});

  final int kcal;
  final int level;
  final int timeMin;
}
