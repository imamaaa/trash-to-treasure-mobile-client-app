import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChangePhotoPage extends StatefulWidget {
  @override
  _ChangePhotoPageState createState() => _ChangePhotoPageState();
}

class _ChangePhotoPageState extends State<ChangePhotoPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _isUploading = false;
  String? _profilePhotoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  Future<void> _loadProfilePhoto() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc['profilePhoto'] != null) {
          setState(() {
            _profilePhotoUrl = userDoc['profilePhoto'];
          });
        }
      }
    } catch (e) {
      print('Error loading profile photo: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  Future<void> _uploadPhoto() async {
    if (_image == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Upload image to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref().child('profile_photos/${user.uid}');
        final uploadTask = storageRef.putFile(File(_image!.path));
        final snapshot = await uploadTask.whenComplete(() {});
        final downloadUrl = await snapshot.ref.getDownloadURL();

        // Update Firestore with the new profile photo URL
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'profilePhoto': downloadUrl,
        });

        setState(() {
          _profilePhotoUrl = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile photo updated successfully.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating profile photo: $e')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        leading: IconButton(
          icon: SvgPicture.asset('assets/vectors/backArrow.svg', color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Change Profile Photo',
          style: TextStyle(color: Colors.black, fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            width: 375,
            height: 812,
            decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 1)),
            child: Stack(
              children: [
                Positioned(
                  top: 40,
                  left: 0,
                  child: Container(), // Placeholder for top bar if needed
                ),
                Positioned(
                  top: 160,
                  left: 96,
                  child: Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFF138A36), // Your desired border color
                        width: 3.0, // Border width
                      ),
                      borderRadius: BorderRadius.circular(90), // Make the border circular
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(90), // Ensure the image fits within the circular border
                      child: _image != null
                          ? Image.file(
                        File(_image!.path),
                        height: 180,
                        width: 180,
                        fit: BoxFit.cover,
                      )
                          : _profilePhotoUrl != null
                          ? Image.network(
                        _profilePhotoUrl!,
                        height: 180,
                        width: 180,
                        fit: BoxFit.cover,
                      )
                          : SvgPicture.asset(
                        'assets/vectors/Avatar.svg',
                        height: 180,
                        width: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 404,
                  left: 24,
                  child: ElevatedButton.icon(
                    onPressed: _pickImageFromGallery,
                    icon: Icon(Icons.photo_library, color: Colors.white),
                    label: Text('Choose from Gallery', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF138A36),
                      minimumSize: Size(327, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 486,
                  left: 24,
                  child: ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    label: Text('Take a Photo', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF138A36),
                      minimumSize: Size(327, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                if (_image != null)
                  Positioned(
                    top: 600,
                    left: 24,
                    child: ElevatedButton(
                      onPressed: _isUploading ? null : _uploadPhoto,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isUploading ? Colors.grey : Color(0xFF1E7C4D),
                        minimumSize: Size(330, 60),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: _isUploading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Save Photo',
                        style: TextStyle(fontSize: 16, fontFamily: 'Poppins', color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
