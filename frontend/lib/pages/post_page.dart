import 'package:flutter/material.dart';
import '../dto/shared_item_model.dart';

class PostPage extends StatelessWidget {
  final SharedItem postData;

  const PostPage({
    super.key,
    required this.postData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Shared Item Information'),
          actions: [],
        ),
        body: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FractionallySizedBox(
                  widthFactor: 1.0,
                  child: SizedBox(
                    height: 200,
                    child: Card(
                      child: Text(
                          'Here shall be map giving the range of the location of the item publisher'),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  postData.name,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                    'Amount: ${postData.amount.nominal} ${postData.amount.unit}',
                    style: Theme.of(context).textTheme.headlineSmall),
                Text(
                    'Person: ${postData.user.name.first} ${postData.user.name.last} (${postData.user.rating} stars)'),
                const Spacer(),
                FilledButton(
                    onPressed: () {},
                    child: FractionallySizedBox(
                      widthFactor: 1,
                      child: Text(
                        'Chat with ${postData.user.name}',
                        textAlign: TextAlign.center,
                      ),
                    ))
              ],
            )));
  }
}
