import 'package:flutter/material.dart';
import 'package:tooGoodToWaste/dto/shared_item_model.dart';
import 'package:tooGoodToWaste/dto/user_item_detail_model.dart';
import '../dto/user_model.dart';
import 'package:tooGoodToWaste/constant/category_icon_map.dart';

class itemDetailPage extends StatelessWidget {
  const itemDetailPage({super.key, required this.foodDetail});

  // Declare a field that holds the food.
  final UserItemDetail foodDetail;

   @override
  Widget build(BuildContext context) {

    String categoryIconImagePath;

    if (GlobalCateIconMap[foodDetail.category] == null) {
      categoryIconImagePath = GlobalCateIconMap["Others"]!;
    } else {
      categoryIconImagePath = GlobalCateIconMap[foodDetail.category]!;
    }

     return Scaffold(
        appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              title: const Text('Item Detail Page')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
           
            children: <Widget>[
              //name
              //quantity number and quantity type
              Positioned(
                top: MediaQuery.of(context).size.height * 0.05,
                right: 0,
                child: const SwitchButton(),
              ),
              Expanded(
                child: Stack(
                  children: [
                   
                    DetailsList(
                      quantitynum: foodDetail.quantitynum,
                      quantitytype: foodDetail.quantitytype,
                      category: foodDetail.category,
                      remainDays: foodDetail.remainDays,
                      imagePth: categoryIconImagePath,
                    ),
                    
                  ],
                ),
              ),
              SizedBox(
                height: 5,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(Colors.blue),
                  value: foodDetail.consumestate,
                ),
              ),
            ],
          ),

        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            try {
              // add a new item to Shared_Item_Collection
              // add the user_id attribute to the shared_item
              // add the location attribute to the shared_item

              Navigator.pop(context);
            } catch (e) {
              print(e);
            }
          },
          tooltip: 'Publish Item',
          label: Text('Publish Item'),
          icon: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
       );
  }
}

class SwitchButton extends StatefulWidget {
  const SwitchButton({super.key});

  @override
  State<SwitchButton> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchButton> {
  bool light1 = false;

  final MaterialStateProperty<Icon?> thumbIcon =
      MaterialStateProperty.resolveWith<Icon?>(
    (Set<MaterialState> states) {
      if (states.contains(MaterialState.selected)) {
        return const Icon(Icons.check);
      }
      return const Icon(Icons.close);
    },
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Switch(
          thumbIcon: thumbIcon,
          value: light1,
          onChanged: (bool value) {
            setState(() {
              light1 = value;

              //make all fields editable
            });
          },
        ),
      ],
    );
  }
}

class DetailsList extends StatelessWidget {
  const DetailsList({super.key, required this.quantitynum, required this.quantitytype, required this.category, required this.remainDays, required this.imagePth});

  final double quantitynum;
  final String quantitytype;
  final String category;
  final int remainDays;
  final String imagePth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Card(
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: Container(
                    padding: EdgeInsets.only(right: 12.0),
                    decoration: BoxDecoration(
                        border: Border(right: BorderSide(width: 1.0))),
                    child: Image(
                      image: AssetImage("$imagePth"),
                      width: 32,
                      height: 32,
                    ),
                  ),
                  title: Text(
                    'Storage Now:',
                    style: TextStyle(fontSize: 25),
                  ),
                  // subtitle: Text("Expired in $expire days", style: TextStyle(fontStyle: FontStyle.italic),),
                  trailing: Text("$quantitynum $quantitytype",
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24,
                      )),
               ),
              ),
            ),
            Divider(),
            Expanded(
              child: Card(
               child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: Container(
                    padding: EdgeInsets.only(right: 12.0),
                    decoration: BoxDecoration(
                        border: Border(right: BorderSide(width: 1.0))),
                    child: Image(
                      image: AssetImage("$imagePth"),
                      width: 32,
                      height: 32,
                    ),
                  ),
                  title: Text(
                    'Category:',
                    style: TextStyle(fontSize: 25),
                  ),
                  // subtitle: Text("Expired in $expire days", style: TextStyle(fontStyle: FontStyle.italic),),
                  trailing: Text("$category",
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24,
                      )),
               ),
              ),
            ),
            Divider(),
            Expanded(
              child: Card(
               child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: Container(
                    padding: EdgeInsets.only(right: 12.0),
                    decoration: BoxDecoration(
                        border: Border(right: BorderSide(width: 1.0))),
                    child: Image(
                      image: AssetImage("$imagePth"),
                      width: 32,
                      height: 32,
                    ),
                  ),
                  title: Text(
                    'Expires in:',
                    style: TextStyle(fontSize: 25),
                  ),
                  // subtitle: Text("Expired in $expire days", style: TextStyle(fontStyle: FontStyle.italic),),
                  trailing: Text("$remainDays Days",
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24,
                      )),
               ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


