import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_text_style.dart';

class AppButton extends StatelessWidget {
  final double? width;
  final double? height;
  final double fontSize;
  final BorderRadius? borderRadius;
  final EdgeInsets padding;
  final bool enabled;
  final bool showBorder;
  final String? text;
  final Color? buttonColor;
  final Color? disabledButtonColor;
  final Color? borderColor;
  final Color? textColor;
  final Widget? child;
  final Alignment? alignment;
  final Function()? onTap;

  const AppButton({
    super.key,
    this.width,
    this.height,
    this.fontSize = 14,
    this.borderRadius,
    this.padding = const EdgeInsets.all(AppSizes.padding),
    this.enabled = true,
    this.showBorder = true,
    this.buttonColor,
    this.disabledButtonColor,
    this.borderColor,
    this.textColor,
    this.child,
    this.alignment = Alignment.center,
    this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Material(
        borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radius),
        child: InkWell(
          onTap: enabled ? onTap : null,
          splashFactory: InkRipple.splashFactory,
          borderRadius: borderRadius ?? BorderRadius.circular(AppSizes.radius),
          child: Ink(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: enabled
                  ? buttonColor ?? AppColors.tangerineLv1
                  : disabledButtonColor ?? AppColors.blackLv5,
              borderRadius:
                  borderRadius ?? BorderRadius.circular(AppSizes.radius),
              border: showBorder
                  ? Border.all(
                      width: 1,
                      color: enabled
                          ? borderColor ?? buttonColor ?? AppColors.blackLv1
                          : disabledButtonColor ?? AppColors.blackLv3,
                    )
                  : null,
            ),
            child: alignment != null
                ? Align(alignment: alignment!, child: buttonChild(context))
                : buttonChild(context),
          ),
        ),
      ),
    );
  }

  Widget buttonChild(BuildContext context) {
    return child ??
        Text(
          text ?? '',
          overflow: TextOverflow.ellipsis,
          style: AppTextStyle.extraBold(
            size: fontSize,
            color: enabled
                ? textColor ?? AppColors.blackLv1
                : AppColors.blackLv2,
          ),
        );
  }
}
