import 'package:shamsi_date/shamsi_date.dart';

import 'persian_number_formatter.dart';

class PersianDateFormatter {
  const PersianDateFormatter._();

  static const _monthNames = [
    'فروردین',
    'اردیبهشت',
    'خرداد',
    'تیر',
    'مرداد',
    'شهریور',
    'مهر',
    'آبان',
    'آذر',
    'دی',
    'بهمن',
    'اسفند',
  ];

  static const _weekDayNames = [
    'شنبه',
    'یکشنبه',
    'دوشنبه',
    'سه شنبه',
    'چهارشنبه',
    'پنجشنبه',
    'جمعه',
  ];

  static Jalali toJalali(DateTime dateTime) => Jalali.fromDateTime(dateTime);

  static String monthName(int month) => _monthNames[month - 1];

  static String formatFull(DateTime dateTime) {
    final jalali = toJalali(dateTime);
    final weekDay = _weekDayNames[jalali.weekDay - 1];
    final text =
        '$weekDay ${jalali.day} ${_monthNames[jalali.month - 1]} ${jalali.year}';
    return PersianNumberFormatter.toPersianDigits(text);
  }

  static String formatDate(DateTime dateTime) {
    final jalali = toJalali(dateTime);
    final text =
        '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/${jalali.day.toString().padLeft(2, '0')}';
    return PersianNumberFormatter.toPersianDigits(text);
  }

  static String formatDateShort(DateTime dateTime) {
    final jalali = toJalali(dateTime);
    final text = '${jalali.day} ${_monthNames[jalali.month - 1]}';
    return PersianNumberFormatter.toPersianDigits(text);
  }

  static String formatDateTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '${formatDate(dateTime)} - ${PersianNumberFormatter.toPersianDigits('$hour:$minute')}';
  }

  static String currentMonthName(DateTime dateTime) {
    final jalali = toJalali(dateTime);
    return PersianNumberFormatter.toPersianDigits(
        '${_monthNames[jalali.month - 1]} ${jalali.year}');
  }

  static DateTime startOfJalaliMonth(DateTime dateTime) {
    final jalali = toJalali(dateTime);
    return Jalali(jalali.year, jalali.month, 1).toDateTime();
  }

  static DateTime endOfJalaliMonth(DateTime dateTime) {
    final jalali = toJalali(dateTime);
    final daysInMonth = jalali.monthLength;
    return Jalali(jalali.year, jalali.month, daysInMonth)
        .toDateTime()
        .add(const Duration(hours: 23, minutes: 59, seconds: 59));
  }

  static DateTime startOfJalaliYear(DateTime dateTime) {
    final jalali = toJalali(dateTime);
    return Jalali(jalali.year, 1, 1).toDateTime();
  }

  static DateTime startOfWeek(DateTime dateTime) {
    final jalali = toJalali(dateTime);
    final offset = jalali.weekDay - 1;
    return jalali
        .addDays(-offset)
        .toDateTime()
        .copyWith(hour: 0, minute: 0, second: 0);
  }
}

extension on DateTime {
  DateTime copyWith({int? hour, int? minute, int? second}) {
    return DateTime(year, month, day, hour ?? this.hour, minute ?? this.minute,
        second ?? this.second);
  }
}
