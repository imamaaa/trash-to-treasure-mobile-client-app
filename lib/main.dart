import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import dotenv
import 'package:overlay_support/overlay_support.dart';
import 'firebase_options.dart'; // Import Firebase options
import 'splash_screen.dart';
import 'profilePage.dart';
import 'scan_qr.dart';
import 'settings.dart';
import 'history.dart';
import 'wallet.dart';
import 'feedback.dart';
import 'challenges.dart';
import 'my_badges.dart';
import 'enter_pin.dart';
import 'stores.dart';
import 'sign_in_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load();

  // Initialize Firebase securely
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OverlaySupport(
      child: MaterialApp(
        routes: {
          '/profile': (context) => ProfilePage(),
          '/scan_qr': (context) => QRScannerPage(),
          '/settings': (context) => SettingsPage(),
          '/history': (context) => HistoryPage(),
          '/wallet': (context) => WalletPage(),
          '/signinpage': (context) => SignInPage(),
          '/feedback': (context) => FeedbackPage(),
          '/challenges': (context) => ChallengesPage(),
          '/my_badges': (context) => MyBadgesPage(),
          '/enter_pin': (context) => EnterPINCodePage(),
          '/stores': (context) => StoresPage(),
        },
        title: 'Trash to Treasure',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(),
      ),
    );
  }
}
