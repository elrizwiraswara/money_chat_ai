import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class AppIconButton extends StatelessWidget {
  final double? width;
  final double? height;
  final double? iconSize;
  final EdgeInsets padding;
  final bool enabled;
  final bool showBorder;
  final double borderRadius;
  final IconData icon;
  final Function() onTap;

  const AppIconButton({
    super.key,
    this.width,
    this.height,
    this.iconSize,
    this.padding = const EdgeInsets.all(6),
    this.enabled = true,
    this.showBorder = true,
    this.borderRadius = 100,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        splashFactory: InkRipple.splashFactory,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: enabled ? AppColors.blackLv6 : AppColors.blackLv4,
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder
                ? Border.all(
                    width: 1,
                    color: enabled ? AppColors.blackLv1 : AppColors.blackLv4,
                  )
                : null,
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: enabled ? AppColors.blackLv1 : AppColors.blackLv3,
          ),
        ),
      ),
    );
  }
}
