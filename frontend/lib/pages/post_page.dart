import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tooGoodToWaste/dto/chatroom_model.dart';
import 'package:tooGoodToWaste/service/user_location_service.dart';
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
  Uint8List? imageFile;

  Future<void> downloadImage(imageUrl) async {
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();

    // Create a reference from an HTTPS URL
    // Note that in the URL, characters are URL escaped!
    final httpsReference = FirebaseStorage.instance.refFromURL(
        imageUrl);

    try {
      const oneMegabyte = 1024 * 1024;
      final Uint8List? data = await httpsReference.getData(oneMegabyte);
      setState(() {
        imageFile = data;
      });
      // Data for "images/island.jpg" is returned, use this as needed.
    } on FirebaseException catch (error) {
      logger.e('Error while downloading image: $error');
      // Handle any errors.
    }
  }

  final StorageService storageService = StorageService();

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
                        Text(
                          'Shared by: ${postUser.name.first} ${postUser.name.last}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        widget.postData.imageUrl != null
                            ? Center(
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
                                        if (imageUrlSnapshot.hasData) {
                                          return Image.network(
                                            imageUrlSnapshot.requireData,
                                            height: 250,
                                          );
                                        } else {
                                          return const CircularProgressIndicator();
                                        }
                                      },
                                    )),
                              )
                            : const Text('No image provided'),
                        const Spacer(),
                        Builder(builder: (BuildContext context) {
                          if (currentUser != null &&
                              currentUser!.uid != widget.postData.user) {
                            return FilledButton(
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
                                    )));
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
        ));
  }
}
