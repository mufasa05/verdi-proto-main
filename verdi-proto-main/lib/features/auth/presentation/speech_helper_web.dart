// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:js' as js;
import 'package:flutter/foundation.dart';

void speakWeb(String text) {
  try {
    js.context.callMethod('eval', [
      '''
      (function(txt) {
        if ('speechSynthesis' in window) {
          window.speechSynthesis.cancel();
          var utterance = new SpeechSynthesisUtterance(txt);
          utterance.rate = 0.95;
          utterance.pitch = 0.85;
          utterance.volume = 1.0;
          
          var played = false;
          var playSpeech = function() {
            if (played) return;
            played = true;
            try {
              var voices = window.speechSynthesis.getVoices();
              if (voices && voices.length > 0) {
                var selectedVoice = null;
                for (var i = 0; i < voices.length; i++) {
                  var v = voices[i];
                  var lang = (v.lang || '').toLowerCase();
                  var name = (v.name || '').toLowerCase();
                  
                  // Skip female voice names
                  if (name.indexOf('female') !== -1 || name.indexOf('zira') !== -1 || 
                      name.indexOf('aria') !== -1 || name.indexOf('samantha') !== -1 || 
                      name.indexOf('victoria') !== -1 || name.indexOf('jenny') !== -1 ||
                      name.indexOf('catherine') !== -1 || name.indexOf('fiona') !== -1 || 
                      name.indexOf('google us english') !== -1) {
                    continue;
                  }

                  if (lang.indexOf('en') !== -1) {
                    if (name.indexOf('male') !== -1 || name.indexOf('david') !== -1 || 
                        name.indexOf('guy') !== -1 || name.indexOf('mark') !== -1 || 
                        name.indexOf('george') !== -1 || name.indexOf('james') !== -1 || 
                        name.indexOf('brian') !== -1 || name.indexOf('daniel') !== -1 || 
                        name.indexOf('alex') !== -1 || name.indexOf('fred') !== -1) {
                      selectedVoice = v;
                      break;
                    }
                  }
                }
                
                // Fallback to any non-female English voice if no specific male name matched
                if (!selectedVoice) {
                  for (var j = 0; j < voices.length; j++) {
                    var v2 = voices[j];
                    var l2 = (v2.lang || '').toLowerCase();
                    var n2 = (v2.name || '').toLowerCase();
                    if (l2.indexOf('en') !== -1 && n2.indexOf('female') === -1 && 
                        n2.indexOf('zira') === -1 && n2.indexOf('aria') === -1) {
                      selectedVoice = v2;
                      break;
                    }
                  }
                }

                if (selectedVoice) {
                  utterance.voice = selectedVoice;
                }
              }
            } catch(e){}
            window.speechSynthesis.speak(utterance);
          };

          var existingVoices = window.speechSynthesis.getVoices();
          if (existingVoices && existingVoices.length > 0) {
            playSpeech();
          } else {
            window.speechSynthesis.onvoiceschanged = function() {
              window.speechSynthesis.onvoiceschanged = null;
              playSpeech();
            };
            setTimeout(function() {
              playSpeech();
            }, 200);
          }
        }
      })('${text.replaceAll("'", "\\'").replaceAll("\n", " ")}')
      '''
    ]);
  } catch (e) {
    debugPrint("Web Speech Synthesis Error: $e");
  }
}

void stopWeb() {
  try {
    js.context.callMethod('eval', [
      '''
      if ('speechSynthesis' in window) {
        window.speechSynthesis.cancel();
      }
      '''
    ]);
  } catch (e) {
    debugPrint("Web Speech Stop Error: $e");
  }
}

