import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profilePage.dart'; // Ensure you have a ProfilePage and it's imported correctly

class OTPSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: BoxDecoration(
          color: Color(0xFFFFFFFF),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(screenWidth * 0.064, screenHeight * 0.14, screenWidth * 0.064, screenHeight * 0.035),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.04),
                child: SizedBox(
                  width: screenWidth * 0.872,
                  height: screenHeight * 0.27,
                  child: SvgPicture.asset(
                    'assets/vectors/verified_person.svg',
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.03),
                child: Text(
                  'Account Verified!',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: screenWidth * 0.043,
                    height: 1.5,
                    color: Color(0xFF138A36),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.03),
                child: Text(
                  'You have successfully made an account.\nPress ‘Ok’ to go to your profile.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: screenWidth * 0.037,
                    height: 1.5,
                    color: Color(0xFF343434),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03), // Adjust the spacing here
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()), // Make sure this navigates to the actual profile page
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF138A36),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015, horizontal: screenWidth * 0.1),
                  child: Text(
                    'Ok',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: screenWidth * 0.043,
                      height: 1.5,
                      color: Color(0xFFFFFFFF),
                    ),
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
