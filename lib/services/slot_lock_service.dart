import 'dart:async';

class SlotLockService {
  SlotLockService._();
  static final SlotLockService instance = SlotLockService._();

  static const Duration lockDuration = Duration(minutes: 10);

  String? _lockedSlotCode;
  DateTime? _lockExpiry;
  bool _lastReleaseWasExpiry = false;
  final _controller = StreamController<Duration>.broadcast();
  Timer? _ticker;

  Stream<Duration> get countdown => _controller.stream;
  String? get lockedSlotCode => _lockedSlotCode;

  /// True if the most recent lock ended because its countdown genuinely
  /// reached zero, as opposed to an intentional [release] call (e.g. after
  /// a successful booking). Both cases emit the same `Duration.zero` value
  /// on [countdown] — there's no other way to tell them apart from state
  /// alone, since a released lock and an expired lock look identical
  /// afterwards (no locked slot, no expiry). Listeners should check this
  /// before treating a zero-duration tick as a real expiry.
  bool get lastReleaseWasExpiry => _lastReleaseWasExpiry;

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
    _lastReleaseWasExpiry = false;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final r = remaining;
      _controller.add(r);
      if (r == Duration.zero) {
        _expire();
      }
    });
  }

  /// Ends the current lock for any reason other than its countdown running
  /// out — e.g. a successful booking, or the user backing out of slot
  /// selection. Call this instead of letting the lock expire whenever the
  /// lock is being given up intentionally.
  void release() {
    _lastReleaseWasExpiry = false;
    _clear();
  }

  /// Called only by the internal ticker when the countdown genuinely
  /// reaches zero.
  void _expire() {
    _lastReleaseWasExpiry = true;
    _clear();
  }

  void _clear() {
    _lockedSlotCode = null;
    _lockExpiry = null;
    _ticker?.cancel();
    _controller.add(Duration.zero);
  }
}
