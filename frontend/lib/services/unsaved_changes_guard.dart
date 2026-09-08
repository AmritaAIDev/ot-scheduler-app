import 'dart:html' as html;
import 'dart:js_util' as js_util;

/// Warns the user with the browser's native "leave site?" confirmation if
/// they try to close the tab or reload while this screen has data that
/// hasn't been saved to the backend yet.
///
/// Flutter Web can't intercept a reload after it happens — a hard refresh
/// always restarts the app and discards all in-memory widget state. This
/// makes that an explicit choice instead of silent, invisible data loss.
/// Wire it up with `enable()` in `initState()` and `disable()` in
/// `dispose()` for any screen holding unconfirmed/unsaved user input.
///
/// Deliberately avoids casting the native event to `html.BeforeUnloadEvent`:
/// if dart:html's runtime type-check for that wrapper doesn't match the
/// browser's native 'beforeunload' event, the cast throws *inside* the JS
/// listener. The browser swallows that (just logs it to the console) and
/// unloads the page anyway — `returnValue` never gets set, so the dialog
/// silently never appears. Using dart:js_util to poke the property directly
/// sidesteps that. `preventDefault()` is also required by current
/// Chrome/Firefox alongside `returnValue` for the prompt to show at all.
class UnsavedChangesGuard {
  void Function(html.Event)? _listener;

  void enable() {
    if (_listener != null) return;
    _listener = (html.Event event) {
      event.preventDefault();
      js_util.setProperty(event, 'returnValue', '');
    };
    html.window.addEventListener('beforeunload', _listener);
  }

  void disable() {
    if (_listener == null) return;
    html.window.removeEventListener('beforeunload', _listener);
    _listener = null;
  }
}
