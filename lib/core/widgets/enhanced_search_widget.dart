import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/product_providers.dart';

class EnhancedSearchWidget extends ConsumerStatefulWidget {
  final Function(String) onSearchChanged;
  final String initialQuery;

  const EnhancedSearchWidget({
    super.key,
    required this.onSearchChanged,
    this.initialQuery = '',
  });

  @override
  ConsumerState<EnhancedSearchWidget> createState() =>
      _EnhancedSearchWidgetState();
}

class _EnhancedSearchWidgetState extends ConsumerState<EnhancedSearchWidget> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  List<String> _suggestions = [];
  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _focusNode.addListener(_onFocusChanged);
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _showSuggestions = _focusNode.hasFocus;
    });

    if (_focusNode.hasFocus) {
      _updateSuggestions(_controller.text);
    }
  }

  void _updateSuggestions(String query) {
    final productNotifier = ref.read(productSearchProvider.notifier);
    final suggestions = productNotifier.getSearchSuggestions(query);
    final popularSearches = productNotifier.getPopularSearches();

    setState(() {
      if (query.isEmpty) {
        _suggestions = [
          ..._recentSearches,
          ...popularSearches
              .where((search) => !_recentSearches.contains(search)),
        ].take(8).toList();
      } else {
        _suggestions = suggestions;
      }
    });
  }

  void _loadRecentSearches() {
    // In a real app, this would load from SharedPreferences
    setState(() {
      _recentSearches = ['Organic', 'Wireless', 'Fresh'];
    });
  }

  void _saveRecentSearch(String query) {
    if (query.isNotEmpty && !_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches = _recentSearches.take(5).toList();
        }
      });
      // In a real app, save to SharedPreferences here
    }
  }

  void _onSearchSubmitted(String query) {
    _saveRecentSearch(query);
    widget.onSearchChanged(query);
    _focusNode.unfocus();
    setState(() {
      _showSuggestions = false;
    });
  }

  void _onSuggestionTapped(String suggestion) {
    _controller.text = suggestion;
    _onSearchSubmitted(suggestion);
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Input Field
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppColors.primary
                  : AppColors.borderColor,
              width: _focusNode.hasFocus ? 2 : 1,
            ),
            boxShadow: _focusNode.hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: 'Search products, categories...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear,
                          color: AppColors.textSecondary),
                      onPressed: () {
                        _controller.clear();
                        widget.onSearchChanged('');
                        _updateSuggestions('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              hintStyle:
                  AppTextStyles.body2.copyWith(color: AppColors.textLight),
            ),
            style: AppTextStyles.body1,
            onChanged: (value) {
              widget.onSearchChanged(value);
              _updateSuggestions(value);
            },
            onSubmitted: _onSearchSubmitted,
            textInputAction: TextInputAction.search,
          ),
        ),

        // Suggestions Dropdown
        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _controller.text.isEmpty ? Icons.history : Icons.search,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _controller.text.isEmpty
                            ? 'Recent & Popular'
                            : 'Suggestions',
                        style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      if (_controller.text.isEmpty &&
                          _recentSearches.isNotEmpty)
                        GestureDetector(
                          onTap: _clearRecentSearches,
                          child: Text(
                            'Clear',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Suggestions List
                ..._suggestions.map((suggestion) {
                  final isRecent = _recentSearches.contains(suggestion);
                  return InkWell(
                    onTap: () => _onSuggestionTapped(suggestion),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            isRecent ? Icons.history : Icons.search,
                            size: 18,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              suggestion,
                              style: AppTextStyles.body2,
                            ),
                          ),
                          Icon(
                            Icons.north_west,
                            size: 16,
                            color: AppColors.textLight,
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 8),
              ],
            ),
          ),
      ],
    );
  }
}

// Advanced Filter Widget
class AdvancedFilterWidget extends ConsumerWidget {
  final Function() onApplyFilters;

  const AdvancedFilterWidget({
    super.key,
    required this.onApplyFilters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(productSearchProvider);
    final categories = ref.watch(categoriesProvider);
    final sortOptions = ref.watch(sortOptionsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Advanced Filters', style: AppTextStyles.heading3),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    ref.read(productSearchProvider.notifier).clearFilters();
                  },
                  child: const Text('Reset All'),
                ),
              ],
            ),
          ),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Filter
                  _buildFilterSection(
                    'Category',
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((category) {
                        final isSelected =
                            category == searchState.selectedCategory;
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            ref
                                .read(productSearchProvider.notifier)
                                .updateCategory(category);
                          },
                          backgroundColor: AppColors.surface,
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Price Range Filter
                  _buildFilterSection(
                    'Price Range',
                    Column(
                      children: [
                        RangeSlider(
                          values: RangeValues(
                              searchState.minPrice, searchState.maxPrice),
                          min: 0,
                          max: 1000,
                          divisions: 20,
                          labels: RangeLabels(
                            '\$${searchState.minPrice.round()}',
                            '\$${searchState.maxPrice.round()}',
                          ),
                          onChanged: (values) {
                            ref
                                .read(productSearchProvider.notifier)
                                .updatePriceRange(values.start, values.end);
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('\$${searchState.minPrice.round()}',
                                  style: AppTextStyles.caption),
                              Text('\$${searchState.maxPrice.round()}',
                                  style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sort Options
                  _buildFilterSection(
                    'Sort By',
                    Column(
                      children: sortOptions.entries.map((entry) {
                        final isSelected = entry.key == searchState.sortBy;
                        return RadioListTile<String>(
                          title: Text(entry.value),
                          value: entry.key,
                          groupValue: searchState.sortBy,
                          onChanged: (value) {
                            if (value != null) {
                              ref
                                  .read(productSearchProvider.notifier)
                                  .updateSortBy(value);
                            }
                          },
                          activeColor: AppColors.primary,
                          contentPadding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Additional Filters
                  _buildFilterSection(
                    'Availability',
                    CheckboxListTile(
                      title: const Text('In Stock Only'),
                      subtitle: const Text('Show only available products'),
                      value: searchState.inStockOnly,
                      onChanged: (value) {
                        ref
                            .read(productSearchProvider.notifier)
                            .updateInStockOnly(value ?? false);
                      },
                      contentPadding: EdgeInsets.zero,
                      activeColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Apply Button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  onApplyFilters();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Apply Filters (${searchState.filteredProducts.length} products)',
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.subtitle1),
        const SizedBox(height: 12),
        content,
      ],
    );
  }
}
