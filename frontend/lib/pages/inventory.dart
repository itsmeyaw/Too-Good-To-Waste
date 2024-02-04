import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rive/rive.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tooGoodToWaste/service/db_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:async';


import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class Inventory extends StatefulWidget {
  const Inventory({super.key});

  @override
  State<StatefulWidget> createState() => _BottomTopScreenState();
}

class _BottomTopScreenState extends State<Inventory>
    with TickerProviderStateMixin {
  TextEditingController nameController = TextEditingController();
  TextEditingController expireTimeController = TextEditingController();
  TextEditingController boughtTimeController = TextEditingController();
  TextEditingController quanTypeController = TextEditingController();
  TextEditingController quanNumController = TextEditingController();
  TextEditingController quanNumAndTypeController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  // camera related
  late String imagePath;
  late File imageFile;
  late String imageData;
  DateTime timeNowDate = DateTime.now();
  int timeNow = DateTime.now().millisecondsSinceEpoch;

  @override
  void dispose() {
    //Clean up all controllers when the widget is disposed
    nameController.dispose();
    expireTimeController.dispose();
    boughtTimeController.dispose();
    quanNumController.dispose();
    quanTypeController.dispose();
    categoryController.dispose();
    super.dispose();
  }
  //FocusNode focusNode1 = FocusNode();
  //FocusNode focusNode2 = FocusNode();
  //FocusScopeNode? focusScopeNode;

  Map<String, String> GlobalCateIconMap = {
    "Sea Food": "assets/category/seafood.png",
    "Meat": "assets/category/meat.png",
    "Milk": "assets/category/milk.png",
    "Milk Product": "assets/category/cheese.png",
    "Fruit": "assets/category/fruits.png",
    "Egg": "assets/category/egg.png",
    "Vegetable": "assets/category/vegetable.png",
    "Others": "assets/category/others.png"
  };

  String foodName = '';
  bool showSuggestList = false;
  List<Food> items = [];
  List<String> itemsWaste = [];
  //List<String> items = ['eggs','milk','butter];

  //Create Databse Object
  DBHelper dbhelper = DBHelper();
  Food food = Food(name: 'name', category: '', boughttime: -1, expiretime: -1, quantitytype: '', quantitynum: 0.0, consumestate: 0.0, state: 'good');
  //List food = ['name', '', -1, -1, '', -1.0, -1.0, ''];

  //check the primary state of uservalue should be updated or not; if so, update to the latest
  Future<void> updateStates() async {
    var user1 = await dbhelper.queryAll('users');
    int value = user1[0].positive - user1[0].negative;
    String primaryState;
    // String check = checkIfPrimaryStateChanged(value);
    String secondaryState = user1[0].secondarystate;

    if (value < 2) {
      primaryState = 'initialization';
      await dbhelper.updateUserPrimary(primaryState);
    } else if (value <= 6) {
      //judge the primary state
      primaryState = 'encounter';
      await dbhelper.updateUserPrimary(primaryState);
    } else if (value > 6 && value <= 14) {
      primaryState = 'mate';
      await dbhelper.updateUserPrimary(primaryState);
    } else if (value > 14 && value <= 30) {
      primaryState = 'nest';
      await dbhelper.updateUserPrimary(primaryState);
    } else if (value > 30 && value <= 46) {
      primaryState = 'hatch';
      await dbhelper.updateUserPrimary(primaryState);
    } else if (value > 46 && value <= 78) {
      primaryState = 'learn';
      await dbhelper.updateUserPrimary(primaryState);
    } else if (value > 78 && value <= 82) {
      primaryState = 'leavehome';
      await dbhelper.updateUserPrimary(primaryState);
    } else if (value > 82 && value <= 91) {
      primaryState = 'snow owl';
      await dbhelper.updateUserPrimary(primaryState);
    } else if (value > 91 && value <= 100) {
      primaryState = 'tawny owl';
      await dbhelper.updateUserPrimary(primaryState);
    }

    // if (secondaryState=="true" && check!="None"){
    if (secondaryState == "true") {
      await dbhelper.updateUserSecondary("false");
    }
  }

  Future<void> insertDB(Food food) async {
    //var maxId = await dbhelper.getMaxId();
    //print('##########################MaxID = $maxId###############################');
    //maxId = maxId + 1;
    // var newFood = Food(
    //     name: food[0],
    //     category: food[1],
    //     boughttime: food[2],
    //     expiretime: food[3],
    //     quantitytype: food[4],
    //     quantitynum: food[5],
    //     consumestate: food[6],
    //     state: food[7]);
    

    await dbhelper.insertFood(food);
    // print(await dbhelper.queryAll('foods'));
  }

  Future<List<dynamic>> getAllItems(String dbname) async {
    //await insertItem();

    //get all foods name as a list of string
    List<dynamic> items = await dbhelper.queryAll(dbname);
    //print('##################################first######################################');
    print(items);

    return items;
  }

  Future<List<String>> getItemName() async {
    //await insertItem();

    //get all foods name as a list of string
    List<String> items = await dbhelper.getAllUncosumedFoodStringValues('name');
    //print('##################################first######################################');
    //print(items);

    return items;
  }

  Future<List<String>> getItemCategory() async {
    //await insertItem();

    //get all foods name as a list of string
    List<String> category =
        await dbhelper.getAllUncosumedFoodStringValues('category');
    //print('##################################first######################################');
    //print(items);

    return category;
  }

  //
  Future<List<double>> getItemQuanNum() async {
    //get all foods quantity number as a list of integers
    List<double> num = await dbhelper.getAllUncosumedFoodDoubleValues('quantitynum');

    return num;
  }

  Future<List<String>> getItemQuanType() async {
    //get all foods quantity number as a list of integers
    List<String> type =
        await dbhelper.getAllUncosumedFoodStringValues('quantitytype');

    return type;
  }

  Future<List<DateTime>> getItemExpiringTime() async {
    List<int> expire =
        await dbhelper.getAllUncosumedFoodIntValues('expiretime');
    var expireDate = List<DateTime>.generate(
        expire.length, (i) => DateTime.fromMillisecondsSinceEpoch(expire[i]));
    return expireDate;
  }

  Future<List<DateTime>> getItemBoughtTime() async {
    List<int> boughttime =
        await dbhelper.getAllUncosumedFoodIntValues('boughttime');
    var boughtDate = List<DateTime>.generate(boughttime.length,
        (i) => DateTime.fromMillisecondsSinceEpoch(boughttime[i]));
    return boughtDate;
  }

  Future<void> addItemName(value) async {
    List<String> items = await dbhelper.getAllUncosumedFoodStringValues('name');
    //items = await getItemName();
    //print(items);

    setState(() {
      items.add(value);
    });
  }

  Future<void> addItemExpi(value) async {
    List<int> expires =
        await dbhelper.getAllUncosumedFoodIntValues('expiretime');
    print(expires);

    setState(() {
      expires.add(value);
    });
  }

  Future<void> editItem(index, value) async {
    // items = await getItemName();
    setState(() async {
      items[index] = value;
    });
  }

  Future<void> deleteItem(String value) async {
    //items = await getItemName();
    await dbhelper.deleteFood(value);
  }

  Future<void> updateFoodState(String name, String attribute) async {
    var updatedFood = await dbhelper.queryOne('foods', name);
    print(updatedFood);
    if (attribute == 'consumed') {
      //var consumedFoodUpdate = Food(id: id, name: name, category: updatedFood[0].category, boughttime: updatedFood[0].boughttime, expiretime: updatedFood[0].expiretime, quantitytype: updatedFood[0].quantitytype, quantitynum: 0, consumestate: 1.0, state: 'consumed');
      await dbhelper.updateFoodConsumed(name, 'consumed');
      print(await dbhelper.queryAll('foods'));
    } else {
      //var wastedFoodUpdate = Food(id: id, name: name, category: updatedFood[0].category, boughttime: updatedFood[0].boughttime, expiretime: updatedFood[0].expiretime, quantitytype: updatedFood[0].quantitytype, quantitynum: updatedFood[0].quantitynum, consumestate: 1.0, state: 'wasted');
      await dbhelper.updateFoodWaste(name);
      print(await dbhelper.queryAll('foods'));
    }
  }

  //edit the state to 'consumed' and consumestate to 1, and user positive data adds 1
  //the arugument should be 'positive'(which means positive + 1) or 'negative'(which means negative + 1)
  Future<void> updateUserValue(String state) async {
    var user1 = await dbhelper.queryAll('users');
    //int value = user1[0]['positive'] - user1[0]['negative'];
    print('================= user =================');
    print(user1);

    if (state == 'positive') {
      //judge the primary state
      var uservalue = UserValue(
          name: user1[0].name,
          negative: user1[0].negative,
          positive: user1[0].positive + 1,
          primarystate: user1[0].primarystate,
          secondarystate: 'true',
          secondaryevent: "single",
          thirdstate: "move",
          species: "folca",
          childrennum: 0,
          fatherstate: "single",
          motherstate: "single",
          time: timeNow);
      await dbhelper.updateUser(uservalue);
      await updateStates();
      print(await dbhelper.queryAll("users"));
    } else {
      var uservalue = UserValue(
          name: user1[0].name,
          negative: user1[0].negative + 1,
          positive: user1[0].positive,
          primarystate: user1[0].primarystate,
          secondarystate: 'true',
          secondaryevent: "single",
          thirdstate: "move",
          species: "folca",
          childrennum: 0,
          fatherstate: "single",
          motherstate: "single",
          time: timeNow);
      await dbhelper.updateUser(uservalue);
      await updateStates();
      print(await dbhelper.queryAll("users"));
    }
  }

  Future pickImage(bool isCamera) async {
    XFile? image;
    if (isCamera == true) {
      image = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      image = await ImagePicker().pickImage(source: ImageSource.gallery);
    }
    if (image == null) return;
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: image.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(context: context),
      ],
    );
    if (croppedFile != null) {
      setState(() {
        imageFile = File(croppedFile.path);
        imageData = base64Encode(imageFile.readAsBytesSync());
      });
    }
    doUpload();
  }

  //upload picture request related
  final url_to_api = "http://34.65.81.128:5000/";

  doUpload() async {
    Map<String, dynamic> jsonMap = {
      "image": imageData,
      "headers": {"Content-Type": "application/json"}
    };
    String jsonString = json.encode(jsonMap);
    http.Response response =
        await http.post(Uri.parse(url_to_api), body: jsonString);
    var parsed = jsonDecode(response.body);
    //fromJson(parsed);
    parsed.forEach((key, value) async {
      //record the key and value
      await insertDBbyKey(key, value);
      print('#####$key######$value############');
    });
    //updateUserValue();
    print(response.body);
  }

 // Mock data for testing Image Uploading function
  Future<void> insertDBbyKey(String name, int number) async {
    // var maxId = await dbhelper.getMaxId();
    //print('##########################MaxID = $maxId###############################');
    //maxId = maxId + 1;
    //timeNow -> DateTime, + 7 days, --> int timestamp
    var expireDate =
        timeNowDate.add(const Duration(days: 7)).millisecondsSinceEpoch;
    print('#########################$expireDate##################');
    var newFood = Food(
        name: name,
        category: 'Meat',
        boughttime: timeNow,
        expiretime: expireDate,
        quantitytype: 'bag',
        quantitynum: 0.0,
        consumestate: 0.0,
        state: 'good');

    print(newFood);

    await dbhelper.insertFood(newFood);
    print(await dbhelper.queryAll('foods'));
  }

  var txt = TextEditingController();
  late TooltipBehavior _tooltipBehavior;
  //late bool _isLoading;
  late TabController _tabController;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    //_controller = TabController(length: 3, vsync: this);
    //Future.delayed(Duration(seconds: 3)).then((value) {
    //setState(() {
    //_isLoading = false;
    //});
    //});
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    DateTime dateToday = DateTime.now();
    String date = dateToday.toString().substring(0, 10);

    Color color = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          toolbarHeight: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.storefront_outlined), text: "Current"),
              Tab(icon: Icon(Icons.bar_chart), text: "Statistic"),
              Tab(icon: Icon(Icons.calendar_today), text: "Plan"),
            ],
          )),
      body: TabBarView(
        controller: _tabController,
        children: [
          Column(
            children: [
              TextField(
                decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                    ),
                    hintText: "Search"),
              ),
              Expanded(
                  child: buildList()),
            ],
          ),
          Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ListView(
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Your Statistic',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text('Month: January'),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                            height: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 200,
                                  child: PieChart(PieChartData(sections: [
                                    PieChartSectionData(
                                        value: 10,
                                        title: 'Wasted',
                                        color: Colors.red),
                                    PieChartSectionData(
                                        value: 50,
                                        title: 'Used',
                                        color: Colors.blue),
                                    PieChartSectionData(
                                        value: 25,
                                        title: 'Shared',
                                        color: Colors.green),
                                    PieChartSectionData(
                                        value: 10,
                                        title: 'Almost Expired',
                                        color: Colors.yellow)
                                  ])),
                                )
                              ],
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        Text('Period: Jan 2024 - Dec 2024'),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                            height: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width -
                                      20, // 20 is padding left + right
                                  child: _LineChart(),
                                )
                              ],
                            )),
                      ]),
                ],
              )),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                flex: 2,
                child: GestureDetector(
                  child: const RiveAnimation.asset(
                    'assets/anime/noWasted.riv',
                  ),
                ),
              ),
              Flexible(
                flex: 1,
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Nothing expired yet, keep it on!',
                      textStyle: const TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  totalRepeatCount: 4,
                  pause: const Duration(milliseconds: 100000),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
              ),
              Flexible(
                flex: 1,
                child: Container(),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton:
          Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          tooltip: "Add item",
          onPressed: () {
            // clear out txt buffer before entering new screen
            txt.value = const TextEditingValue();
            //pushAddItemPage();
            pushAddItemScreen();
          },
          child: const Icon(Icons.add),
        ),
        const SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          onPressed: () => pickImage(false),
          heroTag: null,
          child: const Icon(Icons.photo_album),
        ),
        const SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          onPressed: () => pickImage(true),
          heroTag: null,
          child: const Icon(Icons.camera_alt),
        )
      ]),
    );
  }

  Future<List<String>> getWasteItemString(String value) async {
    List<Map<String, dynamic>> items = await dbhelper.getAllWastedFoodList();
    print(
        '#################################$items############################');
    List<String> WasteName =
        List<String>.generate(items.length, (i) => items[i][value]);
    return WasteName;
  }

  Future<List<double>> getWasteItemDouble(String value) async {
    List<Map<String, dynamic>> items = await dbhelper.getAllWastedFoodList();
    List<double> WasteName =
        List<double>.generate(items.length, (i) => items[i][value]);
    return WasteName;
  }

  Widget buildWasteList() {
    return FutureBuilder(
        future: Future.wait([
          getWasteItemString('name'),
          //getWasteItemInt('expiretime'),
          getWasteItemDouble('quantitynum'),
          getWasteItemString('quantitytype'),
          getWasteItemString('category'),
          //getWasteItemInt('boughttime'),
        ]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const Text('Loading...'); // still loading
          }
          // alternatively use snapshot.connectionState != ConnectionState.done
          if (snapshot.hasError) return const Text('Something went wrong.');
          List<String> itemsWaste = snapshot.requireData[0];
          if (itemsWaste.isEmpty) {
            return const Center(
              child: Text(
                "Nothing yet...",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            );
          }

          //List<dynamic> foodItems = getFoodItems(snapshot.requireData);

          //final List<DateTime> expires = List<DateTime>.from(foodItems[1]);
          List<double> num = snapshot.requireData[1];
          List<String> type = snapshot.requireData[2];
          List<String> categoryies = snapshot.requireData[3];
          print(
              '###################$Category##############$num#####################3$type#######################$itemsWaste##################');

          return ListTileTheme(
              contentPadding: const EdgeInsets.all(15),
              textColor: Colors.black54,
              style: ListTileStyle.list,
              dense: true,
              child: ListView.builder(
                  itemCount: itemsWaste.length,
                  itemBuilder: (context, index) {
                    var item = itemsWaste[index];
                    //how to show the quantity tyoe and quantity number?

                    //var expires = getItemExpiringTime();
                    //how to show the listsby sequence of expire time?
                    //var remainDays = remainingTime[index].inDays;
                    //var progressPercentage = remainDays / (expires[index].difference(boughtTime[index]).inDays);
                    var foodNum = num[index];
                    var foodType = type[index];

                    var category = categoryies[index];

                    return buildWasteItem(
                        item,
                        //remainDays,
                        foodNum,
                        foodType,
                        category);
                    //progressPercentage);
                  }));
        });
  }

  Widget buildWasteItem(String item, double num, String type, String category) {
    String? categoryIconImagePath;

    if (GlobalCateIconMap[category] == null) {
      categoryIconImagePath = GlobalCateIconMap["Others"];
    } else {
      categoryIconImagePath = GlobalCateIconMap[category];
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(10.0),
      child: Column(children: [
        Flexible(
          flex: 1,
          child: AnimatedTextKit(
            animatedTexts: [
              TypewriterAnimatedText(
                'Oh No! You have wasted $num $type $item already...',
                textStyle: const TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
                speed: const Duration(milliseconds: 100),
              ),
            ],
            totalRepeatCount: 4,
            pause: const Duration(milliseconds: 100000),
            displayFullTextOnTap: true,
            stopPauseOnTap: true,
          ),
        ),
        Flexible(
            flex: 1,
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  leading: Container(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Image(
                      image: AssetImage(categoryIconImagePath!),
                      width: 32,
                      height: 32,
                    ),
                  ),
                  title: Text(
                    item,
                    style: const TextStyle(fontSize: 25),
                  ),
                  // subtitle: Text("Expired in $expire days", style: TextStyle(fontStyle: FontStyle.italic),),
                  trailing: Text("$num $type",
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24,
                      )),
                ),
              ],
            )),
      ]),
    );
  }

  Widget buildList() {
    //items = await getItemName();
    return FutureBuilder(
        future: Future.wait([
          getAllItems('foods')
        ]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const Text('Loading...'); // still loading
          }
          // alternatively use snapshot.connectionState != ConnectionState.done
          if (snapshot.hasError) return const Text('Something went wrong.');
          items = snapshot.requireData[0].cast<Food>();
          items = items.where((i) => i.consumestate < 1).toList();
          if (items.isEmpty) {
            return const Center(
              child: Text(
                "Nothing yet...",
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            );
          }
          return ListTileTheme(
              contentPadding: const EdgeInsets.all(15),
              textColor: Colors.black54,
              style: ListTileStyle.list,
              dense: true,
              child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var item = items[index];
                    //how to show the quantity tyoe and quantity number?

                    //var expires = getItemExpiringTime();
                    //how to show the listsby sequence of expire time?
                    var remainDays = DateTime.fromMillisecondsSinceEpoch(item.expiretime).difference(DateTime.now()).inDays;
                    var progressPercentage = 1.0 - (remainDays / DateTime.fromMillisecondsSinceEpoch(item.expiretime).difference(DateTime.fromMillisecondsSinceEpoch(item.boughttime)).inDays);
                    progressPercentage = progressPercentage > 1.0 ? 1.0 : progressPercentage;
                    print(remainDays);
                    print(progressPercentage);
                    print(DateTime.fromMillisecondsSinceEpoch(item.expiretime));
                    var foodNum = item.quantitynum;
                    var foodType = item.quantitytype;

                    var category = item.category;

                    return buildItem(item.name, remainDays, foodNum, foodType, index,
                        category, progressPercentage);
                  }));
        });
  }

  Widget buildItem(String text, int expire, double foodNum, String foodType,
      int index, String category, double progressPercentage) {
    String? categoryIconImagePath;
    Color progressColor;
    if (GlobalCateIconMap[category] == null) {
      categoryIconImagePath = GlobalCateIconMap["Others"];
    } else {
      categoryIconImagePath = GlobalCateIconMap[category];
    }
    if (progressPercentage > 0.0 && progressPercentage < 0.49) {
      progressColor = Colors.green;
    } else if (progressPercentage >= 0.49 && progressPercentage < 0.66) {
      progressColor = Colors.yellow;
    } else if (progressPercentage >= 0.66 && progressPercentage < 1.0) {
      progressColor = Colors.red;
    } else {
      progressColor = Colors.black;
    }
    //test = food name, 
    updateFoodDB(text, index, attribute) async {
          await updateFoodState(text, attribute);
          await updateUserValue(attribute == "consumed" ? 'positive' : 'negative');
          items.removeAt(index);
          print(items);
          print(await getAllItems('foods'));
        }
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
      color:
          expire > 3 ? Colors.white : const Color.fromRGBO(238, 162, 164, 0.8),
      child: Slidable(
        key: const ValueKey(0),
        startActionPane: ActionPane(
          // A motion is a widget used to control how the pane animates.
          motion: const ScrollMotion(),

          // A pane can dismiss the Slidable.
          dismissible: DismissiblePane(onDismissed: () {
            updateFoodDB(text, index, 'wasted');
          }),

          // All actions are defined in the children parameter.
          children: [
            // A SlidableAction can have an icon and/or a label.
            SlidableAction(
              onPressed: (BuildContext context) async {

                updateFoodDB(text, index, 'wasted');
                // ignore: list_remove_unrelated_type
                //items is supposed to be [] right?
                //items.remove(text);
                //await Provider.of<BottomTopScreen>(context, listen: false).remove(items[0]);
                // print('#########${user1[0].primarystate}#############');
              },
              backgroundColor: const Color(0xFFFE4A49),
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Waste',
            ),
          ],
        ),

        // The end action pane is the one at the right or the bottom side.
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          dismissible: DismissiblePane(onDismissed: () {
            updateFoodDB(text, index, 'consumed');
          }),
          children: [
            SlidableAction(
              // An action can be bigger than the others.
              flex: 2,
              onPressed: (BuildContext context) async {
                updateFoodDB(text, index, 'consumed');
              },
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              icon: Icons.archive,
              label: 'Consume',
            ),
          ],
        ),

        // The child of the Slidable is what the user sees when the
        // component is not dragged.
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: Container(
            padding: const EdgeInsets.only(right: 12.0),
            decoration: const BoxDecoration(
                border: Border(right: BorderSide(width: 1.0))),
            child: Image(
              image: AssetImage("$categoryIconImagePath"),
              width: 32,
              height: 32,
            ),
          ),
          title: Text(
            text,
            style: const TextStyle(fontSize: 25),
          ),
          subtitle: Row(
            children: <Widget>[
              Expanded(
                  flex: 1,
                  child: Container(
                    child: LinearProgressIndicator(
                        backgroundColor:
                            const Color.fromRGBO(209, 224, 224, 0.2),
                        value: progressPercentage,
                        valueColor: AlwaysStoppedAnimation(progressColor)),
                  )),
              Expanded(
                flex: 4,
                child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text("$expire Days Left",
                        style: TextStyle(
                            color: expire > 3 ? Colors.orange : Colors.black))),
              )
            ],
          ),
          // subtitle: Text("Expired in $expire days", style: TextStyle(fontStyle: FontStyle.italic),),
          trailing: Text("$foodNum $foodType",
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 24,
              )),
          onTap: () {
            //edit one specific card ---------直接跳去詳情頁面吧
            //txt.value = new TextEditingController.fromValue(new TextEditingValue(text: items[index])).value;
            //transport the index or name of the tapped food card to itemDetailPage

            //builder: (BuildContext index) => itemDetailPage();
            pushItemDetailScreen(index, text);
          },
          onLongPress: () async {
            //長按卡片刪除
            await deleteItem(text);
            items.removeAt(index);
            print(
                '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%${await getAllItems('foods')}%%%%%%%%%%%%%%%%%%%%%%%%');
          },
        ),
      ),
    );
  }

  void pushItemDetailScreen(int index, String text) async {
    String quantype = await dbhelper.getOneFoodValue(text, 'quantitytype');
    double quannum = await dbhelper.getOneFoodDoubleValue(text, 'quantitynum');
    int expitime = await dbhelper.getOneFoodIntValue(text, 'expiretime');
    var expireDate = DateTime.fromMillisecondsSinceEpoch(expitime);
    var remainDays = expireDate.difference(timeNowDate).inDays;

    String category = await dbhelper.getOneFoodValue(text, 'category');
    double consumeprogress =
        await dbhelper.getOneFoodDoubleValue(text, 'consumestate');

    Navigator.push(context, MaterialPageRoute<void>(
      builder: (BuildContext context) {
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
              title: text,
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text('Storage Now: $quannum $quantype'),
                      //Text(quantype),
                    ],
                  ),
                  Row(children: <Widget>[Text('Category: $category')]),
                  Row(children: <Widget>[Text('Expires in: $remainDays')]),
                ],
              ),
              //progress bar of cosume state
            ),
            SizedBox(
              height: 5,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
                value: consumeprogress,
              ),
            ),
          ]),
        );
      },
    ));
  }

  Widget getTextWidgets(List<String> strings) {
    return Row(children: strings.map((item) => Text(item)).toList());
  }

  Widget heightSpacer(double myHeight) => SizedBox(height: myHeight);

  /// opens add new item screen
  void pushAddItemScreen() {
    //String date = dateToday.toString().substring(0, 10);
    Color color = Theme.of(context).primaryColor;
    const double padding = 15;

    final category = [
      "Vegetable",
      "Meat",
      "Fruit",
      "Milk Product",
      "Milk",
      "Sea Food",
      "Egg",
      "Others"
    ];
    categoryController.text = 'Vegetable';
    quanTypeController.text = 'g';
    List<Widget> categortyList =
        List<Widget>.generate(8, (index) => Text(category[index]));
    final quanTypes = ["g", "kg", "piece", "bag", "bottle", "num"];
    List<Widget> quanTypeList =
        List<Widget>.generate(6, (index) => Text(quanTypes[index]));
    final nums = List.generate(10, (index) => index);
    List<Widget> numList = List.generate(10, (index) => Text("$index"));
    int quanNum = 0;
    int quanSmallNum = 0;
    var quanType = "";
    DateTime selectedDate = DateTime.now();
    int expireTimeStamp = 0;
    Color textFieldColor = const Color.fromRGBO(178, 207, 135, 0.8);

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            nameController.clear();
            categoryController.clear();
            quanNumController.clear();
            quanTypeController.clear();
            expireTimeController.clear();
            quanNumAndTypeController.clear();
            Navigator.of(context).pop(false);
          }
        ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Add an Item'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(
            children: <Widget>[
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.fastfood),
                  hintText: 'e.g. Eggs',
                ),
                autofocus: true,
                controller: nameController,
                onSubmitted: (value) {},
              ),
              heightSpacer(5),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.food_bank),
                  hintText: 'Food type',
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
                                  child: CupertinoPicker(
                                    itemExtent: 24.0,
                                    onSelectedItemChanged: (value) {
                                      setState(() {
                                        categoryController.text =
                                            category[value];
                                      });
                                    },
                                    children: categortyList,
                                  ),
                                )
                              ],
                            ));
                      });
                },
                controller: categoryController,
              ),
              heightSpacer(5),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.shopping_bag,
                  ),
                  hintText: 'Amount',
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
                                        quanNumController.text =
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
                                        quanNumController.text =
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
                                        quanTypeController.text =
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
                controller: quanNumAndTypeController,
              ),
              heightSpacer(5),
              TextField(
                decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.calendar_today,
                    ),
                    hintText: 'Expiration date'),
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
                                      if (value != selectedDate) {
                                        setState(() {
                                          selectedDate = value;
                                          int year = selectedDate.year;
                                          int month = selectedDate.month;
                                          int day = selectedDate.day;
                                          int timestamp = selectedDate
                                              .millisecondsSinceEpoch;
                                          print("timestamp$timestamp");
                                          expireTimeStamp = timestamp;
                                          food.expiretime = expireTimeStamp;
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
                controller: expireTimeController,
              ),
              heightSpacer(5),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Expiration date',
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      //需要添加只能選擇一個的判斷
                      _buildButtonColumn1(1),
                      _buildButtonColumn1(4),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildButtonColumn1(7),
                      _buildButtonColumn1(14),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            try {
              food.name = nameController.text;
              food.category = categoryController.text;
              food.boughttime = timeNow;
              //food[3] = expireTimeStamp;
              food.quantitytype = quanTypeController.text;
              food.quantitynum = double.parse(quanNumController.text);
              food.consumestate = 0.0;
              food.state = 'good';
              print(food);
              //var quantityNum = int.parse(quanNumController.text);
              //接上InputPage裏DateTime時間組件，再轉化成timestamp存進數據庫
              //var expiretime = int.parse(expireTimeController.text);

              //food[3]是可以直接傳入數據庫的int timestamp
              DateTime expireDays =
                  DateTime.fromMillisecondsSinceEpoch(food.expiretime);
              var remainExpireDays = expireDays.difference(timeNowDate).inDays;
              addItemExpi(remainExpireDays);
              addItemName(food.name);
              print(food);

              //Calculate the current state of the new food
              //well actually i should assume the state of a new food should always be good, unless the user is an idiot
              //But i'm going to do the calculation anyway

              //insert new data into database
              insertDB(food);
              print(
                  '#################################${dbhelper.queryAll('foods')}#####################');

              //user positive value add 1
              //var user1 = dbhelper.queryAll('users');
              updateUserValue('positive');
            } on FormatException {
              print('Format Error!');
            }
          
            // close route
            // when push is used, it pushes new item on stack of navigator
            // simply pop off stack and it goes back
            nameController.clear();
            categoryController.clear();
            quanNumController.clear();
            quanTypeController.clear();
            expireTimeController.clear();
            quanNumAndTypeController.clear();
            Navigator.pop(context);
          },
          tooltip: 'Add item',
          label: Text('Add item'),
          icon: const Icon(Icons.add),
        ),
      );
    }));
  }

  // button list for expiring date (only button)
  OutlinedButton _buildButtonColumn1(int value) {
    return OutlinedButton.icon(
      onPressed: () {
        //record new expire time ----> value
        var later = timeNowDate.add(Duration(days: value));
        food.expiretime = later.millisecondsSinceEpoch;
        int year = later.year;
        int month = later.month;
        int day = later.day;
        expireTimeController.text = "$year-$month-$day";
      },
      icon: const Icon(Icons.calendar_today),
      label: Text("+ $value days"),
    );
  }

  /// opens edit item screen
  void pushEditItemScreen(index) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Edit item..'),
        ),
        body: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Eggs',
            border: OutlineInputBorder(),
          ),
          controller: txt,
          onSubmitted: (value) {
            editItem(index, value);
            Navigator.pop(context);
            buildList();
          },
        ),
      );
    }));
  }

  // input textfield
  Widget customizedTextField(controller, hint) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
        child: TextField(
          onChanged: (String txt) {},
          style: const TextStyle(
            fontSize: 20,
          ),
          // cursorColor: HotelAppTheme.buildLightTheme().primaryColor,
          decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16),
              labelText: hint,
              prefixIcon: const Icon(Icons.food_bank)),
          controller: quanTypeController,
        ));
  }

  List<Duration> getRemainingExpiringTime(List<DateTime> expiringTime) {
    List<Duration> remainingTime = [];
    for (var i = 0; i < expiringTime.length; i++) {
      remainingTime.add(expiringTime[i].difference(DateTime.now()));
    }
    return remainingTime;
  }
}

