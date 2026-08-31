import 'package:flutter/material.dart';
import '../models/ground_transport_model.dart';
import 'transport_category_detail_screen.dart';

class GroundTransportScreen extends StatelessWidget {
  const GroundTransportScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E5EFF);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Transportasi Lanjutan',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: primaryBlue, size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pilih moda transportasi untuk melanjutkan perjalanan Anda dari Bandara Soekarno-Hatta.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...GroundTransportData.all.map((info) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCategoryCard(context, info),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, GroundTransportInfo info) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => TransportCategoryDetailScreen(info: info))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: info.color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(info.icon, color: info.color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(info.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(info.subtitle,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 11, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(info.operatingHours,
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade600)),
                      const SizedBox(width: 10),
                      Icon(Icons.apartment,
                          size: 11, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text('${info.operators.length} operator',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade600)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
