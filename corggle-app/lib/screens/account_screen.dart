import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iroiro/components/app_bar.dart';
import 'package:iroiro/firebase/auth.dart';
import 'package:iroiro/firebase/firestore.dart';
import 'package:iroiro/model/user.dart';
import 'package:iroiro/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:random_avatar/random_avatar.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _username = '';
  String _gender = '';
  int _age = 0;
  String _occupation = '';
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = Provider.of<UserProvider>(context).user;
    if (user != null) {
      setState(() {
        _username = user.name;
        _gender = user.gender?.toString().split('.').last ?? '';
        _age = user.age ?? 0;
        _occupation = user.occupation ?? '';
      });
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
            ? Gender.values
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
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                DropdownButtonFormField<Gender>(
                  value: gender.isNotEmpty
                      ? Gender.values.firstWhere(
                          (e) => e.toString().split('.').last == gender)
                      : null,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: Gender.values
                      .map((label) => DropdownMenuItem(
                            value: label,
                            child: Text(label.toString().split('.').last),
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
      resizeToAvoidBottomInset: false,
      appBar: CorggleAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
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
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (_gender.isNotEmpty)
                Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text('性別: $_gender'),
                  ),
                ),
              if (_age != 0)
                Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                  child: ListTile(
                    leading: Icon(Icons.cake),
                    title: Text('年齢: $_age'),
                  ),
                ),
              if (_occupation.isNotEmpty)
                Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
        )),
      ),
    );
  }
}
