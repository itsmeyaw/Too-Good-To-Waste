import 'package:flutter/material.dart';
import 'package:tooGoodToWaste/dto/shared_item_model.dart';
import 'package:tooGoodToWaste/dto/user_item_detail_model.dart';
import '../dto/user_model.dart';

class itemDetailPage extends StatelessWidget {
  const itemDetailPage({super.key, required this.foodDetail});

  // Declare a field that holds the food.
  final UserItemDetail foodDetail;

   @override
  Widget build(BuildContext context) {
     return Scaffold(
          appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text('Item Detail Page')),
          body: Column(children: <Widget>[
            TextButton(
              child: const Text('Edit'),
              onPressed: () {
                //var qnum = dbhelper.getOneFoodValue(index, "quantitynum");
                Navigator.pop(context);
              },
            ),
            //name
            //quantity number and quantity type
            Title(
              color: Colors.blue,
              title: foodDetail.name,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text('Storage Now: ${foodDetail.quantitynum} ${foodDetail.quantitytype}'),
                      //Text(quantype),
                    ],
                  ),
                  Row(children: <Widget>[Text('Category: ${foodDetail.category}')]),
                  Row(children: <Widget>[Text('Expires in: ${foodDetail.remainDays}')]),
                ],
              ),
              //progress bar of cosume state
            ),
            SizedBox(
              height: 5,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
                value: foodDetail.consumestate,
              ),
            ),
          ]),
        );
  }
}

