import 'dart:async';

/// Grants once at the earned event, but keeps navigation locked until dismissal.
class RewardedSession {
  RewardedSession(this.onEarned);

  final void Function() onEarned;
  final _dismissed = Completer<bool>();
  bool _earned = false;
  bool _closed = false;

  Future<bool> get finished => _dismissed.future;

  void earn() {
    if (_earned || _closed) return;
    onEarned();
    _earned = true;
  }

  void close() {
    if (_closed) return;
    _closed = true;
    _dismissed.complete(_earned);
  }
}
