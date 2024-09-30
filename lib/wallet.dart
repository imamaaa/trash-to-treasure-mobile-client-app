import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletPage extends StatefulWidget {
  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String currentPoints = '0';

  @override
  void initState() {
    super.initState();
    fetchPoints();
  }

  Future<void> fetchPoints() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('userWallets')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          setState(() {
            currentPoints = snapshot['currentPoints'].toString();
          });
        }
      } catch (e) {
        print('Error fetching points: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching points: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Wallet',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Color(0xFFFFFFFF),
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Color(0xFF138A36),
        leading: IconButton(
          icon: SvgPicture.asset('assets/vectors/backArrow.svg'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(17, 59, 16, 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Wallet Image
              Container(
                width: double.infinity,
                height: 200,
                child: SvgPicture.asset('assets/vectors/getPointsWallet.svg'),
              ),
              // Adding gap between the image and points earned
              SizedBox(height: 50),
              // Full-width rectangular Card with Custom Color
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width: 2), // Adds a green border to the Card
              borderRadius: BorderRadius.circular(15), // Optional: matches the Card's border radius
            ),
              child: SizedBox(
                width: double.infinity,
                child: Card(
                  color: Color(0xFFFFFFFF), // Card background color
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Rounded corners
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 0), // Optional: Set to zero if you want the card to touch the screen edges
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center, // Ensures the text is centered horizontally
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 50,
                          color: Color(0xFFFFEB3B),
                        ),
                        SizedBox(height: 10),
                        // Points Label Text
                        Text(
                          'Points Earned',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF138A36),
                          ),
                        ),
                        SizedBox(height: 5), // Optional: Add spacing between label and points
                        // Points Value Text
                        Text(
                          currentPoints,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 2,
                            color: Color(0xFF138A36),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    ),

              SizedBox(height: 60),

              // Buttons Column: Confirm and History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to the Profile page
                        Navigator.pushReplacementNamed(context, '/profile');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF138A36),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Center(
                          child: Text(
                            'Confirm',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10), // Add space between the buttons
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to the History page
                        Navigator.pushNamed(context, '/history');
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF138A36),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Center(
                          child: Text(
                            'History',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, screenWidth),
    );
  }

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
          buildMenuItem(context, "Home", "assets/vectors/homeSelected.svg", 30,
              30, Colors.green, screenWidth, false, "/profile"),
          buildMenuItem(context, "QR Scan", "assets/vectors/qrCodeHome.svg", 30,
              30, Colors.green, screenWidth, false, "/scan_qr"),
          buildMenuItem(context, "my Badges", "assets/vectors/medalHome.svg", 30,
              30, Colors.green, screenWidth, false, "/my_badges"),
          buildMenuItem(context, "Settings", "assets/vectors/settingsHome.svg",
              30, 30, Colors.green, screenWidth, false, "/settings"),
        ],
      ),
    );
  }

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
