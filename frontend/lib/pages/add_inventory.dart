// import 'package:tooGoodToWaste/service/db_helper.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';

// import '../widgets/date_picker.dart';
// import '../widgets/dialog.dart';
// import '../widgets/quantity_dialog.dart';

// import 'package:tooGoodToWaste/dto/user_item_model.dart';

// class AddInventoryPage extends StatefulWidget {
//   const AddInventoryPage({super.key});
//   //const AddInventoryPage({super.key, required this.foodDetail});

//   @override
//   State<StatefulWidget> createState() => _InputPageState();
// }

// class _InputPageState extends State<AddInventoryPage>
//     with TickerProviderStateMixin {
//     TextEditingController nameController = TextEditingController();
//     TextEditingController expireTimeController = TextEditingController();
//     TextEditingController boughtTimeController = TextEditingController();
//     TextEditingController quanTypeController = TextEditingController();
//     TextEditingController quanNumController = TextEditingController();
//     TextEditingController quanNumAndTypeController = TextEditingController();
//     TextEditingController categoryController = TextEditingController();

//   //const InputPage({Key? key}) : super(key: key);
//   DateTime timeNowDate = DateTime.now();
//   int timeNow = DateTime.now().millisecondsSinceEpoch;

//   //Create Databse Object
//   DBHelper dbhelper = DBHelper();
//   // List food = ['', '', -1, -1, '', -1, -1.0, ''];
//   UserItem food = UserItem(name: 'name', category: '', boughttime: -1, expiretime: -1, quantitytype: '', quantitynum: 0.0, consumestate: 0.0, state: 'good');

//   @override
//   void dispose() {
//     //Clean up all controllers when the widget is disposed
//     nameController.dispose();
//     expireTimeController.dispose();
//     boughtTimeController.dispose();
//     quanNumController.dispose();
//     quanTypeController.dispose();
//     categoryController.dispose();
//     super.dispose();
//   }

//   Map<String, String> GlobalCateIconMap = {
//     "Sea Food": "assets/category/seafood.png",
//     "Meat": "assets/category/meat.png",
//     "Milk": "assets/category/milk.png",
//     "Milk Product": "assets/category/cheese.png",
//     "Fruit": "assets/category/fruits.png",
//     "Egg": "assets/category/egg.png",
//     "Vegetable": "assets/category/vegetable.png",
//     "Others": "assets/category/others.png"
//   };
//   //check the primary state of uservalue should be updated or not; if so, update to the latest
//   Future<void> updatePrimaryState() async {
//     var user1 = await dbhelper.queryAll('users');
//     int value = user1[0].positive - user1[0].negative;
//     String primaryState;

//     if (value < 2) {
//       primaryState = 'initialization';
//       await dbhelper.updateUserPrimary(primaryState);
//     }
//     if (value <= 6) {
//       //judge the primary state
//       primaryState = 'encounter';
//       await dbhelper.updateUserPrimary(primaryState);
//     }
//     if (value > 6 && value <= 14) {
//       primaryState = 'mate';
//       await dbhelper.updateUserPrimary(primaryState);
//     }
//     if (value > 14 && value <= 30) {
//       primaryState = 'nest';
//       await dbhelper.updateUserPrimary(primaryState);
//     }
//     if (value > 30 && value <= 46) {
//       primaryState = 'hatch';
//       await dbhelper.updateUserPrimary(primaryState);
//     }
//     if (value > 46 && value <= 78) {
//       primaryState = 'learn';
//       await dbhelper.updateUserPrimary(primaryState);
//     } else if (value > 78 && value <= 82) {
//       primaryState = 'leavehome';
//       await dbhelper.updateUserPrimary(primaryState);
//     } else if (value > 82 && value <= 91) {
//       primaryState = 'snow owl';
//       await dbhelper.updateUserPrimary(primaryState);
//     } else if (value > 91 && value <= 100) {
//       primaryState = 'tawny owl';
//     }
//   }

//   //edit the state to 'consumed' and consumestate to 1, and user positive data adds 1
//   //the arugument should be 'positive'(which means positive + 1) or 'negative'(which means negative + 1)
//   Future<void> insertDB(UserItem food) async {
//     //var maxId = await dbhelper.getMaxId();
//     //print('##########################MaxID = $maxId###############################');
//     //maxId = maxId + 1;

//     await dbhelper.insertFood(food);
//     // print(await dbhelper.queryAll('foods'));
//   }

//   Future<void> addItemName(value) async {
//     List<String> items = await dbhelper.getAllUncosumedFoodStringValues('name');
//     //items = await getItemName();
//     //print(items);

//     setState(() {
//       items.add(value);
//     });
//   }

