import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';

// Product search and filter state
class ProductSearchState {
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  final String searchQuery;
  final String selectedCategory;
  final String sortBy;
  final double minPrice;
  final double maxPrice;
  final bool inStockOnly;
  final bool isGridView;
  final bool isLoading;

  const ProductSearchState({
    this.allProducts = const [],
    this.filteredProducts = const [],
    this.searchQuery = '',
    this.selectedCategory = 'All',
    this.sortBy = 'name',
    this.minPrice = 0,
    this.maxPrice = 1000,
    this.inStockOnly = false,
    this.isGridView = true,
    this.isLoading = false,
  });

  ProductSearchState copyWith({
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    String? searchQuery,
    String? selectedCategory,
    String? sortBy,
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
    bool? isGridView,
    bool? isLoading,
  }) {
    return ProductSearchState(
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortBy: sortBy ?? this.sortBy,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      isGridView: isGridView ?? this.isGridView,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Product search provider
final productSearchProvider =
    StateNotifierProvider<ProductSearchNotifier, ProductSearchState>((ref) {
  return ProductSearchNotifier();
});

// Search suggestions provider
final searchSuggestionsProvider = StateProvider<List<String>>((ref) {
  return [];
});

// Categories provider
final categoriesProvider = Provider<List<String>>((ref) {
  return [
    'All',
    'Groceries',
    'Electronics',
    'Clothing',
    'Books',
    'Home & Garden',
    'Sports & Outdoors',
    'Beauty & Health',
    'Toys & Games',
    'Automotive',
  ];
});

// Sort options provider
final sortOptionsProvider = Provider<Map<String, String>>((ref) {
  return {
    'name': 'Name A-Z',
    'name_desc': 'Name Z-A',
    'price_low': 'Price: Low to High',
    'price_high': 'Price: High to Low',
    'newest': 'Newest First',
    'oldest': 'Oldest First',
    'popularity': 'Most Popular',
    'rating': 'Highest Rated',
  };
});

class ProductSearchNotifier extends StateNotifier<ProductSearchState> {
  ProductSearchNotifier() : super(const ProductSearchState()) {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    state = state.copyWith(isLoading: true);

    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));

    final products = _generateProducts();
    state = state.copyWith(
      allProducts: products,
      filteredProducts: products,
      isLoading: false,
    );
  }

  // Enhanced product generation with more variety
  static List<Product> _generateProducts() {
    return [
      // Groceries
      Product(
        id: '1',
        name: 'Fresh Organic Apples',
        description:
            'Crispy organic red apples, perfect for snacking and baking',
        price: 4.99,
        stock: 50,
        category: 'Groceries',
        imageUrl: 'https://via.placeholder.com/200x200?text=Apples',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '2',
        name: 'Fresh Bananas',
        description: 'Yellow bananas rich in potassium and natural sweetness',
        price: 2.99,
        stock: 100,
        category: 'Groceries',
        imageUrl: 'https://via.placeholder.com/200x200?text=Bananas',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '3',
        name: 'Organic Milk',
        description: 'Fresh organic whole milk from grass-fed cows',
        price: 5.99,
        stock: 30,
        category: 'Groceries',
        imageUrl: 'https://via.placeholder.com/200x200?text=Milk',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '4',
        name: 'Whole Grain Bread',
        description: 'Freshly baked whole grain bread with seeds',
        price: 3.49,
        stock: 25,
        category: 'Groceries',
        imageUrl: 'https://via.placeholder.com/200x200?text=Bread',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now(),
      ),

      // Electronics
      Product(
        id: '5',
        name: 'Wireless Bluetooth Headphones',
        description:
            'Premium wireless headphones with active noise cancellation',
        price: 129.99,
        stock: 15,
        category: 'Electronics',
        imageUrl: 'https://via.placeholder.com/200x200?text=Headphones',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '6',
        name: 'Smartphone Pro Max',
        description: 'Latest flagship smartphone with advanced camera system',
        price: 999.99,
        stock: 8,
        category: 'Electronics',
        imageUrl: 'https://via.placeholder.com/200x200?text=Smartphone',
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '7',
        name: 'Wireless Charging Pad',
        description: 'Fast wireless charging pad compatible with all devices',
        price: 39.99,
        stock: 22,
        category: 'Electronics',
        imageUrl: 'https://via.placeholder.com/200x200?text=Charger',
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        updatedAt: DateTime.now(),
      ),

      // Clothing
      Product(
        id: '8',
        name: 'Premium Cotton T-Shirt',
        description: 'Soft premium cotton t-shirt available in multiple colors',
        price: 24.99,
        stock: 45,
        category: 'Clothing',
        imageUrl: 'https://via.placeholder.com/200x200?text=T-Shirt',
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '9',
        name: 'Classic Denim Jeans',
        description: 'Classic blue denim jeans with comfortable fit',
        price: 59.99,
        stock: 28,
        category: 'Clothing',
        imageUrl: 'https://via.placeholder.com/200x200?text=Jeans',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '10',
        name: 'Winter Jacket',
        description: 'Warm winter jacket with water-resistant material',
        price: 89.99,
        stock: 12,
        category: 'Clothing',
        imageUrl: 'https://via.placeholder.com/200x200?text=Jacket',
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),

      // Books
      Product(
        id: '11',
        name: 'Cooking Masterclass',
        description: 'Complete guide to cooking with 500+ recipes',
        price: 29.99,
        stock: 18,
        category: 'Books',
        imageUrl: 'https://via.placeholder.com/200x200?text=Cookbook',
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '12',
        name: 'Programming Guide',
        description: 'Comprehensive programming guide for beginners',
        price: 34.99,
        stock: 0, // Out of stock
        category: 'Books',
        imageUrl: 'https://via.placeholder.com/200x200?text=Programming',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),

      // Home & Garden
      Product(
        id: '13',
        name: 'Complete Garden Tool Set',
        description: 'Professional grade gardening tools set with carry case',
        price: 79.99,
        stock: 9,
        category: 'Home & Garden',
        imageUrl: 'https://via.placeholder.com/200x200?text=Garden+Tools',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '14',
        name: 'Indoor Plant Collection',
        description: 'Set of 3 easy-care indoor plants for home decoration',
        price: 45.99,
        stock: 16,
        category: 'Home & Garden',
        imageUrl: 'https://via.placeholder.com/200x200?text=Plants',
        createdAt: DateTime.now().subtract(const Duration(days: 9)),
        updatedAt: DateTime.now(),
      ),

      // Additional categories
      Product(
        id: '15',
        name: 'Yoga Mat Premium',
        description: 'Non-slip premium yoga mat with carrying strap',
        price: 35.99,
        stock: 20,
        category: 'Sports & Outdoors',
        imageUrl: 'https://via.placeholder.com/200x200?text=Yoga+Mat',
        createdAt: DateTime.now().subtract(const Duration(days: 11)),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: '16',
        name: 'Face Moisturizer',
        description: 'Hydrating face moisturizer with SPF protection',
        price: 18.99,
        stock: 35,
        category: 'Beauty & Health',
        imageUrl: 'https://via.placeholder.com/200x200?text=Moisturizer',
        createdAt: DateTime.now().subtract(const Duration(days: 13)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  // Search functionality
  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  void updateCategory(String category) {
    state = state.copyWith(selectedCategory: category);
    _applyFilters();
  }

  void updateSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
    _applyFilters();
  }

  void updatePriceRange(double min, double max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
    _applyFilters();
  }

  void updateInStockOnly(bool inStockOnly) {
    state = state.copyWith(inStockOnly: inStockOnly);
    _applyFilters();
  }

  void toggleViewMode() {
    state = state.copyWith(isGridView: !state.isGridView);
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedCategory: 'All',
      sortBy: 'name',
      minPrice: 0,
      maxPrice: 1000,
      inStockOnly: false,
    );
    _applyFilters();
  }

  void _applyFilters() {
    List<Product> filtered = List.from(state.allProducts);

    // Apply search query filter
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.description.toLowerCase().contains(query) ||
            product.category.toLowerCase().contains(query);
      }).toList();
    }

    // Apply category filter
    if (state.selectedCategory != 'All') {
      filtered = filtered
          .where((product) => product.category == state.selectedCategory)
          .toList();
    }

    // Apply price range filter
    filtered = filtered
        .where((product) =>
            product.price >= state.minPrice && product.price <= state.maxPrice)
        .toList();

    // Apply stock filter
    if (state.inStockOnly) {
      filtered = filtered.where((product) => product.isInStock).toList();
    }

    // Apply sorting
    switch (state.sortBy) {
      case 'name_desc':
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'newest':
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'oldest':
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'popularity':
        // Simulate popularity based on inverse stock (lower stock = more popular)
        filtered.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case 'rating':
        // Simulate rating based on price (higher price = higher rating for demo)
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'name':
      default:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
    }

    state = state.copyWith(filteredProducts: filtered);
  }

