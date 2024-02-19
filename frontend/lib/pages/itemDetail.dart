import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tooGoodToWaste/dto/item_category_enum.dart';
import 'package:tooGoodToWaste/dto/shared_item_model.dart';
import 'package:tooGoodToWaste/dto/user_item_detail_model.dart';
import 'package:tooGoodToWaste/dto/user_item_model.dart';
import 'package:tooGoodToWaste/dto/user_model.dart' as dto_user;
import 'package:tooGoodToWaste/dto/category_icon_map.dart';
import 'package:tooGoodToWaste/service/shared_items_service.dart';
import 'package:tooGoodToWaste/service/user_location_service.dart';
import 'package:tooGoodToWaste/widgets/category_picker.dart';
import 'package:tooGoodToWaste/widgets/user_location_aware_widget.dart';
import 'package:tooGoodToWaste/service/db_helper.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tooGoodToWaste/service/user_item_service.dart';
import '../dto/user_item_amount_model.dart';

class itemDetailPage extends StatefulWidget {
    // Declare a field that holds the food.
  final UserItemDetail foodDetail;

  const itemDetailPage({super.key, required this.foodDetail});

  @override
  State<StatefulWidget> createState() => _ItemDetailPage();
}

class _ItemDetailPage extends State<itemDetailPage> {

