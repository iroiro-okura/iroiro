import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iroiro/components/app_bar.dart';
import 'package:iroiro/components/custom_button.dart';
import 'package:iroiro/firebase/auth.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.signIn();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Sign-in failed: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CorggleAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Gap(20),
                    Text(
                      'Welcome to',
                      style: TextStyle(
                        fontFamily: "Alexandria",
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      'Corggle',
                      style: TextStyle(
                        fontFamily: "Alexandria",
                        fontSize: 50,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 10,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      'Your Personal Talk Companion',
                      style: TextStyle(
                        fontFamily: "Alexandria",
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const Gap(28),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/home_corgi.png',
                          width: constraints.maxWidth *
                              0.6, // Adjust the width based on screen size
                        ),
                      ],
                    ),
                    const Gap(40),
                    Column(
                      children: [
                        Text(
                          _isLoading ? 'Loading...' : 'Googleでログイン',
                          style: TextStyle(
                              fontFamily: "Alexandria",
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.w300),
                        ),
                        CustomButton(
                          onPressed: _isLoading ? () => {} : _handleSignIn,
                          buttonTitle: 'G',
                          buttonStyle: ElevatedButton.styleFrom(
                            backgroundColor: _isLoading
                                ? Color.fromARGB(100, 51, 6, 5)
                                : Color.fromARGB(50, 51, 6, 5),
                            fixedSize: const Size(150, 45),
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7)),
                            ),
                          ),
                          textStyle: const TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontSize: 24,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
