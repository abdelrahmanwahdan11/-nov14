import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../app/localization.dart';
import '../../core/utils/debouncer.dart';
import '../../core/widgets/skeleton_box.dart';
import '../../data/models/catalog_item.dart';
import '../catalog/catalog_detail_page.dart';
import '../shared/app_state.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  static const route = '/search';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Debouncer _debouncer = Debouncer();
  final ValueNotifier<List<CatalogItem>> _results = ValueNotifier<List<CatalogItem>>(<CatalogItem>[]);
  final ValueNotifier<bool> _loading = ValueNotifier<bool>(false);
  final ValueNotifier<List<String>> _history = ValueNotifier<List<String>>(<String>[]);

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _debouncer.dispose();
    _results.dispose();
    _loading.dispose();
    _history.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      _results.value = const [];
      return;
    }
    _loading.value = true;
    final state = AppStateScope.of(context);
    await Future<void>.delayed(const Duration(milliseconds: 160));
    final results = <CatalogItem>[];
    for (var page = 0; page < 3; page++) {
      results.addAll(state.catalogController.repository.fetchPage(page, 20, query: query));
    }
    _results.value = results;
    _loading.value = false;
    final currentHistory = _history.value;
    if (!currentHistory.contains(query)) {
      _history.value = [query, ...currentHistory].take(6).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final trending = [
      strings.t('mobility'),
      strings.t('cardio'),
      strings.t('focusRecovery'),
      strings.t('strength'),
      strings.t('hiit'),
      strings.t('yoga'),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Hero(
          tag: 'global-search-field',
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: strings.t('searchHint'),
                filled: true,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _controller.clear();
                    _results.value = const [];
                    setState(() {});
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {});
                _debouncer(() => _performSearch(value));
              },
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder<List<CatalogItem>>(
        valueListenable: _results,
        builder: (context, results, _) {
          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 220),
                        opacity: _controller.text.isEmpty ? 1 : 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(strings.t('discover'), style: theme.textTheme.headlineSmall),
                            const SizedBox(height: 8),
                            Text(
                              strings.t('discoverSubtitle'),
                              style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                for (final term in trending)
                                  ActionChip(
                                    label: Text(term),
                                    onPressed: () {
                                      _controller.text = term;
                                      _performSearch(term);
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      ValueListenableBuilder<List<String>>(
                        valueListenable: _history,
                        builder: (context, history, child) {
                          if (history.isEmpty) return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(strings.t('recentSearches'), style: theme.textTheme.titleMedium),
                                  TextButton(
                                    onPressed: () => _history.value = const [],
                                    child: Text(strings.t('clear')),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                children: [
                                  for (final item in history)
                                    InputChip(
                                      label: Text(item),
                                      onDeleted: () {
                                        _history.value = List<String>.from(history)..remove(item);
                                      },
                                      onPressed: () {
                                        _controller.text = item;
                                        _performSearch(item);
                                      },
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: ValueListenableBuilder<bool>(
                  valueListenable: _loading,
                  builder: (context, loading, child) {
                    if (loading) {
                      return SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (_, index) => const SkeletonBox(),
                          childCount: 6,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: .78,
                        ),
                      );
                    }
                    if (results.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(IconlyLight.search, size: 64, color: theme.colorScheme.primary),
                              const SizedBox(height: 16),
                              Text(strings.t('searchEmpty'), style: theme.textTheme.titleMedium),
                            ],
                          ),
                        ),
                      );
                    }
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = results[index];
                          return _SearchCard(item: item);
                        },
                        childCount: results.length,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: .78,
                      ),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }
}

class _SearchCard extends StatelessWidget {
  const _SearchCard({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, CatalogDetailPage.route, arguments: item),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(color: theme.shadowColor.withOpacity(.08), blurRadius: 18, offset: const Offset(0, 12)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'catalog-${item.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Image.network(item.imageUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('${item.metrics.timeMin}${strings.t('minutes')} · ${strings.t('level')} ${item.metrics.level}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
