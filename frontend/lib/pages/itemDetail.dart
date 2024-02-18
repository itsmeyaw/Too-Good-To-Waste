import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:tooGoodToWaste/dto/item_category_enum.dart';
import 'package:tooGoodToWaste/dto/shared_item_model.dart';
import 'package:tooGoodToWaste/dto/user_item_detail_model.dart';
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
  // UserItemDetail _foodDetail;
  //  _foodDetail = widget.foodDetail;

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
                      quantitynum: widget.foodDetail.quantitynum,
                      quantitytype: widget.foodDetail.quantitytype,
                      category: widget.foodDetail.category,
                      remainDays: widget.foodDetail.remainDays,
                      imagePth: categoryIconImagePath,
                      buyDate: DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.buyDate),
                      expiryDate: DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.expiryDate),
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
  const DetailsList({super.key, required this.buyDate, required this.expiryDate, required this.quantitynum, required this.quantitytype, required this.category, required this.remainDays, required this.imagePth});

  final double quantitynum;
  final String quantitytype;
  final DateTime buyDate;
  final DateTime expiryDate;
  final String category;
  final int remainDays;
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
  late DateTime currentBuyDate;
  late DateTime currentExpiryDate;

  @override
  void initState() {
    super.initState();
    currentCategory = widget.category;
    currentQuantityNum = widget.quantitynum.toString();
    currentQuantityType = widget.quantitytype;
    currentRemainDays = widget.remainDays.toString();
    currentBuyDate = widget.buyDate;
    currentExpiryDate = widget.expiryDate;
    quantityTypeController = TextEditingController(text: widget.quantitytype);
    categoryController = TextEditingController(text: widget.category);
    remainDaysController = TextEditingController(text: widget.remainDays.toString());
    expireTimeController = TextEditingController(text: "${widget.expiryDate.year}-${widget.expiryDate.month}-${widget.expiryDate.day}");
    buyTimeController = TextEditingController(text: "${widget.buyDate.year}-${widget.buyDate.month}-${widget.buyDate.day}");
    quantityNumController = TextEditingController(text: widget.quantitynum.toString());
    quanNumAndTypeController = TextEditingController(text: "${widget.quantitynum} ${widget.quantitytype}");
  }

  Future<void> _showCategoryDialog() async {
    final ItemCategory? selectedCategory = await showDialog<ItemCategory>(
        context: context,
        builder: (context) => CategoryPicker(initialCategory: ItemCategory.parse(widget.category)));

    if (selectedCategory != null) {
      setState(() {
        categoryController.text = selectedCategory.name;
      });
    }
    // return selectedCategory;
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

    DateTime selectedBuyDate = widget.buyDate;
    DateTime selectedExpiryDate= widget.expiryDate;

    bool _isEditMode = false;

    void _toggleEditMode() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        // Save changes
        currentCategory = categoryController.text;
        currentQuantityNum = quantityNumController.text;
        currentQuantityType = quantityTypeController.text;
        currentRemainDays = remainDaysController.text;
        currentBuyDate = DateTime.parse(buyTimeController.text);
        currentExpiryDate = DateTime.parse(expireTimeController.text);
      }
  }

    return Stack(
                  children: [
                    Positioned(
                      top: 0.0,
                      right: 0.0,
                      child: 
                      // const SwitchButton(),
                        IconButton(
                          icon: Icon(_isEditMode ? Icons.done : Icons.edit),
                          onPressed: () {
                            setState(() {
                              _toggleEditMode();
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
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(height: 5), 
                  // subtitle: Text("Expired in $expire days", style: TextStyle(fontStyle: FontStyle.italic),),
                 Container(
                    width: 300,
                    child:
                     TextField(   
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Quantity',
                    ),
                    enabled: _isEditMode,
                    controller: quanNumAndTypeController,
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
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(height: 10),
                  // subtitle: Text("Expired in $expire days", style: TextStyle(fontStyle: FontStyle.italic),),
                  Container(
                    width: 300,
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Category',
                      ),
                      enabled: _isEditMode,
                      controller: categoryController,
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24,
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
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(height: 5),
                  Container(
                    width: 300,
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Purchase date',
                      ),
                      enabled: _isEditMode,
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

                                          int expireTimeStamp = timestamp;
                                          
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
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(height: 5),
                  Container(
                    width: 300,
                    child: TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Expiration date',
                      ),
                      enabled: _isEditMode,
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

                                          int expireTimeStamp = timestamp;
                                          
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


