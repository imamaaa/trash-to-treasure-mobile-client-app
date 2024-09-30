import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Add this package in pubspec.yaml for QR code display

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String userId;
  Map<String, List<Map<String, dynamic>>> userHistory = {
    'active': [],
    'redeemed': [],
    'expired': [],
  };

  @override
  void initState() {
    super.initState();
    userId = _auth.currentUser?.uid ?? '';
    fetchUserHistory();
    updateExpiredCodes();
  }

  // Fetch the user history from Firestore
  Future<void> fetchUserHistory() async {
    final userHistoryRef = FirebaseFirestore.instance.collection('userHistory').doc(userId);

    DocumentSnapshot userHistorySnapshot = await userHistoryRef.get();
    if (userHistorySnapshot.exists) {
      List activeCodes = userHistorySnapshot['active'] ?? [];
      List redeemedCodes = userHistorySnapshot['redeemed'] ?? [];
      List expiredCodes = userHistorySnapshot['expired'] ?? [];

      userHistory['active'] = await fetchTrashItemsDetails(activeCodes);
      userHistory['redeemed'] = await fetchTrashItemsDetails(redeemedCodes);
      userHistory['expired'] = await fetchTrashItemsDetails(expiredCodes);
      setState(() {});
    }
  }

  // Fetch details for each trash item ID in the array
  Future<List<Map<String, dynamic>>> fetchTrashItemsDetails(List<dynamic> trashItemIds) async {
    List<Map<String, dynamic>> details = [];
    for (String id in trashItemIds) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('trashItems').doc(id).get();
      if (snapshot.exists) {
        details.add(snapshot.data() as Map<String, dynamic>);
      }
    }
    return details;
  }


  // Function to display code details in a dialog
  void showCodeDetails(BuildContext context, String trashItemId) async {
    // Fetch the trash item data from Firestore
    DocumentSnapshot trashItem = await FirebaseFirestore.instance.collection('trashItems').doc(trashItemId).get();

    if (trashItem.exists) {
      String pinCode = trashItem['pinCode']; // Assuming your document has a 'pinCode' field
      String qrData = trashItemId; // Data you want to encode in the QR code

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Code Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                QrImage(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
                SizedBox(height: 10),
                Text('PIN Code: $pinCode', style: TextStyle(fontSize: 16)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/vectors/backArrow.svg'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Back to Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Color(0xFF343434),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
        children: [
          buildHistorySection('Active Codes', userHistory['active']),
          buildHistorySection('Redeemed Codes', userHistory['redeemed']),
          buildHistorySection('Expired Codes', userHistory['expired']),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, screenWidth),
    );
  }

  // Builds each section of history (active, redeemed, expired)
  Widget buildHistorySection(String title, List<Map<String, dynamic>> historyList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
        ...historyList.map((data) => historyItem(context, data)).toList(),
        SizedBox(height: 20),
      ],
    );
  }

  // Builds each history item tile
  Widget historyItem(BuildContext context, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () => showCodeDetails(context, data['id']),
      child: Container(
        margin: EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x123629B7),
              offset: Offset(0, 4),
              blurRadius: 15,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      data['type'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Color(0xFF343434),
                      ),
                    ),
                  ),
                  Text(
                    data['timestamp'].toDate().toString(), // Assuming timestamp is stored
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF979797),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Status: ${data['status']}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: data['status'] == 'Expired'
                          ? Colors.red
                          : data['status'] == 'Redeemed'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                  Text(
                    'Points: ${data['points']}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFF138A36),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom Navigation Bar
  Widget buildBottomNavigationBar(BuildContext context, double screenWidth) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildMenuItem(context, "Home", "assets/vectors/homeSelected.svg", 30, 30, Colors.green, screenWidth, false, "/profile"),
          buildMenuItem(context, "QR Scan", "assets/vectors/qrCodeHome.svg", 30, 30, Colors.green, screenWidth, false, "/scan_qr"),
          buildMenuItem(context, "my Badges", "assets/vectors/medalHome.svg", 30, 30, Colors.green, screenWidth, false, "/my_badges"),
          buildMenuItem(context, "Settings", "assets/vectors/settingsHome.svg", 30, 30, Colors.green, screenWidth, false, "/settings"),
        ],
      ),
    );
  }

  // Menu Item for Bottom Navigation
  Widget buildMenuItem(BuildContext context, String text, String assetPath,
      double width, double height, Color color, double screenWidth, bool isSelected, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0.8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                assetPath,
                width: isSelected ? width * 0.9 : width,
                height: isSelected ? height * 0.9 : height,
                color: isSelected ? Color(0xFF138A36) : Color(0xFF979797),
              ),
              if (isSelected)
                Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: screenWidth * 0.03,
                      height: 1.3,
                      color: Colors.black,
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
