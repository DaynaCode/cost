class PersianNumberFormatter {
  const PersianNumberFormatter._();

  static const _englishDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  static const _persianDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

  static String toPersianDigits(String input) {
    var result = input;
    for (var i = 0; i < _englishDigits.length; i++) {
      result = result.replaceAll(_englishDigits[i], _persianDigits[i]);
    }
    return result;
  }

  static String toEnglishDigits(String input) {
    var result = input;
    for (var i = 0; i < _persianDigits.length; i++) {
      result = result.replaceAll(_persianDigits[i], _englishDigits[i]);
    }
    return result;
  }

  static String formatAmount(num amount) {
    final rounded = amount.round();
    final isNegative = rounded < 0;
    final digits = rounded.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final positionFromEnd = digits.length - i;
      buffer.write(digits[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    final formatted = '${isNegative ? '-' : ''}${buffer.toString()}';
    return toPersianDigits(formatted);
  }

  static String formatCurrency(num amount) {
    return '${formatAmount(amount)} تومان';
  }
}
