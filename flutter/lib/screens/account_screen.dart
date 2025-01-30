import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iroiro/firebase/auth.dart';
import 'package:iroiro/firebase/firestore.dart';
import 'package:iroiro/model/user.dart';
import 'package:random_avatar/random_avatar.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String _username = '';
  String _gender = '';
  int _age = 0;
  String _occupation = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = AuthService.auth.currentUser;
    if (user != null) {
      final userProfile = await FirestoreService.getUser();
      if (userProfile != null) {
        setState(() {
          _username = userProfile.name;
          _gender = userProfile.gender != null
              ? userProfile.gender.toString().split('.').last
              : '';
          _age = userProfile.age ?? 0;
          _occupation = userProfile.occupation ?? '';
        });
      }
    }
  }

  Future<void> _handleSignOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.signOut();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserProfile(
      String username, String gender, int age, String occupation) async {
    final user = AuthService.auth.currentUser;
    if (user != null) {
      final updatedUser = User(
        uid: user.uid,
        email: user.email!,
        name: username,
        gender: gender.isNotEmpty
            ? Sex.values
                .firstWhere((e) => e.toString().split('.').last == gender)
            : null,
        age: age,
        occupation: occupation,
      );
      await FirestoreService.updateUser(updatedUser);
    }
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController usernameController =
            TextEditingController(text: _username);

        final TextEditingController ageController =
            TextEditingController(text: _age == 0 ? '' : _age.toString());
        final TextEditingController occupationController =
            TextEditingController(text: _occupation);
        String gender = _gender;

        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                DropdownButtonFormField<Sex>(
                  value: gender.isNotEmpty
                      ? Sex.values.firstWhere(
                          (e) => e.toString().split('.').last == gender)
                      : null,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: Sex.values
                      .map((label) => DropdownMenuItem(
                            child: Text(label.toString().split('.').last),
                            value: label,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      gender = value?.toString().split('.').last ?? '';
                    });
                  },
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: occupationController,
                  decoration: const InputDecoration(labelText: 'Occupation'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                setState(() {
                  _username = usernameController.text;
                  _gender = gender;
                  _age = int.tryParse(ageController.text) ?? _age;
                  _occupation = occupationController.text;
                });
                await _updateUserProfile(_username, _gender, _age, _occupation);
                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Corggle'),
          titleTextStyle: TextStyle(
            fontFamily: 'Alexandria',
            fontSize: 20,
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w500,
          ),
          titleSpacing: 0,
          leading: IconButton(
            padding: const EdgeInsets.all(11),
            onPressed: null,
            icon: Image.asset('assets/icon/icon_transparent.png'),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  child: SvgPicture.string(
                    RandomAvatarString(_username),
                    width: 100,
                    height: 100,
                  ),
                ),
                Text(
                  _username,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('性別: $_gender'),
                  ),
                ),
                Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                  child: ListTile(
                    leading: Icon(Icons.cake),
                    title: Text('年齢: ${_age == 0 ? '' : _age}'),
                  ),
                ),
                Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                  child: ListTile(
                    leading: Icon(Icons.work),
                    title: Text('職業: $_occupation'),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _editProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text('編集する'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isLoading ? Colors.brown[100] : Colors.brown,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : const Text('サインアウト'),
                ),
              ],
            ),
          ),
        ));
  }
}
