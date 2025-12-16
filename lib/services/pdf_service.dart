import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/stock_history.dart';
import '../models/financial_transaction.dart';

class PdfService {
  static Future<void> printStockReport({
    required List<Product> products,
    required List<StockHistory> stockHistory,
    required int stockIn,
    required int stockOut,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader('LAPORAN STOK', dateFormat.format(now)),
          pw.SizedBox(height: 20),
          
          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total Produk', '${products.length}'),
                _buildSummaryItem('Stok Masuk (7 hari)', '$stockIn'),
                _buildSummaryItem('Stok Keluar (7 hari)', '$stockOut'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Products Table
          pw.Text('Daftar Produk', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellHeight: 25,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
            },
            headers: ['Nama Produk', 'Kode', 'Harga', 'Stok', 'Status'],
            data: products.map((p) => [
              p.name,
              p.sku,
              _formatRupiah(p.price),
              '${p.stock}',
              p.isOutOfStock ? 'Habis' : (p.isLowStock ? 'Tipis' : 'Ada'),
            ]).toList(),
          ),
          pw.SizedBox(height: 20),
          
          // Recent Stock History
          pw.Text('Riwayat Stok Terbaru', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellHeight: 25,
            headers: ['Tanggal', 'Produk', 'Tipe', 'Jumlah'],
            data: stockHistory.take(20).map((h) => [
              DateFormat('dd/MM/yyyy').format(h.createdAt),
              h.productName,
              h.type == StockChangeType.add ? 'Masuk' : 'Keluar',
              '${h.type == StockChangeType.add ? '+' : '-'}${h.quantity}',
            ]).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static Future<void> printFinancialReport({
    required List<FinancialTransaction> transactions,
    required double totalIncome,
    required double totalExpense,
    required int year,
    required int month,
  }) async {
    final pdf = pw.Document();
    final monthFormat = DateFormat('MMMM yyyy', 'id_ID');
    final monthDate = DateTime(year, month);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader('LAPORAN KEUANGAN', monthFormat.format(monthDate)),
          pw.SizedBox(height: 20),
          
          // Summary
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Pemasukan:', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text(_formatRupiah(totalIncome), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Pengeluaran:', style: const pw.TextStyle(fontSize: 12)),
                    pw.Text(_formatRupiah(totalExpense), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
                  ],
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Laba/Rugi:', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                      _formatRupiah(totalIncome - totalExpense),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: (totalIncome - totalExpense) >= 0 ? PdfColors.green700 : PdfColors.red700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Transactions Table
          pw.Text('Detail Transaksi', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellHeight: 25,
            cellAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
              3: pw.Alignment.centerRight,
            },
            headers: ['Tanggal', 'Keterangan', 'Kategori', 'Jumlah'],
            data: transactions.map((t) => [
              DateFormat('dd/MM').format(t.createdAt),
              t.description,
              t.category,
              '${t.isIncome ? '+' : '-'}${_formatRupiah(t.amount)}',
            ]).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static Future<void> printCompleteReport({
    required List<Product> products,
    required List<StockHistory> stockHistory,
    required List<FinancialTransaction> transactions,
    required int stockIn,
    required int stockOut,
    required double totalIncome,
    required double totalExpense,
    required int year,
    required int month,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final monthFormat = DateFormat('MMMM yyyy', 'id_ID');
    final monthDate = DateTime(year, month);

    // Page 1: Stock Report
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader('LAPORAN LENGKAP - STOK', dateFormat.format(now)),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total Produk', '${products.length}'),
                _buildSummaryItem('Stok Masuk', '$stockIn'),
                _buildSummaryItem('Stok Keluar', '$stockOut'),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Daftar Produk', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellHeight: 25,
            headers: ['Nama Produk', 'Kode', 'Harga', 'Stok', 'Status'],
            data: products.map((p) => [p.name, p.sku, _formatRupiah(p.price), '${p.stock}', p.isOutOfStock ? 'Habis' : (p.isLowStock ? 'Tipis' : 'Ada')]).toList(),
          ),
        ],
      ),
    );

    // Page 2: Financial Report
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader('LAPORAN LENGKAP - KEUANGAN', monthFormat.format(monthDate)),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(8)),
            child: pw.Column(children: [
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Total Pemasukan:'), pw.Text(_formatRupiah(totalIncome), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
              ]),
              pw.SizedBox(height: 8),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Total Pengeluaran:'), pw.Text(_formatRupiah(totalExpense), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.red700)),
              ]),
              pw.Divider(),
              pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                pw.Text('Laba/Rugi:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text(_formatRupiah(totalIncome - totalExpense), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: (totalIncome - totalExpense) >= 0 ? PdfColors.green700 : PdfColors.red700)),
              ]),
            ]),
          ),
          pw.SizedBox(height: 20),
          pw.Text('Detail Transaksi', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
            cellHeight: 25,
            headers: ['Tanggal', 'Keterangan', 'Kategori', 'Jumlah'],
            data: transactions.map((t) => [DateFormat('dd/MM').format(t.createdAt), t.description, t.category, '${t.isIncome ? '+' : '-'}${_formatRupiah(t.amount)}']).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  static pw.Widget _buildHeader(String title, String date) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('TOKO KELONTONG', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text(date, style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
        pw.Divider(thickness: 2, color: PdfColors.green700),
      ],
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(value, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
      ],
    );
  }

  static String _formatRupiah(double value) {
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}
