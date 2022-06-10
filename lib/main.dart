
import 'dart:developer';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:avatar_glow/avatar_glow.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText speechToText;
  bool isListen = false;
  String speechText = 'Speek somethings';
  double confident = 1.0;
  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    speechToText = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Flutter Voice Assistence Ratio: ${(confident * 100.0).toStringAsFixed(1)}%",
          style: const TextStyle(fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          margin: const EdgeInsets.all(10),
          child: Text(
            speechText,
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: isListen,
        glowColor: Theme.of(context).primaryColor,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        endRadius: 75.0,
        repeat: true,
        child: FloatingActionButton(
          onPressed: () {
            listen();
          },
          child: Icon(isListen ? Icons.mic : Icons.mic_none),
        ),
      ),
    );
  }

  void speek(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  Future<void> listen() async {
    if (!isListen) {
      bool available = await speechToText.initialize(
        onStatus: (val) => log("status: $val"),
        onError: (val) => log("error: $val"),
      );
      if (available) {
        setState(() {
          isListen = true;
        });
        speechToText.listen(
          onResult: (val) => setState(() {
            speechText = val.recognizedWords;
            if (speechText == "Marco") {
              speek("telo");
            } else {
              speek(speechText);
            }
            log("test_speaking: $isListen");
            
            if (val.hasConfidenceRating && val.confidence > 0) {
              confident = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() {
        isListen = false;
        speechToText.stop();
      });
    }
  }
}
