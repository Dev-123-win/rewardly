import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// This class provides a generic shimmer loading effect.
// For more specific skeleton loading, individual screens will implement their own
// loading widgets using Shimmer.fromColors and custom layouts.
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;
  final BorderRadius? borderRadius; // Added for custom rounded rectangles

  const ShimmerLoading.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius, // Allow custom border radius for rectangular shimmers
  }) : shapeBorder = const RoundedRectangleBorder();

  const ShimmerLoading.circular({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius, // Not typically used for circular, but kept for consistency
    this.shapeBorder = const CircleBorder(),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: Colors.grey[300]!,
          shape: shapeBorder is RoundedRectangleBorder && borderRadius != null
              ? RoundedRectangleBorder(borderRadius: borderRadius!)
              : (shapeBorder is RoundedRectangleBorder
                  ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)) // Default small radius for rectangular
                  : shapeBorder),
        ),
      ),
    );
  }
}
