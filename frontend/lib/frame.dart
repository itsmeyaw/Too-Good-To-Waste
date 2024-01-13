import 'package:flutter/material.dart';
import 'package:tooGoodToWaste/Pages/home.dart';
import 'package:tooGoodToWaste/Pages/account.dart';
import 'package:tooGoodToWaste/pages/Inventory.dart';
import 'package:tooGoodToWaste/helper/DBHelper.dart';
import 'dart:async';


class Frame extends StatefulWidget {
  const Frame({super.key});

  @override
  State<StatefulWidget> createState() => _FrameState();
}

class _FrameState extends State<Frame> {
  bool b = false;

  // Create Database Object
  DBHelper dbHelper = DBHelper();
  DateTime timeNowDate = DateTime.now();
  int timeNow = DateTime.now().millisecondsSinceEpoch;
  // Navigation Bar related
  AnimationController? animationController;
  

  String imagePath(String category) {
    String imagePath = "assets/category/$category.png";
    return imagePath;
  }

  Map<String, String> GlobalCateIconMap = {
    "seafood": "assets/category/seafood.png",
    "Meat": "assets/category/meat.png",
    "Milk": "assets/category/milk.png",
    "Milk Product": "assets/category/cheese.png",
    "Fruit": "assets/category/fruits.png",
    "Egg": "assets/category/egg.png",
    "Vegetable": "assets/category/vegetable.png",
    "Others": "assets/category/others.png"
  };

   //when to call this function? At a certain time evey day.
  Future<void> autocheckWaste() async{
    //get every instance out of Foods table and compare its expiretime with current time
    //int maxID = await dbhelper.getMaxId();
    var foods = await dbHelper.queryAllGoodFood('good');
    //var foods = await dbhelper.queryAllUnconsumedFood();
    print('######################$foods#################');

    for(int i = 0; i < foods.length ; i++ ){
      //var expiretime = await dbhelper.getAllGoodFoodIntValues('expiretime', 'good');
      var expiretime = foods[i].expiretime;
      var foodName = foods[i].name;
      var foodState = foods[i].state;
      if(expiretime < timeNow){
        if(foodState == 'good' || foodState == 'expiring') {
          await dbHelper.updateFoodWaste(foodName);
        }
        //update uservalue negative

        String category = await dbHelper.getOneFoodValue(foodName, 'category');
        showExpiredDialog(foodName, category);
        print('###########################$foodName is wasted###########################');
      }
    }
     for(int i = 0; i < foods.length ; i++ ){
      var expiretime = foods[i].expiretime;
      var foodName = foods[i].name;
      var foodState = foods[i].state;
      int remainDays = DateTime.fromMillisecondsSinceEpoch(expiretime).difference(timeNowDate).inDays;
      print('#######################$remainDays#######################');
      // ignore: unrelated_type_equality_checks
      if(remainDays < 2 && foodState == 'good' && remainDays > 0){
        //pop up a toast
        await dbHelper.updateFoodExpiring(foodName);
        String category = await dbHelper.getOneFoodValue(foodName, 'category');
        showExpiringDialog(foodName, category);
        print('###########################$foodName is expiring!!!###########################');
      }
    }
  }

  //toast contains 'Alert! Your ***  will expire in two days'
  showExpiredDialog(String foodname, String category){
    String? categoryIconImagePath;
    var progressColor;
    if(GlobalCateIconMap[category] == null) {
      categoryIconImagePath = GlobalCateIconMap["Others"];
    } else {
      categoryIconImagePath = GlobalCateIconMap[category];
    }
    double width= MediaQuery.of(context).size.width;
    double height= MediaQuery.of(context).size.height;
    AlertDialog dialog = AlertDialog(
      title: const Text("Alert!",textAlign: TextAlign.center),
      content:
      Container(
        width: 3*width/5,
        height: height/3,
        padding: const EdgeInsets.all(10.0),
        child:
          Column(
            children: [
              Image.asset(categoryIconImagePath!),
              //Expanded(child: stateIndex>-1? Image.asset(imageList[stateIndex]):Image.asset(imageList[12])),
              Text(
                  'Your $foodname is already expired!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context,'OK'),
          child: const Text('OK'),
        ),
      ],
    );
    showDialog(context: context, builder: (BuildContext context){
      return dialog;
    });
  }

  //toast contains 'Alert! Your ***  will expire in two days'
  showExpiringDialog(String foodname, String category){
    String? categoryIconImagePath;
    var progressColor;
    if(GlobalCateIconMap[category] == null) {
      categoryIconImagePath = GlobalCateIconMap["Others"];
    } else {
      categoryIconImagePath = GlobalCateIconMap[category];
    }
    double width= MediaQuery.of(context).size.width;
    double height= MediaQuery.of(context).size.height;
    AlertDialog dialog = AlertDialog(
      title: const Text("Alert!",textAlign: TextAlign.center),
      content:
      Container(
        width: 3*width/5,
        height: height/3,
        padding: const EdgeInsets.all(10.0),
        child:
          Column(
            children: [
              Image.asset(categoryIconImagePath!),
              //Expanded(child: stateIndex>-1? Image.asset(imageList[stateIndex]):Image.asset(imageList[12])),
              Text(
                  'Your $foodname will expire in two days!',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold))
            ],
          ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context,'OK'),
          child: const Text('OK'),
        ),
      ],
    );
    showDialog(context: context, builder: (BuildContext context){
      return dialog;
    });
  }

  
  Future<void> insertItem() async {
    //Insert a new Food butter
    var butter = Food(
        name: 'butter',
        category: 'Milk Product',
        boughttime: timeNow,
        expiretime: 1649969762604,
        quantitytype: 'piece',
        quantitynum: 3,
        consumestate: 0.50,
        state: 'good');
    await dbHelper.insertFood(butter);
    var egg = Food(
        name: 'eggs',
        category: 'Egg',
        boughttime: timeNow,
        expiretime: 1697969762604,
        quantitytype: 'num',
        quantitynum: 4,
        consumestate: 0,
        state: 'good');
    await dbHelper.insertFood(egg);

    //Insert a new UserValue instance
    var user1 = UserValue(name: "user1",
        negative: 0,
        positive: 0,
        primarystate: "initialization",
        secondarystate: "false",
        secondaryevent: "single",
        thirdstate: "move",
        species: "folca",
        childrennum: 0,
        fatherstate: "single",
        motherstate: "single",
        time: timeNow);
    await dbHelper.insertUser(user1);
    print(await dbHelper.queryAll("users"));

    //await dbhelper.testDB();
  }

  //bottom navigation

  int currentPage = 1;
 
  GlobalKey bottomNavigationKey = GlobalKey();
  _getPage(int page) {
    switch (page) {
      case 0:       
        return const Home();
      case 1:
        return const Inventory();
      default:
      return const AccountPage();
    }
  }

@override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text('Too Good To Waste'),
        actions: const [],
      ),
    body: Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(color: Colors.white),
      child: _getPage(currentPage),
    ),
    bottomNavigationBar: NavigationBar(
      onDestinationSelected: (int index) {
          setState(() {
            currentPage = index;
          });
        },
        selectedIndex: currentPage,
        destinations: const <Widget>[
          NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home'
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.inventory_2),
              icon: Icon(Icons.inventory_2_outlined),
              label: 'Inventory'
          ),
          NavigationDestination(
              selectedIcon: Icon(Icons.person),
              icon: Icon(Icons.person_outline),
              label: 'Account'
          )
        ]
      )
  );
}
}
