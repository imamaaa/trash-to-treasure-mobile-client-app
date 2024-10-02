import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'qr_success.dart';
import 'package:intl/intl.dart';

class EnterPINCodePage extends StatefulWidget {
  @override
  _EnterPINCodePage createState() => _EnterPINCodePage();
}

class _EnterPINCodePage extends State<EnterPINCodePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSubmitting = false;
  int _currentFocusedIndex = -1; // Track the currently focused index


  // Create 6 TextEditingControllers for each digit
  final List<TextEditingController> _pinControllers =
  List.generate(6, (index) => TextEditingController());

  Future<void> _submitPinCode() async {
    setState(() {
      _isSubmitting = true;
    });

    final pinCodeString = _pinControllers.map((e) => e.text).join(); // Collect all digits
    final pinCode = int.tryParse(pinCodeString); // Convert to integer
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: User not logged in!')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    try {
      final trashItemDoc = await _firestore
          .collection('trashItems')
          .where('pinCode', isEqualTo: pinCode)
          .limit(1)
          .get();

      if (trashItemDoc.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid PIN Code!')),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final trashItemData = trashItemDoc.docs.first.data();
      final trashItemId = trashItemDoc.docs.first.id;

      // Check if the userID field exists in the trashItem doc
      if (trashItemData.containsKey('userID') && trashItemData['userID'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: This reward has already been claimed!')),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Update the userID in the trashItem doc with the current user's ID
      await _firestore.collection('trashItems').doc(trashItemId).update({
        'userID': user.uid,
      });

      // Fetch the required fields from the trashItem document
      final pointsAssigned = trashItemData['pointsAssigned'] ?? 0;
      final numOfItems = trashItemData['numOfItems'] ?? 0;
      final itemType = trashItemData['type'] ?? '';

      // Convert Firestore Timestamp to DateTime and format it
      final Timestamp timestamp = trashItemData['timestamp'];
      final DateTime dateTime = timestamp.toDate(); // Convert to DateTime
      final String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(dateTime); // Format the DateTime

      // Call Azure Functions for updateuserbadges, updateuserwallets, updateuserHistory
      /* await _callAzureFunctions(
        userID: user.uid,
        trashItemID: trashItemId,
        itemType: itemType,
        pointsAssigned: pointsAssigned,
    );
    */

      // Navigate to qr_success page and pass the required data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRSuccessPage(
            pointsAssigned: pointsAssigned.toString(), // Convert int to String
            numOfItems: numOfItems.toString(),         // Convert int to String
            itemType: itemType,                        // Already String
            timestamp: formattedDate,                  // Pass the formatted DateTime
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }



  Widget _buildPinBox({
    required TextEditingController controller,
    required int index,
  }) {
    return Container(
      width: 50,
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        border: Border.all(
          color: _currentFocusedIndex == index ? Colors.green : Colors.grey, // Change based on focus
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: '',
        ),
        onTap: () {
          setState(() {
            _currentFocusedIndex = index; // Update the focused box
          });
        },
          onChanged: (value) {
            if (value.isNotEmpty && index < _pinControllers.length - 1) {
              FocusScope.of(context).nextFocus(); // Move to the next field
            } else if (index == _pinControllers.length - 1) {
              FocusScope.of(context).unfocus(); // Hide the keyboard if it's the last field
            }
          }

      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Getting screen width for responsive sizing

    return Scaffold(
      appBar: AppBar(
        title: Text('PIN Code Reader', style: TextStyle(fontFamily: 'Poppins', color: Color(0xFFFFFFFF), fontWeight: FontWeight.w600)),
        backgroundColor: Color(0xFF138A36),
        leading: IconButton(
          icon: SvgPicture.asset('assets/vectors/backArrow.svg'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 70),
            Text(
              'Enter PIN Code',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),

            ),
            SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) {
            return _buildPinBox(
                  controller: _pinControllers[index],
                  index: index,
                  );
                }),
            ),
            SizedBox(height: 60),
            _isSubmitting
                ? CircularProgressIndicator()
                : TextButton(
              onPressed: _submitPinCode,
              style: TextButton.styleFrom(
                backgroundColor: Colors.green, // Set background to green
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              child: Text('Submit', style:TextStyle(color: Colors.white)),
            ),


          ],
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, screenWidth), // Use the buildBottomNavigationBar here
    );
  }

  Widget buildBottomNavigationBar(BuildContext context, double screenWidth) {
    return Container(
      width: double.infinity, // Ensures the navbar fills the screen width
      padding: EdgeInsets.symmetric(vertical: 20), // Consistent padding as wallet.dart
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
          buildMenuItem(context, "Home", "assets/vectors/homeSelected.svg", 30, 30, Colors.green, screenWidth, false, "/profile"),
          buildMenuItem(context, "QR Scan", "assets/vectors/qrCodeHome.svg", 30, 30, Colors.green, screenWidth, false, "/scan_qr"), // Selected Item
          buildMenuItem(context, "My Badges", "assets/vectors/medalHome.svg", 30, 30, Colors.green, screenWidth, false, "/my_badges"),
          buildMenuItem(context, "Settings", "assets/vectors/settingsHome.svg", 30, 30, Colors.green, screenWidth, false, "/settings"),
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
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 2), // Increase bottom margin for spacing
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: isSelected
              ? EdgeInsets.symmetric(vertical: 10, horizontal: 7) // More padding for selected item
              : EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                assetPath,
                width: isSelected ? width : width * 0.9, // Slightly increased size for better visibility
                height: isSelected ? height : height * 0.9,
                color: isSelected ? Colors.white : Color(0xFF979797), // Icon color
              ),
              if (isSelected) // Show text only if selected
                Padding(
                  padding: EdgeInsets.only(left: 8), // Adjusted padding for better text spacing
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: screenWidth * 0.035, // Slightly increased text size for better visibility
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
}