   @override
  Widget build(BuildContext context) {
    DBHelper dbhelper = DBHelper();
    String categoryIconImagePath;

    if (GlobalCateIconMap[widget.foodDetail.category] == null) {
      categoryIconImagePath = GlobalCateIconMap["Others"]!;
    } else {
      categoryIconImagePath = GlobalCateIconMap[widget.foodDetail.category]!;
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
        height: height / 2.5,
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
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
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
                height: 400,
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
                height: 400,
                child: Column(
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text('Are you sue to share this item?',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: 
                        // Image.asset('assets/images/food_icons/${foodDetail.category}.png')
                        Image.asset('assets/images/sharedItem.png'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          //Extract Location information
                          locationController.value.text;              
            
                          SharedItemService sharedItemService = SharedItemService();

                          User? currentUser = FirebaseAuth.instance.currentUser;
                            if (currentUser == null) {
                              throw Exception('User is null but want to publish item');
                            } else {
                              getUserFromDatabase(currentUser.uid).then((dto_user.TGTWUser userData) {
                                SharedItem sharedItem = SharedItem(
                                  name: widget.foodDetail.name,
                                  category: ItemCategory.parse(widget.foodDetail.category),
                                  amount:  UserItemAmount(
                                    nominal: widget.foodDetail.quantitynum,
                                    unit: widget.foodDetail.quantitytype
                                  ),
                                  buyDate: widget.foodDetail.remainDays,
                                  expireDate: widget.foodDetail.remainDays,
                                  user: currentUser.uid,
                                  itemRef: '',
                                );
                                sharedItemService.postSharedItem(userLocation, sharedItem);

                              });
                            }

                              UserItemService userItemService = UserItemService();
                              
                              await userItemService.deleteUserItem(currentUser.uid, widget.foodDetail.id);
                         
                              await dbhelper.deleteFood(widget.foodDetail.id);
                              
                              // Navigator.of(context, rootNavigator: true).pop();
                              // Navigator.pop(context);
                              setState(() {
                                Navigator.of(context).pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
                              });
                             
                        },
                        child: const Text('Yes, I do!'),
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
              Expanded(
                child:
                    DetailsList(
                      foodDetail: widget.foodDetail,
                      imagePth: categoryIconImagePath,
                    ),
                    ),
                  ],
                ),
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            try {
      
              //check if the state is still good
              if(widget.foodDetail.state == 'good'){
                
                showLocationDialog();
                // Navigator.pop(context);
              } else {
                showExpiredDialog(widget.foodDetail.name, widget.foodDetail.category);
              }
            } catch (e) {
              logger.e(e);
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

class DetailsList extends StatefulWidget {
  // const DetailsList({super.key, required this.buyDate, required this.expiryDate, required this.quantitynum, required this.quantitytype, required this.category, required this.remainDays, required this.imagePth});
  const DetailsList({super.key, required this.imagePth, required this.foodDetail});

  final UserItemDetail foodDetail;
  final String imagePth;

  @override
  _DetailsListState createState() => _DetailsListState();

}

class _DetailsListState extends State<DetailsList> {
  late TextEditingController quantityNumController;
  late TextEditingController quantityTypeController;
  late TextEditingController categoryController;
  late TextEditingController remainDaysController;
  late TextEditingController quanNumAndTypeController;
  late TextEditingController expireTimeController;
  late TextEditingController buyTimeController;

  late String currentQuantityNum;
  late String currentQuantityType;
  late String currentCategory;
  late String currentRemainDays;
  late int currentBuyDate;
  late int currentExpiryDate;

  @override
  void initState() {
    super.initState();
    currentCategory = widget.foodDetail.category;
    currentQuantityNum = widget.foodDetail.quantitynum.toString();
    currentQuantityType = widget.foodDetail.quantitytype;
    currentRemainDays = widget.foodDetail.remainDays.toString();
    currentBuyDate = widget.foodDetail.buyDate;
    currentExpiryDate = widget.foodDetail.expiryDate;
    quantityTypeController = TextEditingController(text: widget.foodDetail.quantitytype);
    categoryController = TextEditingController(text: widget.foodDetail.category);
    remainDaysController = TextEditingController(text: widget.foodDetail.remainDays.toString());
    expireTimeController = TextEditingController(text: "${DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.expiryDate).year}-${DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.expiryDate).month}-${DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.expiryDate).day}");
    buyTimeController = TextEditingController(text: "${DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.buyDate).year}-${DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.buyDate).month}-${DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.buyDate).day}");
    quantityNumController = TextEditingController(text: widget.foodDetail.quantitynum.toString());
    quanNumAndTypeController = TextEditingController(text: "${widget.foodDetail.quantitynum} ${widget.foodDetail.quantitytype}");
  }

  Future<void> _showCategoryDialog() async {
    final ItemCategory? selectedCategory = await showDialog<ItemCategory>(
        context: context,
        builder: (context) => CategoryPicker(initialCategory: ItemCategory.parse(widget.foodDetail.category)));

    if (selectedCategory != null) {
      setState(() {
        categoryController.text = selectedCategory.name;
      });
    }
    // return selectedCategory;
  }

  bool isEditMode = false;

  showUpdateDialog() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    AlertDialog dialog = AlertDialog(
      title: const Text("Hey!",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          )),
      content: Container(
          width: 3 * width / 5,
          height: height / 8,
          padding: const EdgeInsets.all(10.0),
          child: Text('Are you sure you want to update this item?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ))),
      actions: [
        TextButton(
          onPressed: () async {
            await updateFood();
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text('Yes!'),
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }


  Future<void> updateFood() async {
    DBHelper dbhelper = DBHelper();

    UserItem newFood = UserItem(
      id: widget.foodDetail.id,
      name: widget.foodDetail.name,
      category: ItemCategory.parse(currentCategory),
      quantityType: currentQuantityType,
      quantityNum: double.parse(currentQuantityNum),
      buyDate: currentBuyDate,
      expiryDate: currentExpiryDate,
      consumeState: widget.foodDetail.consumestate,
      state: widget.foodDetail.state
    );
   
    await dbhelper.updateFood(newFood);

     //insert new data into cloud firebase first and get the auto-generated id
    UserItemService userItemService = UserItemService();
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('You should Login first!');
    } else {
      await userItemService.updateUserItem(
        currentUser.uid, newFood.id!, newFood);
    }

     Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final nums = List.generate(10, (index) => index);
    int quanNum = 0;
    int quanSmallNum = 0;
    var quanType = "";
    List<Widget> numList = List.generate(10, (index) => Text("$index"));
    final quanTypes = ["g", "kg", "piece", "bag", "bottle", "num"];
    List<Widget> quanTypeList =
      List<Widget>.generate(6, (index) => Text(quanTypes[index]));

    DateTime selectedBuyDate = DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.buyDate);
    DateTime selectedExpiryDate= DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.expiryDate);
   
    return Stack(
      children: [
        Positioned(
            top: 0.0,
            right: 0.0,
            child: 
            // const SwitchButton(),
              IconButton(
                icon: Icon(isEditMode ? Icons.done : Icons.edit),
                onPressed: () {
                  setState(() {
                    isEditMode = !isEditMode;
                    if (!isEditMode) {
                      // Save changes
                      currentCategory = categoryController.text;
                      currentQuantityNum = quantityNumController.text;
                      currentQuantityType = quantityTypeController.text;
                      currentRemainDays = remainDaysController.text;
                    
                      showUpdateDialog();
                      // updateFood();
                    }
                  });
                },
              ),
          ),
          Container(
            padding: EdgeInsets.only(top: 20, bottom: 40),
            child:
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: Card(
                      child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[   
                          const Text(
                            'Storage Detail',
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 5), 
                        // subtitle: Text("Expired in $expire days", style: TextStyle(fontStyle: FontStyle.italic),),
                      Container(
                          width: 250,
                          child:
                          TextField(   
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Quantity',
                          ),
                          enabled: isEditMode,
                          controller: quanNumAndTypeController,
                          style: const TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20,
                          ),
                          onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        showCupertinoModalPopup(
                            context: context,
                            builder: (context) {
                              return Container(
                                  height: 200,
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: CupertinoPicker(
                                          itemExtent: 24.0,
                                          onSelectedItemChanged: (value) {
                                            setState(() {
                                              quanNum = nums[value];
                                              quantityNumController.text =
                                                  "$quanNum.$quanSmallNum";
                                              quanNumAndTypeController.text =
                                                  "$quanNum.$quanSmallNum $quanType";
                                            });
                                          },
                                          children: numList,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: CupertinoPicker(
                                          itemExtent: 24.0,
                                          onSelectedItemChanged: (value) {
                                            setState(() {
                                              quanSmallNum = nums[value];
                                              quantityNumController.text =
                                                  "$quanNum.$quanSmallNum";
                                              quanNumAndTypeController.text =
                                                  "$quanNum.$quanSmallNum $quanType";
                                            });
                                          },
                                          children: numList,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: CupertinoPicker(
                                          itemExtent: 24.0,
                                          onSelectedItemChanged: (value) {
                                            setState(() {
                                              quantityTypeController.text =
                                                  quanTypes[value];
                                              quanType = quanTypes[value];
                                              quanNumAndTypeController.text =
                                                  "$quanNum.$quanSmallNum $quanType";
                                            });
                                          },
                                          children: quanTypeList,
                                        ),
                                      )
                                    ],
                                  ));
                            });
                          },
                        ),
                        ),
                        ],
                    ),
                      ),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: Card(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[   
                          const Text(
                            'Category',
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 5),
                        // subtitle: Text("Expired in $expire days", style: TextStyle(fontStyle: FontStyle.italic),),
                        Container(
                          width: 250,
                          child: TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Category',
                            ),
                            enabled: isEditMode,
                            controller: categoryController,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 20,
                            ),
                            onTap: () {
                              FocusScope.of(context).requestFocus(FocusNode());
                              _showCategoryDialog();
                            },
                          ),
                        ),
                      ],
                    ),
                    ),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: Card(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[   
                          const Text(
                            'Bought in',
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 5),
                        Container(
                          width: 250,
                          child: TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Purchase date',
                            ),
                            enabled: isEditMode,
                            controller: buyTimeController,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 24,
                            ),
                            onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        showCupertinoModalPopup(
                            context: context,
                            builder: (context) {
                              return Container(
                                  height: 200,
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Container(
                                        height: MediaQuery.of(context)
                                                .copyWith()
                                                .size
                                                .height *
                                            0.25,
                                        color: Colors.white,
                                        child: CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.date,
                                          onDateTimeChanged: (value) {
                                            if (value != selectedBuyDate) {
                                              setState(() {
                                                selectedBuyDate = value;
                                                int year = selectedBuyDate.year;
                                                int month = selectedBuyDate.month;
                                                int day = selectedBuyDate.day;
                                                int timestamp = selectedBuyDate
                                                    .millisecondsSinceEpoch;

                                                currentBuyDate = timestamp;
                                                
                                                buyTimeController.text =
                                                    "$year-$month-$day";
                                                // Navigator.pop(context)
                                                //記錄下用戶選擇的時間 ------> 存入數據庫
                                              });
                                            }
                                          },
                                          initialDateTime: DateTime.now(),
                                          minimumYear: 2000,
                                          maximumYear: 2025,
                                        ),
                                      ))
                                    ],
                                  ));
                            });
                          },
                          ),
                          ),

                        ], 
                    ),
                    ),
                  ),
                  ),
                  const Divider(),
                  Expanded(
                    child: Card(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[   
                          const Text(
                            'Expires in',
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 5),
                        Container(
                          width: 250,
                          child: TextField(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Expiration date',
                            ),
                            enabled: isEditMode,
                            controller: expireTimeController,
                            style: const TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 24,
                            ),
                            onTap: () {
                        FocusScope.of(context).requestFocus(FocusNode());
                        showCupertinoModalPopup(
                            context: context,
                            builder: (context) {
                              return Container(
                                  height: 200,
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Container(
                                        height: MediaQuery.of(context)
                                                .copyWith()
                                                .size
                                                .height *
                                            0.25,
                                        color: Colors.white,
                                        child: CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.date,
                                          onDateTimeChanged: (value) {
                                            if (value != selectedExpiryDate) {
                                              setState(() {
                                                selectedExpiryDate = value;
                                                int year = selectedExpiryDate.year;
                                                int month = selectedExpiryDate.month;
                                                int day = selectedExpiryDate.day;
                                                int timestamp = selectedExpiryDate
                                                    .millisecondsSinceEpoch;

                                                currentExpiryDate = timestamp;
                                                
                                                expireTimeController.text =
                                                    "$year-$month-$day";
                                                // Navigator.pop(context)
                                                //記錄下用戶選擇的時間 ------> 存入數據庫
                                              });
                                            }
                                          },
                                          initialDateTime: DateTime.now(),
                                          minimumYear: 2000,
                                          maximumYear: 2025,
                                        ),
                                      ))
                                    ],
                                  ));
                            });
                          },
                          ),
                          ),

                        ], 
                    ),
                    ),
                  ),
                  ),
                ],
              ),
            ),
          )
                          ),]
              );
  }
}


