import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:maintenance2/core/utils/app_colors.dart';
import 'package:maintenance2/core/utils/app_text_styles.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.width,
    this.backgroundcolor,
    this.textColor,
    this.image,
    this.textStyle,
  });
  final VoidCallback onPressed;
  final String text;
  final double? width ;
  final Color? backgroundcolor;
  final Color? textColor;
  final SvgPicture? image;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * width!,
      height: 44,
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: AppColors.primaryColor,
            ),
            borderRadius: BorderRadius.circular(
              8,
            ),
          ),
          backgroundColor: backgroundcolor ?? AppColors.primaryColor,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 11,
          children: [
            Text(
              text,
              style: textStyle ??
                  TextStyles.regular13.copyWith(
                    color: textColor ?? Colors.white,
                  ),
            ),
            image ?? const SizedBox(width: 0),
          ],
        ),
      ),
    );
  }
}
