import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'settings.dart';


class PassSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 375,
              height: 812,
              decoration: BoxDecoration(color: Colors.white),
              child: Stack(
                children: [
                  // Back arrow positioned at the top-left corner
                  Positioned(
                    left: 24,
                    top: 70,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SettingsPage()),
                        );
                      },
                      child: SvgPicture.asset(
                        'assets/vectors/backArrow.svg',
                        width: 26,
                        height: 26,
                        colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  // passChangeSuccess.svg centered in the page
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 160,
                    child: SvgPicture.asset(
                      'assets/vectors/passChangeSuccess.svg',
                      width: 200,
                      height: 200,
                    ),
                  ),
                  // Success message
                  Positioned(
                    left: 58,
                    right: 58,
                    top: 380,
                    child: Text(
                      'Changed password successfully!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF138A36),
                        fontSize: 19,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Informative message below the success text
                  Positioned(
                    left: 24,
                    right: 24,
                    top: 495,
                    child: SizedBox(
                      width: 327,
                      child: Text(
                        'Please use the new password when signing in.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF333333),
                          fontSize: 14,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // "Ok" button at the bottom
                  Positioned(
                    left: 24,
                    right: 24,
                    top: 580, // Moved further down for cleaner spacing
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SettingsPage()),
                        );
                      },
                      child: Container(
                        width: 327,
                        height: 44,
                        decoration: ShapeDecoration(
                          color: Color(0xFF138A36),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Ok',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
