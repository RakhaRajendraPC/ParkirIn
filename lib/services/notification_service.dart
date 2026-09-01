import '../models/notification_model.dart';

class NotificationService {
  static List<AppNotification> getMockNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'n1',
        type: NotificationType.shuttleArriving,
        title: 'Shuttle Arriving Soon',
        description:
            'Shuttle Anda menuju Terminal 3 diperkirakan tiba dalam 5 menit. Mohon menuju titik jemput sekarang.',
        timestamp: now.subtract(const Duration(seconds: 30)),
        actionLabel: 'Lacak Shuttle',
        bookingCode: 'PKR-88213',
        isRead: false,
      ),
      AppNotification(
        id: 'n2',
        type: NotificationType.overstayWarning,
        title: 'Durasi Parkir Akan Berakhir',
        description:
            'Booking Anda akan melewati batas waktu dalam 2 jam. Perpanjang durasi sekarang untuk menghindari biaya overstay.',
        timestamp: now.subtract(const Duration(minutes: 45)),
        actionLabel: 'Perpanjang Durasi',
        bookingCode: 'PKR-88213',
        isRead: false,
      ),
      AppNotification(
        id: 'n3',
        type: NotificationType.checkinReminder,
        title: 'Check-in Besok',
        description:
            'Booking Anda di Soekarno-Hatta Park & Fly dimulai besok pukul 08.00. Siapkan QR Code untuk check-in.',
        timestamp: now.subtract(const Duration(hours: 2)),
        actionLabel: 'Lihat Booking',
        bookingCode: 'PKR-88213',
        isRead: false,
      ),
      AppNotification(
        id: 'n4',
        type: NotificationType.flightStatusChange,
        title: 'Jadwal Penerbangan Berubah',
        description:
            'Penerbangan GA-212 mengalami delay 1 jam menjadi 10.30. Waktu jemput shuttle telah disesuaikan otomatis.',
        timestamp: now.subtract(const Duration(hours: 5)),
        actionLabel: 'Lihat Detail',
        bookingCode: 'PKR-88213',
        isRead: true,
      ),
      AppNotification(
        id: 'n5',
        type: NotificationType.bookingConfirmation,
        title: 'Booking Berhasil Dikonfirmasi',
        description:
            'Slot parkir Anda di CGK - Soekarno Hatta Park & Fly (12-15 Okt) telah dikonfirmasi. Kode booking: PKR-88213.',
        timestamp: now.subtract(const Duration(days: 1)),
        actionLabel: 'Lihat QR Code',
        bookingCode: 'PKR-88213',
        isRead: true,
      ),
      AppNotification(
        id: 'n6',
        type: NotificationType.checkoutConfirmation,
        title: 'Kendaraan Berhasil Diambil',
        description:
            'Kendaraan Anda (B 1234 CD) telah berhasil check-out. Terima kasih telah menggunakan ParkirIn!',
        timestamp: now.subtract(const Duration(days: 2)),
        actionLabel: 'Lihat Invoice',
        bookingCode: 'PKR-88099',
        isRead: true,
      ),
    ];
  }
}
