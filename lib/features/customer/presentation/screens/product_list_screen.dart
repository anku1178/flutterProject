import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Product> _allProducts = _generateProducts();
  List<Product> _filteredProducts = [];
  String _selectedCategory = 'All';
  String _sortBy = 'name';
  bool _isGridView = true;
  double _minPrice = 0;
  double _maxPrice = 200;
  bool _inStockOnly = false;

  final List<String> _categories = [
    'All',
    'Groceries',
    'Electronics',
    'Clothing',
    'Books',
    'Home & Garden',
  ];

  final List<String> _sortOptions = [
    'name',
    'price_low',
    'price_high',
    'newest',
  ];

  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts;
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static List<Product> _generateProducts() {
    return [
      Product(
        id: '1',
        name: 'Fresh Apples',
        description: 'Organic red apples, perfect for snacking',
        price: 4.99,
        stock: 50,
        category: 'Groceries',
        imageUrl: 'https://via.placeholder.com/200x200?text=Apples',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '2',
        name: 'Wireless Headphones',
        description: 'High-quality wireless headphones with noise cancellation',
        price: 129.99,
        stock: 15,
        category: 'Electronics',
        imageUrl: 'https://via.placeholder.com/200x200?text=Headphones',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '3',
        name: 'Cotton T-Shirt',
        description: 'Comfortable cotton t-shirt, available in multiple colors',
        price: 19.99,
        stock: 30,
        category: 'Clothing',
        imageUrl: 'https://via.placeholder.com/200x200?text=T-Shirt',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '4',
        name: 'Cooking Book',
        description:
            'Learn to cook delicious meals with this comprehensive guide',
        price: 24.99,
        stock: 0,
        category: 'Books',
        imageUrl: 'https://via.placeholder.com/200x200?text=Cookbook',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '5',
        name: 'Smartphone',
        description: 'Latest smartphone with advanced camera features',
        price: 699.99,
        stock: 8,
        category: 'Electronics',
        imageUrl: 'https://via.placeholder.com/200x200?text=Smartphone',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '6',
        name: 'Bananas',
        description: 'Fresh yellow bananas, rich in potassium',
        price: 2.99,
        stock: 100,
        category: 'Groceries',
        imageUrl: 'https://via.placeholder.com/200x200?text=Bananas',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '7',
        name: 'Garden Tools Set',
        description: 'Complete set of essential gardening tools',
        price: 45.99,
        stock: 12,
        category: 'Home & Garden',
        imageUrl: 'https://via.placeholder.com/200x200?text=Garden+Tools',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '8',
        name: 'Jeans',
        description: 'Classic blue denim jeans, comfortable fit',
        price: 39.99,
        stock: 25,
        category: 'Clothing',
        imageUrl: 'https://via.placeholder.com/200x200?text=Jeans',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  void _filterProducts() {
    List<Product> filtered = _allProducts;

    // Filter by search query
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

    // Filter by price range
    filtered = filtered
        .where((product) =>
            product.price >= _minPrice && product.price <= _maxPrice)
        .toList();

    // Filter by stock availability
    if (_inStockOnly) {
      filtered = filtered.where((product) => product.isInStock).toList();
    }

    // Sort products
    switch (_sortBy) {
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'name':
      default:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    setState(() {
      _filteredProducts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      _filterProducts();
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

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_filteredProducts.length} products found',
                  style: AppTextStyles.body2,
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: _sortBy,
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                    _filterProducts();
                  },
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name A-Z')),
                    DropdownMenuItem(
                        value: 'price_low', child: Text('Price: Low to High')),
                    DropdownMenuItem(
                        value: 'price_high', child: Text('Price: High to Low')),
                    DropdownMenuItem(
                        value: 'newest', child: Text('Newest First')),
                  ],
                  underline: Container(),
                  style: AppTextStyles.body2,
                ),
              ],
            ),
          ),

          // Products List/Grid
          Expanded(
            child: _filteredProducts.isEmpty
                ? _buildEmptyState()
                : _isGridView
                    ? _buildGridView()
                    : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ProductCard(
          product: product,
          onTap: () => context.push('/customer/product/${product.id}'),
          onAddToCart: () => _addToCart(product),
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
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
              setState(() {
                _searchController.clear();
                _selectedCategory = 'All';
                _minPrice = 0;
                _maxPrice = 200;
                _inStockOnly = false;
              });
              _filterProducts();
            },
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text('Filters', style: AppTextStyles.heading3),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _minPrice = 0;
                          _maxPrice = 200;
                          _inStockOnly = false;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),

              // Filter Options
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price Range
                      Text('Price Range', style: AppTextStyles.subtitle1),
                      const SizedBox(height: 8),
                      RangeSlider(
                        values: RangeValues(_minPrice, _maxPrice),
                        min: 0,
                        max: 1000,
                        divisions: 20,
                        labels: RangeLabels(
                          '\$${_minPrice.round()}',
                          '\$${_maxPrice.round()}',
                        ),
                        onChanged: (values) {
                          setModalState(() {
                            _minPrice = values.start;
                            _maxPrice = values.end;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // In Stock Only
                      CheckboxListTile(
                        title: const Text('In Stock Only'),
                        value: _inStockOnly,
                        onChanged: (value) {
                          setModalState(() {
                            _inStockOnly = value ?? false;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),

              // Apply Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: PrimaryButton(
                  text: 'Apply Filters',
                  onPressed: () {
                    setState(() {
                      // Update the main state with modal state
                    });
                    _filterProducts();
                    Navigator.pop(context);
                  },
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(Product product) {
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
