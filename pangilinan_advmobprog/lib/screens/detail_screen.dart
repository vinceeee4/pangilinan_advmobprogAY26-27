import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../widgets/custom_text.dart';

// ENHANCEMENT 2: Details page shown when a product card is tapped.
// Layout follows the handout sample: big image header on a tinted
// background, then a rounded white sheet with the title and description.
//
// It only needs a productId. If the caller already has the Product object
// it can pass it to skip the network call; otherwise the screen loads it
// from GET /products/{id}. This lets any screen reuse it.
class DetailScreen extends StatefulWidget {
  final int productId;
  final Product? product;

  const DetailScreen({super.key, required this.productId, this.product});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late final Future<Product> _productFuture;
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    _productFuture = widget.product != null
        ? Future.value(widget.product!)
        : ProductService().getProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: CustomText(
                text: 'Could not load product.\n${snapshot.error ?? ''}',
                fontSize: 14.sp,
                textAlign: TextAlign.center,
              ),
            );
          }
          return _buildDetails(context, snapshot.data!);
        },
      ),
    );
  }

  Widget _buildDetails(BuildContext context, Product product) {
    final images = product.images.isNotEmpty
        ? product.images
        : <String>[product.thumbnail];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // Image header with back button
        SliverAppBar(
          expandedHeight: 340.h,
          pinned: true,
          backgroundColor: isDark ? null : const Color(0xFFDCE4FA),
          foregroundColor: isDark ? Colors.white : Colors.black87,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  itemCount: images.length,
                  onPageChanged: (i) => setState(() => _imageIndex = i),
                  itemBuilder: (context, i) {
                    final image = Image.network(
                      images[i],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.image, size: 48.sp),
                    );
                    return Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 80.h, 24.w, 40.h),
                      child: i == 0
                          ? Hero(tag: 'product-${product.id}', child: image)
                          : image,
                    );
                  },
                ),
                // "Read all"-style pill from the sample, used as image counter
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: CustomText(
                      text: '${_imageIndex + 1} / ${images.length}',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Rounded content sheet
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: product.title,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  text: [
                    product.brand,
                    product.category,
                  ].where((s) => s.isNotEmpty).join(' • '),
                  fontSize: 13.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    CustomText(
                      text: '\$${product.price.toStringAsFixed(2)}',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: kAccent,
                    ),
                    SizedBox(width: 8.w),
                    if (product.discountPercentage > 0)
                      _Chip(
                        text:
                            '-${product.discountPercentage.toStringAsFixed(0)}%',
                      ),
                    const Spacer(),
                    Icon(Icons.star_rounded, color: kAccent, size: 20.sp),
                    CustomText(
                      text: product.rating.toStringAsFixed(1),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                CustomText(
                  text: 'Description',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                SizedBox(height: 6.h),
                CustomText(text: product.description, fontSize: 14.sp),
                SizedBox(height: 16.h),
                _InfoRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'Stock',
                  value: '${product.stock} • ${product.availabilityStatus}',
                ),
                _InfoRow(
                  icon: Icons.local_shipping_outlined,
                  label: 'Shipping',
                  value: product.shippingInformation,
                ),
                _InfoRow(
                  icon: Icons.verified_outlined,
                  label: 'Warranty',
                  value: product.warrantyInformation,
                ),
                _InfoRow(
                  icon: Icons.assignment_return_outlined,
                  label: 'Returns',
                  value: product.returnPolicy,
                ),
                if (product.reviews.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  CustomText(
                    text: 'Reviews (${product.reviews.length})',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: 6.h),
                  ...product.reviews.map(
                    (r) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: CustomText(
                          text: r.reviewerName.isNotEmpty
                              ? r.reviewerName[0].toUpperCase()
                              : '?',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      title: CustomText(
                        text: '${r.reviewerName}  ★${r.rating}',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      subtitle: CustomText(text: r.comment, fontSize: 12.sp),
                    ),
                  ),
                ],
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Small rounded label (used for the discount badge).
class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: CustomText(
        text: text,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: Colors.redAccent,
      ),
    );
  }
}

/// Icon + label + value row for the product info list.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: kPrimary),
          SizedBox(width: 8.w),
          CustomText(
            text: '$label: ',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
          Expanded(
            child: CustomText(text: value, fontSize: 13.sp),
          ),
        ],
      ),
    );
  }
}
