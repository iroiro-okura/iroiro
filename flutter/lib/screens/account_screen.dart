import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Account extends StatelessWidget {
  const Account({super.key});

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
              onPressed: () async {
                await googleSignOut();
              },
              child: const Text('Sign Out'),
            )
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