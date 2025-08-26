import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  State<CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _currentIndex = 0;
  final List<Product> _featuredProducts = _generateFeaturedProducts();
  final List<String> _categories = [
    'All',
    'Groceries',
    'Electronics',
    'Clothing',
    'Books',
    'Home & Garden',
  ];
  String _selectedCategory = 'All';

  static List<Product> _generateFeaturedProducts() {
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
        stock: 0, // Out of stock
        category: 'Books',
        imageUrl: 'https://via.placeholder.com/200x200?text=Cookbook',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildCategoriesTab(),
          _buildCartTab(),
          _buildOrdersTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          backgroundColor: AppColors.primary,
          title: const Text('General Store'),
          actions: [
            badges.Badge(
              badgeContent: const Text('3',
                  style: TextStyle(color: Colors.white, fontSize: 10)),
              child: IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  _showNotifications(context);
                },
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),

        // Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    _showFilterBottomSheet(context);
                  },
                ),
              ),
              onTap: () {
                context.push('/customer/products');
              },
              readOnly: true,
            ),
          ),
        ),

        // Categories
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Categories',
                  style: AppTextStyles.heading3,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _buildCategoryCard(category);
                  },
                ),
              ),
            ],
          ),
        ),

        // Featured Products
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Featured Products',
                  style: AppTextStyles.heading3,
                ),
                CustomTextButton(
                  text: 'View All',
                  onPressed: () {
                    context.push('/customer/products');
                  },
                ),
              ],
            ),
          ),
        ),

        // Products Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = _featuredProducts[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    context.push('/customer/product/${product.id}');
                  },
                  onAddToCart: () {
                    _addToCart(product);
                  },
                );
              },
              childCount: _featuredProducts.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(String category, {bool isLarge = false}) {
    final isSelected = category == _selectedCategory;
    final IconData icon = _getCategoryIcon(category);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
        context.push('/customer/products');
      },
      child: isLarge
          ? Card(
              elevation: 2,
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        icon,
                        color:
                            isSelected ? Colors.white : AppColors.textSecondary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      category,
                      style: AppTextStyles.subtitle1.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(category.length * 3 + 10)} items',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            )
          : Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      icon,
                      color:
                          isSelected ? Colors.white : AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category,
                    style: AppTextStyles.caption.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'All':
        return Icons.apps;
      case 'Groceries':
        return Icons.local_grocery_store;
      case 'Electronics':
        return Icons.devices;
      case 'Clothing':
        return Icons.checkroom;
      case 'Books':
        return Icons.menu_book;
      case 'Home & Garden':
        return Icons.home;
      default:
        return Icons.category;
    }
  }

  Widget _buildCategoriesTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Categories'),
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category =
                    _categories.skip(1).toList()[index]; // Skip 'All'
                return _buildCategoryCard(category, isLarge: true);
              },
              childCount: _categories.length - 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Shopping Cart'),
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Mock cart items
                ...List.generate(
                    3,
                    (index) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.image,
                                  color: AppColors.textLight),
                            ),
                            title: Text('Product ${index + 1}'),
                            subtitle: Text('Quantity: ${index + 1}'),
                            trailing: Text(
                                '\$${((index + 1) * 10.99).toStringAsFixed(2)}',
                                style: AppTextStyles.price),
                          ),
                        )),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: 'Proceed to Checkout',
                  onPressed: () => context.push('/customer/checkout'),
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('My Orders'),
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OrderCard(
                    order: Order(
                      id: 'ORD00${index + 1}',
                      customerId: 'customer1',
                      items: [],
                      totalAmount: (index + 1) * 25.99,
                      status:
                          OrderStatus.values[index % OrderStatus.values.length],
                      paymentMethod: index % 2 == 0
                          ? PaymentMethod.online
                          : PaymentMethod.cashOnPickup,
                      createdAt: DateTime.now().subtract(Duration(days: index)),
                    ),
                    onTap: () =>
                        context.push('/customer/orders/ORD00${index + 1}'),
                  ),
                );
              },
              childCount: 5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Profile'),
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primary,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Header
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'John Doe',
                                style: AppTextStyles.heading3,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'customer@demo.com',
                                style: AppTextStyles.body2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Member since Jan 2024',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Profile Options
                Card(
                  child: Column(
                    children: [
                      _buildProfileOption(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle: 'Update your personal information',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _buildProfileOption(
                        icon: Icons.location_on_outlined,
                        title: 'Addresses',
                        subtitle: 'Manage your delivery addresses',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _buildProfileOption(
                        icon: Icons.payment_outlined,
                        title: 'Payment Methods',
                        subtitle: 'Manage your payment options',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _buildProfileOption(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Configure notification preferences',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _buildProfileOption(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get help and contact support',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _buildProfileOption(
                        icon: Icons.logout,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        onTap: () => context.go('/login'),
                        isDestructive: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.primary,
      ),
      title: Text(
        title,
        style: AppTextStyles.subtitle1.copyWith(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppColors.textLight,
      ),
      onTap: onTap,
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.category_outlined),
          activeIcon: Icon(Icons.category),
          label: 'Categories',
        ),
        BottomNavigationBarItem(
          icon: badges.Badge(
            badgeContent: const Text('2',
                style: TextStyle(color: Colors.white, fontSize: 10)),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          activeIcon: badges.Badge(
            badgeContent: const Text('2',
                style: TextStyle(color: Colors.white, fontSize: 10)),
            child: const Icon(Icons.shopping_cart),
          ),
          label: 'Cart',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
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
              child: Row(
                children: [
                  Text(
                    'Notifications',
                    style: AppTextStyles.heading3,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Mark all as read'),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('No notifications yet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
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
                'Filter Products',
                style: AppTextStyles.heading3,
              ),
            ),
            const Expanded(
              child: Center(
                child: Text('Filter options coming soon'),
              ),
            ),
          ],
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
          onPressed: () {
            setState(() {
              _currentIndex = 2;
            });
          },
        ),
      ),
    );
  }
}
