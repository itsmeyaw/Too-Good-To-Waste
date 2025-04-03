import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tooGoodToWaste/widgets/line_chart.dart';
import 'dart:convert';
import 'package:flutter/src/painting/gradient.dart' as Gradient;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';
import 'package:rive/rive.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tooGoodToWaste/const/color_const.dart';
import 'package:tooGoodToWaste/dto/category_icon_map.dart';
import 'package:tooGoodToWaste/dto/item_allergies_enum.dart';
import 'package:tooGoodToWaste/dto/item_category_enum.dart';
import 'package:tooGoodToWaste/service/ai_service.dart';
import 'package:tooGoodToWaste/service/db_helper.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:tooGoodToWaste/service/shared_items_service.dart';
import 'package:tooGoodToWaste/widgets/category_picker.dart';
import 'package:tooGoodToWaste/widgets/expandableFab.dart';
import 'package:tooGoodToWaste/widgets/indicator.dart';
import 'dart:io';
import 'itemDetail.dart';
import '../dto/user_item_detail_model.dart';
import '../dto/user_item_model.dart';
import 'package:tooGoodToWaste/service/user_item_service.dart';

import 'package:tooGoodToWaste/dto/user_model.dart' as dto_user;

Logger logger = Logger();

class Inventory extends StatefulWidget {
  const Inventory({super.key});
  static const route = '/inventory';

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
  AiService aiService = AiService();

  // camera related
  late String imagePath;
  late File imageFile;
  late String imageData;
  DateTime timeNowDate = DateTime.now();
  int timeNow = DateTime.now().millisecondsSinceEpoch;
  ItemCategory? category;
  List<ItemAllergy> allergies = [];

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

  String foodName = '';
  bool showSuggestList = false;
  List<UserItem> items = [];
  List<String> itemsWaste = [];

  //Create Databse Object
  DBHelper dbhelper = DBHelper();
  UserItem food = UserItem(
      id: '',
      name: '',
      category: ItemCategory.Others,
      buyDate: -1,
      expiryDate: -1,
      quantityType: '',
      quantityNum: 0.0,
      consumeState: 0.0,
      state: 'good');

  Future<void> insertDB(UserItem food) async {
    //Insert a new UserValue instance
    await dbhelper.insertFood(food);
  }

  Future<List<dynamic>> getAllItems(String dbname) async {
    //get all foods name as a list of string
    List<dynamic> items = await dbhelper.queryAll(dbname);

    return items;
  }

  Future<List<String>> getItemName() async {
    List<String> items = await dbhelper.getAllUncosumedFoodStringValues('name');

    return items;
  }

  Future<List<String>> getItemCategory() async {
    List<String> category =
        await dbhelper.getAllUncosumedFoodStringValues('category');

    return category;
  }

  //
  Future<List<double>> getItemQuanNum() async {
    //get all foods quantity number as a list of integers
    List<double> num =
        await dbhelper.getAllUncosumedFoodDoubleValues('quantity_num');

    return num;
  }

  Future<List<String>> getItemQuanType() async {
    //get all foods quantity number as a list of integers
    List<String> type =
        await dbhelper.getAllUncosumedFoodStringValues('quantity_type');

    return type;
  }

  Future<List<DateTime>> getItemExpiringTime() async {
    List<int> expire =
        await dbhelper.getAllUncosumedFoodIntValues('expiry_date');
    var expireDate = List<DateTime>.generate(
        expire.length, (i) => DateTime.fromMillisecondsSinceEpoch(expire[i]));
    return expireDate;
  }

  Future<List<DateTime>> getItemBoughtTime() async {
    List<int> boughttime =
        await dbhelper.getAllUncosumedFoodIntValues('buy_date');
    var boughtDate = List<DateTime>.generate(boughttime.length,
        (i) => DateTime.fromMillisecondsSinceEpoch(boughttime[i]));
    return boughtDate;
  }

  Future<void> addItemName(value) async {
    List<String> items = await dbhelper.getAllUncosumedFoodStringValues('name');
    setState(() {
      items.add(value);
    });
  }

