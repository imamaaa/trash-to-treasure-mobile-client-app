import 'package:firebase_core/firebase_core.dart';
import 'package:myapp/sign_in_page.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'profilePage.dart';
import 'scan_qr.dart';
import 'settings.dart';
import 'history.dart';
import 'wallet.dart';
import 'feedback.dart';
import 'challenges.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/profile': (context) => ProfilePage(),
        '/scan_qr': (context) => QRScannerPage(),
        '/settings': (context) => SettingsPage(),
        '/history': (context) => HistoryPage(),
        '/wallet': (context) => WalletPage(),
        '/signinpage': (context) => SignInPage(),
        '/feedback': (context) => FeedbackPage(),
        '/challenges':(context) => ChallengesPage(),

      },
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
    );
  }
}
