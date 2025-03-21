import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profilePage.dart';
import 'sign_up.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showForgotPasswordDialog() {
    TextEditingController _resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password'),
        content: TextField(
          controller: _resetEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter your email',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              String resetEmail = _resetEmailController.text.trim();
              if (resetEmail.isNotEmpty) {
                try {
                  await _auth.sendPasswordResetEmail(email: resetEmail);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password reset email sent!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${e.toString()}')),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter your email')),
                );
              }
            },
            child: Text('Send'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignIn() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog(context, 'Input Error', 'Please fill in all fields.');
      return;
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    if (!emailRegex.hasMatch(email)) {
      _showErrorDialog(context, 'Invalid Email', 'Please enter a valid email address.');
      return;
    }

    try {
      // Attempt to sign in with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Check if 'disabled' field exists and its value
        if (userData.containsKey('disabled') && userData['disabled'] == true) {
          _showErrorDialog(
            context,
            'Account Disabled',
            'Your account has been disabled. Please contact app support at imamaaamjad@gmail.com.',
          );
          return;
        }
      }

      // If no 'disabled' field or not disabled, proceed to profile page
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase exceptions
      if (e.code == 'user-not-found') {
        _showErrorDialog(context, 'Sign In Error', 'No account found for this email.');
      } else if (e.code == 'wrong-password') {
        _showErrorDialog(context, 'Sign In Error', 'Incorrect password.');
      } else if (e.code == 'invalid-email') {
        _showErrorDialog(context, 'Sign In Error', 'The email address is badly formatted.');
      } else if (e.code == 'user-disabled') {
        _showErrorDialog(context, 'Sign In Error', 'This user has been disabled.');
      } else if (e.code == 'too-many-requests') {
        _showErrorDialog(context, 'Sign In Error', 'Too many attempts. Please try again later.');
      } else {
        _showErrorDialog(context, 'Sign In Error', e.message ?? 'An unexpected error occurred.');
      }
    } catch (e) {
      _showErrorDialog(context, 'Error', 'An unexpected error occurred. Please try again later.');
    }
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
          padding: EdgeInsets.fromLTRB(0, 17.2, 0, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(32.1, 0, 14.7, 44.3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0.2, 0, 0),
                      child: SizedBox(
                        width: 66.7,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(27.3, 0, 27.3, 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        'Sign In',
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
                    padding: EdgeInsets.fromLTRB(24, 23, 24, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 4),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Welcome Back!',
                              style: GoogleFonts.getFont(
                                'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                                height: 1.2,
                                color: Color(0xFF138A36),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 32),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Hello, sign in to continue',
                              style: GoogleFonts.getFont(
                                'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                                height: 1.3,
                                color: Color(0xFF343434),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 32),
                          child: SizedBox(
                            width: 213,
                            height: 165,
                            child: SvgPicture.asset(
                              'assets/vectors/lockAndDots.svg',
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
                          child: TextField(
                            controller: _emailController,
                            style: TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'e.g., example@example.com',
                              helperText: 'Enter your email in the correct format',
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
                              hintStyle: GoogleFonts.getFont(
                                'Poppins',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                height: 1.5,
                                color: Color(0xFFCACACA),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 12),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 15.4,
                                top: 17.7,
                                child: Container(
                                  width: 15.2,
                                  height: 8.3,
                                  child: SizedBox(
                                    width: 15.2,
                                    height: 8.3,
                                    child: SvgPicture.asset(
                                      'assets/vectors/backArrow.svg',
                                      width: 24, // Adjust width for better visibility
                                      height: 24, // Adjust height for better visibility
                                      ),
                                  ),
                                ),
                              ),
                              Container(
                                child: TextField(
                                  controller: _passwordController,
                                  style: TextStyle(fontSize: 16),
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    hintText: 'Enter your password',
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
                                    hintStyle: GoogleFonts.getFont(
                                      'Poppins',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      height: 1.5,
                                      color: Color(0xFFCACACA),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(3.1, 0, 3.1, 20),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              onTap: _showForgotPasswordDialog,
                              child: Text(
                                'Forgot your password?',
                                style: GoogleFonts.getFont(
                                  'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  height: 1.3,
                                  color: Color(0xFFCACACA),
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _handleSignIn,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF1E7C4D),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Center(
                              child: Text(
                                'Sign in',
                                style: GoogleFonts.getFont(
                                  'Poppins',
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
                              'Don\'t have an account? ',
                              style: GoogleFonts.getFont(
                                'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.3,
                                color: Color(0xFF343434),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => SignUpPage1()), // Ensure you have a SignUpPage created
                                );
                              },
                              child: Text(
                                'Sign Up',
                                style: GoogleFonts.getFont(
                                  'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  height: 1.3,
                                  color: Color(0xFF138A36),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
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
