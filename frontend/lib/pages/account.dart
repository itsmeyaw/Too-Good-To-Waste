import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tooGoodToWaste/dto/user_model.dart' as dto_user;
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<StatefulWidget> createState() => _MyAccountPageState();
}

class _MyAccountPageState extends State<AccountPage> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  Logger logger = Logger();

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      throw Exception('User is null but accessing account page');
    } else {
      return AccountSettingPage(user: currentUser!);
    }
  }
}

class AccountSettingPage extends StatelessWidget {
  final User user;

  const AccountSettingPage({super.key, required this.user});

  Future<dto_user.User> getUserFromDatabase(String uid) async {
    Logger logger = Logger();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get()
        .then((DocumentSnapshot doc) {
      logger.d('Got data ${doc.data()}');
      return dto_user.User.fromJson(doc.data() as Map<String, dynamic>);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getUserFromDatabase(user.uid),
        builder: (BuildContext context, AsyncSnapshot<dto_user.User> dtoUser) {
          if (!dtoUser.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          dto_user.User userData = dtoUser.data!;

          return DefaultTabController(
              length: 3,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  toolbarHeight: 0,
                  bottom: const TabBar(
                    tabs: [
                      Tab(
                        icon: Icon(Icons.person_outline),
                        text: 'Pers. Info',
                      ),
                      Tab(
                        icon: Icon(Icons.chat_bubble_outline),
                        text: 'Messages',
                      ),
                      Tab(
                        icon: Icon(Icons.notifications_active_outlined),
                        text: 'Active Posts',
                      )
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      height: MediaQuery.of(context).size.height,
                      child: ListView(children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'User Information',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Name'),
                        RichText(
                            text: TextSpan(
                          text: '${userData.name.first} ${userData.name.last}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        )),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('E-Mail'),
                        Text(
                          '${user.email}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Phone Number'),
                        RichText(
                            text: TextSpan(
                          text: userData.phoneNumber,
                          style: Theme.of(context).textTheme.bodyLarge,
                        )),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Address',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Address Line 1'),
                        Text(
                          userData.address.line1,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Address Line 2'),
                        Text(
                          userData.address.line2,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('City'),
                        Text(
                          userData.address.city,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Zip Code'),
                        Text(
                          userData.address.zipCode,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Country'),
                        Text(
                          userData.address.country,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Additional Information',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Allergies'),
                        Text(
                          userData.allergies.isEmpty ? 'No allergies listed' : userData.allergies.join(', '),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Achievements',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('GoodPoints'),
                        Text(
                          '${userData.goodPoints}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Carbon Emission Reduced'),
                        Text(
                          '${userData.reducedCarbonKg} kg',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            IntrinsicWidth(
                                child: FilledButton(
                                    onPressed: () {
                                      FirebaseAuth.instance.signOut();
                                    },
                                    child: const Text('Sign Out')))
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ]),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      height: MediaQuery.of(context).size.height,
                      child: ListView(children: [
                        const SizedBox(
                          height: 10,
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                      ]),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      height: MediaQuery.of(context).size.height,
                      child: ListView(children: const [
                        SizedBox(
                          height: 10,
                        ),
                        Text('You have no active post currently'),
                      ]),
                    )
                  ],
                ),
              ));
        });
  }
}
