import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  bool _isLoading = false;

  Future<void> _handleSignOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await googleSignOut();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Account',
              style: TextStyle(
                fontSize: 24,
              ),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSignOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoading
                    ? Color.fromARGB(100, 51, 6, 5) // Darker color when loading
                    : Color.fromARGB(50, 51, 6, 5), // Original color
              ),
              child: _isLoading ? CircularProgressIndicator() : const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> googleSignOut() async {
  await GoogleSignIn().signOut();
  await FirebaseAuth.instance.signOut();
}