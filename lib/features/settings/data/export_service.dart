import 'dart:io';

import 'package:csv/csv.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/persian_date_formatter.dart';
import '../../../core/utils/persian_number_formatter.dart';
import '../../../shared/models/transaction_type.dart';

class ExportService {
  Future<File> exportCsv({
    required List<TransactionData> transactions,
    required Map<String, CategoryData> categoriesById,
    required Map<String, AccountData> accountsById,
  }) async {
    final rows = <List<String>>[
      ['عنوان', 'مبلغ', 'نوع', 'دسته بندی', 'حساب', 'تاریخ', 'توضیحات'],
      for (final tx in transactions)
        [
          tx.title,
          tx.amount.toStringAsFixed(0),
          TransactionTypeX.fromStorage(tx.type).label,
          categoriesById[tx.categoryId]?.name ?? '',
          accountsById[tx.accountId]?.name ?? '',
          PersianDateFormatter.formatDate(tx.date),
          tx.description,
        ],
    ];

    final csvData = const ListToCsvConverter().convert(rows);
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/transactions-${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString('﻿$csvData', encoding: SystemEncoding());
    return file;
  }

  Future<File> exportExcel({
    required List<TransactionData> transactions,
    required Map<String, CategoryData> categoriesById,
    required Map<String, AccountData> accountsById,
  }) async {
    final workbook = excel_lib.Excel.createExcel();
    final sheet = workbook['تراکنش ها'];
    workbook.setDefaultSheet('تراکنش ها');

    sheet.appendRow([
      excel_lib.TextCellValue('عنوان'),
      excel_lib.TextCellValue('مبلغ'),
      excel_lib.TextCellValue('نوع'),
      excel_lib.TextCellValue('دسته بندی'),
      excel_lib.TextCellValue('حساب'),
      excel_lib.TextCellValue('تاریخ'),
      excel_lib.TextCellValue('توضیحات'),
    ]);

    for (final tx in transactions) {
      sheet.appendRow([
        excel_lib.TextCellValue(tx.title),
        excel_lib.DoubleCellValue(tx.amount),
        excel_lib.TextCellValue(TransactionTypeX.fromStorage(tx.type).label),
        excel_lib.TextCellValue(categoriesById[tx.categoryId]?.name ?? ''),
        excel_lib.TextCellValue(accountsById[tx.accountId]?.name ?? ''),
        excel_lib.TextCellValue(PersianDateFormatter.formatDate(tx.date)),
        excel_lib.TextCellValue(tx.description),
      ]);
    }

    final bytes = workbook.encode();
    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/transactions-${DateTime.now().millisecondsSinceEpoch}.xlsx');
    await file.writeAsBytes(bytes!);
    return file;
  }

  Future<File> exportPdf({
    required List<TransactionData> transactions,
    required Map<String, CategoryData> categoriesById,
    required Map<String, AccountData> accountsById,
  }) async {
    final fontData =
        await rootBundle.load('assets/fonts/Vazirmatn-Regular.ttf');
    final boldFontData =
        await rootBundle.load('assets/fonts/Vazirmatn-Bold.ttf');
    final persianFont = pw.Font.ttf(fontData);
    final persianBoldFont = pw.Font.ttf(boldFontData);

    final document = pw.Document(
      theme: pw.ThemeData.withFont(base: persianFont, bold: persianBoldFont),
    );

    document.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          pw.Header(text: 'گزارش تراکنش ها'),
          pw.Table.fromTextArray(
            headers: ['عنوان', 'مبلغ', 'نوع', 'دسته بندی', 'تاریخ'],
            data: [
              for (final tx in transactions)
                [
                  tx.title,
                  PersianNumberFormatter.formatAmount(tx.amount),
                  TransactionTypeX.fromStorage(tx.type).label,
                  categoriesById[tx.categoryId]?.name ?? '',
                  PersianDateFormatter.formatDate(tx.date),
                ],
            ],
          ),
        ],
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final file = File(
        '${directory.path}/transactions-${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await document.save());
    return file;
  }

  Future<void> shareFile(File file) async {
    await Share.shareXFiles([XFile(file.path)]);
  }
}
