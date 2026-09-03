import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ground_transport_model.dart';
import '../widgets/stub_icon.dart';

class TransportCategoryDetailScreen extends StatelessWidget {
  final GroundTransportInfo info;

  const TransportCategoryDetailScreen({super.key, required this.info});

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
                  color: Color(0xFF16181F),
                  fontWeight: FontWeight.w800,
                  fontSize: 16)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 14),
            _buildInfoGrid(),
            const SizedBox(height: 18),
            _buildOperatorSection(context),
            const SizedBox(height: 14),
            _buildPickupSection(),
            if (info.extraNote != null) ...[
              const SizedBox(height: 14),
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
        color: info.color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: info.color.withOpacity(0.1),
              blurRadius: 18,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StubIcon(icon: info.icon, color: info.color, size: 50),
          const SizedBox(height: 14),
          Text(info.title,
              style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16181F),
                  letterSpacing: -0.3)),
          const SizedBox(height: 5),
          Text(info.destinationNote,
              style: TextStyle(
                  fontSize: 12, color: Colors.grey.shade700, height: 1.45)),
        ],
      ),
    );
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        Expanded(
            child: _infoTile(Icons.access_time_rounded, 'JAM OPERASIONAL',
                info.operatingHours)),
        const SizedBox(width: 10),
        Expanded(
            child: _infoTile(
                Icons.payments_rounded, 'ESTIMASI TARIF', info.priceRange)),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: info.color),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 8.5,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16181F))),
        ],
      ),
    );
  }

  Widget _buildOperatorSection(BuildContext context) {
    final isOnline = info.category == TransportCategory.onlineTransport;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 14,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BarAccentLabel(text: 'OPERATOR TERSEDIA', color: info.color),
          const SizedBox(height: 10),
          const PerforationDivider(),
          const SizedBox(height: 4),
          ...info.operators.map((op) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 15, color: info.color),
                    const SizedBox(width: 9),
                    Expanded(
                        child: Text(op.name,
                            style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF16181F)))),
                    if (isOnline)
                      InkWell(
                        onTap: () => _openOperatorApp(context, op),
                        borderRadius: BorderRadius.circular(6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('BUKA',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: info.color,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.3)),
                            const SizedBox(width: 2),
                            LinkArrow(color: info.color),
                          ],
                        ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 14,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BarAccentLabel(text: 'TITIK JEMPUT', color: info.color),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: info.pickupPoints
                .map((p) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 11, vertical: 7),
                      decoration: BoxDecoration(
                          color: info.color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(9)),
                      child: Text(p,
                          style: TextStyle(
                              fontSize: 11,
                              color: info.color,
                              fontWeight: FontWeight.w700)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraNote() {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: Colors.amber.withOpacity(0.09),
          borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, size: 16, color: Colors.amber),
          const SizedBox(width: 10),
          Expanded(
              child: Text(info.extraNote!,
                  style: const TextStyle(fontSize: 11.5, height: 1.4))),
        ],
      ),
    );
  }
}
