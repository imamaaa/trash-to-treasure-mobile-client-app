import 'package:flutter/material.dart';

class MyBadgesPage extends StatelessWidget {
  const MyBadgesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Badges'),
      ),
      body: const Center(
        child: Text('This is the My Badges page'),
      ),
    );
  }
}
