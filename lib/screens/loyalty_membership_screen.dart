// lib/screens/loyalty_membership_screen.dart
import 'package:flutter/material.dart';

class LoyaltyMembershipScreen extends StatelessWidget {
  const LoyaltyMembershipScreen({super.key});

  static const Color primaryBlue = Color(0xFF1E5EFF);

  @override
  Widget build(BuildContext context) {
    const currentPoints = 2450;
    const nextTierPoints = 5000;
    const progress = currentPoints / nextTierPoints;

    final history = [
      ('Booking di SkyPark Fly & Park', '+450 poin', '12 Agu 2026'),
      ('Bonus Ulang Tahun', '+200 poin', '2 Agu 2026'),
      ('Booking di SafePark Soekarno Hatta', '+380 poin', '20 Jul 2026'),
      ('Redeem Diskon Parkir', '-500 poin', '5 Jul 2026'),
    ];

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Loyalty & Membership',
              style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFFFD97A), Color(0xFFFFB800)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.star, color: Colors.white),
                      SizedBox(width: 6),
                      Text('Gold Member',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('$currentPoints Poin',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation(Colors.white)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                      '${nextTierPoints - currentPoints} poin lagi menuju Platinum Member',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Keuntungan Gold Member',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _benefitTile(Icons.discount_outlined, 'Diskon 10% setiap booking'),
            _benefitTile(Icons.priority_high_rounded,
                'Prioritas slot parkir saat peak season'),
            _benefitTile(Icons.support_agent, 'Akses Live Chat prioritas'),
            const SizedBox(height: 20),
            const Text('Riwayat Poin',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04), blurRadius: 8)
                  ]),
              child: Column(
                children: history.map((h) {
                  final isPositive = h.$2.startsWith('+');
                  return ListTile(
                    title: Text(h.$1,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                    subtitle: Text(h.$3,
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade500)),
                    trailing: Text(h.$2,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color:
                                isPositive ? Colors.green : Colors.redAccent)),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)
            ]),
        child: Row(
          children: [
            Icon(icon, color: Colors.amber.shade700, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
          ],
        ),
      ),
    );
  }
}
