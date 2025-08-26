import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

// Generic skeleton loading widget
class SkeletonWidget extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets margin;

  const SkeletonWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: AppColors.borderColor,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

// Product card skeleton
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            const SkeletonWidget(
              width: double.infinity,
              height: 120,
              borderRadius: 8,
            ),
            const SizedBox(height: 12),

            // Title
            const SkeletonWidget(
              width: double.infinity,
              height: 16,
              borderRadius: 4,
            ),
            const SizedBox(height: 8),

            // Subtitle
            const SkeletonWidget(
              width: 100,
              height: 12,
              borderRadius: 4,
            ),
            const SizedBox(height: 12),

            // Price and button row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonWidget(
                  width: 60,
                  height: 20,
                  borderRadius: 4,
                ),
                SkeletonWidget(
                  width: 80,
                  height: 32,
                  borderRadius: 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Order card skeleton
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonWidget(
                  width: 80,
                  height: 16,
                  borderRadius: 4,
                ),
                SkeletonWidget(
                  width: 60,
                  height: 20,
                  borderRadius: 10,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Customer info
            const SkeletonWidget(
              width: 120,
              height: 14,
              borderRadius: 4,
            ),
            const SizedBox(height: 8),

            // Items
            Row(
              children: [
                const SkeletonWidget(
                  width: 40,
                  height: 40,
                  borderRadius: 8,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonWidget(
                        width: double.infinity,
                        height: 14,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 4),
                      const SkeletonWidget(
                        width: 80,
                        height: 12,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SkeletonWidget(
                  width: 50,
                  height: 16,
                  borderRadius: 4,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                const SkeletonWidget(
                  width: 100,
                  height: 32,
                  borderRadius: 8,
                ),
                const Spacer(),
                const SkeletonWidget(
                  width: 80,
                  height: 32,
                  borderRadius: 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// List skeleton with multiple items
class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final Widget Function() itemBuilder;
  final EdgeInsets padding;

  const ListSkeleton({
    super.key,
    this.itemCount = 5,
    required this.itemBuilder,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding,
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(),
    );
  }
}

// Grid skeleton
class GridSkeleton extends StatelessWidget {
  final int itemCount;
  final Widget Function() itemBuilder;
  final int crossAxisCount;
  final EdgeInsets padding;

  const GridSkeleton({
    super.key,
    this.itemCount = 6,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => itemBuilder(),
    );
  }
}

// Dashboard stats skeleton
class StatsSkeleton extends StatelessWidget {
  const StatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SkeletonWidget(
                  width: 24,
                  height: 24,
                  borderRadius: 4,
                ),
                const SkeletonWidget(
                  width: 20,
                  height: 20,
                  borderRadius: 4,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const SkeletonWidget(
              width: 40,
              height: 24,
              borderRadius: 4,
            ),
            const SizedBox(height: 4),
            const SkeletonWidget(
              width: 80,
              height: 12,
              borderRadius: 4,
            ),
          ],
        ),
      ),
    );
  }
}

// Search skeleton
class SearchSkeleton extends StatelessWidget {
  const SearchSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar
          const SkeletonWidget(
            width: double.infinity,
            height: 48,
            borderRadius: 12,
          ),
          const SizedBox(height: 16),

          // Filter chips
          Row(
            children: [
              const SkeletonWidget(
                width: 80,
                height: 32,
                borderRadius: 16,
              ),
              const SizedBox(width: 8),
              const SkeletonWidget(
                width: 100,
                height: 32,
                borderRadius: 16,
              ),
              const SizedBox(width: 8),
              const SkeletonWidget(
                width: 60,
                height: 32,
                borderRadius: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Results count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SkeletonWidget(
                width: 120,
                height: 14,
                borderRadius: 4,
              ),
              const SkeletonWidget(
                width: 80,
                height: 14,
                borderRadius: 4,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Cart skeleton
class CartSkeleton extends StatelessWidget {
  const CartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (context, index) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const SkeletonWidget(
                      width: 80,
                      height: 80,
                      borderRadius: 8,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SkeletonWidget(
                            width: double.infinity,
                            height: 16,
                            borderRadius: 4,
                          ),
                          const SizedBox(height: 8),
                          const SkeletonWidget(
                            width: 80,
                            height: 12,
                            borderRadius: 4,
                          ),
                          const SizedBox(height: 8),
                          const SkeletonWidget(
                            width: 60,
                            height: 16,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        const SkeletonWidget(
                          width: 100,
                          height: 32,
                          borderRadius: 4,
                        ),
                        const SizedBox(height: 8),
                        const SkeletonWidget(
                          width: 60,
                          height: 16,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Order summary skeleton
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.borderColor)),
          ),
          child: Column(
            children: [
              const SkeletonWidget(
                width: 120,
                height: 16,
                borderRadius: 4,
              ),
              const SizedBox(height: 12),
              ...List.generate(
                  4,
                  (index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SkeletonWidget(
                              width: 80,
                              height: 14,
                              borderRadius: 4,
                            ),
                            const SkeletonWidget(
                              width: 60,
                              height: 14,
                              borderRadius: 4,
                            ),
                          ],
                        ),
                      )),
              const SizedBox(height: 16),
              const SkeletonWidget(
                width: double.infinity,
                height: 48,
                borderRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom skeleton with animation control
class CustomSkeleton extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool isEnabled;

  const CustomSkeleton({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.isEnabled = true,
  });

  @override
  State<CustomSkeleton> createState() => _CustomSkeletonState();
}

class _CustomSkeletonState extends State<CustomSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    if (widget.isEnabled) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) {
      return widget.child;
    }

    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.borderColor,
      period: widget.duration,
      child: widget.child,
    );
  }
}
