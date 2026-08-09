import 'speech_helper_stub.dart'
    if (dart.library.js) 'speech_helper_web.dart' as helper;

void speakWebPlatform(String text) {
  helper.speakWeb(text);
}

void stopWebPlatform() {
  helper.stopWeb();
}

