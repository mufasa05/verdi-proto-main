import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Export service for all platform reporting dimensions:
/// - Analytics overview (KPIs, revenue trend)
/// - Order summaries
/// - Delivery performance
/// - Marketplace activity
class AnalyticsExportService {
  static final _dateStamp =
      DateFormat('yyyyMMdd_HHmm').format(DateTime.now());

  static Future<Directory> _getExportDirectory() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        return downloadDir;
      }
      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        return extDir;
      }
    }
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows || defaultTargetPlatform == TargetPlatform.macOS || defaultTargetPlatform == TargetPlatform.linux)) {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        return downloadsDir;
      }
    }
    if (kIsWeb) {
      return Directory('/tmp');
    }
    return await getApplicationDocumentsDirectory();
  }

  // ─── CSV helpers ────────────────────────────────────────────────

  static Future<File> exportCsv({
    required List<List<dynamic>> rows,
    String fileName = 'analytics_report.csv',
  }) async {
    final csvData = const ListToCsvConverter().convert(rows);
    final dir = await _getExportDirectory();
    final file = File('${dir.path}/$fileName');
    if (!kIsWeb) {
      await file.writeAsString(csvData);
    }
    return file;
  }

  // ─── Analytics Overview Export ───────────────────────────────────

  /// Exports a formatted CSV with the main KPI dashboard snapshot.
  static Future<File> exportAnalyticsCsv({
    required String timeframe,
    required String region,
    required String revenue,
    required String revenueChange,
    required String orders,
    required String ordersChange,
    required String buyers,
    required String buyersChange,
    required String fulfillment,
    required String fulfillmentChange,
    required List<List<dynamic>> topProductRows,
  }) async {
    final rows = [
      ['Verdi Platform — Analytics Report'],
      ['Generated', DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())],
      ['Timeframe', timeframe],
      ['Region', region],
      [],
      ['KPI Summary', '', ''],
      ['Metric', 'Value', 'Change'],
      ['Revenue', revenue, revenueChange],
      ['Orders', orders, ordersChange],
      ['Active Buyers', buyers, buyersChange],
      ['Order Fulfillment Rate', fulfillment, fulfillmentChange],
      [],
      ['Top Products', '', '', '', ''],
      ['Product', 'Category', 'Revenue', 'Order Count', 'Completion Rate'],
      ...topProductRows,
    ];
    return exportCsv(
      rows: rows,
      fileName: 'verdi_analytics_${timeframe.toLowerCase().replaceAll(' ', '_')}_$_dateStamp.csv',
    );
  }

  // ─── Order Summary Export ────────────────────────────────────────

  /// Exports a CSV of all orders with status, payment, and delivery info.
  static Future<File> exportOrderSummary({
    required List<Map<String, dynamic>> orders,
  }) async {
    final rows = [
      ['Verdi Platform — Order Summary Report'],
      ['Generated', DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())],
      [],
      ['Order ID', 'Buyer', 'Product', 'Quantity', 'Destination', 'Status', 'Payment', 'Total', 'Date', 'ETA', 'Priority'],
      ...orders.map((o) => [
            o['id'] ?? '',
            o['buyer'] ?? '',
            o['product'] ?? '',
            o['quantity'] ?? '',
            o['destination'] ?? '',
            o['status'] ?? '',
            o['payment'] ?? '',
            o['total'] ?? '',
            o['date'] ?? '',
            o['eta'] ?? '',
            o['priority'] ?? '',
          ]),
    ];
    return exportCsv(
      rows: rows,
      fileName: 'verdi_order_summary_$_dateStamp.csv',
    );
  }

  // ─── Delivery Performance Export ─────────────────────────────────

  /// Exports a CSV of all deliveries with timing and performance metrics.
  static Future<File> exportDeliveryPerformance({
    required List<Map<String, dynamic>> deliveries,
    required double onTimeRate,
    required String avgEta,
    required int deliveredToday,
    required int failedCount,
  }) async {
    final rows = [
      ['Verdi Platform — Delivery Performance Report'],
      ['Generated', DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())],
      [],
      ['Performance Summary', ''],
      ['On-Time Rate', '${(onTimeRate * 100).toStringAsFixed(1)}%'],
      ['Avg ETA Accuracy', avgEta],
      ['Delivered Today', deliveredToday.toString()],
      ['Failed / Cancelled', failedCount.toString()],
      [],
      ['Delivery ID', 'Customer', 'Product', 'From', 'To', 'Driver', 'Vehicle', 'Status', 'ETA', 'Progress %'],
      ...deliveries.map((d) => [
            d['id'] ?? '',
            d['customer'] ?? '',
            d['product'] ?? '',
            d['from'] ?? '',
            d['to'] ?? '',
            d['driver'] ?? '',
            d['vehicle'] ?? '',
            d['status'] ?? '',
            d['eta'] ?? '',
            '${((d['progress'] as double? ?? 0.0) * 100).round()}%',
          ]),
    ];
    return exportCsv(
      rows: rows,
      fileName: 'verdi_delivery_performance_$_dateStamp.csv',
    );
  }

  // ─── Marketplace Activity Export ─────────────────────────────────

  /// Exports marketplace crop volumes, demand, and revenue by category.
  static Future<File> exportMarketplaceActivity({
    required List<Map<String, dynamic>> products,
    required String timeframe,
    required String region,
  }) async {
    final rows = [
      ['Verdi Platform — Marketplace Activity Report'],
      ['Generated', DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())],
      ['Timeframe', timeframe],
      ['Region', region],
      [],
      ['Product', 'Category', 'Volume (kg)', 'Revenue (USD)', 'Orders', 'Completion Rate', 'Trend'],
      ...products.map((p) => [
            p['name'] ?? '',
            p['category'] ?? '',
            p['volume'] ?? '',
            p['revenue'] ?? '',
            p['orders'] ?? '',
            p['completion'] ?? '',
            p['trend'] ?? '',
          ]),
    ];
    return exportCsv(
      rows: rows,
      fileName: 'verdi_marketplace_activity_$_dateStamp.csv',
    );
  }

  // ─── Full Platform PDF Report ─────────────────────────────────────

  /// Generates a comprehensive multi-section PDF report for executive review.
  static Future<File> exportFullPdfReport({
    required String title,
    required String timeframe,
    required String region,
    required List<String> kpiLines,
    required List<String> deliveryLines,
    required List<String> marketplaceLines,
    String fileName = 'verdi_platform_report.pdf',
  }) async {
    final pdf = pw.Document();
    final now = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now());

    pw.Widget sectionHeader(String text) => pw.Padding(
          padding: const pw.EdgeInsets.only(top: 18, bottom: 6),
          child: pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
        );

    pw.Widget line(String text) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 5),
          child: pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
        );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Header
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green900,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Generated: $now  |  Period: $timeframe  |  Region: $region',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.Divider(color: PdfColors.green400, thickness: 1.5),
          pw.SizedBox(height: 8),

          // KPI Summary
          sectionHeader('📊  Platform KPI Summary'),
          ...kpiLines.map(line),

          // Delivery Performance
          sectionHeader('🚚  Delivery Performance'),
          ...deliveryLines.map(line),

          // Marketplace Activity
          sectionHeader('🛒  Marketplace Activity'),
          ...marketplaceLines.map(line),

          // Footer
          pw.SizedBox(height: 24),
          pw.Divider(color: PdfColors.grey400),
          pw.Text(
            'Verdi Agricultural Value Chain Platform  •  Confidential  •  Official Platform Audit Report',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    final dir = await _getExportDirectory();
    final outputName = fileName.replaceAll('.pdf', '_$_dateStamp.pdf');
    final file = File('${dir.path}/$outputName');
    if (!kIsWeb) {
      await file.writeAsBytes(bytes);
    }
    return file;
  }

  // ─── Legacy compat ────────────────────────────────────────────────

  /// Original simple PDF export (kept for backward compatibility).
  static Future<File> exportPdf({
    required String title,
    required List<String> summaryLines,
    String fileName = 'analytics_report.pdf',
  }) async {
    return exportFullPdfReport(
      title: title,
      timeframe: 'Custom',
      region: 'All Regions',
      kpiLines: summaryLines,
      deliveryLines: [],
      marketplaceLines: [],
      fileName: fileName,
    );
  }
}