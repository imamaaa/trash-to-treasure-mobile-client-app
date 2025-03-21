import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For formatting

class StoresPage extends StatefulWidget {
  @override
  _StoresPageState createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> {
  List<Map<String, dynamic>> stores = [];

  @override
  void initState() {
    super.initState();
    fetchStores();
  }

  // Fetch all stores from Firebase
  Future<void> fetchStores() async {
    QuerySnapshot storesSnapshot = await FirebaseFirestore.instance.collection('shops').get();
    List<QueryDocumentSnapshot> docs = storesSnapshot.docs;

    List<Map<String, dynamic>> fetchedStores = [];
    for (var doc in docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      fetchedStores.add(data);
    }

    setState(() {
      stores = fetchedStores;
    });
  }

  // Get the operating hours for today
  String getOperatingHoursForToday(Map<String, dynamic> operatingHours) {
    String today = DateFormat('EEEE').format(DateTime.now()); // Get current day of the week (e.g., Monday)
    return operatingHours[today] ?? 'Closed'; // Default to 'Closed' if no hours for today
  }

  // Display operating hours for all 7 days in a scrollable pop-up
  void showStoreDetails(BuildContext context, Map<String, dynamic> store) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(
              store['name'],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.teal,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (store.containsKey('photo')) // Show photo if the field exists
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Center(
                      child: Image.network(
                        store['photo'], // URL to the photo
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                Text(
                  'Address: ${store['address'] ?? 'N/A'}',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'City: ${store['city'] ?? 'N/A'}',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Operating Hours:',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                // Display operating hours for all 7 days
                ...['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
                    .map((day) => Text(
                  '$day: ${store['operatingHours'][day] ?? 'Closed'}',
                  style: GoogleFonts.poppins(fontSize: 16),
                ))
                    .toList(),
                SizedBox(height: 8),
                Text(
                  'Phone: ${store['phone'] ?? 'N/A'}',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Email: ${store['email'] ?? 'N/A'}',
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(color: Colors.teal),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF138A36),
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset('assets/vectors/backArrow.svg'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Stores',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info, color: Colors.white),
            onPressed: () {
              // Show info popup
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Our Partners'),
                    content: Text('You can see all partnered stores here where you can redeem your collected rewards.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> store = stores[index];

          return GestureDetector(
            onTap: () {
              showStoreDetails(context, store); // Show store details when tapped
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x123629B7),
                    offset: Offset(0, 4),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (store.containsKey('photo')) // Show photo if it exists for the store
                      Center(
                        child: Image.network(
                          store['photo'], // Store photo URL
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            store['name'] ?? 'Unknown Store', // Store name
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Color(0xFF343434),
                            ),
                          ),
                        ),
                        Text(
                          'City: ${store['city'] ?? 'N/A'}',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Phone: ${store['phone'] ?? 'N/A'}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.indigo,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Today\'s Hours: ${getOperatingHoursForToday(store['operatingHours'])}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.brown,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: buildBottomNavigationBar(context, screenWidth),
    );
  }

  // Bottom Navigation Bar (same as in history.dart)
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
          buildMenuItem(context, "my Badges", "assets/vectors/medalHome.svg", 30, 30, Colors.green, screenWidth, false, "/my_badges"),
          buildMenuItem(context, "Settings", "assets/vectors/settingsHome.svg", 30, 30, Colors.green, screenWidth, false, "/settings"),
        ],
      ),
    );
  }

  // Menu Item for Bottom Navigation
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
