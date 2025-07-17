import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/values/app_colors.dart';

class CustomFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final EdgeInsetsGeometry? contentPadding;
  final Widget? suffix;
  final Widget? prefix;
  final bool autofocus;
  final bool showCursor;
  final bool autocorrect;
  final bool enableSuggestions;
  final bool expands;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final String? initialValue;
  final bool filled;
  final Color? fillColor;
  final Color? cursorColor;
  final double? cursorHeight;
  final double? cursorWidth;
  final Radius? cursorRadius;
  final bool showCounter;
  final bool isDense;
  final bool isRequired;

  const CustomFormField({
    Key? key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.focusNode,
    this.textInputAction,
    this.contentPadding,
    this.suffix,
    this.prefix,
    this.autofocus = false,
    this.showCursor = true,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.expands = false,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.initialValue,
    this.filled = true,
    this.fillColor,
    this.cursorColor,
    this.cursorHeight,
    this.cursorWidth,
    this.cursorRadius,
    this.showCounter = false,
    this.isDense = false,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: enabled ? AppColors.textColor : AppColors.textLightColor,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: AppColors.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          onTap: onTap,
          focusNode: focusNode,
          textInputAction: textInputAction,
          autofocus: autofocus,
          showCursor: showCursor,
          autocorrect: autocorrect,
          enableSuggestions: enableSuggestions,
          expands: expands,
          textCapitalization: textCapitalization,
          textAlign: textAlign,
          textAlignVertical: textAlignVertical,
          cursorColor: cursorColor ?? AppColors.primaryColor,
          cursorHeight: cursorHeight,
          cursorWidth: cursorWidth ?? 2.0,
          cursorRadius: cursorRadius ?? Radius.circular(1.0),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : prefix,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixIconPressed,
                  )
                : suffix,
            contentPadding: contentPadding ??
                EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
            filled: filled,
            fillColor: fillColor ?? (enabled ? Colors.white : Colors.grey[100]),
            counterText: showCounter ? null : '',
            isDense: isDense,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.errorColor,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.errorColor,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.borderColor.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final bool isDense;
  final bool filled;
  final Color? fillColor;

  const CustomDropdownField({
    Key? key,
    required this.label,
    this.hint,
    required this.items,
    this.value,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.isDense = false,
    this.filled = true,
    this.fillColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: enabled ? AppColors.textColor : AppColors.textLightColor,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: AppColors.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          icon: suffixIcon ?? Icon(Icons.arrow_drop_down),
          isExpanded: true,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon,
            contentPadding: contentPadding ??
                EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
            filled: filled,
            fillColor: fillColor ?? (enabled ? Colors.white : Colors.grey[100]),
            isDense: isDense,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.errorColor,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.errorColor,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.borderColor.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomDateField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isRequired;
  final bool enabled;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime)? onDateSelected;
  final EdgeInsetsGeometry? contentPadding;
  final bool isDense;
  final bool filled;
  final Color? fillColor;

  const CustomDateField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.isRequired = false,
    this.enabled = true,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.contentPadding,
    this.isDense = false,
    this.filled = true,
    this.fillColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: enabled ? AppColors.textColor : AppColors.textLightColor,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: AppColors.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          readOnly: true,
          enabled: enabled,
          onTap: enabled
              ? () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: initialDate ?? DateTime.now(),
                    firstDate: firstDate ?? DateTime(2000),
                    lastDate: lastDate ?? DateTime(2100),
                  );
                  if (picked != null) {
                    controller.text = picked.toString().split(' ')[0];
                    if (onDateSelected != null) {
                      onDateSelected!(picked);
                    }
                  }
                }
              : null,
          decoration: InputDecoration(
            hintText: hint ?? 'Select date',
            prefixIcon: Icon(Icons.calendar_today),
            suffixIcon: Icon(Icons.arrow_drop_down),
            contentPadding: contentPadding ??
                EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
            filled: filled,
            fillColor: fillColor ?? (enabled ? Colors.white : Colors.grey[100]),
            isDense: isDense,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.errorColor,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.errorColor,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.borderColor.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomTimeField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool isRequired;
  final bool enabled;
  final TimeOfDay? initialTime;
  final void Function(TimeOfDay)? onTimeSelected;
  final EdgeInsetsGeometry? contentPadding;
  final bool isDense;
  final bool filled;
  final Color? fillColor;

  const CustomTimeField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.validator,
    this.isRequired = false,
    this.enabled = true,
    this.initialTime,
    this.onTimeSelected,
    this.contentPadding,
    this.isDense = false,
    this.filled = true,
    this.fillColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: enabled ? AppColors.textColor : AppColors.textLightColor,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  color: AppColors.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          readOnly: true,
          enabled: enabled,
          onTap: enabled
              ? () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: initialTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    controller.text = picked.format(context);
                    if (onTimeSelected != null) {
                      onTimeSelected!(picked);
                    }
                  }
                }
              : null,
          decoration: InputDecoration(
            hintText: hint ?? 'Select time',
            prefixIcon: Icon(Icons.access_time),
            suffixIcon: Icon(Icons.arrow_drop_down),
            contentPadding: contentPadding ??
                EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
            filled: filled,
            fillColor: fillColor ?? (enabled ? Colors.white : Colors.grey[100]),
            isDense: isDense,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.errorColor,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.errorColor,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.borderColor.withOpacity(0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CustomSearchField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onSearch;
  final bool autofocus;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final bool isDense;
  final bool filled;
  final Color? fillColor;

  const CustomSearchField({
    Key? key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onClear,
    this.onSearch,
    this.autofocus = false,
    this.focusNode,
    this.contentPadding,
    this.isDense = false,
    this.filled = true,
    this.fillColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      autofocus: autofocus,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hint ?? 'Search...',
        prefixIcon: Icon(Icons.search),
        suffixIcon: controller != null && controller!.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear),
                onPressed: () {
                  controller!.clear();
                  if (onClear != null) {
                    onClear!();
                  }
                },
              )
            : null,
        contentPadding: contentPadding ??
            EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
        filled: filled,
        fillColor: fillColor ?? Colors.white,
        isDense: isDense,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.borderColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.borderColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: AppColors.primaryColor,
            width: 2,
          ),
        ),
      ),
      textInputAction: TextInputAction.search,
      onFieldSubmitted: (_) {
        if (onSearch != null) {
          onSearch!();
        }
      },
    );
  }
}

