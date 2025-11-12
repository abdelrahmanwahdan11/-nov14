import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../app/localization.dart';
import '../../core/utils/debouncer.dart';
import '../../core/widgets/ai_info_button.dart';
import '../../core/widgets/skeleton_box.dart';
import '../../data/models/catalog_item.dart';
import '../compare/compare_page.dart';
import '../shared/app_state.dart';
import 'widgets/catalog_filters_sheet.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  static const route = '/catalog';

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _scrollController = ScrollController();
  final _debouncer = Debouncer();
  final ValueNotifier<Set<String>> _compare = ValueNotifier(<String>{});
  bool _initialized = false;
  late AppState _state;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_scrollController.position.extentAfter < 300) {
      _state.catalogController.loadMore();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = AppStateScope.of(context);
    if (!_initialized) {
      _initialized = true;
      _state.catalogController.refresh();
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _debouncer.dispose();
    _compare.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.t('catalog')),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () async {
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                builder: (_) => CatalogFiltersSheet(initial: state.catalogController.filters),
              );
              if (result != null) {
                await state.catalogController.applyFilters(result);
              }
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: state.catalogController,
        builder: (context, _) {
          final items = state.catalogController.items;
          return RefreshIndicator(
            onRefresh: () => state.catalogController.refresh(),
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: strings.t('searchHint'),
                      ),
                      onChanged: (value) => _debouncer(() => state.catalogController.search(value)),
                    ),
                  ),
                ),
                if (items.isEmpty && !state.catalogController.isLoading)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(IconlyLight.close_square, size: 48, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: 12),
                          Text(strings.t('emptyResults')),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= items.length) {
                            return const SkeletonBox();
                          }
                          final item = items[index];
                          return ValueListenableBuilder<Set<String>>(
                            valueListenable: _compare,
                            builder: (context, selectedIds, _) {
                              final isSelected = selectedIds.contains(item.id);
                              return _CatalogCard(
                                item: item,
                                selected: isSelected,
                                onSelected: (value) {
                                  final current = selectedIds;
                                  if (value) {
                                    if (current.length < 3) {
                                      _compare.value = {...current, item.id};
                                    }
                                  } else {
                                    final copy = {...current}..remove(item.id);
                                    _compare.value = copy;
                                  }
                                },
                              );
                            },
                          );
                        },
                        childCount: items.length + (state.catalogController.isLoading ? 6 : 0),
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: .72,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: ValueListenableBuilder<Set<String>>(
        valueListenable: _compare,
        builder: (context, value, child) {
          if (value.isEmpty) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () {
              final items = AppStateScope.of(context)
                  .catalogController
                  .items
                  .where((element) => value.contains(element.id))
                  .toList();
              Navigator.pushNamed(context, ComparePage.route, arguments: items);
            },
            label: Text('${strings.t('compare')} (${value.length})'),
          );
        },
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({required this.item, required this.onSelected, required this.selected});

  final CatalogItem item;
  final ValueChanged<bool> onSelected;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => onSelected(!selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            if (selected)
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(.25),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(item.imageUrl, fit: BoxFit.cover),
                    Positioned(top: 8, right: 8, child: AiInfoButton()),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text('${item.metrics.timeMin}${strings.t('minutes')}'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Chip(label: Text('${strings.t('level')} ${item.metrics.level}')),
                      for (final tag in item.tags.take(2)) Chip(label: Text(tag)),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => onSelected(!selected),
                      child: Text(selected ? strings.t('remove') : strings.t('addToCompare')),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