class _LineChart extends StatelessWidget {
  const _LineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      sampleData2,
      duration: const Duration(milliseconds: 250),
    );
  }

  LineChartData get sampleData2 => LineChartData(
        lineTouchData: lineTouchData2,
        gridData: gridData,
        titlesData: titlesData2,
        lineBarsData: lineBarsData2,
        minX: 0,
        maxX: 13,
        maxY: 17,
        minY: 0,
      );

  LineTouchData get lineTouchData1 => LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
        ),
      );

  FlTitlesData get titlesData1 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  LineTouchData get lineTouchData2 => const LineTouchData(
        enabled: false,
      );

  FlTitlesData get titlesData2 => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: bottomTitles,
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: leftTitles(),
        ),
      );

  List<LineChartBarData> get lineBarsData2 => [
        lineChartBarData2_1,
        lineChartBarData2_2,
        lineChartBarData2_3,
      ];

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
    );
    String text;
    switch (value.toInt()) {
      case 5:
        text = '5kg';
        break;
      case 10:
        text = '10kg';
        break;
      case 15:
        text = '15kg';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: 1,
        reservedSize: 40,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontSize: 10,
    );
    Widget text;
    switch (value.toInt()) {
      case 1:
        text = const Text('JAN', style: style);
        break;
      case 2:
        text = const Text('FEB', style: style);
        break;
      case 3:
        text = const Text('MAR', style: style);
        break;
      case 4:
        text = const Text('APR', style: style);
        break;
      case 5:
        text = const Text('MAY', style: style);
        break;
      case 6:
        text = const Text('JUN', style: style);
        break;
      case 7:
        text = const Text('JUL', style: style);
        break;
      case 8:
        text = const Text('AUG', style: style);
        break;
      case 9:
        text = const Text('SEP', style: style);
        break;
      case 10:
        text = const Text('OCT', style: style);
        break;
      case 11:
        text = const Text('NOV', style: style);
        break;
      case 12:
        text = const Text('DEC', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 10,
      child: text,
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData => const FlGridData(show: false);

  LineChartBarData get lineChartBarData2_1 => LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: Colors.green,
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 1),
          FlSpot(2, 3),
          FlSpot(3, 4),
          FlSpot(4, 2),
          FlSpot(5, 1.8),
          FlSpot(6, 4),
          FlSpot(7, 7),
          FlSpot(8, 5),
          FlSpot(9, 3),
          FlSpot(10, 2),
          FlSpot(11, 1),
          FlSpot(12, 2.2),
        ],
      );

  LineChartBarData get lineChartBarData2_2 => LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: Colors.blue,
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        spots: const [
          FlSpot(1, 12),
          FlSpot(2, 11),
          FlSpot(3, 14),
          FlSpot(4, 9),
          FlSpot(5, 11),
          FlSpot(6, 10),
          FlSpot(7, 12),
          FlSpot(8, 13),
          FlSpot(9, 14),
          FlSpot(10, 11),
          FlSpot(11, 10),
          FlSpot(12, 12),
        ],
      );

  LineChartBarData get lineChartBarData2_3 => LineChartBarData(
        isCurved: true,
        curveSmoothness: 0,
        color: Colors.red,
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        spots: const [
          FlSpot(1, 3.8),
          FlSpot(2, 2),
          FlSpot(3, 1.9),
          FlSpot(4, 2),
          FlSpot(5, 1),
          FlSpot(6, 5),
          FlSpot(7, 1),
          FlSpot(8, 2),
          FlSpot(9, 4),
          FlSpot(10, 3.3),
          FlSpot(11, 2),
          FlSpot(12, 4),
        ],
      );
}
