import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OTPFailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to verify email.',
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logic to resend verification email or navigate back
              },
              child: Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
