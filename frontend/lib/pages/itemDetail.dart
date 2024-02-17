import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:tooGoodToWaste/dto/shared_item_model.dart';
import 'package:tooGoodToWaste/dto/user_item_detail_model.dart';
import 'package:tooGoodToWaste/dto/user_model.dart' as dto_user;
import 'package:tooGoodToWaste/dto/category_icon_map.dart';
import 'package:tooGoodToWaste/service/shared_items_service.dart';
import 'package:tooGoodToWaste/service/user_location_service.dart';
import 'package:tooGoodToWaste/widgets/user_location_aware_widget.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tooGoodToWaste/dto/public_user_model.dart';
import 'package:tooGoodToWaste/service/user_item_service.dart';
import '../dto/user_name_model.dart';
import '../dto/user_item_amount_model.dart';

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

    Future<dto_user.TGTWUser> getUserFromDatabase(String uid) async {
      Logger logger = Logger();

      return FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .then((DocumentSnapshot doc) {
        logger.d('Got data ${doc.data()}');
        return dto_user.TGTWUser.fromJson(doc.data() as Map<String, dynamic>);
      });
    }

    //toast contains 'Alert! Your *** has already expired and cannot be shared!'
  showExpiredDialog(String foodname, String category) {
    String? categoryIconImagePath;

    if (GlobalCateIconMap[category] == null) {
      categoryIconImagePath = GlobalCateIconMap["Others"];
    } else {
      categoryIconImagePath = GlobalCateIconMap[category];
    }
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    AlertDialog dialog = AlertDialog(
      title: const Text("Alert!", textAlign: TextAlign.center),
      content: Container(
        width: 3 * width / 5,
        height: height / 3,
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Image.asset(categoryIconImagePath!),
            //Expanded(child: stateIndex>-1? Image.asset(imageList[stateIndex]):Image.asset(imageList[12])),
            Text('Your $foodname is already expired and cannot be shared!',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold))
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      }
    );
  }

  TextEditingController locationController = TextEditingController();

  showLocationDialog(){
    // BuildContext dialogContext;
    Dialog dialog = Dialog(

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
       child:
      //   children: [
          UserLocationAwareWidget(
            loader: (BuildContext context) => FractionallySizedBox(
              widthFactor: 1.0,
              child: SizedBox(
                height: 200,
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
            builder: (BuildContext context, GeoPoint userLocation) =>
              SizedBox(
                height: 200,
                child: Column(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text('Please enter the location for picking up:'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Location',
                        ),
                      ),
                    ),
                    // GoogleMap(
                    //   initialCameraPosition: CameraPosition(
                    //     target: LatLng(
                    //       userLocation.latitude, userLocation.longitude),
                    //     zoom: 15.0,
                    // )),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ElevatedButton(
                        onPressed: () {
                          //Extract Location information
                          locationController.value.text;

                  // add a new item to Shared_Item_Collection
                // add the user_id attribute to the shared_item
                // add the location attribute to the shared_item                
            
                SharedItemService sharedItemService = SharedItemService.withCustomFirestore(db: FirebaseFirestore.instance);

                User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser == null) {
                    throw Exception('User is null but want to publish item');
                  } else {
                    getUserFromDatabase(currentUser.uid).then((dto_user.TGTWUser userData) {
                      SharedItem sharedItem = SharedItem(
                        name: foodDetail.name,
                        category: foodDetail.category,
                        amount:  UserItemAmount(
                          nominal: foodDetail.quantitynum,
                          unit: foodDetail.quantitytype
                        ),
                        buyDate: foodDetail.remainDays,
                        expireDate: foodDetail.remainDays,
                        user: currentUser.uid,
                        itemRef: '',
                      );
                      sharedItemService.postSharedItem(userLocation, sharedItem);

                    });
                  }

                  //TODO: delete the card in Inventory
                  UserItemService userItemService = UserItemService.withCustomFirestore(db: FirebaseFirestore.instance);
                  // userItemService.deleteUserItem(currentUser.uid, foodDetail.id);

                            Navigator.of(context, rootNavigator: true).pop();
                            // Navigator.pop(context);
                        },
                        child: const Text('Submit'),
                      )
                    ),
                  ]
                  )
              ),
          )
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // dialogContext = context;
        return dialog;
      }
    );
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
      
              //check if the state is still good
              if(foodDetail.state == 'good'){
                // add a new item to Shared_Item_Collection
                // add the user_id attribute to the shared_item
                // add the location attribute to the shared_item
                
                showLocationDialog();
                // Navigator.pop(context);
              } else {
                showExpiredDialog(foodDetail.name, foodDetail.category);
              }
            } catch (e) {
              print(e);
            }
          },
          tooltip: 'Publish Item',
          label: const Text('Publish Item'),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: Card(
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: Container(
                    padding: const EdgeInsets.only(right: 12.0),
                    decoration: const BoxDecoration(
                        border: Border(right: BorderSide(width: 1.0))),
                    child: Image(
                      image: AssetImage(imagePth),
                      width: 32,
                      height: 32,
                    ),
                  ),
                  title: const Text(
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
            const Divider(),
            Expanded(
              child: Card(
               child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: Container(
                    padding: const EdgeInsets.only(right: 12.0),
                    decoration: const BoxDecoration(
                        border: Border(right: BorderSide(width: 1.0))),
                    child: Image(
                      image: AssetImage(imagePth),
                      width: 32,
                      height: 32,
                    ),
                  ),
                  title: const Text(
                    'Category:',
                    style: TextStyle(fontSize: 25),
                  ),
                  // subtitle: Text("Expired in $expire days", style: TextStyle(fontStyle: FontStyle.italic),),
                  trailing: Text(category,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24,
                      )),
               ),
              ),
            ),
            const Divider(),
            Expanded(
              child: Card(
               child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: Container(
                    padding: const EdgeInsets.only(right: 12.0),
                    decoration: const BoxDecoration(
                        border: Border(right: BorderSide(width: 1.0))),
                    child: Image(
                      image: AssetImage(imagePth),
                      width: 32,
                      height: 32,
                    ),
                  ),
                  title: const Text(
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


