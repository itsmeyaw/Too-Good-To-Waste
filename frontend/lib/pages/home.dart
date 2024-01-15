import 'package:flutter/material.dart';
import 'package:tooGoodToWaste/dto/user_model.dart';
import 'package:tooGoodToWaste/dto/post_model.dart';
import '../Pages/post_page.dart';

// The social places timeline
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    var users = [
    ];

    var postData = [
      PostModel(
          title: 'Red bell pepper',
          distance: 0.2,
          measurement: 'items',
          amount: 2,
          user: users[0]
      ),
      PostModel(
          title: 'Green bell pepper',
          distance: 0.3,
          measurement: 'items',
          amount: 1,
          user: users[1]
      ),
      PostModel(
          title: 'Grated gouda cheese',
          distance: 0.5,
          measurement: 'grams',
          amount: 200,
          user: users[2]
      ),
      PostModel(
          title: 'Green bell pepper',
          distance: 0.6,
          measurement: 'items',
          amount: 1,
          user: users[0]
      ),
      PostModel(
          title: 'Green bell pepper',
          distance: 1,
          measurement: 'items',
          amount: 1,
          user: users[1]
      )
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10 ,0),
      child: Column(
        children: [
        const FractionallySizedBox(
        widthFactor: 1.0,
        child: SizedBox(
                height: 200,
                child: Card(
                  child: Text('Here shall be map showing locations of available items'),
              ),
            ),
          ),
          const SizedBox(height: 10,),
          const SearchBar(),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Results',
              style: Theme.of(context).textTheme.headlineMedium,
              )
            ],
          ),
          Expanded(child: ListView.separated(
            itemCount: postData.length,
            itemBuilder: (_, index) {
              return Post(postData: postData[index],);
            },
            separatorBuilder: (_, index) {
              return const Divider();
            },
          ))
        ],
      ),
    );
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
          SizedBox(width: 10,),
          Chip(
            avatar: Icon(Icons.location_pin, size: 16),
            label: Text('Range'),
          ),
          SizedBox(width: 10,),
          Chip(
              avatar: Icon(Icons.warning),
              label: Text('Allergies')
          )
        ],
      ),
    );
  }
}

class Post extends StatelessWidget {
  final PostModel postData;

  const Post({
    super.key,
    required this.postData
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => PostPage(postData: postData))); },
      style: ButtonStyle(
          overlayColor: MaterialStatePropertyAll(Theme.of(context).colorScheme.background),
          textStyle: MaterialStatePropertyAll(
            TextStyle(
              color: Colors.black,
            )
          ),
          padding: MaterialStatePropertyAll(EdgeInsets.zero),
      ),
      child: FractionallySizedBox(
      widthFactor: 1.0,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item name: ${postData.title}', style: const TextStyle(color: Colors.black),),
            Text('Amount: ${postData.amount} ${postData.measurement}', style: const TextStyle(color: Colors.black),),
            Text('Distance: ${postData.distance} km', style: const TextStyle(color: Colors.black),)
          ],
        )
      ),
      )
    );
  }
}