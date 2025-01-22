import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iroiro/components/primary_button%20copy.dart';
import 'package:iroiro/hooks/auth_hook.dart';
import 'package:iroiro/screens/home_screen.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome to',
              style: TextStyle(
                  fontFamily: "Alexandria",
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w300),
            ),
            Text(
              'Corggle',
              style: TextStyle(
                  fontFamily: "Alexandria",
                  fontSize: 50,
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10),
            ),
            Text(
              'Your Personal Talk Companion',
              style: TextStyle(
                  fontFamily: "Alexandria",
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w300),
            ),
            Gap(28),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Image.asset('assets/images/home_corgi.png'),
            ]),
            Gap(60),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      onPressed: () async {
                        await googleSignInHook();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => const Home()),
                              (route) => false);
                        }
                      },
                      buttonTitle: 'G',
                      buttonStyle: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(50, 51, 6, 5),
                        fixedSize: const Size(150, 45),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                        ),
                      ),
                      textStyle: const TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                          fontSize: 24,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Text(
                  'Googleでログイン',
                  style: TextStyle(
                      fontFamily: "Alexandria",
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.w300),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
