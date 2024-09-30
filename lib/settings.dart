import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profilePage.dart';
import 'changeName.dart';
import 'changePass.dart';
import 'changePhoto.dart';

class SettingsPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String appInformationUrl = 'https://drive.google.com/file/d/1kmGazSF5fhuC_ICpDqKO5pUS4hIWLRIm/view?usp=sharing';
  final String customerCarePhoneNumber = '+92 9999999';

  Future<Map<String, String?>> _getUserInfo() async {
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
    return {'name': 'User Name', 'photo': null};
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      // The URL was launched successfully
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await launchUrl(phoneUri)) {
      // The phone dialer was opened successfully
    } else {
      throw 'Could not launch $phoneUri';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Getting screen width for responsive sizing

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF138A36),
                ),
                child: Container(
                  padding: EdgeInsets.fromLTRB(0, 65, 0, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Bar Section
                      Container(
                        margin: EdgeInsets.fromLTRB(27.3, 0, 27.3, 67),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => ProfilePage()),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 6, 20, 6),
                                  width: 8.7,
                                  height: 16,
                                  child: SvgPicture.asset(
                                    'assets/vectors/backArrow.svg',
                                  ),
                                ),
                              ),
                              Text(
                                'Settings',
                                style: GoogleFonts.getFont(
                                  'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                  height: 1.4,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x0D000000),
                              offset: Offset(0, -2),
                              blurRadius: 1.5,
                            ),
                          ],
                        ),
                        child: Container(
                          padding: EdgeInsets.fromLTRB(0, 80, 0, 0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Fetch user info section
                              FutureBuilder<Map<String, String?>>(
                                future: _getUserInfo(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator(); // Show loading indicator while fetching data
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error fetching data');
                                  }
                                  final String? profilePhotoUrl = snapshot.data?['photo'];
                                  final String name = snapshot.data?['name'] ?? 'User Name';

                                  return Column(
                                    children: [
                                      // User profile photo
                                      Container(
                                        width: 100,
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.circular(50),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 10,
                                              offset: Offset(0, 5),
                                            ),
                                          ],
                                          image: profilePhotoUrl != null
                                              ? DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(profilePhotoUrl),
                                          )
                                              : null, // No DecorationImage if using SVG
                                        ),
                                        child: profilePhotoUrl == null
                                            ? ClipRRect(
                                          borderRadius: BorderRadius.circular(50),
                                          child: SvgPicture.asset(
                                            'assets/vectors/Avatar.svg',
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                            : null, // If a profile photo is available, the image will be handled by DecorationImage
                                      ),

                                      SizedBox(height: 10),
                                      // User name
                                      Text(
                                        name,
                                        style: GoogleFonts.getFont(
                                          'Poppins',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          height: 1.5,
                                          color: Color(0xFF138A36),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              SizedBox(height: 20),
                              // Change Password
                              _buildSettingsOption(
                                context,
                                title: 'Change Password',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ChangePasswordPage()),
                                  );
                                },
                              ),
                              // Change Name
                              _buildSettingsOption(
                                context,
                                title: 'Change Name',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ChangeName()),
                                  );
                                },
                              ),
                              // Change Profile Photo
                              _buildSettingsOption(
                                context,
                                title: 'Change Profile Photo',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ChangePhotoPage()),
                                  );
                                },
                              ),
                              // App information
                              _buildSettingsOption(
                                context,
                                title: 'App Information',
                                onTap: () {
                                  _launchURL(appInformationUrl); // Open Google Drive link
                                },
                              ),
                              // Customer care option
                              _buildSettingsOption(
                                context,
                                title: 'Customer Care',
                                rightWidget: Text(
                                  customerCarePhoneNumber,
                                  style: GoogleFonts.getFont(
                                    'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    height: 1.3,
                                    color: Color(0xFF979797),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  _makePhoneCall(customerCarePhoneNumber); // Open phone dialer
                                },
                              ),
                              SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
            offset: Offset(0, -1), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildMenuItem(context, "Home", "assets/vectors/homeSelected.svg", 30, 30, Colors.green, screenWidth, false, "/profile"),
          buildMenuItem(context, "QR Scan", "assets/vectors/qrCodeHome.svg", 30, 30, Colors.green, screenWidth, false, "/scan_qr"),
          buildMenuItem(context, "my Badges", "assets/vectors/medalHome.svg", 30, 30, Colors.green, screenWidth, false, "/my_badges"),
          buildMenuItem(context, "Settings", "assets/vectors/settingsHome.svg", 30, 30, Colors.green, screenWidth, true, "/settings"), // Selected Item
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
          // Navigate to the corresponding route if the item is not already selected
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0.8), // Spacing adjustment
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
                color: isSelected ? Colors.white : Color(0xFF979797),
              ),
              if (isSelected)
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
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
      ),
    );
  }

  Widget _buildSettingsOption(BuildContext context, {required String title, Widget? rightWidget, required Function onTap}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        margin: EdgeInsets.fromLTRB(24, 0, 24, 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 4, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.getFont(
                      'Poppins',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      height: 1.5,
                      color: Color(0xFF343434),
                    ),
                  ),
                  rightWidget ??
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 4.4, 0, 4.4),
                        width: 8.3,
                        height: 15.2,
                        child: SvgPicture.asset(
                          'assets/vectors/rightArrow.svg',
                        ),
                      ),
                ],
              ),
            ),
            Divider(color: Color(0xFFECECEC), thickness: 1),
          ],
        ),
      ),
    );
  }
}