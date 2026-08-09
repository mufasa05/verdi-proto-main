import 'package:flutter/material.dart';

Widget getEmbeddedSubAiView(String url) {
  return Container(
    color: const Color(0xFF0F172A),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.mic, color: Color(0xFF16A34A), size: 48),
          SizedBox(height: 16),
          Text(
            'Verdi Sub AI Live Voice Console',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Running live voice session inside the app window.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    ),
  );
}
