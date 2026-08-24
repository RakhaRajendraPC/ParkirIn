// lib/models/ground_transport_model.dart
import 'package:flutter/material.dart';

enum TransportCategory {
  minibusTravel,
  taxi,
  bus,
  onlineTransport,
  carRental,
  airportTrain
}

class TransportOperator {
  final String name;
  final String? appScheme; // deep link scheme, khusus onlineTransport
  final String? webFallback; // url website/pencarian sebagai fallback

  const TransportOperator(
      {required this.name, this.appScheme, this.webFallback});
}

class GroundTransportInfo {
  final TransportCategory category;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<TransportOperator> operators;
  final String priceRange;
  final String operatingHours;
  final List<String> pickupPoints;
  final String destinationNote;
  final String? extraNote;

  const GroundTransportInfo({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.operators,
    required this.priceRange,
    required this.operatingHours,
    required this.pickupPoints,
    required this.destinationNote,
    this.extraNote,
  });
}

/// Data moda transportasi lanjutan dari Bandara Soekarno-Hatta.
/// Di production: pindahkan ke backend/CMS supaya harga & operator bisa
/// diperbarui tanpa rilis ulang aplikasi.
class GroundTransportData {
  static const List<GroundTransportInfo> all = [
    GroundTransportInfo(
      category: TransportCategory.minibusTravel,
      title: 'Minibus / Travel',
      subtitle: 'Cocok untuk tujuan Bandung dan sekitarnya',
      icon: Icons.airport_shuttle,
      color: Color(0xFF1E5EFF),
      operators: [
        TransportOperator(name: 'Bhinneka Shuttle'),
        TransportOperator(name: 'Citi Trans'),
        TransportOperator(name: 'Jackal Holiday'),
        TransportOperator(name: 'Lintas Shuttle'),
        TransportOperator(name: 'Primajasa Shuttle'),
        TransportOperator(name: 'Sinar Shuttle'),
      ],
      priceRange: 'Rp185.000 – Rp210.000',
      operatingHours: '07.00 – 24.00 WIB',
      pickupPoints: [
        'Shelter Bus',
        'Terminal 1A',
        'Terminal 2',
        'Terminal 2F',
        'Terminal 3 Domestik',
        'Terminal 3 Internasional'
      ],
      destinationNote: 'Hanya melayani rute menuju Bandung dan sekitarnya.',
    ),
    GroundTransportInfo(
      category: TransportCategory.taxi,
      title: 'Taksi',
      subtitle: 'Tersedia 24 jam, tarif berbasis argometer',
      icon: Icons.local_taxi,
      color: Color(0xFFFFB800),
      operators: [
        TransportOperator(name: 'Blue Bird'),
        TransportOperator(name: 'Silver Bird'),
        TransportOperator(name: 'Diamond'),
        TransportOperator(name: 'Gamya'),
        TransportOperator(name: 'Primajasa'),
      ],
      priceRange: 'Sesuai argometer (tergantung jarak tujuan)',
      operatingHours: '24 jam',
      pickupPoints: ['Hampir seluruh pintu keluar terminal'],
      destinationNote:
          'Angkutan umum resmi dengan tanda khusus & argometer sesuai Permenhub 32/2016.',
      extraNote:
          'Pastikan menggunakan taksi resmi berargometer untuk tarif yang wajar dan transparan.',
    ),
    GroundTransportInfo(
      category: TransportCategory.bus,
      title: 'Bus',
      subtitle: 'Untuk tujuan Jabodetabek, Depok, atau Bandung',
      icon: Icons.directions_bus_filled,
      color: Color(0xFF2FAE60),
      operators: [
        TransportOperator(name: 'Damri'),
        TransportOperator(name: 'JA Connexion Agra Mas'),
        TransportOperator(name: 'JA Connexion Perum PPD'),
        TransportOperator(name: 'JA Connexion Sinar Jaya'),
        TransportOperator(name: 'JA Connexion Big Bird'),
        TransportOperator(name: 'JA Connexion Hiba Utama'),
        TransportOperator(name: 'Primajasa'),
      ],
      priceRange: 'Rp55.000 – Rp200.000',
      operatingHours: '02.00 – 23.00 WIB',
      pickupPoints: [
        'Terminal 1A',
        'Shelter Bus',
        'Terminal 2F',
        'Terminal 3 Domestik',
        'Terminal 3 Internasional'
      ],
      destinationNote: 'Tarif tergantung destinasi yang dituju.',
    ),
    GroundTransportInfo(
      category: TransportCategory.onlineTransport,
      title: 'Transportasi Online',
      subtitle: 'Pemesanan mudah lewat aplikasi, 24 jam',
      icon: Icons.smartphone,
      color: Color(0xFF7C4DFF),
      operators: [
        TransportOperator(
            name: 'GoCar',
            appScheme: 'gojek://',
            webFallback: 'https://www.gojek.com'),
        TransportOperator(
            name: 'Grab',
            appScheme: 'grab://',
            webFallback: 'https://www.grab.com/id'),
        TransportOperator(
            name: 'Maxim',
            appScheme: 'maxim://',
            webFallback: 'https://taximaxim.com'),
        TransportOperator(
            name: 'My BlueBird',
            appScheme: 'mybluebird://',
            webFallback: 'https://www.bluebirdgroup.com'),
        TransportOperator(name: 'My Drivers'),
        TransportOperator(name: 'Smartrans'),
        TransportOperator(name: 'ATRANS'),
        TransportOperator(name: 'Transshia KUPP'),
      ],
      priceRange: 'Sesuai tarif di aplikasi (estimasi sebelum pesan)',
      operatingHours: '24 jam',
      pickupPoints: ['Titik jemput sesuai lokasi GPS Anda di aplikasi'],
      destinationNote:
          'Operator resmi yang bekerja sama dengan Bandara Soekarno-Hatta.',
    ),
    GroundTransportInfo(
      category: TransportCategory.carRental,
      title: 'Sewa Mobil',
      subtitle: 'Cocok untuk rombongan hingga 6 penumpang',
      icon: Icons.car_rental,
      color: Color(0xFFFF6B6B),
      operators: [
        TransportOperator(name: 'Induk Koperasi Angkutan Udara (Inkopau)'),
      ],
      priceRange: 'Hubungi operator untuk info tarif',
      operatingHours: '24 jam',
      pickupPoints: ['Konter sewa mobil di area kedatangan terminal'],
      destinationNote: 'Melayani tujuan wilayah Jabodetabek.',
      extraNote:
          'Muat hingga 6 penumpang dalam satu perjalanan — cocok untuk keluarga atau rombongan.',
    ),
    GroundTransportInfo(
      category: TransportCategory.airportTrain,
      title: 'Kereta Bandara',
      subtitle: 'Railink Express menuju Jakarta',
      icon: Icons.train,
      color: Color(0xFF00A896),
      operators: [
        TransportOperator(name: 'Railink'),
      ],
      priceRange: 'Sesuai tarif resmi Railink',
      operatingHours: '05.00 – 23.30 WIB',
      pickupPoints: [
        'Stasiun Bandara Soekarno-Hatta (terintegrasi dengan terminal via Skytrain)'
      ],
      destinationNote:
          'Melayani rute dari Bandara Soetta menuju wilayah Jakarta.',
    ),
  ];
}
