import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'sign_in_page.dart';
import 'sign_up.dart'; // Import your SignUpPage1

class GetStartedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 1),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 150),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Welcome to TrashToTreasure',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color.fromRGBO(51, 51, 51, 1),
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.normal,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 40),
                    _buildFeature(
                      'assets/vectors/qrcode.svg',
                      'QR Code Scanning',
                      'Scan to earn points - Recycling made quick and smart',
                    ),
                    SizedBox(height: 24),
                    _buildFeature(
                      'assets/vectors/dashboard.svg',
                      'Real-Time Point Tracking',
                      'Watch your eco-savings grow in real-time with every item you recycle',
                    ),
                    SizedBox(height: 24),
                    _buildFeature(
                      'assets/vectors/gift.svg',
                      'Redeem Points',
                      'Turn your trash into treasure – Use your points at partnered stores and cafes',
                    ),
                    SizedBox(height: 24),
                    _buildFeature(
                      'assets/vectors/trophy.svg',
                      'Green Quests',
                      'Take on recycling challenges, earn badges, and level up your environmental impact',
                    ),
                    SizedBox(height: 40),
                    _buildGetStartedButton(context),
                    SizedBox(height: 8),
                    _buildSignInPrompt(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(String assetPath, String title, String description) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          SvgPicture.asset(
            assetPath,
            width: 40,
            height: 40,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color.fromRGBO(51, 51, 51, 1),
                    fontFamily: 'Roboto',
                    fontSize: 15,
                    fontWeight: FontWeight.normal,
                    height: 1,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  description,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Color.fromRGBO(137, 137, 137, 1),
                    fontFamily: 'Roboto',
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to the SignUpPage1 when the button is pressed
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignUpPage1()), // Link to your sign-up page
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color.fromRGBO(30, 124, 77, 1),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        child: Center(
          child: Text(
            'Get started',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontFamily: 'Roboto',
              fontSize: 16,
              fontWeight: FontWeight.normal,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInPrompt(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Already have an account?',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Color.fromRGBO(51, 51, 51, 1),
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              height: 1,
            ),
          ),
          SizedBox(width: 4),
          Text(
            'Sign in',
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Color.fromRGBO(30, 124, 77, 1),
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
