import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/values/app_colors.dart';

class CustomFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool obscureText;
  final bool readOnly;
  final TextInputType keyboardType;
  final int? maxLines;
  final int? minLines;
  final Widget? prefix;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool autofocus;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  
  const CustomFormField({
    Key? key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines,
    this.prefix,
    this.suffix,
    this.validator,
    this.onChanged,
    this.onTap,
    this.autofocus = false,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: minLines,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      autofocus: autofocus,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefix,
        suffixIcon: suffix,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class CustomSearchField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final void Function()? onClear;
  final bool autofocus;
  final FocusNode? focusNode;
  
  const CustomSearchField({
    Key? key,
    required this.hint,
    required this.controller,
    this.onChanged,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      autofocus: autofocus,
      focusNode: focusNode,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            controller.clear();
            if (onClear != null) {
              onClear!();
            }
          },
        ),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class CustomDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isExpanded;
  final bool enabled;
  
  const CustomDropdownField({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.isExpanded = true,
    this.enabled = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      validator: validator,
      isExpanded: isExpanded,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}

class CustomDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(DateTime?)? onDateSelected;
  final bool enabled;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  
  const CustomDateField({
    Key? key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.onDateSelected,
    this.enabled = true,
    this.initialDate,
    this.firstDate,
    this.lastDate,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: const Icon(Icons.calendar_today),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onTap: enabled
          ? () async {
              final DateTime now = DateTime.now();
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: initialDate ?? now,
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
    );
  }
}

class CustomTimeField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(TimeOfDay?)? onTimeSelected;
  final bool enabled;
  final TimeOfDay? initialTime;
  
  const CustomTimeField({
    Key? key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.onTimeSelected,
    this.enabled = true,
    this.initialTime,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: const Icon(Icons.access_time),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onTap: enabled
          ? () async {
              final TimeOfDay now = TimeOfDay.now();
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: initialTime ?? now,
              );
              
              if (picked != null) {
                controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                if (onTimeSelected != null) {
                  onTimeSelected!(picked);
                }
              }
            }
          : null,
    );
  }
}

class CustomNumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final bool enabled;
  final String? suffixText;
  final int? maxLength;
  final bool allowDecimal;
  
  const CustomNumberField({
    Key? key,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.enabled = true,
    this.suffixText,
    this.maxLength,
    this.allowDecimal = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      readOnly: readOnly,
      enabled: enabled,
      validator: validator,
      onChanged: onChanged,
      maxLength: maxLength,
      inputFormatters: [
        if (allowDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixText: suffixText,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        counterText: '',
      ),
    );
  }
}

