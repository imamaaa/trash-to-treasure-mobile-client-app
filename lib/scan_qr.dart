import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'qr_success.dart';
import 'dart:convert';

class QRScannerPage extends StatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  bool _isScanning = true; // State variable to track if scanning is active
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((Barcode scanData) {
      if (!_isScanning) return; // Stop processing if scanning is not active

      if (scanData.code != null) {
        _handleQRCode(scanData.code!); // Extract the string data from Barcode
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Scanned data is empty!')),
        );
      }
    });
  }

  void _handleQRCode(String scanData) async {
    setState(() {
      _isScanning = false; // Disable scanning while processing
    });

    // Stop the camera to prevent further scanning
    await controller?.pauseCamera();

    try {
      final trashItemID = scanData;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: User not logged in!')),
        );
        return;
      }
      final userID = user.uid;

      DocumentSnapshot trashItemDoc = await _firestore.collection('trashItems').doc(trashItemID).get();

      if (!trashItemDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Invalid QR Code!')),
        );
        return;
      }

      final data = trashItemDoc.data() as Map<String, dynamic>;

      if (data.containsKey('userID')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: This QR Code has already been claimed!')),
        );
        return;
      }

      // Update the trash item with the user ID
      await _firestore.collection('trashItems').doc(trashItemID).update({
        'userID': userID,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR Code claimed successfully!')),
      );

      // Ensure numeric values are converted to strings using .toString()
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRSuccessPage(
            pointsAssigned: data['pointsAssigned'].toString(),  // Convert int to String
            numOfItems: data['numOfItems'].toString(),  // Convert int to String
            itemType: data['type'],
            timestamp: (data['timestamp'] as Timestamp).toDate().toString(),  // Ensure Timestamp is handled correctly
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isScanning = true; // Re-enable scanning after processing
      });
    }
  }


  Future<void> _updateUserWallet(String userID, int pointsAssigned) async {
    try {
      final url = 'https://<your-azure-function-app-url>/updateUserWallet'; // Replace with your actual Azure Function URL
      final response = await http.post(
        Uri.parse(url),
        body: {
          'userID': userID,
          'pointsAssigned': pointsAssigned.toString(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update user wallet.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user wallet: ${e.toString()}')),
      );
    }
  }

  Future<void> _updateUserHistory(String userID, String trashItemID) async {
    try {
      final url = 'https://<your-azure-function-app-url>/updateUserHistory'; // Replace with your actual Azure Function URL
      final response = await http.post(
        Uri.parse(url),
        body: {
          'userID': userID,
          'trashItemID': trashItemID,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update user history.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user history: ${e.toString()}')),
      );
    }
  }

  Future<void> updateUserBadges(String userID, String itemType, int pointsAssigned) async {
    final url = Uri.parse('https://<your-function-app-name>.azurewebsites.net/api/updateUserBadges');

    // Prepare the body of the POST request
    final body = jsonEncode({
      'userID': userID,
      'itemType': itemType,
      'pointsAssigned': pointsAssigned,
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Request successful, handle the response
        final responseData = jsonDecode(response.body);
        print("Badges updated: ${responseData['badgesUnlocked']}");
      } else {
        // Handle error response
        print("Failed to update badges: ${response.statusCode}");
      }
    } catch (e) {
      // Handle any network or parsing errors
      print("Error while calling Azure Function: $e");
    }
  }
  
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Getting screen width for responsive sizing

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Scanner', style: TextStyle(fontFamily: 'Poppins', color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF138A36),
        leading: IconButton(
          icon: SvgPicture.asset('assets/vectors/backArrow.svg'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.fromLTRB(21.2, 30, 20.9, 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 4,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.green,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: MediaQuery.of(context).size.width * 0.6,
                ),
              ),
            ),
            SizedBox(height: 50),
            Text(
              'Scan your QR Code',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.w500,
                fontSize: 18, // Smaller font size
                color: Color(0xFF101010),
              ),
            ),
            Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, screenWidth), // Use the buildBottomNavigationBar here
    );
  }

  Widget buildBottomNavigationBar(BuildContext context, double screenWidth) {
    return Container(
      width: double.infinity, // Ensures the navbar fills the screen width
      padding: EdgeInsets.symmetric(vertical: 20), // Consistent padding as wallet.dart
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, -1), // Position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildMenuItem(context, "Home", "assets/vectors/homeSelected.svg", 30, 30, Colors.green, screenWidth, false, "/profile"),
          buildMenuItem(context, "QR Scan", "assets/vectors/qrCodeHome.svg", 30, 30, Colors.green, screenWidth, true, "/scan_qr"), // Selected Item
          buildMenuItem(context, "My Badges", "assets/vectors/medalHome.svg", 30, 30, Colors.green, screenWidth, false, "/my_badges"),
          buildMenuItem(context, "Settings", "assets/vectors/settingsHome.svg", 30, 30, Colors.green, screenWidth, false, "/settings"),
        ],
      ),
    );
  }

  Widget buildMenuItem(
      BuildContext context,
      String text,
      String assetPath,
      double width,
      double height,
      Color color,
      double screenWidth,
      bool isSelected,
      String route,
      ) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          // Avoid navigation if already selected
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 2), // Increase bottom margin for spacing
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: isSelected
              ? EdgeInsets.symmetric(vertical: 10, horizontal: 7) // More padding for selected item
              : EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                assetPath,
                width: isSelected ? width : width * 0.9, // Slightly increased size for better visibility
                height: isSelected ? height : height * 0.9,
                color: isSelected ? Colors.white : Color(0xFF979797), // Icon color
              ),
              if (isSelected) // Show text only if selected
                Padding(
                  padding: EdgeInsets.only(left: 8), // Adjusted padding for better text spacing
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: screenWidth * 0.035, // Slightly increased text size for better visibility
                      height: 1.3,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
