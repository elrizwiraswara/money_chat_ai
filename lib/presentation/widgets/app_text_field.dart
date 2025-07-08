import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/locale/app_locale.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_sizes.dart';
import '../../app/theme/app_text_style.dart';
import 'app_icon_button.dart';

enum AppTextFieldType { general, search, currency }

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool enabled;
  final bool autofocus;
  final bool obscureText;
  final double fontSize;
  final int? minLines;
  final int maxLines;
  final int? maxLength;
  final Color fillColor;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? hintText;
  final String? labelText;
  final Widget? prefixWidget;
  final Widget? suffixWidget;
  final EdgeInsets contentPadding;
  final Function(String text)? onChanged;
  final Function()? onEditingComplete;
  final Function()? onTapClearButton;
  final List<TextInputFormatter>? inputFormatters;
  final bool showCounter;
  final bool showBorder;
  final AppTextFieldType type;

  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.enabled = true,
    this.autofocus = false,
    this.obscureText = false,
    this.fontSize = 12,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.fillColor = AppColors.white,
    this.keyboardType,
    this.textInputAction,
    this.hintText,
    this.labelText,
    this.prefixWidget,
    this.suffixWidget,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: AppSizes.padding,
      vertical: AppSizes.padding * 1.2,
    ),
    this.onChanged,
    this.onEditingComplete,
    this.onTapClearButton,
    this.inputFormatters,
    this.showCounter = false,
    this.showBorder = false,
    this.type = AppTextFieldType.general,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    textEditingController = widget.controller ?? TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.labelText != null && widget.labelText != '')
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                widget.labelText!,
                style: AppTextStyle.bold(size: widget.fontSize),
              ),
            ),
          TextField(
            controller: textEditingController,
            focusNode: widget.focusNode,
            onChanged: onChanged,
            onEditingComplete: widget.onEditingComplete,
            enabled: widget.enabled,
            style: AppTextStyle.semibold(size: 12),
            cursorColor: Theme.of(context).colorScheme.primary,
            cursorWidth: 1.5,
            autofocus: widget.autofocus,
            obscureText: widget.obscureText,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            maxLengthEnforcement: MaxLengthEnforcement.enforced,
            keyboardType: textInputType(),
            textInputAction: textInputAction(),
            inputFormatters: inputFormatters(),
            decoration: InputDecoration(
              counterText: widget.showCounter ? null : '',
              isDense: true,
              filled: true,
              fillColor: widget.fillColor,
              prefixIcon: prefix(context),
              suffixIcon: suffix(context),
              hintText: widget.hintText,
              hintStyle: AppTextStyle.medium(
                size: 12,
                color: AppColors.blackLv3,
              ),
              hoverColor: Colors.transparent,
              contentPadding: widget.contentPadding,
              focusedBorder: widget.showBorder
                  ? OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppSizes.radius),
                      ),
                      borderSide: BorderSide.none,
                    )
                  : InputBorder.none,
              enabledBorder: widget.showBorder
                  ? OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppSizes.radius),
                      ),
                      borderSide: BorderSide.none,
                    )
                  : InputBorder.none,
              disabledBorder: widget.showBorder
                  ? OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppSizes.radius),
                      ),
                      borderSide: BorderSide.none,
                    )
                  : InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  void onChanged(String val) {
    if (widget.onChanged != null) {
      widget.onChanged!(val);
    }

    setState(() {});
  }

  Widget? prefix(BuildContext context) {
    if (widget.prefixWidget != null) {
      return widget.prefixWidget!;
    }

    if (widget.type == AppTextFieldType.currency) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.padding,
          AppSizes.padding,
          AppSizes.padding / 2,
          AppSizes.padding,
        ),
        child: Text(
          AppLocale.defaultCurrencyCode,
          textAlign: TextAlign.center,
          style: AppTextStyle.semibold(size: 11),
        ),
      );
    }

    if (widget.type == AppTextFieldType.search) {
      return Icon(Icons.search, color: AppColors.blackLv1);
    }

    return null;
  }

  Widget? suffix(BuildContext context) {
    if (widget.suffixWidget != null) {
      return widget.suffixWidget!;
    }

    if (widget.type == AppTextFieldType.search) {
      return textEditingController.text.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(AppSizes.padding / 2),
              child: AppIconButton(
                icon: Icons.clear_rounded,
                padding: EdgeInsets.zero,
                onTap: () {
                  textEditingController.clear();

                  if (widget.onTapClearButton != null) {
                    widget.onTapClearButton!();
                  }

                  setState(() {});
                },
              ),
            )
          : null;
    }

    return null;
  }

  TextInputType? textInputType() {
    if (widget.keyboardType != null) {
      return widget.keyboardType!;
    }

    if (widget.type == AppTextFieldType.currency) {
      return TextInputType.number;
    }

    return null;
  }

  List<TextInputFormatter>? inputFormatters() {
    if (widget.inputFormatters != null) {
      return widget.inputFormatters!;
    }

    if (widget.type == AppTextFieldType.currency) {
      return [FilteringTextInputFormatter.digitsOnly];
    }

    return null;
  }

  TextInputAction? textInputAction() {
    if (widget.textInputAction != null) {
      return widget.textInputAction!;
    }

    if (widget.type == AppTextFieldType.search) {
      return TextInputAction.search;
    }

    return null;
  }
}
