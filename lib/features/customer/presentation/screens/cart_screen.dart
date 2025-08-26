import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/auth_providers.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _promoController = TextEditingController();
  double _deliveryFee = 5.99;
  double _taxRate = 0.08; // 8% tax
  String? _appliedPromoCode;
  double _promoDiscount = 0.0;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  double get _subtotal {
    final cartItems = ref.read(cartProvider);
    return cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get _tax {
    return _subtotal * _taxRate;
  }

  double get _total {
    return _subtotal + _deliveryFee + _tax - _promoDiscount;
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Shopping Cart (${cartItems.length})'),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () => _clearCart(cartNotifier),
              child: const Text(
                'Clear All',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartContent(cartItems, cartNotifier),
      bottomNavigationBar:
          cartItems.isNotEmpty ? _buildCheckoutSection() : null,
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

  Widget _buildCartContent(
      List<CartItem> cartItems, CartNotifier cartNotifier) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return _buildCartItemCard(item, cartNotifier);
            },
          ),
        ),
        _buildOrderSummary(),
      ],
    );
  }

  Widget _buildCartItemCard(CartItem item, CartNotifier cartNotifier) {
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
                  if (!item.product.isInStock)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Out of Stock',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                      onPressed: () => cartNotifier.updateQuantity(
                        item.product.id,
                        item.quantity - 1,
                      ),
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
                      onPressed: item.product.isInStock
                          ? () => cartNotifier.updateQuantity(
                                item.product.id,
                                item.quantity + 1,
                              )
                          : null,
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
              onPressed: () => _removeItem(item.product.id, cartNotifier),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(
            color: isEnabled ? AppColors.borderColor : AppColors.textLight,
          ),
          borderRadius: BorderRadius.circular(4),
          color: isEnabled ? null : AppColors.surface,
        ),
        child: Icon(
          icon,
          size: 16,
          color: isEnabled ? AppColors.primary : AppColors.textLight,
        ),
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
          if (_promoDiscount > 0) ...[
            _buildSummaryRow('Promo Discount', -_promoDiscount,
                isDiscount: true),
            if (_appliedPromoCode != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  'Code: $_appliedPromoCode',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
          const Divider(),
          _buildSummaryRow('Total', _total, isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount,
      {bool isTotal = false, bool isDiscount = false}) {
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
            '\$${amount.abs().toStringAsFixed(2)}',
            style: isTotal
                ? AppTextStyles.price.copyWith(fontSize: 18)
                : isDiscount
                    ? AppTextStyles.body2.copyWith(color: AppColors.success)
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
            // Promo Code Section
            if (_appliedPromoCode == null) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoController,
                      decoration: const InputDecoration(
                        hintText: 'Enter promo code',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SecondaryButton(
                    text: 'Apply',
                    onPressed: _applyPromoCode,
                    height: 40,
                  ),
                ],
              ),
            ] else ...[
              // Applied Promo Code Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Promo code "$_appliedPromoCode" applied',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _removePromoCode,
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ),
            ],
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

  void _removeItem(String productId, CartNotifier cartNotifier) {
    cartNotifier.removeItem(productId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item removed from cart'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _clearCart(CartNotifier cartNotifier) {
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
              cartNotifier.clearCart();
              _removePromoCode();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _applyPromoCode() {
    final code = _promoController.text.trim().toUpperCase();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a promo code'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Demo promo codes
    double discount = 0.0;
    switch (code) {
      case 'SAVE10':
        discount = _subtotal * 0.10; // 10% discount
        break;
      case 'SAVE20':
        discount = _subtotal * 0.20; // 20% discount
        break;
      case 'FREESHIP':
        discount = _deliveryFee; // Free shipping
        break;
      case 'WELCOME':
        discount = 5.0; // $5 off
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid promo code'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
    }

    setState(() {
      _appliedPromoCode = code;
      _promoDiscount = discount;
      _promoController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Promo code applied! You saved \$${discount.toStringAsFixed(2)}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _removePromoCode() {
    setState(() {
      _appliedPromoCode = null;
      _promoDiscount = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Promo code removed'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
