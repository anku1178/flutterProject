import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItems = [];
  double _deliveryFee = 5.99;
  double _taxRate = 0.08; // 8% tax

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() {
    // Simulate loading cart items
    _cartItems = [
      CartItem(
        product: Product(
          id: '1',
          name: 'Wireless Headphones',
          description: 'High-quality wireless headphones',
          price: 129.99,
          stock: 15,
          category: 'Electronics',
          imageUrl: 'https://via.placeholder.com/100x100?text=Headphones',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        quantity: 1,
      ),
      CartItem(
        product: Product(
          id: '2',
          name: 'Fresh Apples',
          description: 'Organic red apples',
          price: 4.99,
          stock: 50,
          category: 'Groceries',
          imageUrl: 'https://via.placeholder.com/100x100?text=Apples',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        quantity: 3,
      ),
      CartItem(
        product: Product(
          id: '3',
          name: 'Cotton T-Shirt',
          description: 'Comfortable cotton t-shirt',
          price: 19.99,
          stock: 30,
          category: 'Clothing',
          imageUrl: 'https://via.placeholder.com/100x100?text=T-Shirt',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        quantity: 2,
      ),
    ];
  }

  double get _subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get _tax {
    return _subtotal * _taxRate;
  }

  double get _total {
    return _subtotal + _deliveryFee + _tax;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Shopping Cart (${_cartItems.length})'),
        actions: [
          if (_cartItems.isNotEmpty)
            TextButton(
              onPressed: _clearCart,
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: _cartItems.isEmpty ? _buildEmptyCart() : _buildCartContent(),
      bottomNavigationBar:
          _cartItems.isNotEmpty ? _buildCheckoutSection() : null,
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppColors.textLight,
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'Start Shopping',
            icon: Icons.shopping_bag,
            onPressed: () => context.push('/customer/products'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _cartItems.length,
            itemBuilder: (context, index) {
              final item = _cartItems[index];
              return _buildCartItemCard(item, index);
            },
          ),
        ),
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.image,
                color: AppColors.textLight,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: AppTextStyles.subtitle1,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.product.category,
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${item.product.price.toStringAsFixed(2)}',
                    style: AppTextStyles.price,
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onPressed: () =>
                          _updateQuantity(index, item.quantity - 1),
                    ),
                    Container(
                      width: 40,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: AppTextStyles.subtitle2,
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onPressed: () =>
                          _updateQuantity(index, item.quantity + 1),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${item.totalPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.subtitle1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Remove Button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _removeItem(index),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 16, color: AppColors.primary),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Subtotal', _subtotal),
          _buildSummaryRow('Delivery Fee', _deliveryFee),
          _buildSummaryRow('Tax', _tax),
          const Divider(),
          _buildSummaryRow('Total', _total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.subtitle1.copyWith(fontWeight: FontWeight.w600)
                : AppTextStyles.body2,
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: isTotal
                ? AppTextStyles.price.copyWith(fontSize: 18)
                : AppTextStyles.body2,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Promo Code
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Enter promo code',
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SecondaryButton(
                  text: 'Apply',
                  onPressed: () => _applyPromoCode(),
                  height: 40,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Checkout Button
            PrimaryButton(
              text: 'Proceed to Checkout - \$${_total.toStringAsFixed(2)}',
              onPressed: () => context.push('/customer/checkout'),
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuantity(int index, int newQuantity) {
    if (newQuantity < 1) {
      _removeItem(index);
      return;
    }

    setState(() {
      _cartItems[index] = _cartItems[index].copyWith(quantity: newQuantity);
    });
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from cart'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _clearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
            'Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _cartItems.clear();
              });
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _applyPromoCode() {
    // Simulate promo code application
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Promo code feature coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
