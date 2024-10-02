import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyBadgesPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _getEarnedBadges() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Fetch user's badgesEarned array from userBadges collection
      DocumentSnapshot userBadgesSnapshot =
      await _firestore.collection('userBadges').doc(user.uid).get();

      if (userBadgesSnapshot.exists) {
        // Check if the badgesEarned array is available and has data
        List<dynamic> badgeList = userBadgesSnapshot['badgesEarned'] ?? [];

        if (badgeList.isNotEmpty) {
          // Fetch badge details from challenges collection based on badge IDs
          QuerySnapshot badgesSnapshot = await _firestore
              .collection('challenges')
              .where(FieldPath.documentId, whereIn: badgeList)
              .orderBy('rank', descending: false) // Order by rank ascending
              .get();

          // Convert Firestore documents into a list of maps (badge details)
          return badgesSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        }
      }
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF138A36),
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/vectors/backArrow.svg', width: 24, height: 24),
          onPressed: () => Navigator.of(context).pop(),
          color: Colors.black,
        ),
        title: Text(
          'My Badges',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getEarnedBadges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error fetching earned badges'));
          }

          final hasBadges = snapshot.hasData && snapshot.data!.isNotEmpty;

          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(17, 20, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Earned Badges',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 19,
                          color: Color(0xFF1E7C4D),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showInfoDialog(context, hasBadges),
                        child: Icon(
                          Icons.info_outline,
                          color: Color(0xFF1E7C4D),
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                  if (!hasBadges)
                    Center(
                      child: Text(
                        'You have not earned any badges yet. View the "Challenges" page to see all badges you can unlock.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (context, index) {
                        final badge = snapshot.data![index];
                        return GestureDetector(
                          onTap: () => _showBadgeDialog(context, badge),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.09),
                                  offset: Offset(0, 5),
                                  blurRadius: 30,
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.network(
                                  badge['icon'],
                                  width: 90,
                                  height: 90,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  badge['title'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color.fromRGBO(151, 151, 151, 1),
                                    fontFamily: 'Poppins',
                                    fontSize: 15,
                                    fontWeight: FontWeight.normal,
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
          );
        },
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, screenWidth),
    );
  }

  // Info dialog
  void _showInfoDialog(BuildContext context, bool hasBadges) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                hasBadges
                    ? 'Congratulations on reaching milestones!'
                    : 'View the Challenges page to see all badges you can unlock.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E7C4D),
                ),
                textAlign: TextAlign.center,
              ),
              if (hasBadges) SizedBox(height: 30),
              if (!hasBadges) SizedBox(height: 30),
              Text(
                hasBadges
                    ? 'You’ve earned some awesome badges. Keep exploring new challenges to unlock more!'
                    : 'Complete challenges to earn badges and track your achievements on this page.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Color(0xFF555555),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E7C4D),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  // Badge dialog
  void _showBadgeDialog(BuildContext context, Map<String, dynamic> badge) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.network(
                    badge['icon'],
                    width: 60,
                    height: 60,
                  ),
                  SizedBox(height: 10),
                  Text(
                    badge['title'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF343434),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    badge['description'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: Color(0xFF979797),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
          buildMenuItem(context, "Home", "assets/vectors/homeSelected.svg", 30, 30, Colors.green, screenWidth, false, "/profile"),
          buildMenuItem(context, "QR Scan", "assets/vectors/qrCodeHome.svg", 30, 30, Colors.green, screenWidth, false, "/scan_qr"),
          buildMenuItem(context, "My Badges", "assets/vectors/medalHome.svg", 30, 30, Colors.green, screenWidth, true, "/my_badges"),
          buildMenuItem(context, "Settings", "assets/vectors/settingsHome.svg", 30, 30, Colors.green, screenWidth, false, "/settings"),
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
          padding: isSelected ? EdgeInsets.symmetric(vertical: 10, horizontal: 7)
              : EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                      fontSize: screenWidth * 0.035,
                      height: 1.5,
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
