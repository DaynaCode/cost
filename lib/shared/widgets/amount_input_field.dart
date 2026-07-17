import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/persian_number_formatter.dart';

class AmountInputField extends StatelessWidget {
  const AmountInputField({
    super.key,
    required this.controller,
    this.label = 'مبلغ',
    this.autofocus = false,
  });

  final TextEditingController controller;
  final String label;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.right,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹,]')),
        _ThousandsSeparatorFormatter(),
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'تومان',
      ),
      validator: (value) {
        final normalized =
            PersianNumberFormatter.toEnglishDigits(value ?? '')
                .replaceAll(',', '');
        if (normalized.isEmpty) return 'مبلغ را وارد کنید';
        final amount = num.tryParse(normalized);
        if (amount == null || amount <= 0) return 'مبلغ نامعتبر است';
        return null;
      },
    );
  }
}

double parseAmount(String value) {
  final normalized =
      PersianNumberFormatter.toEnglishDigits(value).replaceAll(',', '');
  return double.tryParse(normalized) ?? 0;
}

class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digitsOnly = PersianNumberFormatter.toEnglishDigits(newValue.text)
        .replaceAll(',', '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final number = int.tryParse(digitsOnly);
    if (number == null) return oldValue;

    final buffer = StringBuffer();
    final digits = number.toString();
    for (var i = 0; i < digits.length; i++) {
      final positionFromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
