import 'dart:async';

class SlotLockService {
  SlotLockService._();
  static final SlotLockService instance = SlotLockService._();

  static const Duration lockDuration = Duration(minutes: 10);

  String? _lockedSlotCode;
  DateTime? _lockExpiry;
  final _controller = StreamController<Duration>.broadcast();
  Timer? _ticker;

  Stream<Duration> get countdown => _controller.stream;
  String? get lockedSlotCode => _lockedSlotCode;
  bool get isLocked =>
      _lockedSlotCode != null &&
      _lockExpiry != null &&
      DateTime.now().isBefore(_lockExpiry!);

  Duration get remaining {
    if (_lockExpiry == null) return Duration.zero;
    final diff = _lockExpiry!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  void lockSlot(String slotCode) {
    _lockedSlotCode = slotCode;
    _lockExpiry = DateTime.now().add(lockDuration);
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final r = remaining;
      _controller.add(r);
      if (r == Duration.zero) {
        release();
      }
    });
  }

  void release() {
    _lockedSlotCode = null;
    _lockExpiry = null;
    _ticker?.cancel();
    _controller.add(Duration.zero);
  }
}