  Future<void> addItemExpi(value) async {
    List<int> expires =
        await dbhelper.getAllUncosumedFoodIntValues('expiry_date');

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

  Future<void> deleteItem(String id) async {
    //items = await getItemName();
    await dbhelper.deleteFood(id);
  }

  Future<void> updateFoodState(String id, String attribute) async {
    // var updatedFood = await dbhelper.queryOne('foods', id);
    if (attribute == 'consumed') {
      await dbhelper.updateFoodConsumed(id, 'consumed');
    } else {
      await dbhelper.updateFoodWaste(id);
    }
  }

  bool isCategoryInEnum(String category) {
    return ItemCategory.values
        .map((e) => e.toString().split('.').last.toLowerCase())
        .contains(category);
  }

  String capitalizeFirstLetter(String category) {
    if (category.isEmpty) return category; // Return input if it's empty

    // Capitalize the first letter and keep the rest unchanged
    return '${category[0].toUpperCase()}${category.substring(1)}';
  }

  Future<void> pickImage(bool isCamera) async {
    XFile? image;

    if (isCamera == true) {
      image = await ImagePicker()
          .pickImage(source: ImageSource.camera, requestFullMetadata: true);
    } else {
      image = await ImagePicker()
          .pickImage(source: ImageSource.gallery, requestFullMetadata: true);
    }

    if (image == null) return;

    List<int> pickedImageData = await image.readAsBytes();
    String? mime = lookupMimeType(image.path);

    logger.d(
        'Successfully obtained image data ${image.name} (mime: $mime) (data: ${base64Encode(pickedImageData)})');

    if (mime != null) {
      List<UserItem> items =
          await aiService.readReceipt(mime, base64Encode(pickedImageData));

      UserItemService userItemService = UserItemService();
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('You should Login first!');
      } else {
        for (final item in items) {
          if (item.name == null) {
            logger.e('Item name is null');
            continue;
          } else if (isCategoryInEnum(item.category.name)) {
            logger.e('Item category is not recognised');
            continue;
          } else {
            //insert new data into cloud firebase first and get the auto-generated id
            item.category =
                ItemCategory.parse(capitalizeFirstLetter(item.category.name));
            var id = await userItemService.addUserItem(currentUser.uid, item);

            if (id == null) {
              logger.w('Failed to insert food into local database');
            } else {
              logger.d(item);

              item.id = id;

              await insertDB(item);
              await userItemService.updateUserItem(
                  currentUser.uid, item.id!, item);
            }
          }
        }
      }
      //TODO: Loading widget...
      const duration = Duration(seconds: 2);
      Future.delayed(duration, () {
        // After the duration, trigger buildList() method
        setState(() {
          buildList();
        });
      });
    } else {
      logger.e('Cannot determine mime');
    }
  }

  var txt = TextEditingController();
  late TooltipBehavior _tooltipBehavior;

  //late bool _isLoading;
  late TabController _tabController;
  int wasteNum = 0;

  double wastedPercentage = 0.0;
  double sharedPercentage = 0.0;
  double expiringPercentage = 0.0;
  double goodPercentage = 0.0;

