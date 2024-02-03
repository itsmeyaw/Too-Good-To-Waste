import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tooGoodToWaste/dto/shared_item_model.dart';
import 'package:tooGoodToWaste/service/user_service.dart';
import '../Pages/post_page.dart';
import '../dto/user_model.dart';
import '../service/shared_items_service.dart';

Logger logger = Logger();

// The social places timeline
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      throw StateError("Trying to access user page without authentication");
    }

    final UserService userService = UserService();
    final User firebaseUser = FirebaseAuth.instance.currentUser!;

    var users = [];

    var postData = [];

    return FutureBuilder(
        future: userService.getUserData(firebaseUser.uid),
        builder: (BuildContext context, AsyncSnapshot<TGTWUser> userDataSnapshot) {
          if (userDataSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userDataSnapshot.hasError) {
            return Center(child: Text('Error: ${userDataSnapshot.error}'),);
          }

          final TGTWUser user = userDataSnapshot.requireData;

          return Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Column(
              children: [
                const FractionallySizedBox(
                  widthFactor: 1.0,
                  child: SizedBox(
                    height: 200,
                    child: Card(
                      child: Text(
                          'Here shall be map showing locations of available items'),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const SearchBar(),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Results',
                      style: Theme.of(context).textTheme.headlineMedium,
                    )
                  ],
                ),
                Expanded(
                    child: ListView.separated(
                  itemCount: postData.length,
                  itemBuilder: (_, index) {
                    return Post(
                      postData: postData[index],
                    );
                  },
                  separatorBuilder: (_, index) {
                    return const Divider();
                  },
                ))
              ],
            ),
          );
        });
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Row(
        children: <Widget>[
          Chip(
            avatar: Icon(Icons.tune, size: 16),
            label: Text('Type'),
          ),
          SizedBox(
            width: 10,
          ),
          Chip(
            avatar: Icon(Icons.location_pin, size: 16),
            label: Text('Range'),
          ),
          SizedBox(
            width: 10,
          ),
          Chip(avatar: Icon(Icons.warning), label: Text('Allergies'))
        ],
      ),
    );
  }
}

class Post extends StatelessWidget {
  final SharedItem postData;

  const Post({super.key, required this.postData});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostPage(postData: postData)));
        },
        style: ButtonStyle(
          overlayColor: MaterialStatePropertyAll(
              Theme.of(context).colorScheme.background),
          textStyle: const MaterialStatePropertyAll(TextStyle(
            color: Colors.black,
          )),
          padding: const MaterialStatePropertyAll(EdgeInsets.zero),
        ),
        child: FractionallySizedBox(
          widthFactor: 1.0,
          child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item name: ${postData.name}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text(
                    'Amount: ${postData.amount.nominal} ${postData.amount.unit}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text(
                    'Distance: {TODO}',
                    style: const TextStyle(color: Colors.black),
                  )
                ],
              )),
        ));
  }
}
