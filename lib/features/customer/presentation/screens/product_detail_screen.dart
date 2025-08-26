import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Product _product;
  int _quantity = 1;
  int _currentImageIndex = 0;
  bool _isFavorite = false;

  final List<String> _productImages = [
    'https://via.placeholder.com/400x400?text=Product+1',
    'https://via.placeholder.com/400x400?text=Product+2',
    'https://via.placeholder.com/400x400?text=Product+3',
  ];

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  void _loadProduct() {
    // Simulate loading product data
    _product = Product(
      id: widget.productId,
      name: 'Wireless Headphones',
      description: 'High-quality wireless headphones with noise cancellation. '
          'Features include 30-hour battery life, premium sound quality, '
          'comfortable over-ear design, and quick charge functionality. '
          'Perfect for music lovers, professionals, and travelers.',
      price: 129.99,
      stock: 15,
      category: 'Electronics',
      imageUrl: 'https://via.placeholder.com/400x400?text=Headphones',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Product Images
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildImageGallery(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? AppColors.error : AppColors.textPrimary,
                ),
                onPressed: () {
                  setState(() {
                    _isFavorite = !_isFavorite;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // Share product
                },
              ),
            ],
          ),

          // Product Details
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name and Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _product.name,
                                style: AppTextStyles.heading2,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _product.category,
                                style: AppTextStyles.body2,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${_product.price.toStringAsFixed(2)}',
                          style: AppTextStyles.price.copyWith(fontSize: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stock Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _product.isInStock
                            ? AppColors.success.withOpacity(0.1)
                            : AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _product.isInStock
                            ? 'In Stock (${_product.stock} available)'
                            : 'Out of Stock',
                        style: TextStyle(
                          color: _product.isInStock
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Quantity Selector
                    if (_product.isInStock) ...[
                      Text(
                        'Quantity',
                        style: AppTextStyles.subtitle1,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Container(
                            width: 60,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.borderColor),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$_quantity',
                              style: AppTextStyles.subtitle1,
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onPressed: _quantity < _product.stock
                                ? () => setState(() => _quantity++)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Description
                    Text(
                      'Description',
                      style: AppTextStyles.subtitle1,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _product.description,
                      style: AppTextStyles.body1.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    // Product Features
                    Text(
                      'Features',
                      style: AppTextStyles.subtitle1,
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureList(),
                    const SizedBox(height: 32),

                    // Related Products
                    Text(
                      'You might also like',
                      style: AppTextStyles.subtitle1,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        itemBuilder: (context, index) =>
                            _buildRelatedProductCard(index),
                      ),
                    ),
                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildImageGallery() {
    return Stack(
      children: [
        PageView.builder(
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemCount: _productImages.length,
          itemBuilder: (context, index) {
            return Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: AppColors.surface,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: _productImages[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Image Indicators
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _productImages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentImageIndex == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentImageIndex == index
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }

  Widget _buildFeatureList() {
    final features = [
      'Wireless Bluetooth 5.0 connectivity',
      'Active noise cancellation',
      '30-hour battery life',
      'Fast charging (10 min = 3 hours)',
      'Premium over-ear comfort',
      'Built-in microphone',
    ];

    return Column(
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: AppTextStyles.body2,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildRelatedProductCard(int index) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.image,
                color: AppColors.textLight,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Product ${index + 1}',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: _product.isInStock
            ? Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: 'Add to Cart',
                      icon: Icons.shopping_cart_outlined,
                      onPressed: () => _addToCart(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      text: 'Buy Now',
                      icon: Icons.flash_on,
                      onPressed: () => _buyNow(),
                    ),
                  ),
                ],
              )
            : PrimaryButton(
                text: 'Notify When Available',
                icon: Icons.notifications_outlined,
                onPressed: () => _notifyWhenAvailable(),
                width: double.infinity,
              ),
      ),
    );
  }

  void _addToCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$_quantity x ${_product.name} added to cart'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () => context.push('/customer/cart'),
        ),
      ),
    );
  }

  void _buyNow() {
    // Add to cart and go to checkout
    context.push('/customer/checkout');
  }

  void _notifyWhenAvailable() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
            Text('You will be notified when this product is back in stock'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
