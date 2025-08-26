import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/enhanced_search_widget.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/product_providers.dart';
import '../../../../core/providers/auth_providers.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(productSearchProvider);
    final categories = ref.watch(categoriesProvider);
    final sortOptions = ref.watch(sortOptionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: Icon(
                searchState.isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              ref.read(productSearchProvider.notifier).toggleViewMode();
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showAdvancedFilters(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced Search Widget
          EnhancedSearchWidget(
            initialQuery: searchState.searchQuery,
            onSearchChanged: (query) {
              ref.read(productSearchProvider.notifier).updateSearchQuery(query);
            },
          ),

          // Category Filter Chips
          if (categories.isNotEmpty)
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category == searchState.selectedCategory;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
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
                    ),
                  );
                },
              ),
            ),

          // Results and Sort Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${searchState.filteredProducts.length} products found',
                  style: AppTextStyles.body2,
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: searchState.sortBy,
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(productSearchProvider.notifier)
                          .updateSortBy(value);
                    }
                  },
                  items: sortOptions.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  underline: Container(),
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ),

          // Loading State
          if (searchState.isLoading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else
            // Products List/Grid
            Expanded(
              child: searchState.filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : searchState.isGridView
                      ? _buildGridView(searchState.filteredProducts)
                      : _buildListView(searchState.filteredProducts),
            ),
        ],
      ),
    );
  }

  Widget _buildGridView(List<Product> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => context.push('/customer/product/${product.id}'),
          onAddToCart: () => _addToCart(product),
        );
      },
    );
  }

  Widget _buildListView(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.surface,
              ),
              child: const Icon(Icons.image, color: AppColors.textLight),
            ),
            title: Text(product.name, style: AppTextStyles.subtitle1),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.description,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: AppTextStyles.price,
                ),
              ],
            ),
            trailing: product.isInStock
                ? IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () => _addToCart(product),
                    color: AppColors.primary,
                  )
                : const Text('Out of Stock',
                    style: TextStyle(color: AppColors.error)),
            onTap: () => context.push('/customer/product/${product.id}'),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: AppTextStyles.body2,
          ),
          const SizedBox(height: 24),
          SecondaryButton(
            text: 'Clear Filters',
            onPressed: () {
              ref.read(productSearchProvider.notifier).clearFilters();
            },
          ),
        ],
      ),
    );
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AdvancedFilterWidget(
        onApplyFilters: () {
          // Filters are automatically applied through providers
        },
      ),
    );
  }

  void _addToCart(Product product) {
    ref.read(cartProvider.notifier).addItem(product);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} added to cart'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => context.push('/customer/cart'),
        ),
      ),
    );
  }
}
