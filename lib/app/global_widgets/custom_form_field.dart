import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../core/values/app_colors.dart';

class CustomFormField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefix;
  final Widget? suffix;
  final String? prefixText;
  final String? suffixText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final EdgeInsetsGeometry? contentPadding;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final bool filled;
  final Color? fillColor;
  final FocusNode? focusNode;
  
  const CustomFormField({
    Key? key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefix,
    this.suffix,
    this.prefixText,
    this.suffixText,
    this.validator,
    this.onChanged,
    this.onTap,
    this.inputFormatters,
    this.contentPadding,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.filled = true,
    this.fillColor,
    this.focusNode,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          initialValue: initialValue,
          keyboardType: keyboardType,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          autofocus: autofocus,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          validator: validator,
          onChanged: onChanged,
          onTap: onTap,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          textAlign: textAlign,
          focusNode: focusNode,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefix,
            suffixIcon: suffix,
            prefixText: prefixText,
            suffixText: suffixText,
            contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: filled,
            fillColor: fillColor ?? (Theme.of(context).brightness == Brightness.light ? Colors.white : AppColors.darkSurfaceColor),
          ),
        ),
      ],
    );
  }
}

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final String? hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool filled;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final bool enabled;
  
  const CustomDropdownField({
    Key? key,
    required this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.filled = true,
    this.fillColor,
    this.contentPadding,
    this.enabled = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: filled,
            fillColor: fillColor ?? (Theme.of(context).brightness == Brightness.light ? Colors.white : AppColors.darkSurfaceColor),
          ),
          isExpanded: true,
        ),
      ],
    );
  }
}

class CustomDateField extends StatelessWidget {
  final String label;
  final String? hint;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final TextEditingController controller;
  final void Function(DateTime)? onDateSelected;
  final String? Function(String?)? validator;
  final bool enabled;
  final String format;
  
  const CustomDateField({
    Key? key,
    required this.label,
    this.hint,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    required this.controller,
    this.onDateSelected,
    this.validator,
    this.enabled = true,
    this.format = 'dd/MM/yyyy',
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CustomFormField(
      label: label,
      hint: hint,
      controller: controller,
      readOnly: true,
      enabled: enabled,
      validator: validator,
      suffix: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
      onTap: enabled ? () async {
        final DateTime now = DateTime.now();
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: initialDate ?? now,
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime(2100),
        );
        
        if (picked != null) {
          controller.text = DateFormat(format).format(picked);
          if (onDateSelected != null) {
            onDateSelected!(picked);
          }
        }
      } : null,
    );
  }
}

class CustomTimeField extends StatelessWidget {
  final String label;
  final String? hint;
  final TimeOfDay? initialTime;
  final TextEditingController controller;
  final void Function(TimeOfDay)? onTimeSelected;
  final String? Function(String?)? validator;
  final bool enabled;
  final String format;
  
  const CustomTimeField({
    Key? key,
    required this.label,
    this.hint,
    this.initialTime,
    required this.controller,
    this.onTimeSelected,
    this.validator,
    this.enabled = true,
    this.format = 'HH:mm',
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CustomFormField(
      label: label,
      hint: hint,
      controller: controller,
      readOnly: true,
      enabled: enabled,
      validator: validator,
      suffix: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
      onTap: enabled ? () async {
        final TimeOfDay now = TimeOfDay.now();
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: initialTime ?? now,
        );
        
        if (picked != null) {
          final DateTime dateTime = DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
            picked.hour,
            picked.minute,
          );
          
          controller.text = DateFormat(format).format(dateTime);
          if (onTimeSelected != null) {
            onTimeSelected!(picked);
          }
        }
      } : null,
    );
  }
}

class CustomSearchField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final void Function()? onClear;
  final bool autofocus;
  
  const CustomSearchField({
    Key? key,
    required this.hint,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      autofocus: autofocus,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  controller.clear();
                  if (onClear != null) {
                    onClear!();
                  }
                  if (onChanged != null) {
                    onChanged!('');
                  }
                },
              )
            : null,
        filled: true,
        fillColor: Theme.of(context).brightness == Brightness.light
            ? Colors.white
            : AppColors.darkSurfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
        ),
      ),
    );
  }
}

class CustomNumberField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final Widget? prefix;
  final Widget? suffix;
  final String? prefixText;
  final String? suffixText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final int? maxLength;
  final bool allowDecimal;
  final bool allowNegative;
  final int decimalPlaces;
  
  const CustomNumberField({
    Key? key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.prefix,
    this.suffix,
    this.prefixText,
    this.suffixText,
    this.validator,
    this.onChanged,
    this.onTap,
    this.maxLength,
    this.allowDecimal = true,
    this.allowNegative = false,
    this.decimalPlaces = 2,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return CustomFormField(
      label: label,
      hint: hint,
      initialValue: initialValue,
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(
        decimal: allowDecimal,
        signed: allowNegative,
      ),
      readOnly: readOnly,
      enabled: enabled,
      autofocus: autofocus,
      prefix: prefix,
      suffix: suffix,
      prefixText: prefixText,
      suffixText: suffixText,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      maxLength: maxLength,
      inputFormatters: [
        if (allowDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\-?\d*\.?\d{0,' + decimalPlaces.toString() + r'}'))
        else
          FilteringTextInputFormatter.digitsOnly,
        if (!allowNegative)
          FilteringTextInputFormatter.deny(RegExp(r'^-')),
      ],
    );
  }
}

