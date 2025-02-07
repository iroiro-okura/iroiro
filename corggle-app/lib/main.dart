import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:iroiro/firebase/auth.dart';
import 'package:iroiro/firebase/firestore.dart';
import 'package:iroiro/providers/chat_provider.dart';
import 'package:iroiro/providers/user_provider.dart';
import 'package:iroiro/screens/account_screen.dart';
import 'package:iroiro/screens/chat_screen.dart';
import 'package:iroiro/screens/history_screen.dart';
import 'package:iroiro/screens/home_screen.dart';
import 'package:iroiro/screens/welcome_screen.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

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
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider())
        ],
        child: MaterialApp(
          title: 'Corggle',
          routes: {
            '/chat': (context) => const ChatScreen(),
            '/history': (context) =>
                HistoryScreen(controller: PersistentTabController()),
            '/account': (context) => const AccountScreen(),
          },
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
              onPrimary: Color.fromRGBO(77, 20, 20, 1.0),
              secondary: Color.fromRGBO(229, 229, 183, 1.0),
              onSecondary: Color.fromRGBO(51, 6, 5, 1.0),
              tertiary: Color.fromRGBO(71, 71, 71, 1.0),
              error: Color.fromRGBO(255, 105, 97, 1.0),
              onError: Color.fromRGBO(0, 0, 0, 1.0),
              surface: Color.fromRGBO(51, 51, 51, 1.0),
              onSurface: Color.fromRGBO(229, 229, 183, 1.0),
            ), //
          ),
        ));
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
        return const WelcomeScreen();
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
  final PersistentTabController _controller =
      PersistentTabController(initialIndex: 0);

  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    _screens = [
      HomeScreen(controller: _controller),
      ChatScreen(),
      HistoryScreen(controller: _controller),
      AccountScreen()
    ];

    _controller.addListener(() {
      if (_controller.index == 0) {
        Provider.of<ChatProvider>(context, listen: false).resetScene();
      }
    });
  }

  Future<void> _loadUserProfile() async {
    final user = AuthService.auth.currentUser;
    if (user != null) {
      final userProfile = await FirestoreService.getUser();
      if (!mounted) return;
      if (userProfile != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(userProfile);
      }
    }
  }

  late final List<Widget> _screens;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: PersistentTabView(
        context,
        controller: _controller,
        screens: _screens,
        navBarStyle: NavBarStyle.style3,
        backgroundColor: Theme.of(context).colorScheme.tertiary,
        items: [
          PersistentBottomNavBarItem(
              icon: Icon(Icons.home_filled),
              activeColorPrimary: Theme.of(context).colorScheme.primary,
              inactiveColorPrimary: Theme.of(context).colorScheme.secondary,
              title: 'ホーム'),
          PersistentBottomNavBarItem(
              icon: Icon(Icons.chat),
              activeColorPrimary: Theme.of(context).colorScheme.primary,
              inactiveColorPrimary: Theme.of(context).colorScheme.secondary,
              title: 'チャット'),
          PersistentBottomNavBarItem(
              icon: Icon(Icons.history),
              activeColorPrimary: Theme.of(context).colorScheme.primary,
              inactiveColorPrimary: Theme.of(context).colorScheme.secondary,
              title: ' 履歴'),
          PersistentBottomNavBarItem(
              icon: Icon(Icons.person),
              activeColorPrimary: Theme.of(context).colorScheme.primary,
              inactiveColorPrimary: Theme.of(context).colorScheme.secondary,
              title: 'アカウント'),
        ],
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        animationSettings: const NavBarAnimationSettings(
          navBarItemAnimation: ItemAnimationSettings(
            // Navigation Bar's items animation properties.
            curve: Curves.ease,
          ),
          screenTransitionAnimation: ScreenTransitionAnimationSettings(
            // Screen transition animation on change of selected tab.
            animateTabTransition: true,
            screenTransitionAnimationType: ScreenTransitionAnimationType.slide,
          ),
        ),
      ),
    );
  }
}
