import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tooGoodToWaste/dto/shared_item_model.dart';
import 'package:tooGoodToWaste/dto/user_model.dart';
import 'package:tooGoodToWaste/pages/post_page.dart';
import 'package:tooGoodToWaste/service/shared_items_service.dart';
import 'package:tooGoodToWaste/service/storage_service.dart';
import 'package:tooGoodToWaste/service/user_service.dart';
import 'package:tooGoodToWaste/util/geo_utils.dart';
import 'package:tooGoodToWaste/widgets/user_location_aware_widget.dart';

class FoodItem extends StatefulWidget {
  final SharedItem postData;
  final int remainDays;

  const FoodItem({super.key, required this.postData, required this.remainDays});

  @override
  State<StatefulWidget> createState() => _FoodItemState();
}

class _FoodItemState extends State<FoodItem> {
  final UserService userService = UserService();
  final StorageService storageService = StorageService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  final SharedItemService sharedItemService = SharedItemService();

  @override
  Widget build(BuildContext context) {
    bool isLiked = widget.postData.likedBy.contains(userId);
    final UserService userService = UserService();
    final StorageService storageService = StorageService();
// final String userId = FirebaseAuth.instance.currentUser!.uid;

    // bool isLiked = postData.likedBy.contains(userId);

    return FutureBuilder(
        future: userService.getUserData(widget.postData.user),
        builder:
            (BuildContext context, AsyncSnapshot<TGTWUser> userDataSnapshot) {
          if (userDataSnapshot.connectionState == ConnectionState.done &&
              userDataSnapshot.hasData) {
            TGTWUser postUser = userDataSnapshot.requireData;

            return Container(
              width: 170,
              height: 170,
              // color: Colors.red,
              margin: EdgeInsets.only(left: 5, right: 5, bottom: 5),
              child: Stack(
                children: <Widget>[
                  SizedBox(
                      width: 170,
                      height: 170,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          // remainDays > 1
                          //   ? Colors.white
                          //   : const Color.fromRGBO(238, 162, 164, 0.8), // Button color
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          // if (widget.context != null && mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PostPage(postData: widget.postData)));
                        },
                        child: Hero(
                          transitionOnUserGestures: true,
                          tag: widget.postData.name,
                          child: widget.postData.imageUrl != null
                              ? Container(
                                  height: 100,
                                  padding: const EdgeInsets.all(5.0),
                                  child: FutureBuilder(
                                    future:
                                        storageService.getImageUrlOfSharedItem(
                                            widget.postData.imageUrl!),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String>
                                            imageUrlSnapshot) {
                                      if (imageUrlSnapshot.connectionState ==
                                              ConnectionState.done &&
                                          imageUrlSnapshot.hasData) {
                                        return Image.network(
                                          imageUrlSnapshot.requireData,
                                          height: 100,
                                          width: 120,
                                        );
                                      } else {
                                        return const CircularProgressIndicator();
                                      }
                                    },
                                  ),
                                )
                              : const Text('No image provided'),
                        ),
                      )),
                  Positioned(
                      bottom: 0,
                      right: -10,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.all(5),
                          shape: CircleBorder(),
                        ),
                        onPressed: () async {
                          setState(() {
                            isLiked = !isLiked;
                          });
                          await sharedItemService.setLikedBy(
                              widget.postData.id!, userId);
                        },
                        child: Icon(
                          (isLiked) ? Icons.favorite : Icons.favorite_border,
                          color: (isLiked) ? Colors.black : Colors.grey,
                          size: 20,
                        ),
                      )),
                  Positioned(
                      bottom: 5,
                      left: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.postData.name,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(
                              'Amount: ${widget.postData.amount.nominal} ${widget.postData.amount.unit}',
                              style: const TextStyle(fontSize: 10)),
                        ],
                      )),
                  Positioned(
                      top: 5,
                      left: 5,
                      child: UserLocationAwareWidget(builder:
                          (BuildContext context, GeoPoint userLocation) {
                        return Container(
                          padding: EdgeInsets.only(
                              top: 5, left: 10, right: 10, bottom: 5),
                          decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(50)),
                          child: Text(
                              '${GeoUtils.calculateDistance(userLocation, widget.postData.location.geoPoint).toStringAsFixed(2)}  m',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        );
                      })),
                  Positioned(
                      top: 0,
                      right: 10,
                      child: (postUser.rating != 0.0)
                          ? Container(
                              padding: EdgeInsets.only(
                                  top: 2, left: 10, right: 2, bottom: 5),
                              child: Row(children: <Widget>[
                                const Icon(Icons.grade,
                                    color: Color.fromRGBO(9, 162, 109, 1)),
                                Text(' ${postUser.rating.toStringAsFixed(1)}',
                                    style: TextStyle(
                                        color: Color.fromRGBO(9, 162, 109, 1),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15)),
                              ]))
                          : SizedBox(width: 0))
                ],
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}