  late bool isShowingMainData;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);

    super.initState();
    isShowingMainData = true;
    _tabController = TabController(length: 3, vsync: this);
    _fetchWasteNum();
    calculatePieChart();
  }

  void _fetchWasteNum() async {
    // Fetch wasteNum asynchronously
    int length = await getWasteItemString('name').then((value) => value.length);
    setState(() {
      wasteNum = length; // Set the value of wasteNum
    });
  }

  void calculatePieChart() {
    SharedItemService sharedItemService = SharedItemService();

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception(
          'User is null but want to get statistic. Please login first.');
    } else {
      sharedItemService
          .getSharedItemOfUser(currentUser.uid)
          .then((value) async {
        int sharedNum = value.length;
        int wastedNum =
            await getWasteItemString('name').then((value) => value.length);
        int totalNum = await dbhelper
            .queryAll('foods')
            .then((value) => value.length + sharedNum);
        int expiringNum = await dbhelper
            .queryAllGoodFood('expiring')
            .then((value) => value.length);
        double wastedPerc = (wastedNum / totalNum) * 100;
        double sharedPerc = (sharedNum / totalNum) * 100;
        double expiringPerc = (expiringNum / totalNum) * 100;
        double goodPerc = 100 - wastedPerc - sharedPerc - expiringPerc;
        logger.d(
            'Wasted: $wastedPerc, Shared: $sharedPerc, Expiring: $expiringPerc, Good: $goodPerc');

        setState(() {
          wastedPercentage = wastedPerc;
          sharedPercentage = sharedPerc;
          expiringPercentage = expiringPerc;
          goodPercentage = goodPerc;
        });
      });
    }
  }

  bool isExpanded = false; // State variable to control animation
  bool toClose = false;
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments;
    if (message == null) {
      // logger.d('No Cloud Message');
    } else {
      logger.d('Title: $message');
    }

    final _media = MediaQuery.of(context).size;

    List<PieChartSectionData> showingSections() {
      return List.generate(4, (i) {
        final isTouched = i == touchedIndex;
        final fontSize = isTouched ? 25.0 : 16.0;
        final radius = isTouched ? 60.0 : 50.0;
        const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
        switch (i) {
          case 0:
            return PieChartSectionData(
              color: Colors.red,
              value: wastedPercentage,
              title: '${wastedPercentage.toStringAsFixed(2)}%',
              radius: radius,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                shadows: shadows,
              ),
            );
          case 1:
            return PieChartSectionData(
              color: Colors.blue,
              value: goodPercentage,
              title: '${goodPercentage.toStringAsFixed(2)}%',
              radius: radius,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                shadows: shadows,
              ),
            );
          case 2:
            return PieChartSectionData(
              color: Colors.green,
              value: sharedPercentage,
              title: '${sharedPercentage.toStringAsFixed(2)}%',
              radius: radius,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                shadows: shadows,
              ),
            );
          case 3:
            return PieChartSectionData(
              color: Colors.yellow,
              value: expiringPercentage,
              title: '${expiringPercentage.toStringAsFixed(2)}%',
              radius: radius,
              titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                shadows: shadows,
              ),
            );
          default:
            throw Error();
        }
      });
    }

    List<String> monthNames = [
      '', // Index 0 is empty since months start from 1
      'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];

    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          toolbarHeight: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.storefront_outlined), text: "Current"),
              Tab(icon: Icon(Icons.bar_chart), text: "Statistic"),
              Tab(icon: Icon(Icons.recycling), text: "Recycle"),
            ],
          )),
      body: Container(
        height: _media.height,
        width: _media.width,
        decoration: BoxDecoration(
          gradient: Gradient.LinearGradient(
            begin: FractionalOffset(0.5, 0.0),
            end: FractionalOffset(0.6, 0.8),
            stops: [0.0, 0.9],
            colors: [YELLOW, BLUE],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: [
            Column(
              children: [
                const TextField(
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                      ),
                      hintText: "Search"),
                ),
                Expanded(child: buildList()),
              ],
            ),
            Container(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
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
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                              'Month: ${monthNames[timeNowDate.month]} ${timeNowDate.year}'),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: <Widget>[
                              const SizedBox(
                                width: 15,
                              ),
                              AnimatedContainer(
                                  duration: Duration(seconds: 1),
                                  curve: Curves.easeInOut,
                                  height: isExpanded ? 220 : 150,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: 200,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isExpanded = !isExpanded;
                                              });
                                            },
                                            child: PieChart(
                                              PieChartData(
                                                pieTouchData: PieTouchData(
                                                  touchCallback:
                                                      (FlTouchEvent event,
                                                          pieTouchResponse) {
                                                    setState(() {
                                                      if (!event
                                                              .isInterestedForInteractions ||
                                                          pieTouchResponse ==
                                                              null ||
                                                          pieTouchResponse
                                                                  .touchedSection ==
                                                              null) {
                                                        touchedIndex = -1;
                                                        return;
                                                      }
                                                      touchedIndex =
                                                          pieTouchResponse
                                                              .touchedSection!
                                                              .touchedSectionIndex;
                                                    });
                                                  },
                                                ),
                                                borderData: FlBorderData(
                                                  show: false,
                                                ),
                                                sectionsSpace: 0,
                                                centerSpaceRadius: 40,
                                                sections: showingSections(),
                                              ),
                                            ),
                                          )),
                                    ],
                                  )),
                              const SizedBox(
                                width: 15,
                              ),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Indicator(
                                    color: Colors.red,
                                    text: 'Wasted',
                                    isSquare: true,
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Indicator(
                                    color: Colors.blue,
                                    text: 'Used',
                                    isSquare: true,
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Indicator(
                                    color: Colors.green,
                                    text: 'Shared',
                                    isSquare: true,
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Indicator(
                                    color: Colors.yellow,
                                    text: 'Expiring',
                                    isSquare: true,
                                  ),
                                  SizedBox(
                                    height: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 50,
                          ),
                          const Text('Period: April 2024 - May 2024'),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.refresh,
                                    color: Colors.black.withOpacity(
                                        isShowingMainData ? 1.0 : 0.5),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isShowingMainData = !isShowingMainData;
                                    });
                                  },
                                ),
                                Text(
                                  'Show Food Saving Trend',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(
                                        isShowingMainData ? 1.0 : 0.5),
                                  ),
                                ),
                              ]),
                          SizedBox(
                              height: 200,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width -
                                        20, // 20 is padding left + right
                                    child: Line_Chart(
                                        isShowingMainData: isShowingMainData),
                                  )
                                ],
                              )),
                        ]),
                  ],
                )),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: wasteNum == 0
                  ? [
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
                              'Nothing wasted yet, keep it on!',
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
                    ]
                  : [
                      Expanded(child: buildWasteList()),
                    ],
            ),
          ],
        ),
      ),
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        //toClose: toClose,
        children: [
          FloatingActionButton(
            tooltip: "Add item",
            onPressed: () {
              // clear out txt buffer before entering new screen
              txt.value = const TextEditingValue();
              //pushAddItemPage();
              pushAddItemScreen();
              setState(() {
                toClose = true;
              });
            },
            child: const Icon(Icons.add),
          ),
          FloatingActionButton(
            onPressed: () => pickImage(false),
            heroTag: null,
            child: const Icon(Icons.photo_album),
          ),
          FloatingActionButton(
            onPressed: () => pickImage(true),
            heroTag: null,
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
    );
  }

  Future<List<String>> getWasteItemString(String value) async {
    List<Map<String, dynamic>> items = await dbhelper.getAllWastedFoodList();

    List<String> WastesName =
        List<String>.generate(items.length, (i) => items[i][value]);
    return WastesName;
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
          getWasteItemDouble('quantity_num'),
          getWasteItemString('quantity_type'),
          getWasteItemString('category'),
        ]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const Text('Loading...'); // still loading
          }

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
          List<double> num = snapshot.requireData[1];
          List<String> type = snapshot.requireData[2];
          List<String> categoryies = snapshot.requireData[3];

          return ListTileTheme(
              contentPadding: const EdgeInsets.all(15),
              textColor: Colors.black54,
              style: ListTileStyle.list,
              dense: true,
              child: ListView.builder(
                  itemCount: itemsWaste.length,
                  itemBuilder: (context, index) {
                    var item = itemsWaste[index];
                    var foodNum = num[index];
                    var foodType = type[index];

                    var category = categoryies[index];

                    return buildWasteItem(item, foodNum, foodType, category);
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
                'Oh No! You have wasted $num $type $item already...We provide this trick to help you reuse these Food Scraps !',
                textStyle: const TextStyle(
                  fontSize: 25.0,
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
                    style: const TextStyle(fontSize: 17),
                  ),
                  trailing: Text("$num $type",
                      style: const TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 24,
                      )),
                ),
              ],
            )),
        Flexible(
          flex: 1,
          child: Image.asset('assets/images/foodWaste.png'),
        )
      ]),
    );
  }

  Widget buildList() {
    //items = await getItemName();
    return FutureBuilder(
        future: Future.wait([getAllItems('foods')]),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return const Text('Loading...'); // still loading
          }
          // alternatively use snapshot.connectionState != ConnectionState.done
          if (snapshot.hasError) return const Text('Something went wrong.');
          items = snapshot.requireData[0].cast<UserItem>();
          items = items.where((i) => i.consumeState < 1).toList();
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
                    var remainDays =
                        DateTime.fromMillisecondsSinceEpoch(item.expiryDate)
                            .difference(DateTime.now())
                            .inDays;
                    var progressPercentage = 1.0 -
                        (remainDays /
                            DateTime.fromMillisecondsSinceEpoch(item.expiryDate)
                                .difference(DateTime.fromMillisecondsSinceEpoch(
                                    item.buyDate))
                                .inDays);
                    progressPercentage =
                        progressPercentage > 1.0 ? 1.0 : progressPercentage;

                    var category = item.category;

                    User? currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser == null) {
                      throw Exception('Please login first.');
                    } else {
                      return buildItem(currentUser.uid, item.id!, item,
                          remainDays, index, progressPercentage);
                    }
                  }));
        });
  }

  showDeleteDialog(String foodname, String userId, String itemId, int index) {
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
          child: Text('Are you sure you want to delete this item?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ))),
      actions: [
        TextButton(
          onPressed: () async {
            await deleteItem(itemId);

            UserItemService userItemService = UserItemService();
            await userItemService.deleteUserItem(userId, itemId);
            logger.d('Deleted item $itemId');

            setState(() {
              items.removeAt(index);
              // Navigator.of(context).pushNamedAndRemoveUntil('/', ModalRoute.withName('/'));
              Navigator.of(context, rootNavigator: true).pop();
            });
          },
          child: const Text('Yes'),
        ),
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
  }

  Widget buildItem(String userId, String itemId, UserItem userItem,
      int remainDays, int index, double progressPercentage) {
    String? categoryIconImagePath;
    Color progressColor;
    if (GlobalCateIconMap[userItem.category.name] == null) {
      categoryIconImagePath = GlobalCateIconMap["Others"];
    } else {
      categoryIconImagePath = GlobalCateIconMap[userItem.category.name];
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
    updateFoodDB(index, attribute) async {
      await updateFoodState(itemId, attribute);

      UserItemService userItemService = UserItemService();
      await userItemService.updateUserItem(
          userId,
          itemId,
          UserItem(
            id: itemId,
            name: userItem.name,
            category: userItem.category,
            buyDate: userItem.buyDate,
            expiryDate: userItem.expiryDate,
            quantityType: userItem.quantityType,
            quantityNum: userItem.quantityNum,
            consumeState: 1.0,
            state: attribute,
          ));

      items.removeAt(index);

      setState(() {
        buildWasteList();
        //build();
      });
      // });
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
      color: remainDays > 3
          ? Colors.white
          : const Color.fromRGBO(238, 162, 164, 0.8),
      child: Slidable(
        //key: const ValueKey(0),
        key: UniqueKey(),
        startActionPane: ActionPane(
          // A motion is a widget used to control how the pane animates.
          motion: const ScrollMotion(),

          // A pane can dismiss the Slidable.
          dismissible: DismissiblePane(onDismissed: () {
            updateFoodDB(index, 'wasted');

            // setState(() {
            //   buildWasteList();
            // });
          }),

          // All actions are defined in the children parameter.
          children: [
            // A SlidableAction can have an icon and/or a label.
            SlidableAction(
              onPressed: (context) => {},
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
            updateFoodDB(index, 'consumed');
          }),
          children: [
            SlidableAction(
              // An action can be bigger than the others.
              flex: 2,
              onPressed: (context) => {},
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
            userItem.name,
            style: const TextStyle(fontSize: 18),
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
                    child: Text("$remainDays Days Left",
                        style: TextStyle(
                            color: remainDays > 3
                                ? Colors.orange
                                : Colors.black))),
              )
            ],
          ),
          // subtitle: Text("Expired in $expire days", style: TextStyle(fontStyle: FontStyle.italic),),
          trailing: Text("${userItem.quantityNum} ${userItem.quantityType}",
              style: const TextStyle(
                fontFamily: 'Roboto',
                fontSize: 18,
              )),
          onTap: () {
            pushItemDetailScreen(itemId, userItem.name);
          },
          onLongPress: () async {
            //長按卡片刪除
            showDeleteDialog(userItem.name, userId, itemId, index);
          },
        ),
      ),
    );
  }

  void pushItemDetailScreen(String id, String text) async {
    String quantype = await dbhelper.getOneFoodValue(id, 'quantity_type');
    double quannum = await dbhelper.getOneFoodDoubleValue(id, 'quantity_num');
    int expitime = await dbhelper.getOneFoodIntValue(id, 'expiry_date');
    int buytime = await dbhelper.getOneFoodIntValue(id, 'buy_date');
    String state = await dbhelper.getOneFoodValue(id, 'state');
    var expireDate = DateTime.fromMillisecondsSinceEpoch(expitime);
    var remainDays = expireDate.difference(timeNowDate).inDays;

    String category = await dbhelper.getOneFoodValue(id, 'category');
    double consumeprogress =
        await dbhelper.getOneFoodDoubleValue(id, 'consume_state');

    var foodDetail = UserItemDetail(
        id: id,
        name: text,
        category: category,
        remainDays: remainDays,
        buyDate: buytime,
        expiryDate: expitime,
        quantitytype: quantype,
        quantitynum: quannum,
        consumestate: consumeprogress,
        state: state);

    //navigate to the item detail page
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => itemDetailPage(foodDetail: foodDetail))).then(
      (value) {
        setState(() {});
      },
    );
  }

  Widget getTextWidgets(List<String> strings) {
    return Row(children: strings.map((item) => Text(item)).toList());
  }

  Widget heightSpacer(double myHeight) => SizedBox(height: myHeight);

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

  Future<void> _showCategoryDialog() async {
    final ItemCategory? selectedCategory = await showDialog<ItemCategory>(
        context: context,
        builder: (context) => CategoryPicker(initialCategory: category));

    if (selectedCategory != null) {
      setState(() {
        category = selectedCategory;
        categoryController.text = category!.name;
      });
    }
    // return selectedCategory;
  }

  /// opens add new item screen
  void pushAddItemScreen() {
    //String date = dateToday.toString().substring(0, 10);
    Color color = Theme.of(context).primaryColor;
    const double padding = 15;

    categoryController.text = 'Vegetable';
    quanTypeController.text = 'g';
    // List<Widget> categortyList =
    //     List<Widget>.generate(8, (index) => Text(category[index]));
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
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                nameController.clear();
                categoryController.clear();
                quanNumController.clear();
                quanTypeController.clear();
                expireTimeController.clear();
                quanNumAndTypeController.clear();
                Navigator.of(context).pop(false);
              }),
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
                controller: nameController,
                onSubmitted: (value) {},
              ),
              heightSpacer(5),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.food_bank),
                  hintText: 'Food type',
                ),
                // label: category != null
                //       ? Text('Category: ${category!.name}')
                //       : const Text('Category: Any'),
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                  _showCategoryDialog();
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

                                          expireTimeStamp = timestamp;
                                          food.expiryDate = expireTimeStamp;
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
              food.category = ItemCategory.parse(categoryController.text);
              food.buyDate = timeNow;
              //food[3] = expireTimeStamp;
              food.quantityType = quanTypeController.text;
              food.quantityNum = double.parse(quanNumController.text);
              food.consumeState = 0.0;
              food.state = 'good';
              logger.d('food: $food');
              DateTime expireDays =
                  DateTime.fromMillisecondsSinceEpoch(food.expiryDate);
              var remainExpireDays = expireDays.difference(timeNowDate).inDays;
              addItemExpi(remainExpireDays);
              addItemName(food.name);

              //insert new data into cloud firebase first and get the auto-generated id
              UserItemService userItemService = UserItemService();
              User? currentUser = FirebaseAuth.instance.currentUser;

              if (currentUser == null) {
                throw Exception('You should Login first!');
              } else {
                var id =
                    await userItemService.addUserItem(currentUser.uid, food);

                if (id == null) {
                  logger.w('Failed to insert food into local database');
                } else {
                  logger.d(food);

                  food.id = id;

                  await insertDB(food);
                  await userItemService.updateUserItem(
                      currentUser.uid, food.id!, food);
                }
              }
              await getAllItems('foods');
            } on FormatException {
              logger.e('Format Error!');
            }

            nameController.clear();
            categoryController.clear();
            quanNumController.clear();
            quanTypeController.clear();
            expireTimeController.clear();
            quanNumAndTypeController.clear();

            setState(() {
              buildList();
            });
            Navigator.pop(context);
          },
          tooltip: 'Add item',
          label: const Text('Add item'),
          icon: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }));
  }

  // button list for expiring date (only button)
  OutlinedButton _buildButtonColumn1(int value) {
    return OutlinedButton.icon(
      onPressed: () {
        //record new expire time ----> value
        var later = timeNowDate.add(Duration(days: value));
        food.expiryDate = later.millisecondsSinceEpoch;
        int year = later.year;
        int month = later.month;
        int day = later.day;
        expireTimeController.text = "$year-$month-$day";
      },
      icon: const Icon(Icons.calendar_today),
      label: Text("+ $value days"),
    );
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
