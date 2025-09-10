import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SafeSvg extends StatelessWidget {
  final String assetName;
  final double? width;
  final double? height;
  final Color? color;

  const SafeSvg({
    Key? key,
    required this.assetName,
    this.width,
    this.height,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: SvgPicture.asset(
        assetName,
        width: width,
        height: height,
        colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
        fit: BoxFit.contain,
      ),
    );
  }
}
