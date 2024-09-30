import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

class QRSuccessPage extends StatelessWidget {
  final String pointsAssigned;
  final String numOfItems;
  final String itemType;
  final String timestamp;

  QRSuccessPage({
    required this.pointsAssigned,
    required this.numOfItems,
    required this.itemType,
    required this.timestamp,
  });

  String formatTimestamp(String timestamp) {
    try {
      DateTime parsedDate = DateTime.parse(timestamp);
      return DateFormat('d MMMM yyyy \'at\' HH:mm:ss').format(parsedDate.toLocal());
    } catch (e) {
      return timestamp; // Return original if parsing fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF138A36),
        leading: IconButton(
          icon: SvgPicture.asset('assets/vectors/backArrow.svg', color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/scan_qr'); // Go back to the QR Scan page
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 1),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 39,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/vectors/putInMoney.svg', // Your SVG asset
                width: 250, // Make the image bigger
                height: 250,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 320,
              left: 42,
              right: 42,
              child: Text(
                '$pointsAssigned points',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(19, 138, 54, 1),
                  fontFamily: 'Poppins',
                  fontSize: 30,
                  letterSpacing: 0,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
            ),
            Positioned(
              top: 410, // Add more space between the lines
              left: 24,
              right: 24,
              child: Text(
                'You have successfully earned $pointsAssigned points by scanning $numOfItems $itemType item(s) on ${formatTimestamp(timestamp)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromRGBO(51, 51, 51, 1),
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  letterSpacing: 0,
                  fontWeight: FontWeight.normal,
                  height: 1.5,
                ),
              ),
            ),
            Positioned(
              bottom: 150,
              left: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/profile'); // Go to the Profile page
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF138A36), // Background color
                ),
              ),
            ),
            Positioned(
              bottom: 90,
              left: 24,
              right: 24,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/wallet'); // Go to Wallet page
                },
                child: Text(
                  'Go to Wallet',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Poppins',
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF138A36), // Background color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
