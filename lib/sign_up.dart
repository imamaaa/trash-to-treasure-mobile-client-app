import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'otp_verify_1.dart';
import 'sign_in_page.dart';

final TextEditingController _firstNameController = TextEditingController();
final TextEditingController _lastNameController = TextEditingController();
final TextEditingController _emailController = TextEditingController();
final TextEditingController _passwordController = TextEditingController();
final TextEditingController _confirmPasswordController = TextEditingController();

void _showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      );
    },
  );
}

class SignUpPage1 extends StatelessWidget {

  // Function to create user collections in Firestore after signup
  Future<void> _createUserCollections(String userID) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Initialize userHistory collection
    await firestore.collection('userHistory').doc(userID).set({
      'active': [],   // Initialize active rewards as an empty list
      'expired': [],  // Initialize expired rewards as an empty list
      'redeemed': [], // Initialize redeemed rewards as an empty list
    });

    // Initialize userBadges collection
    await firestore.collection('userBadges').doc(userID).set({
      'badgesEarned': [], // Empty list of earned badges
      'totalItemsRecycled': 0,
      'totalPointsRecycled': 0,
      'consecutiveDaysRecycled': 0,
      'lastDateRecycled': null,
      'plasticItemsRecycled': 0,
      'paperItemsRecycled': 0,
      'metalItemsRecycled': 0,
    });

    // Initialize userWallets collection
    await firestore.collection('userWallets').doc(userID).set({
      'currentPoints': 0, // Initialize with 0 points
    });

    print('User collections created successfully.');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF138A36),
        ),
        child: Container(
          padding: EdgeInsets.fromLTRB(0, screenHeight * 0.08, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.073),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, screenHeight * 0.0074, screenWidth * 0.053, screenHeight * 0.0074),
                          width: screenWidth * 0.0232,
                          height: screenHeight * 0.0197,
                          child: SvgPicture.asset(
                            'assets/vectors/backArrow.svg',
                          ),
                        ),
                      ),
                      Text(
                        'Sign Up',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.053,
                          height: 1.4,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(screenWidth * 0.064, screenHeight * 0.0296, screenWidth * 0.064, screenHeight * 0.0579),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: screenHeight * 0.0049),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Welcome Aboard!',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: screenWidth * 0.064,
                                height: 1.2,
                                color: Color(0xFF138A36),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(screenWidth * 0.008, 0, screenWidth * 0.008, screenHeight * 0.0394),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Please create a new account',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: screenWidth * 0.032,
                                height: 1.3,
                                color: Color(0xFF343434),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: screenHeight * 0.0394),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              width: screenWidth * 0.568,
                              height: screenHeight * 0.203,
                              child: SvgPicture.asset(
                                'assets/vectors/signUp.svg',
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: screenHeight * 0.0246), // Outer spacing
                          child: TextField(
                            controller: _firstNameController,
                            textCapitalization: TextCapitalization.words, // Auto-capitalization for first name
                            style: TextStyle(fontSize: 16), // Adjust text size as necessary
                            decoration: InputDecoration(
                              labelText: "First Name",
                              hintText: "Enter your first name",
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15), // Padding inside the TextField
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color(0xFFCBCBCB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color(0xFFCBCBCB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color(0xFF138A36)), // Optional: Changes color when focused
                              ),
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(bottom: screenHeight * 0.0246), // Outer spacing
                          child: TextField(
                            controller: _lastNameController,
                            textCapitalization: TextCapitalization.words, // Auto-capitalization for last name
                            style: TextStyle(fontSize: 16), // Adjust text size as necessary
                            decoration: InputDecoration(
                              labelText: "Last Name",
                              hintText: "Enter your last name",
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15), // Padding inside the TextField
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color(0xFFCBCBCB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color(0xFFCBCBCB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color(0xFF138A36)), // Optional: Changes color when focused
                              ),
                            ),
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(bottom: screenHeight * 0.0246), // Outer spacing
                          child: TextField(
                            controller: _emailController,
                            style: TextStyle(fontSize: 16), // Adjust text size as necessary
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            decoration: InputDecoration(
                              labelText: "Email Address",
                              hintText: "e.g., example@example.com",
                              helperText: "Enter your email in the correct format", // Helper text outside the field
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15), // Padding inside the TextField
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color(0xFFCBCBCB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color(0xFFCBCBCB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color(0xFF138A36)), // Optional: Changes color when focused
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: screenHeight * 0.0246),
                          child: TextField(
                            controller: _passwordController,
                            obscureText: true, // Hides the password
                            style: TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelText: "Password",
                              hintText: "Enter your password",
                              helperText: "At least 6 characters",
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color(0xFFCBCBCB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color(0xFFCBCBCB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color(0xFF138A36)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: screenHeight * 0.0246),
                          child: TextField(
                            controller: _confirmPasswordController,
                            obscureText: true, // Hides the password
                            style: TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelText: "Re-enter Password",
                              hintText: "Confirm your password",
                              helperText: "Make sure the passwords match",
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color(0xFFCBCBCB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color(0xFFCBCBCB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: Color(0xFF138A36)),
                              ),
                            ),
                          ),
                        ),



                        GestureDetector(
                          onTap: () async {
                            // Check if the email format is correct
                            if (!EmailValidator.validate(_emailController.text)) {
                              _showErrorDialog(context, "Invalid Email", "Please enter a valid email address.");
                              return;
                            }

                            // Check if passwords match and are at least 6 characters long
                            if (_passwordController.text != _confirmPasswordController.text) {
                              _showErrorDialog(context, "Password Error", "Passwords do not match.");
                              return;
                            }
                            if (_passwordController.text.length < 6) {
                              _showErrorDialog(context, "Password Error", "Password must be at least 6 characters.");
                              return;
                            }

                            try {
                              // Check if the email is already in use
                              var list = await FirebaseAuth.instance.fetchSignInMethodsForEmail(_emailController.text);
                              if (list.isNotEmpty) {
                                _showErrorDialog(context, "Account Error", "Email address already in use.");
                                return;
                              }

                              // Create user and send verification email
                              UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                email: _emailController.text,
                                password: _passwordController.text,
                              );

                              // Save additional user data to Firestore
                              await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
                                'firstName': _firstNameController.text,
                                'lastName': _lastNameController.text,
                                'email': _emailController.text,
                              });

                              // Send verification email
                              userCredential.user?.sendEmailVerification().then((_) {
                                // Call _createUserCollections after sending the email verification
                                _createUserCollections(userCredential.user!.uid);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EmailVerificationPage(email: _emailController.text)),
                                );
                              }).catchError((error) {
                                _showErrorDialog(context, "Email Verification Error", "Failed to send verification email.");
                              });
                            } on FirebaseAuthException catch (e) {
                              _showErrorDialog(context, "Registration Error", e.message ?? "Failed to register.");
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF1E7C4D),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Center(
                              child: Text(
                                'Sign Up',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  height: 1.5,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.3,
                                color: Color(0xFF343434),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignInPage()),
                                );
                              },
                              child: Text(
                                'Sign In',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  height: 1.3,
                                  color: Color(0xFF138A36),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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
