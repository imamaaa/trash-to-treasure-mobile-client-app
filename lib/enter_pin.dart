import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'qr_success.dart';

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

    if (pinCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid PIN Code entered!')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User not logged in!')),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    try {
      final trashItemDoc = await _firestore
          .collection('trashItems')
          .where('pinCode', isEqualTo: pinCode) // Compare the integer PIN code
          .limit(1)
          .get();

      if (trashItemDoc.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid PIN Code!')),
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
          const SnackBar(content: Text('Error: This reward has already been claimed!')),
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

      // Call the client-side functions
      await _updateUserWallet(user.uid, pointsAssigned);
      await _updateUserHistory(user.uid, trashItemId);
      await updateUserBadges(user.uid, itemType, pointsAssigned, numOfItems);

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

  // Function to update user wallet balance in Firestore
  Future<void> _updateUserWallet(String userID, int pointsAssigned) async {
    try {
      DocumentReference userWalletRef = _firestore.collection('userWallets').doc(userID);
      DocumentSnapshot userWalletDoc = await userWalletRef.get();

      if (userWalletDoc.exists) {
        int currentPoints = userWalletDoc['currentPoints'];
        int newPoints = currentPoints + pointsAssigned;

        await userWalletRef.update({
          'currentPoints': newPoints,
        });

        // Example for sending a wallet update notification
        _sendTopNotification(
          'Wallet Updated',
          'Your current balance is ${newPoints} Points',
          'https://firebasestorage.googleapis.com/v0/b/trashtotreasure-4a540.appspot.com/o/featureIcons%2Fwallet.svg?alt=media&token=678c0d5a-b1e1-40fc-a23c-4af4f854a7a6',  // Add the correct path
        );
      } else {
        throw Exception('Wallet not found.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user wallet: ${e.toString()}')),
      );
    }
  }

  // Function to update user history in Firestore
  Future<void> _updateUserHistory(String userID, String trashItemID) async {
    try {
      DocumentReference userHistoryRef = _firestore.collection('userHistory').doc(userID);
      DocumentSnapshot userHistoryDoc = await userHistoryRef.get();

      if (userHistoryDoc.exists) {
        List activeRewards = List.from(userHistoryDoc['active'] ?? []);
        activeRewards.add(trashItemID);

        await userHistoryRef.update({
          'active': activeRewards,
        });

        // Example for sending a history update notification
        _sendTopNotification(
          'History Updated',
          'Your history has been updated. View your active rewards.',
          'https://firebasestorage.googleapis.com/v0/b'
              '/trashtotreasure-4a540.appspot.com/o/featureIcons%2Freceipt.svg?alt=media&token=f3abdf67-f6f8-4275-be97-71678f3a226f',  // Add the correct path
        );
      } else {
        throw Exception('History not found.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user history: ${e.toString()}')),
      );
    }
  }

  // Function to update user badges in Firestore
  Future<void> updateUserBadges(String userID, String itemType, int pointsAssigned, int numOfItems) async {
    try {
      DocumentReference userBadgesRef = _firestore.collection('userBadges').doc(userID);
      DocumentSnapshot userBadgesDoc = await userBadgesRef.get();

      if (userBadgesDoc.exists) {
        Map<String, dynamic> badgesData = userBadgesDoc.data() as Map<String, dynamic>;
        DateTime today = DateTime.now();
        DateTime? lastDateRecycled;

        // Update lastDateRecycled and handle consecutiveDaysRecycled logic
        if (badgesData['lastDateRecycled'] != null) {
          lastDateRecycled = (badgesData['lastDateRecycled'] as Timestamp).toDate();
        }

        if (lastDateRecycled != null) {
          int daysDifference = today.difference(lastDateRecycled).inDays;

          if (daysDifference > 1) {
            badgesData['consecutiveDaysRecycled'] = 1;
          } else if (daysDifference == 1) {
            badgesData['consecutiveDaysRecycled'] = (badgesData['consecutiveDaysRecycled'] ?? 0) + 1;
          }
        } else {
          badgesData['consecutiveDaysRecycled'] = 1;
        }

        badgesData['lastDateRecycled'] = Timestamp.fromDate(today);
        badgesData['totalPointsRecycled'] = (badgesData['totalPointsRecycled'] ?? 0) + pointsAssigned;
        badgesData['totalItemsRecycled'] = (badgesData['totalItemsRecycled'] ?? 0) + numOfItems;  // Total items recycled

        // Update recycled item count by type
        if (itemType == 'plastic') {
          badgesData['plasticItemsRecycled'] = (badgesData['plasticItemsRecycled'] ?? 0) + numOfItems;
        } else if (itemType == 'paper') {
          badgesData['paperItemsRecycled'] = (badgesData['paperItemsRecycled'] ?? 0) + numOfItems;
        } else if (itemType == 'metal') {
          badgesData['metalItemsRecycled'] = (badgesData['metalItemsRecycled'] ?? 0) + numOfItems;
        }

        // Fetch available badges from challenges collection
        QuerySnapshot challengesSnapshot = await _firestore.collection('challenges').get();
        List<String> unlockedBadges = List.from(badgesData['badgesEarned'] ?? []);

        // Check badge unlock conditions for all badges
        for (QueryDocumentSnapshot challenge in challengesSnapshot.docs) {
          Map<String, dynamic> challengeData = challenge.data() as Map<String, dynamic>;
          String badgeID = challenge.id;
          String badgeName = challengeData['title'];
          String badgeIcon = challengeData['icon'];

          // First Step Badge
          if (badgeName == 'First Step' && _getTotalItemsRecycled(badgesData) >= 1 && !_isBadgeUnlocked(badgeID, unlockedBadges)) {
            unlockedBadges.add(badgeID);
            _sendTopNotification(badgeName, 'Congratulations! You\'ve taken your first step towards a greener planet by recycling your first item!', badgeIcon);
          }

          // Recycler Rookie Badge
          if (badgeName == 'Recycler Rookie' && _getTotalItemsRecycled(badgesData) >= 5 && !_isBadgeUnlocked(badgeID, unlockedBadges)) {
            unlockedBadges.add(badgeID);
            _sendTopNotification(badgeName, 'Keep going! You\'ve recycled 5 items. Every bit helps!', badgeIcon);
          }

          // Green Navigator Badge
          if (badgeName == 'Green Navigator' && badgesData['totalPointsRecycled'] >= 2000 && !_isBadgeUnlocked(badgeID, unlockedBadges)) {
            unlockedBadges.add(badgeID);
            _sendTopNotification(badgeName, 'You\'re finding the way to a greener world! 2000 points achieved, keep navigating!', badgeIcon);
          }

          // Plastic Hero Badge
          if (badgeName == 'Plastic Hero' && badgesData['plasticItemsRecycled'] >= 10 && !_isBadgeUnlocked(badgeID, unlockedBadges)) {
            unlockedBadges.add(badgeID);
            _sendTopNotification(badgeName, 'Plastic waste, beware! You\'ve saved 10 plastic items from polluting the environment.', badgeIcon);
          }

          // Paper Saver Badge
          if (badgeName == 'Paper Saver' && badgesData['paperItemsRecycled'] >= 20 && !_isBadgeUnlocked(badgeID, unlockedBadges)) {
            unlockedBadges.add(badgeID);
            _sendTopNotification(badgeName, 'You\'re making waves in the world of paper recycling!', badgeIcon);
          }

          // Consistent Crusader Badge
          if (badgeName == 'Consistent Crusader' && badgesData['consecutiveDaysRecycled'] >= 7 && !_isBadgeUnlocked(badgeID, unlockedBadges)) {
            unlockedBadges.add(badgeID);
            _sendTopNotification(badgeName, 'Consistency is key! You\'ve recycled for a whole week. Keep up the great work!', badgeIcon);
          }

          // Metal Guardian Badge
          if (badgeName == 'Metal Guardian' && badgesData['metalItemsRecycled'] >= 15 && !_isBadgeUnlocked(badgeID, unlockedBadges)) {
            unlockedBadges.add(badgeID);
            _sendTopNotification(badgeName, 'Metal guardian in action! You\'ve recycled 15 metal items.', badgeIcon);
          }

          // Green Warrior Badge
          if (badgeName == 'Green Warrior' && _getTotalItemsRecycled(badgesData) >= 100 && !_isBadgeUnlocked(badgeID, unlockedBadges)) {
            unlockedBadges.add(badgeID);
            _sendTopNotification(badgeName, 'You\'ve achieved warrior status! 100 items recycled. Impressive!', badgeIcon);
          }

          // Planet Protector Badge
          if (badgeName == 'Planet Protector' && badgesData['totalPointsRecycled'] >= 10000 && !_isBadgeUnlocked(badgeID, unlockedBadges)) {
            unlockedBadges.add(badgeID);
            _sendTopNotification(badgeName, 'You\'re a Planet Protector! Protecting the planet with 10,000 points collected!', badgeIcon);
          }

          // Zero Waste Advocate Badge
          if (badgeName == 'Zero Waste Advocate' && _getTotalItemsRecycled(badgesData) >= 100 && badgesData['consecutiveDaysRecycled'] >= 30 && !_isBadgeUnlocked(badgeID, unlockedBadges)) {
            unlockedBadges.add(badgeID);
            _sendTopNotification(badgeName, 'You\'re leading the charge for zero waste with 100 items recycled in a month!', badgeIcon);
          }
        }

        // Update Firestore with the new badges and recycling data
        await userBadgesRef.update({
          ...badgesData, // All updated fields, including consecutiveDaysRecycled, totalItemsRecycled, and badgesEarned
          'badgesEarned': unlockedBadges,
        });

        print("Badges updated successfully.");
      } else {
        throw Exception('Badges data not found.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user badges: ${e.toString()}')),
      );
    }
  }

  // Helper to check if the badge is already unlocked
  bool _isBadgeUnlocked(String badgeName, List<String> unlockedBadges) {
    return unlockedBadges.contains(badgeName);
  }

  // Helper to calculate the total items recycled
  int _getTotalItemsRecycled(Map<String, dynamic> badgesData) {
    return (badgesData['plasticItemsRecycled'] ?? 0) +
        (badgesData['paperItemsRecycled'] ?? 0) +
        (badgesData['metalItemsRecycled'] ?? 0) +
        (badgesData['totaItemsRecycled'] ?? 0);
  }

  // Helper function for top notifications
  void _sendTopNotification(String title, String message, String iconPath) {
    showSimpleNotification(
      Row(
        children: [
          SvgPicture.network(iconPath, height: 40, width: 40),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(message, style: TextStyle(color: Colors.white))
              ],
            ),
          ),
        ],
      ),
      background: Color(0xFF989898),
      duration: Duration(seconds: 4),
    );
  }

  // PIN box UI
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
        },
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
              child: Text('Submit', style: TextStyle(color: Colors.white)),
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
          buildMenuItem(context, "QR Scan", "assets/vectors/qrCodeHome.svg", 30, 30, Colors.green, screenWidth, false, "/scan_qr"),
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
              if (isSelected)
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
