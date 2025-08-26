import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/models/models.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  PaymentMethod _selectedPaymentMethod = PaymentMethod.online;
  bool _isLoading = false;

  final List<CartItem> _cartItems = [
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
  ];

  double get _subtotal {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get _deliveryFee => 5.99;
  double get _tax => _subtotal * 0.08;
  double get _total => _subtotal + _deliveryFee + _tax;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Summary
                    _buildOrderSummarySection(),
                    const SizedBox(height: 24),

                    // Customer Information
                    _buildCustomerInfoSection(),
                    const SizedBox(height: 24),

                    // Payment Method
                    _buildPaymentMethodSection(),
                    const SizedBox(height: 24),

                    // Additional Notes
                    _buildNotesSection(),
                    const SizedBox(height: 24),

                    // Pickup Information
                    _buildPickupInfoSection(),
                  ],
                ),
              ),
            ),
            _buildPlaceOrderSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummarySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: 12),

            // Items List
            ...(_cartItems
                .map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
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
                              children: [
                                Text(
                                  item.product.name,
                                  style: AppTextStyles.body2,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Qty: ${item.quantity}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${item.totalPrice.toStringAsFixed(2)}',
                            style: AppTextStyles.subtitle2,
                          ),
                        ],
                      ),
                    ))
                .toList()),

            const Divider(),

            // Price Breakdown
            _buildPriceRow('Subtotal', _subtotal),
            _buildPriceRow('Delivery Fee', _deliveryFee),
            _buildPriceRow('Tax', _tax),
            const Divider(),
            _buildPriceRow('Total', _total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
                ? AppTextStyles.price.copyWith(fontSize: 16)
                : AppTextStyles.body2,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Customer Information',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: 16),

            // Online Payment Option
            RadioListTile<PaymentMethod>(
              title: const Text('Online Payment'),
              subtitle: const Text('Pay now with credit/debit card'),
              value: PaymentMethod.online,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: AppColors.primary,
                ),
              ),
              activeColor: AppColors.primary,
            ),

            // Cash on Pickup Option
            RadioListTile<PaymentMethod>(
              title: const Text('Cash on Pickup'),
              subtitle: const Text('Pay when you collect your order'),
              value: PaymentMethod.cashOnPickup,
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.money,
                  color: AppColors.accent,
                ),
              ),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Notes (Optional)',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Any special instructions or requests...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.store,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pickup Information',
                  style: AppTextStyles.subtitle1,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'General Store',
                    style: AppTextStyles.subtitle2
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text('123 Main Street, Downtown'),
                  const Text('Phone: (555) 123-4567'),
                  const SizedBox(height: 8),
                  Text(
                    'Store Hours:',
                    style: AppTextStyles.subtitle2
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const Text('Mon-Fri: 8:00 AM - 8:00 PM'),
                  const Text('Sat-Sun: 9:00 AM - 6:00 PM'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You will receive a notification when your order is ready for pickup.',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceOrderSection() {
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
            // Terms Agreement
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.caption,
                      children: [
                        const TextSpan(
                            text: 'By placing this order, you agree to our '),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Place Order Button
            PrimaryButton(
              text: _selectedPaymentMethod == PaymentMethod.online
                  ? 'Pay Now - \$${_total.toStringAsFixed(2)}'
                  : 'Place Order - \$${_total.toStringAsFixed(2)}',
              onPressed: _placeOrder,
              isLoading: _isLoading,
              width: double.infinity,
              icon: _selectedPaymentMethod == PaymentMethod.online
                  ? Icons.payment
                  : Icons.receipt_long,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate order placement
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Generate order ID and navigate to order tracking
      final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch}';

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedPaymentMethod == PaymentMethod.online
                ? 'Payment successful! Order placed.'
                : 'Order placed successfully!',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to order tracking
      context.go('/customer/orders/$orderId');
    }
  }
}
