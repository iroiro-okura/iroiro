import 'package:flutter/material.dart';

void main() {
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
          colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Color.fromRGBO(216, 216, 168, 1.0),
              onPrimary: Color.fromRGBO(71, 71, 71, 1.0),
              secondary: Color.fromRGBO(234, 141, 80, 1.0),
              onSecondary: Color.fromRGBO(255, 255, 255, 1),
              tertiary: Color.fromRGBO(51, 6, 5, 1.0),
              error: Color.fromRGBO(171, 36, 56, 1.0),
              onError: Color.fromRGBO(255, 255, 255, 1),
              surface: Colors.blueGrey,
              onSurface: Colors.white)),
      home: const MyHomePage(title: 'Corggle Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome to',
              style: TextStyle(
                  fontSize: 30,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w400),
            ),
            Text(
              'Corggle',
              style: TextStyle(
                  fontSize: 50,
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 8),
            ),
            Image.asset('assets/images/home_corgi.png'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
