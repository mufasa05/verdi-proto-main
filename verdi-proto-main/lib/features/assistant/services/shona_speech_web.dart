// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js' as js;

/// JS interop implementation for Web platform.
void evalJs(String script) {
  try {
    js.context.callMethod('eval', [script]);
  } catch (_) {}
}

void setJsCallback(String name, Function callback) {
  try {
    js.context[name] = callback;
  } catch (_) {}
}
