import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/routes/app_routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_text_style.dart';
import 'app_button.dart';
import 'app_progress_indicator.dart';

class AppDialog {
  static Future<dynamic> show({
    String? title,
    Widget? child,
    String? text,
    EdgeInsets? padding,
    String? leftButtonText,
    String? rightButtonText,
    Function()? onTapLeftButton,
    Function()? onTapRightButton,
    bool? dismissible,
    bool? useRootContext,
    bool? showButtons,
    bool? enableRightButton,
    bool? enableLeftButton,
    Color? leftButtonColor,
    Color? leftButtonTextColor,
    Color? leftButtonBorderColor,
    Color? rightButtonColor,
    Color? rightButtonTextColor,
    Color? rightButtonBorderColor,
    double? elevation,
    double? maxWidth,
  }) async {
    return await showDialog(
      context: AppRoutes.rootNavigatorKey.currentState!.context,
      barrierDismissible: dismissible ?? true,
      builder: (context) {
        return PopScope(
          canPop: dismissible ?? true,
          child: AppDialogWidget(
            title: title,
            text: text,
            padding: padding,
            rightButtonText: rightButtonText,
            leftButtonText: leftButtonText,
            onTapLeftButton: onTapLeftButton,
            onTapRightButton: onTapRightButton,
            dismissible: dismissible ?? true,
            enableRightButton: enableRightButton ?? true,
            enableLeftButton: enableLeftButton ?? true,
            elevation: elevation,
            maxWidth: maxWidth,
            leftButtonColor: leftButtonColor,
            leftButtonTextColor: leftButtonTextColor,
            leftButtonBorderColor: leftButtonBorderColor,
            rightButtonColor: rightButtonColor,
            rightButtonTextColor: rightButtonTextColor,
            rightButtonBorderColor: rightButtonBorderColor,
            child: child,
          ),
        );
      },
    );
  }

  static Future<void> showErrorDialog({
    String? title,
    String? message,
    String? error,
    String buttonText = 'Close',
    Function()? onTapButton,
  }) async {
    return await showDialog(
      context: AppRoutes.router.configuration.navigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AppDialogWidget(
            title: title ?? 'Oops!',
            leftButtonText: buttonText,
            onTapLeftButton: onTapButton,
            child: Column(
              children: [
                Text(
                  message ??
                      'Something went wrong, please contact your system administrator or try restart the app',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.medium(size: 12),
                ),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSizes.padding),
                    child: Text(
                      error.toString().length > 100
                          ? error.toString().substring(0, 100)
                          : error.toString(),
                      textAlign: TextAlign.center,
                      style: AppTextStyle.semibold(
                        size: 10,
                        color: AppColors.blackLv4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> showDialogProgress({bool dismissible = false}) async {
    showDialog(
      context: AppRoutes.router.configuration.navigatorKey.currentContext!,
      builder: (context) {
        return AppDialogWidget(
          dismissible: kDebugMode ? true : dismissible,
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: const AppProgressIndicator(),
        );
      },
    );
  }

  static void closeDialog() {
    AppRoutes.router.configuration.navigatorKey.currentState?.pop();
  }
}

class AppDialogWidget extends StatelessWidget {
  final String? title;
  final Widget? child;
  final String? text;
  final EdgeInsets? padding;
  final String? leftButtonText;
  final String? rightButtonText;
  final bool dismissible;
  final bool enableRightButton;
  final bool enableLeftButton;
  final double? elevation;
  final double? maxWidth;
  final Color? backgroundColor;
  final Color? leftButtonColor;
  final Color? leftButtonTextColor;
  final Color? leftButtonBorderColor;
  final Color? rightButtonColor;
  final Color? rightButtonTextColor;
  final Color? rightButtonBorderColor;
  final Function()? onTapLeftButton;
  final Function()? onTapRightButton;

  const AppDialogWidget({
    super.key,
    this.title,
    this.child,
    this.text,
    this.padding,
    this.rightButtonText,
    this.leftButtonText,
    this.onTapLeftButton,
    this.onTapRightButton,
    this.dismissible = true,
    this.enableRightButton = true,
    this.enableLeftButton = true,
    this.elevation,
    this.maxWidth,
    this.backgroundColor,
    this.leftButtonColor,
    this.leftButtonTextColor,
    this.leftButtonBorderColor,
    this.rightButtonColor,
    this.rightButtonTextColor,
    this.rightButtonBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: dismissible,
      child: Dialog(
        elevation: elevation,
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radius),
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth ?? 512),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildTitle(context),
                _buildBody(context),
                _buildButtons(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    if (title == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.padding,
        AppSizes.padding * 2,
        AppSizes.padding,
        AppSizes.padding,
      ),
      child: Text(
        title!,
        textAlign: TextAlign.center,
        style: AppTextStyle.extraBold(size: 14),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(AppSizes.padding),
      child: text != null
          ? Text(
              text!,
              textAlign: TextAlign.center,
              style: AppTextStyle.semibold(size: 14),
            )
          : child ?? const SizedBox.shrink(),
    );
  }

  Widget _buildButtons(BuildContext context) {
    if (leftButtonText == null && rightButtonText == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.padding,
        AppSizes.padding / 4,
        AppSizes.padding,
        AppSizes.padding,
      ),
      child: Row(
        children: <Widget>[
          if (leftButtonText != null)
            Expanded(
              child: AppButton(
                text: leftButtonText!,
                buttonColor: leftButtonColor ?? Colors.white,
                borderColor:
                    leftButtonBorderColor ??
                    leftButtonTextColor ??
                    Colors.transparent,
                textColor: leftButtonTextColor ?? AppColors.blackLv1,
                onTap: () async {
                  if (enableLeftButton) {
                    if (onTapLeftButton != null) {
                      onTapLeftButton!();
                    } else {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ),
          if (leftButtonText != null && rightButtonText != null)
            const SizedBox(width: AppSizes.padding / 2),
          if (rightButtonText != null)
            Expanded(
              child: AppButton(
                text: rightButtonText!,
                buttonColor: rightButtonColor ?? Colors.white,
                borderColor:
                    rightButtonBorderColor ??
                    rightButtonTextColor ??
                    Colors.transparent,
                textColor: rightButtonTextColor ?? AppColors.blackLv1,
                onTap: () async {
                  if (enableRightButton) {
                    if (onTapRightButton != null) {
                      onTapRightButton!();
                    } else {
                      Navigator.of(context).pop();
                    }
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