  // Get search suggestions based on current query
  List<String> getSearchSuggestions(String query) {
    if (query.isEmpty) return [];

    final suggestions = <String>[];
    final queryLower = query.toLowerCase();

    // Add product name suggestions
    for (final product in state.allProducts) {
      if (product.name.toLowerCase().contains(queryLower) &&
          !suggestions.contains(product.name) &&
          suggestions.length < 5) {
        suggestions.add(product.name);
      }
    }

    // Add category suggestions
    for (final product in state.allProducts) {
      if (product.category.toLowerCase().contains(queryLower) &&
          !suggestions.contains(product.category) &&
          suggestions.length < 8) {
        suggestions.add(product.category);
      }
    }

    return suggestions;
  }

  // Get popular search terms
  List<String> getPopularSearches() {
    return [
      'Organic',
      'Wireless',
      'Premium',
      'Fresh',
      'Classic',
      'Professional',
      'Natural',
      'Smart',
    ];
  }

  // Get category-specific price ranges
  Map<String, double> getCategoryPriceRange(String category) {
    if (category == 'All') {
      return {'min': 0, 'max': 1000};
    }

    final categoryProducts =
        state.allProducts.where((p) => p.category == category).toList();

    if (categoryProducts.isEmpty) {
      return {'min': 0, 'max': 100};
    }

    final prices = categoryProducts.map((p) => p.price).toList();
    return {
      'min': prices.reduce((a, b) => a < b ? a : b),
      'max': prices.reduce((a, b) => a > b ? a : b),
    };
  }
}
