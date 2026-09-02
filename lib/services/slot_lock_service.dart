import 'dart:async';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'api_exception.dart';

/// Thrown when POST /slots/:slotId/lock returns 409 — the slot was just
/// locked by someone else, taken by a confirmed overlapping booking, or is
/// out of service. Distinct from [ApiException] so callers can show a
/// specific "this slot just became unavailable" message instead of the
/// generic connection-error toast.
class SlotLockConflictException implements Exception {
  SlotLockConflictException(this.message);

  final String message;

  @override
  String toString() => message;
}

class SlotLockService {
  SlotLockService._();
  static final SlotLockService instance = SlotLockService._();

  final Dio _dio = ApiClient.instance.dio;

  String? _lockedSlotId;
  DateTime? _lockExpiry;
  bool _lastReleaseWasExpiry = false;
  final _controller = StreamController<Duration>.broadcast();
  Timer? _ticker;

  Stream<Duration> get countdown => _controller.stream;
  String? get lockedSlotId => _lockedSlotId;

  /// True if the most recent lock ended because its countdown genuinely
  /// reached zero, as opposed to an intentional [release] call (e.g. after
  /// a successful booking). Both cases emit the same `Duration.zero` value
  /// on [countdown] — there's no other way to tell them apart from state
  /// alone, since a released lock and an expired lock look identical
  /// afterwards (no locked slot, no expiry). Listeners should check this
  /// before treating a zero-duration tick as a real expiry.
  bool get lastReleaseWasExpiry => _lastReleaseWasExpiry;

  bool get isLocked =>
      _lockedSlotId != null &&
      _lockExpiry != null &&
      DateTime.now().isBefore(_lockExpiry!);

  /// Derived purely from comparing now against the server's [_lockExpiry] —
  /// the backend's Redis TTL is the sole source of truth for when a lock
  /// actually expires, this never invents its own duration.
  Duration get remaining {
    if (_lockExpiry == null) return Duration.zero;
    final diff = _lockExpiry!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// POST /slots/:slotId/lock. On success, stores the server's real
  /// `expiresAt` and starts a local ticker that just compares against it
  /// every second — no local ownership of "10 minutes" anywhere here.
  /// Throws [SlotLockConflictException] on a 409 (already locked / out of
  /// service / overlapping booking), or [ApiException] for anything else.
  Future<void> lockSlot(
    String slotId,
    DateTime checkInPlanned,
    DateTime checkOutPlanned,
  ) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/slots/$slotId/lock',
        data: {
          'checkInPlanned': checkInPlanned.toIso8601String(),
          'checkOutPlanned': checkOutPlanned.toIso8601String(),
        },
      );
      final expiresAt = DateTime.parse(res.data!['expiresAt'] as String);
      _lockedSlotId = slotId;
      _lockExpiry = expiresAt;
      _lastReleaseWasExpiry = false;
      _startTicker();
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw SlotLockConflictException(_conflictMessage(e));
      }
      throw mapDioError(e);
    }
  }

  String _conflictMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['message'] != null) {
      final rawMessage = data['message'];
      return rawMessage is List ? rawMessage.join(', ') : rawMessage.toString();
    }
    return 'Slot ini baru saja dikunci atau tidak tersedia lagi.';
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final r = remaining;
      _controller.add(r);
      if (r == Duration.zero) {
        _expire();
      }
    });
  }

  /// DELETE /slots/:slotId/lock. Local state (and the countdown banner) is
  /// cleared immediately regardless of the network outcome — the caller has
  /// already committed to giving up the lock, so the UI shouldn't wait on
  /// or block on the round-trip. If the DELETE itself fails, it's silently
  /// dropped: the server-side Redis TTL (10 minutes from acquisition) means
  /// the slot frees up on its own even if this call never lands, so there's
  /// nothing a retry or an error dialog would meaningfully protect against
  /// that the TTL doesn't already cover.
  Future<void> release() async {
    final slotId = _lockedSlotId;
    _lastReleaseWasExpiry = false;
    _clearLocalState();
    if (slotId == null) return;
    try {
      await _dio.delete('/slots/$slotId/lock');
    } on DioException {
      // Best-effort — see doc comment above.
    }
  }

  /// Called only by the internal ticker when the countdown genuinely
  /// reaches zero (the server's expiresAt has passed).
  void _expire() {
    _lastReleaseWasExpiry = true;
    _clearLocalState();
  }

  void _clearLocalState() {
    _lockedSlotId = null;
    _lockExpiry = null;
    _ticker?.cancel();
    _controller.add(Duration.zero);
  }
}
