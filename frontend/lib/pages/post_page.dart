import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:rive/rive.dart';
import 'package:tooGoodToWaste/service/shared_items_service.dart';
import 'package:tooGoodToWaste/service/storage_service.dart';
import 'package:tooGoodToWaste/service/user_service.dart';
import '../dto/shared_item_model.dart';
import '../dto/user_model.dart';
import 'chatroom.dart';

class PostPage extends StatefulWidget {
  final SharedItem postData;

  const PostPage({
    super.key,
    required this.postData,
  });

  @override
  State<StatefulWidget> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final UserService userService = UserService();
  final StorageService storageService = StorageService();
  final SharedItemService sharedItemService = SharedItemService();
  final Logger logger = Logger();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Shared Item Information'),
          actions: const [],
        ),
        body: FutureBuilder(
          future: userService.getUserData(widget.postData.user),
          builder:
              (BuildContext context, AsyncSnapshot<TGTWUser> userDataSnapshot) {
            if (userDataSnapshot.connectionState == ConnectionState.done &&
                userDataSnapshot.hasData) {
              TGTWUser postUser = userDataSnapshot.requireData;

              return Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FractionallySizedBox(
                          widthFactor: 1.0,
                          child: SizedBox(
                              height: 160,
                              child: GoogleMap(
                                onMapCreated: (event) {},
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                      widget.postData.location.latitude,
                                      widget.postData.location.longitude),
                                  zoom: 15.0,
                                ),
                                circles: <Circle>{
                                  Circle(
                                      circleId: CircleId(widget.postData.id!),
                                      center: LatLng(
                                          widget.postData.location.latitude,
                                          widget.postData.location.longitude),
                                      fillColor: const Color.fromRGBO(
                                          79, 195, 247, 0.5),
                                      strokeWidth: 1,
                                      strokeColor:
                                          const Color.fromRGBO(79, 195, 247, 1),
                                      radius: 200)
                                },
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Text(
                          widget.postData.name,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        Text(
                            'Amount: ${widget.postData.amount.nominal} ${widget.postData.amount.unit}',
                            style: Theme.of(context).textTheme.headlineSmall),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shared by: ${postUser.name.first} ${postUser.name.last}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.grade,
                                      color: Theme.of(context).colorScheme.primary),
                                  Text(
                                    'User rating: ${postUser.rating.toStringAsFixed(1)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        widget.postData.imageUrl != null
                            ? Hero(
                        transitionOnUserGestures: true,
                        tag: widget.postData.name,
                        child:
                            Center(
                                child: Container(
                                    height: 250,
                                    padding: const EdgeInsets.all(0.0),
                                    child: FutureBuilder(
                                      future: storageService
                                          .getImageUrlOfSharedItem(
                                              widget.postData.imageUrl!),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<String>
                                              imageUrlSnapshot) {
                                        if (imageUrlSnapshot.connectionState ==
                                                ConnectionState.done &&
                                            imageUrlSnapshot.hasData) {
                                          return Image.network(
                                            imageUrlSnapshot.requireData,
                                            height: 250,
                                            width: 250,
                                          );
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                    )),
                              ))
                            : const Text('No image provided'),
                        const Spacer(),
                        Builder(builder: (BuildContext context) {
                          if (currentUser != null &&
                              currentUser!.uid != widget.postData.user) {
                            return
                             Column(
                              children: <Widget>[
                                FilledButton.tonal(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ChatroomPage(
                                                secondUserId:
                                                widget.postData.user,
                                                sharedItem: widget.postData,
                                              )));
                                    },
                                    child: FractionallySizedBox(
                                      widthFactor: 1,
                                      child: Text(
                                        'Chat with ${postUser.name.last}',
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Builder(builder: (BuildContext context) {
                                  if (widget.postData.isAvailable && widget.postData.sharedItemReservation == null) {
                                    return
                                      FilledButton(
                                          onPressed: () async {
                                            try {
                                              if (await sharedItemService.reserveItem(widget.postData.id!)) {
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Succesfully reserved item")));
                                              } else {
                                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Cannot reserved item")));
                                              }
                                            } catch (e) {
                                              logger.e("Error when trying to reserve item", error: e);
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("There was error while reserving item")));
                                            }
                                          },
                                          child: const FractionallySizedBox(
                                              widthFactor: 1,
                                              child: Text(
                                                'Reserve',
                                                textAlign: TextAlign.center,
                                              )
                                          )
                                      );
                                  } else if (widget.postData.sharedItemReservation != null && widget.postData.sharedItemReservation!.reserver == currentUser!.uid) {
                                    // The item is reserved by this user
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          IntrinsicWidth(
                                            child: SizedBox(
                                              child: FilledButton(
                                                  style: FilledButton.styleFrom(backgroundColor: Theme.of(context).buttonTheme.colorScheme!.error),
                                                  onPressed: () {},
                                                  child: const Text('Cancel')
                                                  )
                                            )
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              child: SizedBox(
                                                  child: FilledButton (
                                                      onPressed: () {},
                                                      child: const Text('Confirm Pick Up')
                                                  )
                                              )
                                          )
                                        ],
                                    );
                                  } else {
                                    return FilledButton(onPressed: null, child: const FractionallySizedBox(
                                      widthFactor: 1.0,
                                      child: Text('Item is already reserved'),
                                    ));
                                  }
                                })
                              ],

                             );
                          } else {
                            return const FilledButton(
                                onPressed: null,
                                child: FractionallySizedBox(
                                    widthFactor: 1,
                                    child: Text(
                                      'This is your shared item',
                                      textAlign: TextAlign.center,
                                    )));
                          }
                        }),
                      ]));
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      
      );
  }
}
