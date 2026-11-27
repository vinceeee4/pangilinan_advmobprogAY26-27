import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';
import '../widgets/custom_text.dart';
import 'detail_screen.dart';

// ENHANCEMENT 1: Cart screen that renders the /carts endpoint.
// Every item is clickable and opens the SAME DetailScreen used by the
// product grid (reusing the screen widget with only a productId).
//
// ENHANCEMENT 3: the cart shown is the cart of ONE user
// (GET /carts/user/{userId}) plus the items added with POST /carts/add.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();
  late Future<Cart?> _cartFuture;

  // Local copy of the items so the +/- buttons can change quantities.
  List<CartProduct>? _items;

  static const double _deliveryFee = 0.0;

  @override
  void initState() {
    super.initState();
    _cartFuture = _loadCart();
  }

  /// Which user's cart to show.
  Future<int> _resolveUserId() async => kDefaultUserId;

  Future<Cart?> _loadCart() async {
    final userId = await _resolveUserId();
    final cart = await _cartService.getCartByUserId(userId);

    // Merge API cart items with items added during this session.
    final merged = <CartProduct>[...?cart?.products];
    for (final added in CartService.addedItems) {
      final i = merged.indexWhere((e) => e.id == added.id);
      if (i >= 0) {
        merged[i] = merged[i].copyWith(
          quantity: merged[i].quantity + added.quantity,
        );
      } else {
        merged.add(added);
      }
    }
    _items = merged;
    return cart;
  }

  Future<void> _refresh() async {
    setState(() {
      _items = null;
      _cartFuture = _loadCart();
    });
    await _cartFuture;
  }

  void _changeQty(int index, int delta) {
    setState(() {
      final item = _items![index];
      final q = item.quantity + delta;
      if (q <= 0) {
        _items!.removeAt(index);
      } else {
        _items![index] = item.copyWith(quantity: q);
      }
    });
  }

  double get _subtotal =>
      (_items ?? []).fold(0.0, (sum, e) => sum + e.price * e.quantity);

  double get _discount => (_items ?? []).fold(
    0.0,
    (sum, e) => sum + e.price * e.quantity * e.discountPercentage / 100,
  );

  void _openDetail(CartProduct item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(productId: item.id)),
    ).then((_) => _refresh()); // item may have been added from details
  }

  void _confirmOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order confirmed! (simulated)')),
    );
    CartService.addedItems.clear();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Cart?>(
      future: _cartFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: CustomText(
              text: 'Error: ${snapshot.error}',
              fontSize: 14.sp,
            ),
          );
        }

        final items = _items ?? [];
        if (items.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: [
                SizedBox(height: 160.h),
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 56.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 8.h),
                CustomText(
                  text: 'Your cart is empty',
                  fontSize: 15.sp,
                  textAlign: TextAlign.center,
                  color: Colors.grey,
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  padding: EdgeInsets.all(12.r),
                  children: [
                    ...List.generate(
                      items.length,
                      (i) => _CartItemCard(
                        item: items[i],
                        onTap: () => _openDetail(items[i]),
                        onAdd: () => _changeQty(i, 1),
                        onRemove: () => _changeQty(i, -1),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    _SummaryRow(label: 'Subtotal', value: _subtotal),
                    _SummaryRow(label: 'Discount', value: -_discount),
                    _SummaryRow(label: 'Delivery Fee', value: _deliveryFee),
                    const Divider(),
                    _SummaryRow(
                      label: 'Total',
                      value: _subtotal - _discount + _deliveryFee,
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 12.h),
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: kAccent,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onPressed: _confirmOrder,
                  child: CustomText(
                    text: 'Confirm Order',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// One product row in the cart (image, title, price, +/- quantity).
class _CartItemCard extends StatelessWidget {
  final CartProduct item;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onTap,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final lineTotal = item.price * item.quantity;
    return Card(
      elevation: 1,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap, // ENHANCEMENT 1: item -> DetailScreen
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              Image.network(
                item.thumbnail,
                width: 72.w,
                height: 72.w,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.image, size: 40.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: item.title,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      text: '\$${item.price.toStringAsFixed(2)}',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: kAccent,
                    ),
                    SizedBox(height: 2.h),
                    CustomText(
                      text:
                          '${item.discountPercentage.toStringAsFixed(0)}% off • \$${lineTotal.toStringAsFixed(2)} total',
                      fontSize: 11.sp,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  _QtyButton(icon: Icons.add, onTap: onAdd, filled: true),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: CustomText(
                      text: '${item.quantity}',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  _QtyButton(icon: Icons.remove, onTap: onRemove),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;
  const _QtyButton({
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? kAccent : Colors.grey.shade300,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: onTap,
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: Icon(icon, size: 18.sp, color: Colors.black87),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final bool bold;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = value < 0
        ? '-\$${(-value).toStringAsFixed(2)}'
        : '\$${value.toStringAsFixed(2)}';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: '$label:',
            fontSize: bold ? 15.sp : 13.sp,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            color: bold ? null : Colors.grey,
          ),
          CustomText(
            text: text,
            fontSize: bold ? 16.sp : 14.sp,
            fontWeight: FontWeight.w700,
            color: kAccent,
          ),
        ],
      ),
    );
  }
}
