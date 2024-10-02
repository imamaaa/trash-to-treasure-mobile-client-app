import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart'; // Import intl package

// Format the Firestore timestamp to a user-friendly format
String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  // Format the date (e.g., "Jan 15, 2024 at 3:30 PM")
  String formattedDate = DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  return formattedDate;
}

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
  }

  // Fetch the user history from Firestore
  Future<void> fetchUserHistory() async {
    final userHistoryRef = FirebaseFirestore.instance.collection('userHistory').doc(userId);

    DocumentSnapshot userHistorySnapshot = await userHistoryRef.get();
    if (userHistorySnapshot.exists) {
      // Retrieve arrays for active, redeemed, and expired
      List activeCodes = userHistorySnapshot['active'] ?? [];
      List redeemedCodes = userHistorySnapshot['redeemed'] ?? [];
      List expiredCodes = userHistorySnapshot['expired'] ?? [];

      // Fetch details for each trash item ID and store in the map
      userHistory['active'] = await fetchTrashItemsDetails(activeCodes);
      userHistory['redeemed'] = await fetchTrashItemsDetails(redeemedCodes);
      userHistory['expired'] = await fetchTrashItemsDetails(expiredCodes);

      // Trigger UI update
      setState(() {});
    }
  }

// Fetch details for each trash item ID in the array
  Future<List<Map<String, dynamic>>> fetchTrashItemsDetails(List<dynamic> trashItemIds) async {
    List<Map<String, dynamic>> details = [];

    for (String id in trashItemIds) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('trashItems').doc(id).get();
      if (snapshot.exists) {
        // Add the document ID along with other data
        Map<String, dynamic> itemData = snapshot.data() as Map<String, dynamic>;
        itemData['id'] = snapshot.id; // Store the document ID as 'id'
        details.add(itemData); // Add the entire document data
      }
    }

    return details; // Return the list of item details
  }

  void showCodeDetails(BuildContext context, String trashItemId, String status) async {
    // Fetch the trash item data from Firestore
    DocumentSnapshot trashItem = await FirebaseFirestore.instance.collection('trashItems').doc(trashItemId).get();

    if (trashItem.exists) {
      String pinCode = trashItem['pinCode']; // Assuming your document has a 'pinCode' field
      String qrData = trashItemId; // Data you want to encode in the QR code

      showDialog(
        context: context,
        builder: (context) {
          // Check if the reward is active, redeemed, or expired
          if (status == 'active') {
            // If the reward is active, show the QR code and PIN
            return AlertDialog(
              title: Center(
                child: Text(
                  'Reward Details',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 300, // Fixed width for QR code
                    height: 300, // Fixed height for QR code
                    child: QrImageView(
                      data: qrData, // Encode trashItemId into QR code
                      errorCorrectionLevel: QrErrorCorrectLevel.H,
                      version: QrVersions.auto,
                      gapless: true,
                      backgroundColor: Colors.white,
                      eyeStyle: QrEyeStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: Text(
                      'PIN Code: $pinCode',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ),
              ],
            );
          } else if (status == 'redeemed') {
            // If the reward is redeemed, show this message
            return AlertDialog(
              title: Center(
                child: Text(
                  'Reward Redeemed',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.orange,
                  ),
                ),
              ),
              content: Text(
                'This reward has already been redeemed.',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ),
              ],
            );
          } else if (status == 'expired') {
            // If the reward is expired, show this message
            return AlertDialog(
              title: Center(
                child: Text(
                  'Reward Expired',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.red,
                  ),
                ),
              ),
              content: Text(
                'This reward has expired.',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              actions: [
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ),
              ],
            );
          }
          return Container(); // Fallback (won't usually reach here)
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
        backgroundColor: Color(0xFF138A36),
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/vectors/backArrow.svg'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'History',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
        children: [
          buildHistorySection('Active Rewards', userHistory['active'] ?? []),
          buildHistorySection('Redeemed Rewards', userHistory['redeemed'] ?? []),
          buildHistorySection('Expired Rewards', userHistory['expired'] ?? []),
        ],
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, screenWidth),
    );
  }

  Widget buildHistorySection(String title, List<Map<String, dynamic>> historyList) {
    Color titleColor;

    // Set the color based on the title
    if (title == 'Active Rewards') {
      titleColor = Color(0xFF38A169); // Teal for active codes
    } else if (title == 'Redeemed Rewards') {
      titleColor = Colors.orange; // Green for redeemed codes
    } else if (title == 'Expired Rewards') {
      titleColor = Color(0xFFE53E3E); // Red for expired codes
    } else {
      titleColor = Colors.black; // Default color
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: titleColor,
          ),
        ),
        SizedBox(height: 10),
        ...historyList.map((data) => historyItem(context, data)).toList(),
        SizedBox(height: 20),
      ],
    );
  }
  Widget historyItem(BuildContext context, Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () {
        // Ensure the trash item has a valid ID before showing details
        if (data['id'] != null && data['id'] is String && data['id'].isNotEmpty) {
          showCodeDetails(context, data['id'], data['status']); // Pass the document ID
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Invalid trash item ID or data is missing.'),
          ));
        }
      },
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
                      data['type'] ?? 'unknown type', // Show the type of item
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: Color(0xFF343434),
                      ),
                    ),
                  ),
                  Text(
                    'status: ${data['status'] ?? 'unknown'}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: data['status'] == 'expired'
                          ? Colors.red
                          : data['status'] == 'active'
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'items: ${data['numOfItems'] ?? 'unknown'}', // Show number of items
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.indigo,
                    ),
                  ),
                  Text(
                    'points: ${data['pointsAssigned'] ?? 0}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              // Display the number of items and document ID

              Text(
                formatTimestamp(data['timestamp']), // Format timestamp to a user-friendly format
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: Color(0xFF979797),
                ),
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
