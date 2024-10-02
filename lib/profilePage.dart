import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch total balance from userWallet collection based on the logged-in user's ID
  Future<int> _getUserWalletBalance() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userWalletDoc = await FirebaseFirestore.instance
            .collection('userWallets')
            .doc(user.uid)
            .get();

        if (userWalletDoc.exists) {
          Map<String, dynamic>? data = userWalletDoc.data() as Map<String, dynamic>?;
          int balance = data?['currentPoints'] ?? 0; // Fetch balance, default to 0 if not present
          return balance;
        }
      }
    } catch (e) {
      print("Error fetching wallet balance: $e");
    }
    return 0; // Default balance if there's an issue
  }


  Future<Map<String, String?>> _getUserInfo() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?; // Cast to Map<String, dynamic>
          String firstName = data?['firstName'] ?? '';
          String lastName = data?['lastName'] ?? '';
          String? profilePhotoUrl = data?.containsKey('profilePhoto') == true
              ? data!['profilePhoto']
              : null;

          return {
            'name': '$firstName $lastName',
            'photo': profilePhotoUrl,
          };
        }
      }
    } catch (e) {
      print("Error fetching user info: $e"); // Debug print
    }
    return {'name': 'User Name', 'photo': null};
  }

  Future<void> _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/signinpage'); // Replace with your actual sign-in page route
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          decoration: BoxDecoration(
            color: Color(0xFF138A36),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(0, screenHeight * 0.07, 0, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<Map<String, String?>>(
                      future: _getUserInfo(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Show loading indicator
                        }
                        if (snapshot.hasError) {
                          return Text('Error fetching data');
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return Text('No data available');
                        }

                        final String? profilePhotoUrl = snapshot.data?['photo'];
                        final String name = snapshot.data?['name'] ?? 'User Name';

                        return Container(
                          margin: EdgeInsets.fromLTRB(24, 0, 24, screenHeight * 0.03),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final RenderBox renderBox = context.findRenderObject() as RenderBox;
                                    final Offset offset = renderBox.localToGlobal(Offset.zero);
                                    final Size size = renderBox.size;

                                    showMenu(
                                      context: context,
                                      position: RelativeRect.fromLTRB(
                                        offset.dx + 20, // Horizontal position of the menu
                                        offset.dy + size.height - 30, // Vertical position directly below the profile image
                                        offset.dx + size.width,
                                        offset.dy + size.height + 100, // Adjust this value as needed to control the height
                                      ),
                                      items: [
                                        PopupMenuItem(
                                          child: Text(
                                            "Settings",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.pushNamed(context, '/settings');
                                          },
                                        ),
                                        PopupMenuItem(
                                          child: Text(
                                            "Logout",
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          onTap: () => _logout(context),
                                        ),
                                      ],
                                      color: Color(0xFF4ABD6F), // Green background color
                                    );
                                  },
                                  child: Container(
                                    width: 70, // Increased size
                                    height: 70, // Increased size
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(35), // Circular shape
                                      image: profilePhotoUrl != null
                                          ? DecorationImage(
                                        fit: BoxFit.cover,
                                        image: NetworkImage(profilePhotoUrl),
                                      )
                                          : null, // No DecorationImage if using SVG
                                    ),
                                    child: profilePhotoUrl == null
                                        ? ClipRRect(
                                      borderRadius: BorderRadius.circular(35),
                                      child: SvgPicture.asset(
                                        'assets/vectors/Avatar.svg',
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                        : null, // If a profile photo is available, the image will be handled by DecorationImage
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.fromLTRB(18, 13, 0, 13),
                                  child: Text(
                                    'Hi, $name',
                                    style: GoogleFonts.getFont(
                                      'Poppins',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      height: 1.5,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                decoration: BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Wallet info widget
                    FutureBuilder<int>(
                      future: _getUserWalletBalance(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Loading state
                        } else if (snapshot.hasError) {
                          return Text('Error loading balance');
                        } else if (!snapshot.hasData || snapshot.data == null) {
                          return Text('Balance unavailable');
                        }

                        int totalBalance = snapshot.data!; // Get balance data
                        return buildWalletInfo(context, screenWidth, screenHeight, totalBalance);
                      },
                    ),
                    buildActionButtons(context, screenWidth, screenHeight),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, screenWidth),
    );
  }

  // Build wallet info widget
  Widget buildWalletInfo(BuildContext context, double screenWidth, double screenHeight, int totalBalance) {
    return Container(
      width: screenWidth,
      margin: EdgeInsets.only(top: screenHeight * 0.03, bottom: screenHeight * 0.02),
      height: screenHeight * 0.35, // Adjusted container height
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/vectors/GreenWallet.svg',
              fit: BoxFit.fill, // Ensure the image covers the entire container
            ),
          ),
          Positioned(
            left: 55, // Adjusted for positioning within the SVG
            top: screenHeight * 0.09, // Adjusted for better positioning
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Balance',
                  style: GoogleFonts.getFont(
                    'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: screenWidth * 0.045, // Adjusted font size
                    color: Color(0xFFFFFFFF),
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  '$totalBalance points', // Display fetched balance
                  style: GoogleFonts.getFont(
                    'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.04, // Adjusted font size
                    color: Color(0xFFFFFFFF),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 55, // Adjusted for positioning within the SVG
            bottom: screenHeight * 0.07,
            child: GestureDetector(
              onTap: () {
                // Navigate to history page
                Navigator.pushNamed(context, '/history'); // Navigate to history page
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'History',
                    style: GoogleFonts.getFont(
                      'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.045, // Adjusted font size
                      color: Color(0xFFFFFFFF),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(27),
                    ),
                    width: 32,
                    height: 32,
                    child: Padding(
                      padding: EdgeInsets.all(7),
                      child: SvgPicture.asset(
                        'assets/vectors/rightArrow.svg',
                        width: 10,
                        height: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildActionButtons(BuildContext context, double screenWidth, double screenHeight) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
      child: Wrap(
        spacing: screenWidth * 0.04,
        runSpacing: screenHeight * 0.03,
        children: [
          buildActionButton(context, 'Scan QR', 'assets/vectors/qrScan.svg',
              screenWidth, screenHeight),
          buildActionButton(context, 'Enter PIN', 'assets/vectors/keypad.svg',
              screenWidth, screenHeight),
          buildActionButton(context, 'My Wallet', 'assets/vectors/wallet.svg',
              screenWidth, screenHeight),
          buildActionButton(context, 'History', 'assets/vectors/receipt.svg',
              screenWidth, screenHeight),
          buildActionButton(context, 'Challenges',
              'assets/vectors/trophyFeature.svg', screenWidth, screenHeight),
          buildActionButton(context, 'My Badges', 'assets/vectors/medal.svg',
              screenWidth, screenHeight),
          buildActionButton(context, 'Stores', 'assets/vectors/shop.svg',
              screenWidth, screenHeight),
          buildActionButton(context, 'Feedback', 'assets/vectors/feedback.svg',
              screenWidth, screenHeight),
        ],
      ),
    );
  }

  Widget buildActionButton(BuildContext context, String text, String assetPath, double screenWidth, double screenHeight) {
    return GestureDetector(
      onTap: () {
        switch (text) {
          case "Scan QR":
            Navigator.pushNamed(context, '/scan_qr'); // Navigate to Scan QR page
            break;
          case "History":
            Navigator.pushNamed(context, '/history'); // Navigate to History page
            break;
          case "My Wallet":
            Navigator.pushNamed(context, '/wallet'); // Navigate to My Wallet page
            break;
          case "Feedback":
            Navigator.pushNamed(context, '/feedback'); // Navigate to Feedback page
            break;
          case "Challenges":
            Navigator.pushNamed(context, '/challenges'); // Navigate to Challenges Page
            break;
          case "My Badges":
            Navigator.pushNamed(context, '/my_badges'); // Navigate to Challenges Page
            break;
          case "Enter PIN":
            Navigator.pushNamed(context, '/enter_pin'); // Navigate to Challenges Page
            break;
        //  case "Enter PIN":
        //    Navigator.pushNamed(context, '/challenges'); // Navigate to Enter PIN  page
        //    break;
        }
      },
      child: Container(
        width: screenWidth * 0.4,
        height: screenHeight * 0.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xFFFFFFFF),
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              offset: Offset(0, 5),
              blurRadius: 15,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05), // Adjust padding for better layout
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                assetPath,
                width: screenWidth * 0.1, // Increase size of the vector icons
                height: screenHeight * 0.1, // Increase size of the vector icons
              ),
              SizedBox(height: screenHeight * 0.01), // Add some spacing between icon and text
              Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.getFont(
                  'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: screenWidth * 0.032,
                  height: 1.3,
                  color: Color(0xFF979797),
                ),
              ),
            ],
          ),
        ),
      ),
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
            offset: Offset(0, -1), // Position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildMenuItem(
            context,
            "Home",
            "assets/vectors/homeSelected.svg",
            30,
            30,
            Colors.green,
            screenWidth,
            true, // Mark Home as selected
            "/profile",
          ),
          buildMenuItem(
            context,
            "QR Scan",
            "assets/vectors/qrCodeHome.svg",
            30,
            30,
            Colors.green,
            screenWidth,
            false,
            "/scan_qr",
          ),
          buildMenuItem(
            context,
            "my Badges",
            "assets/vectors/medalHome.svg",
            30,
            30,
            Colors.green,
            screenWidth,
            false,
            "/my_badges",
          ),
          buildMenuItem(
            context,
            "Settings",
            "assets/vectors/settingsHome.svg",
            30,
            30,
            Colors.green,
            screenWidth,
            false,
            "/settings",
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem(BuildContext context, String text, String assetPath, double width, double height, Color color, double screenWidth, bool isSelected, String route) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          Navigator.pushReplacementNamed(context, route); // Navigate only if not selected
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0.8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetPath,
              width: isSelected ? width * 0.9 : width, // Adjust size for visibility
              height: isSelected ? height * 0.9 : height,
              color: isSelected ? Colors.white : Color(0xFF979797), // White if selected, grey otherwise
            ),
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  text,
                  style: GoogleFonts.getFont(
                    'Poppins',
                    fontWeight: FontWeight.w400,
                    fontSize: screenWidth * 0.03,
                    height: 1.3,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