class LikedItem extends StatefulWidget {
  final SharedItem postData;
  final int remainDays;

  const LikedItem(
      {super.key, required this.postData, required this.remainDays});

  @override
  State<StatefulWidget> createState() => _LikedItemState();
}

class _LikedItemState extends State<LikedItem> {
  final UserService userService = UserService();
  final StorageService storageService = StorageService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  final SharedItemService sharedItemService = SharedItemService();

  @override
  Widget build(BuildContext context) {
    bool isLiked = widget.postData.likedBy.contains(userId);

    return FutureBuilder(
        future: userService.getUserData(widget.postData.user),
        builder:
            (BuildContext context, AsyncSnapshot<TGTWUser> userDataSnapshot) {
          if (userDataSnapshot.connectionState == ConnectionState.done &&
              userDataSnapshot.hasData) {
            TGTWUser postUser = userDataSnapshot.requireData;

            return Container(
              width: 350,
              height: 170,
              // color: Colors.red,
              margin: EdgeInsets.only(left: 5, right: 5, bottom: 15),
              child: Stack(
                children: <Widget>[
                  SizedBox(
                      width: 360,
                      height: 170,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          // remainDays > 1
                          //   ? Colors.white
                          //   : const Color.fromRGBO(238, 162, 164, 0.8), // Button color
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        onPressed: () {
                          // if (widget.context != null && mounted) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PostPage(postData: widget.postData)));
                        },
                        child: Hero(
                          transitionOnUserGestures: true,
                          tag: widget.postData.name,
                          child: widget.postData.imageUrl != null
                              ? Container(
                                  height: 100,
                                  padding: const EdgeInsets.all(5.0),
                                  child: FutureBuilder(
                                    future:
                                        storageService.getImageUrlOfSharedItem(
                                            widget.postData.imageUrl!),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String>
                                            imageUrlSnapshot) {
                                      if (imageUrlSnapshot.connectionState ==
                                              ConnectionState.done &&
                                          imageUrlSnapshot.hasData) {
                                        return Image.network(
                                          imageUrlSnapshot.requireData,
                                          height: 100,
                                          width: 120,
                                        );
                                      } else {
                                        return const CircularProgressIndicator();
                                      }
                                    },
                                  ),
                                )
                              : const Text('No image provided'),
                        ),
                      )),
                  Positioned(
                      bottom: 0,
                      right: -10,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.all(5),
                          shape: CircleBorder(),
                        ),
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                          });
                          sharedItemService.setLikedBy(
                              widget.postData.id!, userId);
                        },
                        child: Icon(
                          (isLiked) ? Icons.favorite : Icons.favorite_border,
                          color: (isLiked) ? Colors.black : Colors.grey,
                          size: 20,
                        ),
                      )),
                  Positioned(
                      bottom: 5,
                      left: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(widget.postData.name,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(
                              'Amount: ${widget.postData.amount.nominal} ${widget.postData.amount.unit}',
                              style: const TextStyle(fontSize: 10)),
                        ],
                      )),
                  Positioned(
                      top: 5,
                      left: 5,
                      child: UserLocationAwareWidget(builder:
                          (BuildContext context, GeoPoint userLocation) {
                        return Container(
                          padding: EdgeInsets.only(
                              top: 5, left: 10, right: 10, bottom: 5),
                          decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(50)),
                          child: Text(
                              '${GeoUtils.calculateDistance(userLocation, widget.postData.location.geoPoint).toStringAsFixed(2)} m',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13)),
                        );
                      })),
                  Positioned(
                      top: 0,
                      right: 10,
                      child: (postUser.rating != 0.0)
                          ? Container(
                              padding: EdgeInsets.only(
                                  top: 2, left: 10, right: 2, bottom: 5),
                              child: Row(children: <Widget>[
                                const Icon(Icons.grade,
                                    color: Color.fromRGBO(9, 162, 109, 1)),
                                Text(' ${postUser.rating.toStringAsFixed(1)}',
                                    style: TextStyle(
                                        color: Color.fromRGBO(9, 162, 109, 1),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15)),
                              ]))
                          : SizedBox(width: 0))
                ],
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
