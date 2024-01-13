import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:rive/rive.dart';
import 'package:sg2024/Helper/DB_Helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, this.animationController}) : super(key: key);

  final AnimationController? animationController;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // camera related
  late String imagePath;
  late File imageFile;
  late String imageData;
  DateTime timeNowDate = DateTime.now();
  int timeNow = DateTime.now().millisecondsSinceEpoch;

  //Create Databse Object
  DBHelper dbhelper = DBHelper();

  
 

  //check the primary state of uservalue should be updated or not; if so, update to the latest
  Future<void> updatePrimaryState() async {
    var user1 = await dbhelper.queryAll('users');
    int value = user1[0].positive - user1[0].negative;
    String primaryState;

    if (value < 2) {
      primaryState = 'initialization';
      await dbhelper.updateUserPrimary(primaryState);
    }
    if (value <= 6) {
      //judge the primary state
      primaryState = 'encounter';
      await dbhelper.updateUserPrimary(primaryState);
    }
    if (value > 6 && value <= 14) {
      primaryState = 'mate';
      await dbhelper.updateUserPrimary(primaryState);
    }
    if (value > 14 && value <= 30) {
      primaryState = 'nest';
      await dbhelper.updateUserPrimary(primaryState);
    }
    if (value > 30 && value <= 46) {
      primaryState = 'hatch';
      await dbhelper.updateUserPrimary(primaryState);
    }
    if (value > 46 && value <= 78) {
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
    }
  }

  //edit the state to 'consumed' and consumestate to 1, and user positive data adds 1
  //the arugument should be 'positive'(which means positive + 1) or 'negative'(which means negative + 1)
  Future<void> updateUserValue() async {
    var user1 = await dbhelper.queryAll('users');
    //int value = user1[0]['positive'] - user1[0]['negative'];
    print('================= user =================');
    print(user1);

    //judge the primary state
    var uservalue = UserValue(
        name: user1[0].name,
        negative: user1[0].negative,
        positive: user1[0].positive + 2,
        primarystate: user1[0].primarystate,
        secondarystate: 'false',
        secondaryevent: "single",
        thirdstate: "move",
        species: "folca",
        childrennum: 0,
        fatherstate: "single",
        motherstate: "single",
        time: timeNow);
    await dbhelper.updateUser(uservalue);
    await updatePrimaryState();
    print(await dbhelper.queryAll("users"));
  }


  Future pickImage(bool isCamera) async {
    XFile? image;
    if (isCamera == true) {
      image = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      image = await ImagePicker().pickImage(source: ImageSource.gallery);
    }
    if (image == null) return;
    CroppedFile? croppedFile = await ImageCropper().cropImage(sourcePath: image.path,
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
          title: 'Cropper',),
          WebUiSettings(
            context: context),
        ],
      );
    if(croppedFile != null) {
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
      await insertDB(key, value);
      print('#####$key######$value############');
    });
    updateUserValue();
    print(response.body);
  }

  //NNNNNOOOOOOO NEED!!!!!
  Future<int> getMaxId() async {
    int maxId = await dbhelper.getMaxId();
    return maxId;
  }

  Future<void> insertDB(String name, int number) async {
    // var maxId = await dbhelper.getMaxId();
    //print('##########################MaxID = $maxId###############################');
    //maxId = maxId + 1;
    //timeNow -> DateTime, + 7 days, --> int timestamp
    var expireDate = timeNowDate.add(const Duration(days: 7)).millisecondsSinceEpoch;
    print('#########################$expireDate##################');
    var newFood = Food(
        name: name,
        category: 'Meat',
        boughttime: timeNow,
        expiretime: expireDate,
        quantitytype: 'bag',
        quantitynum: number,
        consumestate: 0.0,
        state: 'good');

    print(newFood);

    await dbhelper.insertFood(newFood);
    print(await dbhelper.queryAll('foods'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              FloatingActionButton(
                backgroundColor: const Color.fromRGBO(178,207, 135, 0.8),
                onPressed: () => pickImage(false),
                heroTag: null,
                child: const Icon(Icons.photo_album, color: Colors.white,),
              ),
              const SizedBox(
                height: 10,
              ),
              FloatingActionButton(
                backgroundColor: const Color.fromRGBO(178,207, 135, 0.8),
                onPressed: () => pickImage(true),
                heroTag: null,
                child: const Icon(Icons.camera_alt, color: Colors.white),
              )
        ]),
        body: Stack(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/tree.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                child: const RiveAnimation.asset(
                  'assets/anime/chid-breath.riv',
                ),
              ),
            ),
          ],
        ));
  }
}
