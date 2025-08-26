import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';

class WorkerInventoryScreen extends StatefulWidget {
  const WorkerInventoryScreen({super.key});

  @override
  State<WorkerInventoryScreen> createState() => _WorkerInventoryScreenState();
}

class _WorkerInventoryScreenState extends State<WorkerInventoryScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All',
    'Groceries',
    'Electronics',
    'Clothing',
    'Books',
    'Home & Garden',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading products
    await Future.delayed(const Duration(seconds: 1));

    _products = [
      Product(
        id: '1',
        name: 'Fresh Apples',
        description: 'Organic red apples, perfect for snacking',
        price: 4.99,
        stock: 50,
        category: 'Groceries',
        imageUrl: 'https://via.placeholder.com/100x100?text=Apples',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '2',
        name: 'Wireless Headphones',
        description: 'High-quality wireless headphones',
        price: 129.99,
        stock: 15,
        category: 'Electronics',
        imageUrl: 'https://via.placeholder.com/100x100?text=Headphones',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '3',
        name: 'Cotton T-Shirt',
        description: 'Comfortable cotton t-shirt',
        price: 19.99,
        stock: 0, // Out of stock
        category: 'Clothing',
        imageUrl: 'https://via.placeholder.com/100x100?text=T-Shirt',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '4',
        name: 'Bananas',
        description: 'Fresh yellow bananas',
        price: 2.99,
        stock: 5, // Low stock
        category: 'Groceries',
        imageUrl: 'https://via.placeholder.com/100x100?text=Bananas',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '5',
        name: 'Garden Tools Set',
        description: 'Complete set of gardening tools',
        price: 45.99,
        stock: 12,
        category: 'Home & Garden',
        imageUrl: 'https://via.placeholder.com/100x100?text=Garden+Tools',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    setState(() {
      _isLoading = false;
    });
  }

  List<Product> get _filteredProducts {
    List<Product> filtered = _products;

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      filtered = filtered
          .where((product) =>
              product.name
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              product.category
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Inventory Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 16),

                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
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
              ],
            ),
          ),

          // Stock Status Summary
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStockSummaryItem(
                    'In Stock',
                    '${_products.where((p) => p.stock > 10).length}',
                    AppColors.success,
                    Icons.check_circle,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.borderColor,
                ),
                Expanded(
                  child: _buildStockSummaryItem(
                    'Low Stock',
                    '${_products.where((p) => p.stock > 0 && p.stock <= 10).length}',
                    AppColors.warning,
                    Icons.warning,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.borderColor,
                ),
                Expanded(
                  child: _buildStockSummaryItem(
                    'Out of Stock',
                    '${_products.where((p) => p.stock == 0).length}',
                    AppColors.error,
                    Icons.error,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Products List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildProductsList(),
          ),
        ],
      ),
      floatingActionButton: CustomFloatingActionButton(
        icon: Icons.inventory,
        tooltip: 'Quick Stock Update',
        onPressed: _showQuickStockUpdate,
      ),
    );
  }

  Widget _buildStockSummaryItem(
      String title, String count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          count,
          style: AppTextStyles.subtitle1.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          title,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_outlined,
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
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredProducts.length,
        itemBuilder: (context, index) {
          final product = _filteredProducts[index];
          return _buildProductCard(product);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    Color stockColor;
    String stockText;
    IconData stockIcon;

    if (product.stock == 0) {
      stockColor = AppColors.error;
      stockText = 'Out of Stock';
      stockIcon = Icons.error;
    } else if (product.stock <= 10) {
      stockColor = AppColors.warning;
      stockText = 'Low Stock';
      stockIcon = Icons.warning;
    } else {
      stockColor = AppColors.success;
      stockText = 'In Stock';
      stockIcon = Icons.check_circle;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Product Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.image,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(width: 12),

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: AppTextStyles.subtitle1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.category,
                        style: AppTextStyles.caption,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(stockIcon, color: stockColor, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '$stockText (${product.stock})',
                            style: TextStyle(
                              color: stockColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Stock Count
                Column(
                  children: [
                    Text(
                      'Stock',
                      style: AppTextStyles.caption,
                    ),
                    Text(
                      '${product.stock}',
                      style: AppTextStyles.heading3.copyWith(
                        color: stockColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Update Stock',
                    icon: Icons.edit,
                    onPressed: () => _showStockUpdateDialog(product),
                    height: 36,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SecondaryButton(
                    text: 'View Details',
                    icon: Icons.info_outline,
                    onPressed: () => _showProductDetails(product),
                    height: 36,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showStockUpdateDialog(Product product) {
    final stockController =
        TextEditingController(text: product.stock.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Stock - ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Current Stock: ${product.stock}',
              style: AppTextStyles.body2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'New Stock Count',
                hintText: 'Enter new stock count',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newStock = int.tryParse(stockController.text);
              if (newStock != null && newStock >= 0) {
                _updateProductStock(product, newStock);
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _updateProductStock(Product product, int newStock) {
    setState(() {
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = product.copyWith(
          stock: newStock,
          updatedAt: DateTime.now(),
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stock updated for ${product.name}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showProductDetails(Product product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                product.name,
                style: AppTextStyles.heading3,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                        'Price', '\$${product.price.toStringAsFixed(2)}'),
                    _buildDetailRow('Stock', '${product.stock}'),
                    _buildDetailRow('Category', product.category),
                    _buildDetailRow('Description', product.description),
                    _buildDetailRow('Created', _formatDate(product.createdAt)),
                    _buildDetailRow(
                        'Last Updated', _formatDate(product.updatedAt)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTextStyles.subtitle2,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickStockUpdate() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Quick Stock Update',
                style: AppTextStyles.heading3,
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _products.where((p) => p.stock <= 10).length,
                itemBuilder: (context, index) {
                  final lowStockProducts =
                      _products.where((p) => p.stock <= 10).toList();
                  final product = lowStockProducts[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text('Current: ${product.stock}'),
                      trailing: SizedBox(
                        width: 80,
                        child: SecondaryButton(
                          text: 'Update',
                          onPressed: () => _showStockUpdateDialog(product),
                          height: 32,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
