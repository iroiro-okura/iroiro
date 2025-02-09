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
  List<String> _hobbies = [];
  String _hometown = '';
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
        _hobbies = user.hobbies ?? [];
        _hometown = user.hometown ?? '';
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
        hometown: _hometown,
        hobbies: _hobbies,
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
        final TextEditingController hometownController =
            TextEditingController(text: _hometown);
        String gender = _gender;

        return AlertDialog(
          title: const Text('プロフィールの編集'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildTextField(usernameController, 'ユーザー名'),
                const SizedBox(height: 8),
                const Text(
                  'ユーザー名を変更するとアバターも変わります。',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 8),
                _buildDropdownButtonFormField(gender),
                _buildTextField(ageController, '年齢', TextInputType.number),
                _buildTextField(occupationController, '職業'),
                _buildTextField(hometownController, '出身地'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _editHobbies,
                  child: Text("趣味を編集",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary)),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('保存'),
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

  void _editHobbies() {
    List<String> allHobbies = [
      "スポーツ",
      "音楽",
      "読書",
      "映画",
      "旅行",
      "ゲーム",
      "料理",
      "アート",
      "カメラ",
      "ダンス"
    ];

    for (String hobby in _hobbies) {
      if (!allHobbies.contains(hobby)) {
        allHobbies.add(hobby);
      }
    }

    List<String> selectedHobbies = List.from(_hobbies);
    TextEditingController customHobbyController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('趣味を編集'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // **選択可能な趣味**
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: allHobbies.map((hobby) {
                        return ChoiceChip(
                          label: Text(hobby),
                          selected: selectedHobbies.contains(hobby),
                          selectedColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withAlpha(70),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedHobbies.add(hobby);
                              } else {
                                selectedHobbies.remove(hobby);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),

                    const Divider(),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: customHobbyController,
                            decoration: const InputDecoration(
                              labelText: "新しい趣味を追加",
                              hintText: "例: ガーデニング",
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (customHobbyController.text.isNotEmpty &&
                                !selectedHobbies
                                    .contains(customHobbyController.text)) {
                              setState(() {
                                allHobbies.add(customHobbyController.text);
                                selectedHobbies.add(customHobbyController.text);
                                customHobbyController.clear();
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('キャンセル'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('保存'),
                  onPressed: () async {
                    setState(() {
                      _hobbies = selectedHobbies;
                    });

                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getGenderDisplayName(String gender) {
    switch (gender) {
      case 'male':
        return '男性';
      case 'female':
        return '女性';
      default:
        return 'その他';
    }
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: keyboardType,
    );
  }

  Widget _buildDropdownButtonFormField(String gender) {
    return DropdownButtonFormField<Gender>(
      value: gender.isNotEmpty
          ? Gender.values
              .firstWhere((e) => e.toString().split('.').last == gender)
          : null,
      decoration: const InputDecoration(labelText: '性別'),
      items: Gender.values
          .map((label) => DropdownMenuItem(
                value: label,
                child: Text(
                    _getGenderDisplayName(label.toString().split('.').last)),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _gender = value?.toString().split('.').last ?? '';
        });
      },
    );
  }

  Widget _buildProfileCard(IconData icon, String title, Widget content) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$title:'),
            const SizedBox(height: 4),
            content,
          ],
        ),
      ),
    );
  }

  final Map<String, IconData> _hobbyIcons = {
    "スポーツ": Icons.sports_soccer,
    "音楽": Icons.music_note,
    "読書": Icons.book,
    "映画": Icons.movie,
    "旅行": Icons.flight,
    "ゲーム": Icons.videogame_asset,
    "料理": Icons.restaurant,
    "アート": Icons.palette,
    "カメラ": Icons.camera_alt,
    "ダンス": Icons.directions_run,
    "サウナ": Icons.waves,
  };

  Widget _buildHobbyChips() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.center,
      children: _hobbies.map((hobby) {
        return Chip(
          label: Text(hobby, style: const TextStyle(fontSize: 10)),
          avatar: Icon(
            _hobbyIcons[hobby] ?? Icons.star,
            size: 18,
            color: Theme.of(context).colorScheme.secondary,
          ),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        );
      }).toList(),
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
              if (_hobbies.isNotEmpty) ...[
                const SizedBox(height: 10),
                _buildHobbyChips(),
              ],
              if (_gender.isNotEmpty)
                _buildProfileCard(
                    Icons.person, '性別', Text(_getGenderDisplayName(_gender))),
              if (_age != 0) _buildProfileCard(Icons.cake, '年齢', Text('$_age')),
              if (_occupation.isNotEmpty)
                _buildProfileCard(Icons.work, '職業', Text(_occupation)),
              if (_hometown.isNotEmpty)
                _buildProfileCard(Icons.home, '出身地', Text(_hometown)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
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
