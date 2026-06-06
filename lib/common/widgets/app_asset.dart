import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppAsset extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final ColorFilter? colorFilter;

  const AppAsset(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.colorFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        colorFilter: colorFilter,
      );
    }
    return Image.asset(path, width: width, height: height, fit: fit);
  }
}
