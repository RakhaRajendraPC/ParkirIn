// lib/screens/transport_category_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ground_transport_model.dart';

class TransportCategoryDetailScreen extends StatelessWidget {
  final GroundTransportInfo info;

  const TransportCategoryDetailScreen({super.key, required this.info});

  static const Color primaryBlue = Color(0xFF1E5EFF);

  Future<void> _openOperatorApp(
      BuildContext context, TransportOperator op) async {
    if (op.appScheme != null) {
      final appUri = Uri.parse(op.appScheme!);
      final launched = await canLaunchUrl(appUri) && await launchUrl(appUri);
      if (launched) return;
    }
    if (op.webFallback != null) {
      await launchUrl(Uri.parse(op.webFallback!),
          mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${op.name} belum terpasang di perangkat Anda')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(info.title,
              style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildInfoGrid(),
            const SizedBox(height: 20),
            _buildOperatorSection(context),
            const SizedBox(height: 20),
            _buildPickupSection(),
            if (info.extraNote != null) ...[
              const SizedBox(height: 16),
              _buildExtraNote(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: info.color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration:
                BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(info.icon, color: info.color, size: 26),
          ),
          const SizedBox(height: 12),
          Text(info.title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(info.destinationNote,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade700, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        Expanded(
          child: _infoTile(
              Icons.access_time, 'Jam Operasional', info.operatingHours),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _infoTile(
              Icons.payments_outlined, 'Estimasi Tarif', info.priceRange),
        ),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: info.color),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(fontSize: 9, color: Colors.grey.shade500)),
          const SizedBox(height: 2),
          Text(value,
              style:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildOperatorSection(BuildContext context) {
    final isOnline = info.category == TransportCategory.onlineTransport;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Operator Tersedia',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          ...info.operators.map((op) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 14, color: info.color),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(op.name,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500))),
                    if (isOnline)
                      TextButton(
                        onPressed: () => _openOperatorApp(context, op),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero),
                        child: Text('Buka Aplikasi',
                            style: TextStyle(
                                fontSize: 10,
                                color: info.color,
                                fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildPickupSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: info.color),
              const SizedBox(width: 8),
              const Text('Titik Jemput',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: info.pickupPoints
                .map((p) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: info.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(p,
                          style: TextStyle(
                              fontSize: 11,
                              color: info.color,
                              fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(
              child:
                  Text(info.extraNote!, style: const TextStyle(fontSize: 11))),
        ],
      ),
    );
  }
}
