import 'package:flutter/material.dart';
import 'package:mime/mime.dart';
import 'package:tooGoodToWaste/Pages/home.dart';
import 'package:tooGoodToWaste/Pages/account.dart';
import 'package:tooGoodToWaste/pages/inventory.dart';
import 'package:tooGoodToWaste/service/db_helper.dart';
import 'dart:async';
import 'package:tooGoodToWaste/dto/category_icon_map.dart';
import 'package:logger/logger.dart';

class Frame extends StatefulWidget {
  const Frame({super.key});

  @override
  State<StatefulWidget> createState() => _FrameState();
}

class _FrameState extends State<Frame> {
  bool b = false;
  final Logger logger = Logger();

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

  //when to call this function? At a certain time evey day.
  Future<void> autocheckWaste() async {
    //get every instance out of Foods table and compare its expiretime with current time
    //int maxID = await dbhelper.getMaxId();
    var foods = await dbHelper.queryAllGoodFood('good');
    //var foods = await dbhelper.queryAllUnconsumedFood();

    for (int i = 0; i < foods.length; i++) {
      //var expiretime = await dbhelper.getAllGoodFoodIntValues('expiretime', 'good');
      var expiretime = foods[i].expiryDate;
      var foodName = foods[i].name;
      var foodState = foods[i].state;
      var foodID = foods[i].id;
      if (expiretime < timeNow) {
        if (foodID == null) {
          throw Exception('Failed to fetch this expired food id from local database');
        } else {
          if (foodState == 'good' || foodState == 'expiring') {
            await dbHelper.updateFoodWaste(foodID);
          }
          String category = await dbHelper.getOneFoodValue(foodID, 'category');
          showExpiredDialog(foodName, category);
        }
   
        logger.e('###########################$foodName is wasted###########################');
      }
    }
    for (int i = 0; i < foods.length; i++) {
      var expiretime = foods[i].expiryDate;
      var foodName = foods[i].name;
      var foodState = foods[i].state;
      var foodID = foods[i].id;
      int remainDays = DateTime.fromMillisecondsSinceEpoch(expiretime)
          .difference(timeNowDate)
          .inDays;
    
      if (remainDays < 2 && foodState == 'good' && remainDays > 0) {
        //pop up a toast
        if (foodID == null) {
          throw Exception('Failed to fetch this expiring food id from local database');
        } else {
          await dbHelper.updateFoodExpiring(foodID);
          String category = await dbHelper.getOneFoodValue(foodID, 'category');
          showExpiringDialog(foodName, category);
        }
        logger.e(
            '###########################$foodName is expiring!!!###########################');
      }
    }
  }

  //toast contains 'Alert! Your ***  will expire in two days'
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
        height: height / 2,
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Image.asset(categoryIconImagePath!),
            //Expanded(child: stateIndex>-1? Image.asset(imageList[stateIndex]):Image.asset(imageList[12])),
            Text('Your $foodname is already expired!',
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
        });
  }

  //toast contains 'Alert! Your ***  will expire in two days'
  showExpiringDialog(String foodname, String category) {
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
        height: height / 2,
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Image.asset(categoryIconImagePath!),
            //Expanded(child: stateIndex>-1? Image.asset(imageList[stateIndex]):Image.asset(imageList[12])),
            Text('Your $foodname will expire in one day!',
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
        });
  }
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
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Too Good To Waste'),
          actions: const [],
        ),
        body: Container(
          child: _getPage(currentPage),
        ),
        bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPage = index;
                const oneDay = Duration(minutes: 1);
                //insertItem();
                Timer.periodic(oneDay, (Timer timer) {
                  autocheckWaste();
                  //pop up  a propmt
                  logger.d("Repeat task every day");  // This statement will be printed after every one second
                }); 
              });
            },
            selectedIndex: currentPage,
            destinations: const <Widget>[
              NavigationDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: 'Home'),
              NavigationDestination(
                  selectedIcon: Icon(Icons.inventory_2),
                  icon: Icon(Icons.inventory_2_outlined),
                  label: 'Inventory'),
              NavigationDestination(
                  selectedIcon: Icon(Icons.person),
                  icon: Icon(Icons.person_outline),
                  label: 'Account')
            ]));
  }
}
