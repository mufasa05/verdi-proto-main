// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Widget getEmbeddedSubAiView(String url) {
  final viewType = 'verdi-sub-ai-iframe-${url.hashCode}';

  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final iframe = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.borderRadius = '12px'
      ..style.backgroundColor = '#0F172A'
      ..allow = 'microphone; camera; autoplay; display-capture; clipboard-write; encrypted-media';
    return iframe;
  });

  return HtmlElementView(viewType: viewType);
}
