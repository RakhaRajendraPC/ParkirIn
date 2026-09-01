import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/booking_model.dart';
import 'package:intl/intl.dart';

class ReceiptGenerator {
  static final _fmt = NumberFormat.decimalPattern('id_ID');

  static Future<void> shareOrPrintReceipt(BookingModel booking) async {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Text(
                'ParkirIn',
                style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#1E5EFF')),
              ),
            ),
            pw.Center(
              child: pw.Text('Struk Booking Parkir Inap Bandara',
                  style: const pw.TextStyle(
                      fontSize: 10, color: PdfColors.grey700)),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 8),
            pw.Center(
              child: pw.Column(
                children: [
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: booking.bookingCode,
                    width: 140,
                    height: 140,
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(booking.bookingCode,
                      style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          letterSpacing: 1.5)),
                  pw.Text('Tunjukkan QR ini saat check-in & check-out',
                      style: const pw.TextStyle(
                          fontSize: 9, color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Divider(),
            pw.SizedBox(height: 8),
            _kv('Lokasi', booking.locationName),
            _kv('Alamat', booking.locationAddress),
            _kv('Check-in', _fmtDate(booking.checkIn)),
            _kv('Check-out', _fmtDate(booking.checkOut)),
            _kv('Durasi', '${booking.durationNights} malam'),
            _kv('Plat Kendaraan', booking.vehiclePlate),
            if (booking.slotCode.isNotEmpty)
              _kv('Slot Parkir', booking.slotCode),
            pw.SizedBox(height: 8),
            pw.Divider(),
            pw.SizedBox(height: 8),
            _kv('Tarif Dasar', 'Rp ${_fmt.format(booking.subtotal)}'),
            _kv('Biaya Layanan', 'Rp ${_fmt.format(booking.serviceFee)}'),
            if (booking.overstayFee > 0)
              _kv('Biaya Overstay', 'Rp ${_fmt.format(booking.overstayFee)}'),
            pw.SizedBox(height: 6),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL',
                    style: pw.TextStyle(
                        fontSize: 13, fontWeight: pw.FontWeight.bold)),
                pw.Text('Rp ${_fmt.format(booking.total)}',
                    style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#1E5EFF'))),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Center(
              child: pw.Text(
                'Terima kasih telah menggunakan ParkirIn',
                style:
                    const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.sharePdf(
        bytes: await doc.save(), filename: 'Struk_${booking.bookingCode}.pdf');
  }

  static pw.Widget _kv(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label,
              style:
                  const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Text(value,
              style:
                  pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static String _fmtDate(DateTime d) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month]} ${d.year}, $hh:$mm';
  }
}
