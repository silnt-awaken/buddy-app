import 'dart:async';
import 'dart:io';

import 'package:buddy_app/blocs/buddy/buddy_bloc.dart';
import 'package:buddy_app/services/openai_service.dart';
import 'package:flutter_speech/flutter_speech.dart';
import 'package:flutter_tts/flutter_tts.dart';

class BuddyRepository {
  late final SpeechRecognition _speech;
  late final FlutterTts _tts;

  BuddyRepository()
      : _speech = SpeechRecognition(),
        _tts = FlutterTts();

  // initialize speech
  Future<bool> initializeSpeech() async {
    return await _speech
        .activate('en_US')
        .then((value) => true)
        .catchError((error) => false);
  }

  Future<bool> startListening() async {
    return await _speech
        .listen()
        .then((value) => true)
        .catchError((error) => false);
  }

  Stream<String> handleResult() {
    final controller = StreamController<String>();
    _speech.setRecognitionResultHandler((result) {
      controller.add(result);
    });
    return controller.stream;
  }

  Stream<String> handleFeedback() {
    final controller = StreamController<String>();
    List<String> completions = [];
    _speech.setRecognitionCompleteHandler((result) async {
      completions.add(result);
      if (completions.length == 2) {
        controller.add(result);
      }
    });
    return controller.stream;
  }

  Future<String> sendMessage(Map<int, String> prompt,
      {BuddyFeature feature = BuddyFeature.normal}) async {
    late final String response;
    // check for the last prompt in the map to see if it contains "book" to setup booking feature
    final lastPrompt = prompt.values.last;
    if (lastPrompt.contains('book') && lastPrompt.contains('appointment')) {
      response = await Future.delayed(
          const Duration(milliseconds: 100),
          () =>
              ' Sure, I can do that for you. What is the address of the location you want to book at? (Specify the city and state)');
    } else {
      final openAiService = OpenAiService();
      if (feature == BuddyFeature.booking) {
        prompt[prompt.keys.last] = 'Give me the coordidates of $lastPrompt';
      }
      // convert the map to a string
      final promptString = prompt.values.join('\n');
      response = await openAiService.create(prompt: promptString);
    }

    return response;
  }

  String convertResponseToReadableText(String response) {
    if (!response.contains(':')) {
      return response;
    }

    final responseSection = response.split(':');
    final readableText = responseSection.last;
    return readableText;
  }

  Future<void> _initializeTts() async {
    await _tts.setVoice({"name": "en-us-x-tpf-local", "locale": "en-US"});
    await _initIos();
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> _initIos() async {
    if (!Platform.isIOS) return;
    await _tts.setSharedInstance(true);
    await _tts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [IosTextToSpeechAudioCategoryOptions.mixWithOthers],
      //IosTextToSpeechAudioMode.voicePrompt,
    );
  }

  Future<void> speak(String text) async {
    await _initializeTts();
    await _tts.awaitSpeakCompletion(true);
    await _tts.speak(text);
  }
}
