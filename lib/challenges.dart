import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ChallengesPage extends StatelessWidget {
  final List<Map<String, String>> badges = [
    {
      'title': 'First Step',
      'description': 'Recycle your first trash item',
      'icon': 'assets/vectors/first_step.svg'
    },
    {
      'title': 'Recycler Rookie',
      'description': 'Recycle 5 items in total',
      'icon': 'assets/vectors/recycler_rookie.svg'
    },
    {
      'title': 'Plastic Hero',
      'description': 'Recycle 10 plastic items',
      'icon': 'assets/vectors/plastic_hero.svg'
    },
    {
      'title': 'Metal Guardian',
      'description': 'Recycle 15 metal items',
      'icon': 'assets/vectors/metal_guardian.svg'
    },
    {
      'title': 'Paper Saver',
      'description': 'Recycle 20 paper items',
      'icon': 'assets/vectors/paper_saver.svg'
    },
    {
      'title': 'Consistent Crusader',
      'description': 'Recycle every day for a week',
      'icon': 'assets/vectors/consistent_crusader.svg'
    },
    {
      'title': 'Eco Warrior',
      'description': 'Recycle 100 items of any type',
      'icon': 'assets/vectors/eco_warrior.svg'
    },
    {
      'title': 'Green Navigator',
      'description': 'Collect 2000 points in your wallet',
      'icon': 'assets/vectors/green_navigator.svg'
    },
    {
      'title': 'Planet Protector',
      'description': 'Collect 10,000 points in your wallet',
      'icon': 'assets/vectors/planet_protector.svg'
    },
    {
      'title': 'Zero Waste Advocate',
      'description': 'Recycle 150 items cumulative without skipping a day for 30 consecutive days',
      'icon': 'assets/vectors/zero_waste.svg'
    },
  ];

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
          'Challenges',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Color(0xFFFFFFFF),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(17, 20, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with Info Icon
              Row(
                children: [
                  Text(
                    'Badges To Collect',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 19,
                      color: Color(0xFF1E7C4D),
                    ),
                  ),
                  SizedBox(width: 80),
                  GestureDetector(
                    onTap: () => _showInfoDialog(context), // Show dialog when tapped
                    child: Icon(
                      Icons.info_outline,
                      color: Color(0xFF1E7C4D),
                      size: 30,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 50),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: badges.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final badge = badges[index];
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
                          SvgPicture.asset(
                            badge['icon']!,
                            width: 90,
                            height: 90,
                          ),
                          SizedBox(height: 10),
                          Text(
                            badge['title']!,
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
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, screenWidth),
    );
  }

  void _showInfoDialog(BuildContext context) {
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
              // Bold and larger text for the first sentence
              Text(
                'Earn badges by completing challenges!',
                style: GoogleFonts.poppins(
                  fontSize: 16, // Bigger font size
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E7C4D),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10), // Spacing between the texts
              // Smaller, regular text for the second sentence
              Text(
                'Meet the requirements to collect badges and view them on the "My Badges" page.',
                style: GoogleFonts.poppins(
                  fontSize: 14, // Smaller font size
                  color: Color(0xFF555555),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center, // Center the OK button
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


  void _showBadgeDialog(BuildContext context, Map<String, String> badge) {
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
                  SvgPicture.asset(
                    badge['icon']!,
                    width: 60,
                    height: 60,
                  ),
                  SizedBox(height: 10),
                  Text(
                    badge['title']!,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF343434),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    badge['description']!,
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
          buildMenuItem(context, "My Badges", "assets/vectors/medalHome.svg", 30, 30, Colors.green, screenWidth, false, "/my_badges"),
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
