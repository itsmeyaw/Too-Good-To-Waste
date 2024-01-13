import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:tooGoodToWaste/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:tooGoodToWaste/frame.dart';
import 'package:tooGoodToWaste/helper/DBHelper.dart';
import 'package:tooGoodToWaste/pages/Account.dart';
import 'package:tooGoodToWaste/pages/AddInventory.dart';
import 'package:tooGoodToWaste/pages/Home.dart';
import 'package:tooGoodToWaste/pages/Inventory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
  const oneDay = Duration(minutes: 1);
  MyApp myapp = MyApp();

    Timer.periodic(oneDay, (Timer timer) {
        //myapp.autocheckWaste();
        //pop up  a propmt
        print("Repeat task every day");  // This statement will be printed after every one second
    }); 
}

class MyApp extends StatelessWidget {
  late BuildContext context;
  DBHelper dbhelper = DBHelper();
  DateTime timeNowDate = DateTime.now();
  int timeNow = DateTime.now().millisecondsSinceEpoch;

  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return MaterialApp(
      title: 'Too Good To Waste',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const Frame(),
    );
  }
  
  Future<void> autocheckWaste() async{
    //get every instance out of Foods table and compare its expiretime with current time
    //int maxID = await dbhelper.getMaxId();
    var foods = await dbhelper.queryAllUnconsumedFood();

    for(int i = 0; i < foods.length ; i++ ){
      var expiretime = await dbhelper.getAllUncosumedFoodIntValues('expiretime');
      var foodName = await dbhelper.getAllUncosumedFoodStringValues('name');
      if(expiretime[i] < timeNow){
        dbhelper.updateFoodWaste(foodName[i]);
        print('###########################${foodName[i]} is wasted###########################');
      }
    }
     for(int i = 0; i < foods.length ; i++ ){
      var expiretime = await dbhelper.getAllUncosumedFoodIntValues('expiretime');
      var foodName = await dbhelper.getAllUncosumedFoodStringValues('name');
      int remainDays = DateTime.fromMillisecondsSinceEpoch(expiretime[i]).difference(timeNowDate).inDays;
      if(remainDays < 2){
        //pop up a toast
        dbhelper.updateFoodConsumed(foodName[i], 'expiring');
        showExpiringDialog(foodName[i]);
        print('###########################${foodName[i]} is expiring!!!###########################');
      }
    }
  }

  showExpiringDialog(String foodname){
    //double width= MediaQuery.of(context).size.width;
    //double height= MediaQuery.of(context).size.height;
    AlertDialog dialog = AlertDialog(
      title: const Text("Alert!",textAlign: TextAlign.center),
      content:
      Container(
        width: 50,
        height: 10,
        padding: const EdgeInsets.all(10.0),
        child:
        Column(
          children: [
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

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

}
