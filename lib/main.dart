import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trace_app_3c/screens/client.dart';
import 'package:trace_app_3c/screens/home.dart';
import 'package:trace_app_3c/screens/register_client.dart';
import 'package:trace_app_3c/screens/register_establishment.dart';
import 'firebase_options.dart';
import 'package:trace_app_3c/screens/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(Assingnment4());
}


class Assingnment4 extends StatelessWidget {
  const Assingnment4({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            //circularprogressindocator
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          //check if logged in
          if (snapshot.hasData) {
            String userId = snapshot.data!.uid;
            return ClientScreen(userId: userId);
          }
          //no sign in data
          return HomeScreen();
        },
      ),
      builder: EasyLoading.init(),
      theme: ThemeData(
        fontFamily: GoogleFonts.montserrat().fontFamily,
        textTheme: TextTheme(
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w100,
          ),
        ),
      ),
    );
  }
}
