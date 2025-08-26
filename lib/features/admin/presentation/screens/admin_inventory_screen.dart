import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';

class AdminInventoryScreen extends StatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _sortBy = 'name';

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
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '2',
        name: 'Wireless Headphones',
        description: 'High-quality wireless headphones with noise cancellation',
        price: 129.99,
        stock: 15,
        category: 'Electronics',
        imageUrl: 'https://via.placeholder.com/100x100?text=Headphones',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '3',
        name: 'Cotton T-Shirt',
        description: 'Comfortable cotton t-shirt, available in multiple colors',
        price: 19.99,
        stock: 0,
        category: 'Clothing',
        imageUrl: 'https://via.placeholder.com/100x100?text=T-Shirt',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '4',
        name: 'Smartphone',
        description: 'Latest smartphone with advanced camera features',
        price: 699.99,
        stock: 8,
        category: 'Electronics',
        imageUrl: 'https://via.placeholder.com/100x100?text=Smartphone',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
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
              product.description
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

    // Sort products
    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'stock':
        filtered.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'name':
      default:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
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
            icon: const Icon(Icons.upload_file),
            onPressed: _importExcel,
            tooltip: 'Import from Excel',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportExcel,
            tooltip: 'Export to Excel',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
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

                // Filters Row
                Row(
                  children: [
                    // Category Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Sort Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _sortBy,
                        decoration: const InputDecoration(
                          labelText: 'Sort by',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'name', child: Text('Name A-Z')),
                          DropdownMenuItem(
                              value: 'price_low',
                              child: Text('Price: Low to High')),
                          DropdownMenuItem(
                              value: 'price_high',
                              child: Text('Price: High to Low')),
                          DropdownMenuItem(
                              value: 'stock',
                              child: Text('Stock: Low to High')),
                          DropdownMenuItem(
                              value: 'newest', child: Text('Newest First')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _sortBy = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Products Count
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '${_filteredProducts.length} products found',
                  style: AppTextStyles.body2,
                ),
                const Spacer(),
                Text(
                  'Total Value: \$${_calculateTotalValue().toStringAsFixed(2)}',
                  style: AppTextStyles.subtitle2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Products Table
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredProducts.isEmpty
                    ? _buildEmptyState()
                    : _buildProductsTable(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewProduct,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Add New Product',
            icon: Icons.add,
            onPressed: _addNewProduct,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTable() {
    return RefreshIndicator(
      onRefresh: _loadProducts,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Product')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Price'), numeric: true),
            DataColumn(label: Text('Stock'), numeric: true),
            DataColumn(label: Text('Actions')),
          ],
          rows: _filteredProducts.map((product) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.image,
                          color: AppColors.textLight,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product.name,
                              style: AppTextStyles.subtitle2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              product.description,
                              style: AppTextStyles.caption,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(Text(product.category)),
                DataCell(
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: AppTextStyles.price.copyWith(fontSize: 14),
                  ),
                ),
                DataCell(
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStockColor(product.stock).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${product.stock}',
                      style: TextStyle(
                        color: _getStockColor(product.stock),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _editProduct(product),
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            size: 20, color: AppColors.error),
                        onPressed: () => _deleteProduct(product),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getStockColor(int stock) {
    if (stock == 0) return AppColors.error;
    if (stock <= 10) return AppColors.warning;
    return AppColors.success;
  }

  double _calculateTotalValue() {
    return _filteredProducts.fold(
        0.0, (sum, product) => sum + (product.price * product.stock));
  }

  void _addNewProduct() {
    _showProductDialog();
  }

  void _editProduct(Product product) {
    _showProductDialog(product: product);
  }

  void _showProductDialog({Product? product}) {
    final isEditing = product != null;
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController =
        TextEditingController(text: product?.description ?? '');
    final priceController =
        TextEditingController(text: product?.price.toString() ?? '');
    final stockController =
        TextEditingController(text: product?.stock.toString() ?? '');
    String selectedCategory = product?.category ?? 'Groceries';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Product' : 'Add New Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.skip(1).map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedCategory = value!;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(labelText: 'Stock'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final description = descriptionController.text.trim();
              final price = double.tryParse(priceController.text);
              final stock = int.tryParse(stockController.text);

              if (name.isNotEmpty &&
                  description.isNotEmpty &&
                  price != null &&
                  stock != null) {
                _saveProduct(
                  product: product,
                  name: name,
                  description: description,
                  category: selectedCategory,
                  price: price,
                  stock: stock,
                );
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _saveProduct({
    Product? product,
    required String name,
    required String description,
    required String category,
    required double price,
    required int stock,
  }) {
    setState(() {
      if (product != null) {
        // Edit existing product
        final index = _products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          _products[index] = product.copyWith(
            name: name,
            description: description,
            category: category,
            price: price,
            stock: stock,
            updatedAt: DateTime.now(),
          );
        }
      } else {
        // Add new product
        final newProduct = Product(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          description: description,
          price: price,
          stock: stock,
          category: category,
          imageUrl:
              'https://via.placeholder.com/100x100?text=${name.replaceAll(' ', '+')}',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _products.add(newProduct);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(product != null
            ? 'Product updated successfully'
            : 'Product added successfully'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _products.removeWhere((p) => p.id == product.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Product deleted successfully'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _importExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Excel import feature coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _exportExcel() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Excel export feature coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
