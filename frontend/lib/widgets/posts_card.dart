import 'package:flutter/material.dart';
import 'package:tooGoodToWaste/dto/shared_item_model.dart';
import 'package:tooGoodToWaste/dto/user_model.dart';
import 'package:tooGoodToWaste/pages/post_page.dart';
import 'package:tooGoodToWaste/service/storage_service.dart';
import 'package:tooGoodToWaste/service/user_service.dart';

Widget foodItem(SharedItem postData, remainDays, {onTapped, onLike}) {
    final UserService userService = UserService();
    final StorageService storageService = StorageService();
    
  return FutureBuilder(
          future: userService.getUserData(postData.user),
          builder:
              (BuildContext context, AsyncSnapshot<TGTWUser> userDataSnapshot) {
          if (userDataSnapshot.connectionState == ConnectionState.done &&
                        userDataSnapshot.hasData) {
                      TGTWUser postUser = userDataSnapshot.requireData;

  return            
  Container(
    width: 170,
    height: 170,
    // color: Colors.red,
    margin: EdgeInsets.only(left: 10),
    child: Stack(
      children: <Widget>[
        SizedBox(
            width: 170,
            height: 170,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: remainDays > 1
                  ? Colors.white
                  : const Color.fromRGBO(238, 162, 164, 0.8), // Button color
                elevation: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: onTapped,
              child: Hero(
                transitionOnUserGestures: true,
                tag: postData.name,
                child: 
                 postData.imageUrl != null ? 
                  Container(
                        height: 100,
                        padding: const EdgeInsets.all(0.0),
                        child: FutureBuilder(
                          future: storageService
                              .getImageUrlOfSharedItem(
                                  postData.imageUrl!),
                          builder: (BuildContext context,
                              AsyncSnapshot<String>
                                  imageUrlSnapshot) {
                            if (imageUrlSnapshot.connectionState ==
                                    ConnectionState.done &&
                                imageUrlSnapshot.hasData) {
                              return Image.network(
                                imageUrlSnapshot.requireData,
                                height: 100,
                                width: 100,
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        ),
                  )
                : const Text('No image provided'),
                ),
            )
        ),
        Positioned(
            bottom: 10,
            right: 0,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.all(20),
                shape: CircleBorder(),
              ),
              onPressed: onLike,
              child: Icon(
                (postData.isAvailable) ? Icons.favorite : Icons.favorite_border,
                color: (postData.isAvailable) ? Colors.black : Colors.grey,
                size: 25,
              ),
            )),
        Positioned(
          bottom: 20,
          left: 5,
          child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text( postData.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text( 'Amount: ${postData.amount.nominal} ${postData.amount.unit}',
                            style: const TextStyle(fontSize: 12)),
                  ],
                )
        ),
        Positioned(
            top: 10,
            left: 10,
            child: Container(
                    padding:
                        EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
                    decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(50)),
                    child: 
                       Text('${postData.distance.toStringAsFixed(2)} m',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                      
                  )
              ),
        Positioned(
            top: 10,
            right: 10,
            child: (postUser.rating != 0.0)
                ? Container(
                    padding:
                        EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.grade,
                                      color: Color.fromRGBO(9, 162, 109, 1)),
                       Text('Rating: ${postUser.rating.toStringAsFixed(1)}',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                      ]
                  ))
                : SizedBox(width: 0))
      ],
    ),
  );
  } else {
    return const CircularProgressIndicator();
  }
  }
);}