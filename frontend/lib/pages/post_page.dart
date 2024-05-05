import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:rive/rive.dart';
import 'package:tooGoodToWaste/pages/home.dart';
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
  double userRating = 0;
  double range = 0;

  @override
  void initState() {
    super.initState();
    range = 1;
  }

  Future<void> showPaymentDialog(TGTWUser counterparty) async {
    final double? selectedPoints = await showDialog<double>(
        context: context,
        builder: (context) => PricePicker(
            initialRange: range,
            counterparty: counterparty,
            postData: widget.postData));

    if (selectedPoints != null) {
      try {
        if (await userService.updateUserPoints(
            counterparty, widget.postData.user, selectedPoints, true)) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Succesfully paid with $selectedPoints points to ${counterparty.name.first} ${counterparty.name.last} for ${widget.postData.name}"),
            duration: const Duration(seconds: 1),
          ));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Cannot pay with ${selectedPoints} points"),
            duration: const Duration(seconds: 1),
          ));
        }
      } catch (e) {
        logger.e("Error when trying to update user points", error: e);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("There was error while updating user points"),
          duration: const Duration(seconds: 1),
        ));
      }
      bool? confirm = await showConfirmDialog(context, widget.postData.id!);
      if (confirm != null && confirm) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<bool?> showConfirmDialog(
      BuildContext context, String sharedItemId) async {
    return showDialog<bool>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Rate and Confirm"),
            content: IntrinsicHeight(
              child: Column(
                children: [
                  const Text("Please rate your experience and confirm"),
                  const SizedBox(
                    height: 10,
                  ),
                  RatingBar.builder(
                    minRating: 1,
                    maxRating: 5,
                    allowHalfRating: true,
                    updateOnDrag: true,
                    itemBuilder: (BuildContext context, int index) {
                      return const Icon(
                        Icons.star,
                        color: Colors.amber,
                      );
                    },
                    onRatingUpdate: (double value) {
                      setState(() {
                        userRating = value;
                      });
                    },
                  )
                ],
              ),
            ),
            actions: [
              FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).buttonTheme.colorScheme!.error),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel')),
              FilledButton(
                  onPressed: () async {
                    if (userRating == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Please input your rating")));
                      return;
                    }

                    await userService.rateUser(
                        widget.postData.user, userRating, sharedItemId);

                    Navigator.of(context).pop(true);
                  },
                  child: const Text("Confirm"))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    String sharedItemId = widget.postData.id!;

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
                                    fillColor:
                                        const Color.fromRGBO(79, 195, 247, 0.5),
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
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Text(
                          'Amount: ${widget.postData.amount.nominal} ${widget.postData.amount.unit}',
                          style: Theme.of(context).textTheme.bodyMedium),
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
                        height: 5,
                      ),
                      widget.postData.imageUrl != null
                          ? Hero(
                              transitionOnUserGestures: true,
                              tag: widget.postData.name,
                              child: Center(
                                child: Container(
                                    height: 200,
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
                                            height: 200,
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
                      StreamBuilder(
                          stream:
                              sharedItemService.streamSharedItem(sharedItemId),
                          builder: (BuildContext context,
                              AsyncSnapshot<SharedItem?> sharedItemSnapshot) {
                            if (sharedItemSnapshot.hasData &&
                                sharedItemSnapshot.data != null) {
                              SharedItem sharedItem = sharedItemSnapshot.data!;
                              if (currentUser != null &&
                                  currentUser!.uid != sharedItem.user) {
                                return Column(
                                  children: <Widget>[
                                    FilledButton.tonal(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatroomPage(
                                                        secondUserId:
                                                            sharedItem.user,
                                                        sharedItem: sharedItem,
                                                      )));
                                        },
                                        child: FractionallySizedBox(
                                          widthFactor: 1,
                                          child: Text(
                                            'Chat with ${postUser.name.last}',
                                            textAlign: TextAlign.center,
                                          ),
                                        )),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Builder(builder: (BuildContext context) {
                                      if (sharedItem.isAvailable &&
                                          sharedItem.sharedItemReservation ==
                                              null) {
                                        return FilledButton(
                                            onPressed: () async {
                                              try {
                                                if (await sharedItemService
                                                    .reserveItem(
                                                        sharedItemId)) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              "Succesfully reserved item")));
                                                } else {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(SnackBar(
                                                          content: Text(
                                                              "Cannot reserved item")));
                                                }
                                              } catch (e) {
                                                logger.e(
                                                    "Error when trying to reserve item",
                                                    error: e);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            "There was error while reserving item")));
                                              }
                                            },
                                            child: const FractionallySizedBox(
                                                widthFactor: 1,
                                                child: Text(
                                                  'Reserve',
                                                  textAlign: TextAlign.center,
                                                )));
                                      } else if (sharedItem
                                                  .sharedItemReservation !=
                                              null &&
                                          sharedItem.sharedItemReservation!
                                                  .reserver ==
                                              currentUser!.uid) {
                                        // The item is reserved by this user
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            IntrinsicWidth(
                                                child: SizedBox(
                                                    child: FilledButton(
                                                        style: FilledButton.styleFrom(
                                                            backgroundColor:
                                                                Theme.of(
                                                                        context)
                                                                    .buttonTheme
                                                                    .colorScheme!
                                                                    .error),
                                                        onPressed: () async {
                                                          if (await sharedItemService
                                                              .cancelReserveItem(
                                                                  sharedItemId)) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                                        content:
                                                                            Text("Succesfully cancelled reservation")));
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    SnackBar(
                                                                        content:
                                                                            Text("Cannot cancel reservation")));
                                                          }
                                                        },
                                                        child: const Text(
                                                            'Cancel')))),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                                child: SizedBox(
                                                    child: FilledButton(
                                                        onPressed: () async {
                                                          await showPaymentDialog(
                                                              postUser);

                                                          // if (payment != null &&
                                                          //     payment) {
                                                          //   Navigator.of(context).pop();
                                                          // }
                                                        },
                                                        child: const Text(
                                                            'Confirm Pick Up'))))
                                          ],
                                        );
                                      } else {
                                        return FilledButton(
                                            onPressed: null,
                                            child: const FractionallySizedBox(
                                              widthFactor: 1.0,
                                              child: Text(
                                                  'Item is already reserved'),
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
                            }
                            return const CircularProgressIndicator();
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

//A seperate class for the PricePicker widget, because Slider() requires a seperate StatefulWidget
class PricePicker extends StatefulWidget {
  final double initialRange;
  final TGTWUser counterparty;
  final SharedItem postData;

  const PricePicker(
      {super.key,
      required this.initialRange,
      required this.counterparty,
      required this.postData});

  @override
  State<StatefulWidget> createState() => _PricePickerState();
}

class _PricePickerState extends State<PricePicker> {
  final UserService userService = UserService();
  final StorageService storageService = StorageService();
  final SharedItemService sharedItemService = SharedItemService();
  final Logger logger = Logger();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  double userRating = 0;
  double range = 0;

  @override
  void initState() {
    super.initState();
    range = widget.initialRange;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pay With Points"),
      content: IntrinsicHeight(
        child: Column(
          children: [
            Text(
                "Please reach an agreement with the Giver and confirm this payment with the below points:"),
            const SizedBox(
              height: 10,
            ),
            Slider(
              value: range,
              max: 10,
              min: 1,
              divisions: 5,
              label: range.round().toString(),
              onChanged: (double newValue) {
                logger.d('Slided value to $newValue');
                setState(() {
                  range = newValue.roundToDouble();
                });
              },
            ),
            Text(
              "You will pay ${range} points to ${widget.counterparty.name.first} ${widget.counterparty.name.last} for ${widget.postData.name}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor:
                    Theme.of(context).buttonTheme.colorScheme!.error),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel')),
        FilledButton(
            onPressed: () async {
              Navigator.of(context).pop(range);
            },
            child: const Text("Confirm"))
      ],
    );
  }
}
