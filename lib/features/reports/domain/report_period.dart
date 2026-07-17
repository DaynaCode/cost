enum ReportPeriod { daily, weekly, monthly, yearly }

extension ReportPeriodX on ReportPeriod {
  String get label {
    switch (this) {
      case ReportPeriod.daily:
        return 'روزانه';
      case ReportPeriod.weekly:
        return 'هفتگی';
      case ReportPeriod.monthly:
        return 'ماهانه';
      case ReportPeriod.yearly:
        return 'سالانه';
    }
  }
}
