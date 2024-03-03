import 'package:chat_app/Auth.dart';
import 'package:chat_app/StartScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import "firebase_options.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor:Color.fromARGB(255, 0, 204, 255),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color.fromARGB(255, 0, 200, 255)
          ),
          snackBarTheme: const SnackBarThemeData(backgroundColor: Color.fromARGB(255, 207, 14, 0))),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              return const StartScreen();
            }
            return const Auth();
          }),
    );
  }
}