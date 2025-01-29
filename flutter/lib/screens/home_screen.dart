import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iroiro/main.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class Home extends StatelessWidget {
  final PersistentTabController controller;

  const Home({super.key, required this.controller});

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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(20),
            Container(
              color: Theme.of(context).colorScheme.tertiary,
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '質問に答えて、\n盛り上がる場面に\n合った話題を見つける',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w400),
                          ),
                          Column(
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/cogimi.png',
                                  height: 150,
                                  width: 160,
                                ),
                              ),
                              Text('AIコーギー：こぎ美',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  )),
                            ],
                          )
                        ],
                      ),
                      SizedBox(height: 40),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                          onPressed: () {
                            controller.jumpToTab(1);
                          },
                          child: const Text('話題を見つける'),
                        ),
                      ),
                    ],
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('よくある場面から探す', style: TextStyle(fontSize: 16)),
                  Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          InkWell(
                              onTap: () {
                                Provider.of<ChatArgumentsProvider>(context,
                                        listen: false)
                                    .setArgument('初めてのデート');
                                controller.jumpToTab(1);
                              },
                              child: Container(
                                height: 110,
                                width: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/dating.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )),
                          Gap(5),
                          const Text('初めてのデート', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Provider.of<ChatArgumentsProvider>(context,
                                      listen: false)
                                  .setArgument('同窓会');
                              controller.jumpToTab(1);
                            },
                            child: Container(
                              height: 110,
                              width: 110,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.2),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                image: DecorationImage(
                                  image:
                                      AssetImage('assets/images/reunion.jpeg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Gap(5),
                          const Text('同窓会', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          InkWell(
                              onTap: () {
                                Provider.of<ChatArgumentsProvider>(context,
                                        listen: false)
                                    .setArgument('会社の懇親会');
                                controller.jumpToTab(1);
                              },
                              child: Container(
                                height: 110,
                                width: 110,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, 0.2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/welcome_party.jpeg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )),
                          Gap(5),
                          const Text('会社の懇親会', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
