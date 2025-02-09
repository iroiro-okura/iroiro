import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:iroiro/components/app_bar.dart';
import 'package:iroiro/components/help_tooltip.dart';
import 'package:iroiro/model/chat.dart';
import 'package:iroiro/providers/chat_provider.dart';
import 'package:iroiro/providers/user_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  final PersistentTabController controller;

  const HomeScreen({super.key, required this.controller});

  Future<void> _handleTap(BuildContext context, String topic) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.createNewChat(userProvider.user!.uid, topic);
    chatProvider.setScene(topic);
    controller.jumpToTab(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CorggleAppBar(),
        body: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Gap(20),
            Container(
              color: Theme.of(context).colorScheme.tertiary,
              child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '質問に答えて、\n場面に合った\n話題を見つけよう！',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w400),
                          ),
                          Column(
                            children: [
                              Center(
                                child: Image.asset(
                                  'assets/images/cogimi.png',
                                  height:
                                      MediaQuery.of(context).size.height / 6,
                                  width: MediaQuery.of(context).size.width / 3,
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
                      Row(
                        children: [
                          ElevatedButton(
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
                          const Gap(10),
                          HelpTooltip(message: '場面は指定せずに、こぎ美との対話で1から話題を探します'),
                        ],
                      ),
                    ],
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('よくある場面から探す', style: TextStyle(fontSize: 16)),
                      const Gap(10),
                      HelpTooltip(message: 'よくある場面から話題を探します'),
                    ],
                  ),
                  Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          InkWell(
                              onTap: () => _handleTap(context, dating),
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
                            onTap: () => _handleTap(context, reunion),
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
                              onTap: () =>
                                  _handleTap(context, companyGathering),
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
        )));
  }
}
