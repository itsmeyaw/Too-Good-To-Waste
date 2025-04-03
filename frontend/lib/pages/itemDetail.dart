import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:tooGoodToWaste/const/gradient_const.dart';
import 'package:tooGoodToWaste/const/size_const.dart';
import 'package:tooGoodToWaste/dto/item_category_enum.dart';
import 'package:tooGoodToWaste/dto/shared_item_model.dart';
import 'package:tooGoodToWaste/dto/user_item_detail_model.dart';
import 'package:tooGoodToWaste/dto/user_item_model.dart';
import 'package:tooGoodToWaste/dto/user_model.dart' as dto_user;
import 'package:tooGoodToWaste/dto/category_icon_map.dart';
import 'package:tooGoodToWaste/service/shared_items_service.dart';
import 'package:tooGoodToWaste/service/storage_service.dart';
import 'package:tooGoodToWaste/service/user_location_service.dart';
import 'package:tooGoodToWaste/widgets/category_picker.dart';
import 'package:tooGoodToWaste/widgets/signup_arrow_button.dart';
import 'package:tooGoodToWaste/widgets/user_location_aware_widget.dart';
import 'package:tooGoodToWaste/service/db_helper.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tooGoodToWaste/service/user_item_service.dart';
import '../dto/user_item_amount_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tooGoodToWaste/widgets/appbar.dart';

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
    final _media = MediaQuery.of(context).size;

    String categoryIconImagePath;

    if (GlobalCateIconMap[widget.foodDetail.category] == null) {
      categoryIconImagePath = GlobalCateIconMap["Others"]!;
    } else {
      categoryIconImagePath = GlobalCateIconMap[widget.foodDetail.category]!;
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
          });
    }

    Future<void> uploadImgToFirebase(XFile image) async {
      if (image == null) logger.e('Image is null');

      List<int> pickedImageData = await image.readAsBytes();
      Reference ref =
          FirebaseStorage.instance.ref().child('images').child('image.jpg');
      // While the file names are the same, the references point to different files
      // assert(ref.name == ref.name);
      // assert(ref.fullPath != ref.fullPath);

      Uint8List bytes = Uint8List.fromList(pickedImageData);
      UploadTask uploadTask = ref.putData(bytes);

      // Listen for state changes, errors, and completion of the upload.
      uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
        switch (taskSnapshot.state) {
          case TaskState.running:
            final progress = 100.0 *
                (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
            logger.f("Upload is $progress% complete.");
            break;
          case TaskState.paused:
            logger.f("Upload is paused.");
            break;
          case TaskState.canceled:
            logger.f("Upload was canceled");
            break;
          case TaskState.error:
            // Handle unsuccessful uploads
            logger.e('Upload failed');
            break;
          case TaskState.success:
            // Handle successful uploads on complete
            logger.d('Upload complete');
            break;
        }
      });

      uploadTask.whenComplete(() async {
        String url = await ref.getDownloadURL();
        logger.d('imgDownloadUrl $url');
        setState(() {
          //imgDownloadUrl = url;
        });
      });
    }

    showLocationDialog() {
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
                height: 420,
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
            builder: (BuildContext context, GeoPoint userLocation) =>
                _DialogContent(
              foodDetail: widget.foodDetail,
              userLocation: userLocation,
            ),
          ));
      showDialog(
          context: context,
          builder: (BuildContext context) {
            // dialogContext = context;
            return dialog;
          });
    }

    return Scaffold(
      appBar: SignupApbar(
          //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: 'Item Detail Page'),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Stack(
          children: <Widget>[
            Container(
              height: _media.height,
              width: _media.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/detail_page.png',
                  ),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Expanded(
              child: DetailsList(
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
            if (widget.foodDetail.state == 'good') {
              showLocationDialog();
              // Navigator.pop(context);
            } else {
              showExpiredDialog(
                  widget.foodDetail.name, widget.foodDetail.category);
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

class _DialogContent extends StatefulWidget {
  // const _DialogContent({Key? key}) : super(key: key);
  final UserItemDetail foodDetail;
  final GeoPoint userLocation;

  const _DialogContent(
      {super.key, required this.foodDetail, required this.userLocation});

  @override
  __DialogContentState createState() => __DialogContentState();
}

class __DialogContentState extends State<_DialogContent> {
  File? imageFile;
  String localPath = '';
  String imagePath = '';
  final StorageService storageService = StorageService();
  TextEditingController locationController = TextEditingController();
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

  Future<void> pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedImage != null) {
        imageFile = File(pickedImage.path);
        localPath = pickedImage.path;
        logger.d('Image path: ${imageFile!.path}');
      } else {
        logger.d('Image is null');
      }
    });
  }

  Future<void> uploadImage(String localPath) async {
    imagePath = await storageService.uploadImage(localPath);
    // imgDownloadUrl = await storageService.getImageUrlOfSharedItem(imagePath);
    logger.d('imagePath $imagePath');
    setState(() {
      imagePath = imagePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    DBHelper dbhelper = DBHelper();

    return SizedBox(
        height: 420,
        child: Column(children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(10.0),
            child: Text('Are you sure to share this item?',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Container(
            height: 250,
            padding: const EdgeInsets.all(10.0),
            child:
                // Image.asset('assets/mock/milk.JPG'),
                imageFile == null
                    ? Image.asset('assets/images/uploadImg.jpeg')
                    : Image.file(imageFile!),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          //Extract Location information
                          await pickImage();
                        },
                        // child: const Icon(Icons.camera_alt),
                        child: const Text('Take Photo'),
                      ),
                      const SizedBox(width: 7),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            localPath = '';
                            imageFile = null;
                          });
                        },
                        // child: const Icon(Icons.camera_alt),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      //Extract Location information
                      locationController.value.text;

                      //Extract Location information
                      if (localPath != '') {
                        await uploadImage(localPath);

                        // await uploadImgToFirebase(image!);
                      } else {
                        logger.e('Please choose an image first!');
                      }

                      SharedItemService sharedItemService = SharedItemService();

                      User? currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser == null) {
                        throw Exception(
                            'User is null but want to publish item');
                      } else {
                        getUserFromDatabase(currentUser.uid)
                            .then((dto_user.TGTWUser userData) {
                          SharedItem sharedItem = SharedItem(
                            name: widget.foodDetail.name,
                            category:
                                ItemCategory.parse(widget.foodDetail.category),
                            amount: UserItemAmount(
                                nominal: widget.foodDetail.quantitynum,
                                unit: widget.foodDetail.quantitytype),
                            buyDate: widget.foodDetail.remainDays,
                            expireDate: widget.foodDetail.remainDays,
                            user: currentUser.uid,
                            isAvailable: true,
                            likedBy: [],
                            imageUrl: imagePath,
                          );
                          sharedItemService.postSharedItem(
                              widget.userLocation, sharedItem);
                        });
                      }

                      UserItemService userItemService = UserItemService();

                      await userItemService.deleteUserItem(
                          currentUser.uid, widget.foodDetail.id);

                      await dbhelper.deleteFood(widget.foodDetail.id);

                      // Navigator.of(context, rootNavigator: true).pop();
                      // Navigator.pop(context);
                      setState(() {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/', ModalRoute.withName('/'));
                      });
                    },
                    child: const Text('Publish'),
                  )
                ],
              )),
        ]));
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
  const DetailsList(
      {super.key, required this.imagePth, required this.foodDetail});

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
    quantityTypeController =
        TextEditingController(text: widget.foodDetail.quantitytype);
    categoryController =
        TextEditingController(text: widget.foodDetail.category);
    remainDaysController =
        TextEditingController(text: widget.foodDetail.remainDays.toString());
    expireTimeController = TextEditingController(
        text:
            "${DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.expiryDate).year}-${DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.expiryDate).month}-${DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.expiryDate).day}");
    buyTimeController = TextEditingController(
        text:
            "${DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.buyDate).year}-${DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.buyDate).month}-${DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.buyDate).day}");
    quantityNumController =
        TextEditingController(text: widget.foodDetail.quantitynum.toString());
    quanNumAndTypeController = TextEditingController(
        text:
            "${widget.foodDetail.quantitynum} ${widget.foodDetail.quantitytype}");
  }

  Future<void> _showCategoryDialog() async {
    final ItemCategory? selectedCategory = await showDialog<ItemCategory>(
        context: context,
        builder: (context) => CategoryPicker(
            initialCategory: ItemCategory.parse(widget.foodDetail.category)));

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
        state: widget.foodDetail.state);

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

  final nums = List.generate(10, (index) => index);
  int quanNum = 0;
  int quanSmallNum = 0;
  var quanType = "";
  List<Widget> numList = List.generate(10, (index) => Text("$index"));
  final quanTypes = ["g", "kg", "piece", "bag", "bottle", "num"];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 30,
        ),
        SignUpArrowButton(
          height: 70,
          width: 70,
          icon: isEditMode ? Icons.done : Icons.edit,
          iconSize: 30,
          onTap: () {
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
        SizedBox(
          height: 30,
        ),
        Text(
          "Tap to edit the item detail",
          style: TextStyle(
            fontSize: 13,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.only(top: 20, bottom: 40),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  QuantityColorBox(SIGNUP_BACKGROUND, "STORAGE DETAILS"),
                  CategoryColorBox(SIGNUP_BACKGROUND, "CATEGORY"),
                  BuyDateColorBox(SIGNUP_BACKGROUND, "BUY DATE"),
                  ExpiryDateColorBox(SIGNUP_BACKGROUND, "EXPIRES IN"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget QuantityColorBox(Gradient gradient, String title) {
    List<Widget> quanTypeList =
        List<Widget>.generate(6, (index) => Text(quanTypes[index]));

    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10,
        bottom: 8,
      ),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 30,
              offset: Offset(1.0, 9.0),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 30,
            ),
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: TextStyle(fontSize: TEXT_SMALL_SIZE, color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 5,
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Quantity',
                ),
                enabled: isEditMode,
                controller: quanNumAndTypeController,
                style: const TextStyle(
                  fontSize: TEXT_NORMAL_SIZE,
                  color: Colors.black,
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
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget CategoryColorBox(Gradient gradient, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10,
        bottom: 8,
      ),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 30,
            ),
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: TextStyle(fontSize: TEXT_SMALL_SIZE, color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 5,
              child: Wrap(
                children: <Widget>[
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Category',
                    ),
                    enabled: isEditMode,
                    controller: categoryController,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      _showCategoryDialog();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget BuyDateColorBox(Gradient gradient, String title) {
    DateTime selectedBuyDate =
        DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.buyDate);

    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10,
        bottom: 8,
      ),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 30,
            ),
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: TextStyle(fontSize: TEXT_SMALL_SIZE, color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 5,
              child: TextField(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Purchase Date',
                ),
                enabled: isEditMode,
                controller: buyTimeController,
                style: const TextStyle(
                  fontSize: TEXT_NORMAL_SIZE,
                  color: Colors.black,
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
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget ExpiryDateColorBox(Gradient gradient, String title) {
    DateTime selectedExpiryDate =
        DateTime.fromMillisecondsSinceEpoch(widget.foodDetail.expiryDate);

    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10,
        bottom: 8,
      ),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 30,
            ),
            Expanded(
              flex: 3,
              child: Text(
                title,
                style: TextStyle(fontSize: TEXT_SMALL_SIZE, color: Colors.grey),
              ),
            ),
            Expanded(
              flex: 5,
              child: Wrap(
                children: <Widget>[
                  TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Expiry Date',
                      ),
                      enabled: isEditMode,
                      controller: expireTimeController,
                      style: const TextStyle(
                        fontSize: TEXT_NORMAL_SIZE,
                        color: Colors.black,
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
                                                int year =
                                                    selectedExpiryDate.year;
                                                int month =
                                                    selectedExpiryDate.month;
                                                int day =
                                                    selectedExpiryDate.day;
                                                int timestamp =
                                                    selectedExpiryDate
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
                      }),
                ],
              ),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }
}