//   Future<void> addItemExpi(value) async {
//     List<int> expires =
//         await dbhelper.getAllUncosumedFoodIntValues('expiretime');
//     print(expires);

//     setState(() {
//       expires.add(value);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {

//     final category = [
//       "Vegetable",
//       "Meat",
//       "Fruit",
//       "Milk Product",
//       "Milk",
//       "Sea Food",
//       "Egg",
//       "Others"
//     ];
//     categoryController.text = 'Vegetable';
//     quanTypeController.text = 'g';
//     List<Widget> categortyList =
//         List<Widget>.generate(8, (index) => Text(category[index]));
//     final quanTypes = ["g", "kg", "piece", "bag", "bottle", "num"];
//     List<Widget> quanTypeList =
//         List<Widget>.generate(6, (index) => Text(quanTypes[index]));
//     final nums = List.generate(10, (index) => index);
//     List<Widget> numList = List.generate(10, (index) => Text("$index"));
//     int quanNum = 0;
//     int quanSmallNum = 0;
//     var quanType = "";
//     DateTime selectedDate = DateTime.now();
//     int expireTimeStamp = 0;

//     OutlinedButton _buildButtonColumn1(int value) {
//       return OutlinedButton.icon(
//         onPressed: () {
//           //record new expire time ----> value
//           var later = timeNowDate.add(Duration(days: value));
//           food.expiretime = later.millisecondsSinceEpoch;
//           int year = later.year;
//           int month = later.month;
//           int day = later.day;
//           expireTimeController.text = "$year-$month-$day";
//         },
//         icon: const Icon(Icons.calendar_today),
//         label: Text("+ $value days"),
//       );
//   }
//     /// build item
//     Widget heightSpacer(double myHeight) => SizedBox(height: myHeight);
//     //var txt = TextEditingController();
//     return MaterialApp(
//       title: 'Flutter layout demo',
//       home: Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             nameController.clear();
//             categoryController.clear();
//             quanNumController.clear();
//             quanTypeController.clear();
//             expireTimeController.clear();
//             quanNumAndTypeController.clear();
//             Navigator.of(context).pop(false);
//           }
//         ),
//           backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//           title: const Text('Add an Item'),
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(15),
//           child: ListView(
//             children: <Widget>[
//               TextField(
//                 decoration: const InputDecoration(
//                   prefixIcon: Icon(Icons.fastfood),
//                   hintText: 'e.g. Eggs',
//                 ),
//                 autofocus: true,
//                 controller: nameController,
//                 onSubmitted: (value) {},
//               ),
//               heightSpacer(5),
//               TextField(
//                 decoration: const InputDecoration(
//                   prefixIcon: Icon(Icons.food_bank),
//                   hintText: 'Food type',
//                 ),
//                 onTap: () {
//                   FocusScope.of(context).requestFocus(FocusNode());
//                   showCupertinoModalPopup(
//                       context: context,
//                       builder: (context) {
//                         return Container(
//                             height: 200,
//                             color: Colors.white,
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: CupertinoPicker(
//                                     itemExtent: 24.0,
//                                     onSelectedItemChanged: (value) {
//                                       setState(() {
//                                         categoryController.text =
//                                             category[value];
//                                       });
//                                     },
//                                     children: categortyList,
//                                   ),
//                                 )
//                               ],
//                             ));
//                       });
//                 },
//                 controller: categoryController,
//               ),
//               heightSpacer(5),
//               TextField(
//                 decoration: const InputDecoration(
//                   prefixIcon: Icon(
//                     Icons.shopping_bag,
//                   ),
//                   hintText: 'Amount',
//                 ),
//                 onTap: () {
//                   FocusScope.of(context).requestFocus(FocusNode());
//                   showCupertinoModalPopup(
//                       context: context,
//                       builder: (context) {
//                         return Container(
//                             height: 200,
//                             color: Colors.white,
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   flex: 2,
//                                   child: CupertinoPicker(
//                                     itemExtent: 24.0,
//                                     onSelectedItemChanged: (value) {
//                                       setState(() {
//                                         quanNum = nums[value];
//                                         quanNumController.text =
//                                             "$quanNum.$quanSmallNum";
//                                         quanNumAndTypeController.text =
//                                             "$quanNum.$quanSmallNum $quanType";
//                                       });
//                                     },
//                                     children: numList,
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 2,
//                                   child: CupertinoPicker(
//                                     itemExtent: 24.0,
//                                     onSelectedItemChanged: (value) {
//                                       setState(() {
//                                         quanSmallNum = nums[value];
//                                         quanNumController.text =
//                                             "$quanNum.$quanSmallNum";
//                                         quanNumAndTypeController.text =
//                                             "$quanNum.$quanSmallNum $quanType";
//                                       });
//                                     },
//                                     children: numList,
//                                   ),
//                                 ),
//                                 Expanded(
//                                   flex: 3,
//                                   child: CupertinoPicker(
//                                     itemExtent: 24.0,
//                                     onSelectedItemChanged: (value) {
//                                       setState(() {
//                                         quanTypeController.text =
//                                             quanTypes[value];
//                                         quanType = quanTypes[value];
//                                         quanNumAndTypeController.text =
//                                             "$quanNum.$quanSmallNum $quanType";
//                                       });
//                                     },
//                                     children: quanTypeList,
//                                   ),
//                                 )
//                               ],
//                             ));
//                       });
//                 },
//                 controller: quanNumAndTypeController,
//               ),
//               heightSpacer(5),
//               TextField(
//                 decoration: const InputDecoration(
//                     prefixIcon: Icon(
//                       Icons.calendar_today,
//                     ),
//                     hintText: 'Expiration date'),
//                 onTap: () {
//                   FocusScope.of(context).requestFocus(FocusNode());
//                   showCupertinoModalPopup(
//                       context: context,
//                       builder: (context) {
//                         return Container(
//                             height: 200,
//                             color: Colors.white,
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                     child: Container(
//                                   height: MediaQuery.of(context)
//                                           .copyWith()
//                                           .size
//                                           .height *
//                                       0.25,
//                                   color: Colors.white,
//                                   child: CupertinoDatePicker(
//                                     mode: CupertinoDatePickerMode.date,
//                                     onDateTimeChanged: (value) {
//                                       if (value != selectedDate) {
//                                         setState(() {
//                                           selectedDate = value;
//                                           int year = selectedDate.year;
//                                           int month = selectedDate.month;
//                                           int day = selectedDate.day;
//                                           int timestamp = selectedDate
//                                               .millisecondsSinceEpoch;
//                                           print("timestamp$timestamp");
//                                           expireTimeStamp = timestamp;
//                                           food.expiretime = expireTimeStamp;
//                                           expireTimeController.text =
//                                               "$year-$month-$day";
//                                           // Navigator.pop(context)
//                                           //記錄下用戶選擇的時間 ------> 存入數據庫
//                                         });
//                                       }
//                                     },
//                                     initialDateTime: DateTime.now(),
//                                     minimumYear: 2000,
//                                     maximumYear: 2025,
//                                   ),
//                                 ))
//                               ],
//                             ));
//                       });
//                 },
//                 controller: expireTimeController,
//               ),
//               heightSpacer(5),
//               Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   const Text(
//                     'Expiration date',
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       //需要添加只能選擇一個的判斷
//                       _buildButtonColumn1(1),
//                       _buildButtonColumn1(4),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       _buildButtonColumn1(7),
//                       _buildButtonColumn1(14),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         floatingActionButton: FloatingActionButton.extended(
//           onPressed: () async {
//             try {
//               food.name = nameController.text;
//               food.category = categoryController.text;
//               food.boughttime = timeNow;
//               //food[3] = expireTimeStamp;
//               food.quantitytype = quanTypeController.text;
//               food.quantitynum = double.parse(quanNumController.text);
//               food.consumestate = 0.0;
//               food.state = 'good';
//               print(food);
//               //var quantityNum = int.parse(quanNumController.text);
//               //接上InputPage裏DateTime時間組件，再轉化成timestamp存進數據庫
//               //var expiretime = int.parse(expireTimeController.text);

//               //food[3]是可以直接傳入數據庫的int timestamp
//               DateTime expireDays =
//                   DateTime.fromMillisecondsSinceEpoch(food.expiretime);
//               var remainExpireDays = expireDays.difference(timeNowDate).inDays;
//               addItemExpi(remainExpireDays);
//               addItemName(food.name);
//               print(food);

//               //Calculate the current state of the new food
//               //well actually i should assume the state of a new food should always be good, unless the user is an idiot
//               //But i'm going to do the calculation anyway

//               //insert new data into database
//               insertDB(food);

//               print(
//                   '#################################${dbhelper.queryAll('foods')}#####################');

//               //user positive value add 1
//               //var user1 = dbhelper.queryAll('users');
//               // updateUserValue('positive');
//             } on FormatException {
//               print('Format Error!');
//             }

//             // close route
//             // when push is used, it pushes new item on stack of navigator
//             // simply pop off stack and it goes back
//             nameController.clear();
//             categoryController.clear();
//             quanNumController.clear();
//             quanTypeController.clear();
//             expireTimeController.clear();
//             quanNumAndTypeController.clear();
//             Navigator.pop(context);
//           },
//           tooltip: 'Add item',
//           label: Text('Add item'),
//           icon: const Icon(Icons.add),

//         ),
//         floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       ),
//    );
//   }
// }
