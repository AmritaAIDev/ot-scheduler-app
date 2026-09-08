import 'dart:html' as html;

/// Warns the user with the browser's native "leave site?" confirmation if
/// they try to close the tab or reload while this screen has data that
/// hasn't been saved to the backend yet.
///
/// Flutter Web can't intercept a reload after it happens — a hard refresh
/// always restarts the app and discards all in-memory widget state. This
/// makes that an explicit choice instead of silent, invisible data loss.
/// Wire it up with `enable()` in `initState()` and `disable()` in
/// `dispose()` for any screen holding unconfirmed/unsaved user input.
class UnsavedChangesGuard {
  html.EventListener? _listener;

  void enable() {
    if (_listener != null) return;
    _listener = (event) {
      (event as html.BeforeUnloadEvent).returnValue = '';
    };
    html.window.addEventListener('beforeunload', _listener);
  }

  void disable() {
    if (_listener == null) return;
    html.window.removeEventListener('beforeunload', _listener);
    _listener = null;
  }
}
