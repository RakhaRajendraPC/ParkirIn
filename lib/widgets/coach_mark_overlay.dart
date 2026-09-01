
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CoachMarkStep {
  final String title;
  final String description;
  final IconData icon;

  const CoachMarkStep(
      {required this.title, required this.description, required this.icon});
}

/// Widget global untuk menampilkan onboarding coach-mark sekali per fitur
/// (pakai [featureKey] unik).
/// Tampilkan lewat [CoachMarkOverlay.showIfFirstTime].
class CoachMarkOverlay {
  static Future<void> showIfFirstTime(BuildContext context, String featureKey,
      List<CoachMarkStep> steps) async {
    final prefs = await SharedPreferences.getInstance();
    final seenKey = 'coachmark_seen_$featureKey';
    if (prefs.getBool(seenKey) == true) return;
    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => _CoachMarkDialog(steps: steps),
    );
    await prefs.setBool(seenKey, true);
  }
}

class _CoachMarkDialog extends StatefulWidget {
  final List<CoachMarkStep> steps;

  const _CoachMarkDialog({required this.steps});

  @override
  State<_CoachMarkDialog> createState() => _CoachMarkDialogState();
}

class _CoachMarkDialogState extends State<_CoachMarkDialog> {
  static const Color primaryBlue = Color(0xFF1E5EFF);
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_index];
    final isLast = _index == widget.steps.length - 1;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(step.icon, color: primaryBlue, size: 32),
            ),
            const SizedBox(height: 16),
            Text(step.title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(step.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600, height: 1.5)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  widget.steps.length,
                  (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _index ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                            color: i == _index
                                ? primaryBlue
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3)),
                      )),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (!isLast)
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Lewati',
                          style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                Expanded(
                  flex: isLast ? 1 : 1,
                  child: ElevatedButton(
                    onPressed: () {
                      if (isLast) {
                        Navigator.pop(context);
                      } else {
                        setState(() => _index++);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: Text(isLast ? 'Mengerti' : 'Lanjut'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
