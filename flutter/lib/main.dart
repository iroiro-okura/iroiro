import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iroiro/screens/account_screen.dart';
import 'package:iroiro/screens/chat_screen.dart';
import 'package:iroiro/screens/home_screen.dart';
import 'package:iroiro/screens/welcome_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Corggle',
      theme: ThemeData(
        fontFamily: 'Murecho',
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color.fromRGBO(234, 120, 60, 1.0),
          onPrimary: Color.fromRGBO(255, 255, 255, 1.0),
          secondary: Color.fromRGBO(77, 20, 20, 1.0),
          onSecondary: Color.fromRGBO(255, 255, 255, 1.0),
          tertiary: Color.fromRGBO(242, 242, 200, 1.0),
          error: Color.fromRGBO(200, 50, 70, 1.0),
          onError: Color.fromRGBO(255, 255, 255, 1.0),
          surface: Color.fromRGBO(245, 245, 220, 1.0),
          onSurface: Color.fromRGBO(51, 51, 51, 1.0),
        ),
      ),
      home: _getLandingPage(),
      darkTheme: ThemeData(
        fontFamily: 'Murecho',
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color.fromRGBO(234, 141, 80, 1.0),
          onPrimary: Color.fromRGBO(255, 255, 255, 1.0),
          secondary: Color.fromRGBO(229, 229, 183, 1.0),
          onSecondary: Color.fromRGBO(51, 6, 5, 1.0),
          tertiary: Color.fromRGBO(71, 71, 71, 1.0),
          error: Color.fromRGBO(255, 105, 97, 1.0),
          onError: Color.fromRGBO(0, 0, 0, 1.0),
          surface: Color.fromRGBO(51, 51, 51, 1.0),
          onSurface: Color.fromRGBO(229, 229, 183, 1.0),
        ), //
      ),
    );
  }
}

Widget _getLandingPage() {
  return StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    initialData: FirebaseAuth.instance.currentUser,
    builder: (context, snapshot) {
      debugPrint('snapshot: ${snapshot.data}');
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasData) {
        return const MainPage();
      } else {
        return const Welcome();
      }
    },
  );
}

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static const _screens = [Home(), Chat(), Account()];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: 'ホーム'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'チャット'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'アカウント'),
          ],
          type: BottomNavigationBarType.fixed,
        ));
  }
}
