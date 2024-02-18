import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:tooGoodToWaste/dto/item_allergies_enum.dart';
import 'package:tooGoodToWaste/dto/item_category_enum.dart';
import 'package:tooGoodToWaste/dto/shared_item_model.dart';
import 'package:tooGoodToWaste/util/geo_utils.dart';
import 'package:tooGoodToWaste/widgets/allergies_picker.dart';
import 'package:tooGoodToWaste/widgets/category_picker.dart';
import 'package:tooGoodToWaste/widgets/user_location_aware_widget.dart';
import '../Pages/post_page.dart';
import '../service/shared_items_service.dart';

Logger logger = Logger();

// The social places timeline
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  final SharedItemService sharedItemService = SharedItemService();

  double radius = 1;
  ItemCategory? category;
  List<ItemAllergy> allergies = [];
  List<SharedItem> sharedItems = [];

  void _resetSharedItems() {
    sharedItems = [];
  }

  Future<void> _showRangeDialog() async {
    final double? selectedRadius = await showDialog<double>(
        context: context,
        builder: (context) => RadiusPicker(initialRange: radius));

    if (selectedRadius != null) {
      setState(() {
        _resetSharedItems();
        radius = selectedRadius;
      });
    }
  }

  Future<void> _showCategoryDialog() async {
    final ItemCategory? selectedCategory = await showDialog<ItemCategory>(
        context: context,
        builder: (context) => CategoryPicker(initialCategory: category));

    if (selectedCategory != null) {
      setState(() {
        _resetSharedItems();
        category = selectedCategory;
      });
    }
  }

  Future<void> _showAllergyDialog() async {
    final List<ItemAllergy>? selectedAllergies =
        await showDialog<List<ItemAllergy>>(
            context: context,
            builder: (context) => AllergiesPicker(initialAllergies: allergies));

    if (selectedAllergies != null) {
      setState(() {
        _resetSharedItems();
        allergies = selectedAllergies;
      });
    }
  }

  Set<Marker> createMarkers(List<SharedItem> sharedItems) {
    logger.d('Created Google Map, adding ${sharedItems.length} results');
    Set<Marker> markers = {};

    for (final sharedItem in sharedItems) {
      if (sharedItem.id == null) {
        continue;
      }

      markers.add(Marker(
          markerId: MarkerId(sharedItem.id!),
          position: LatLng(
              sharedItem.location.latitude, sharedItem.location.longitude)));
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: Column(
        children: [
          UserLocationAwareWidget(
              loader: (BuildContext context) => FractionallySizedBox(
                    widthFactor: 1.0,
                    child: SizedBox(
                      height: 200,
                      child: Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
              builder: (BuildContext context, GeoPoint userLocation) =>
                  StreamBuilder(
                      stream: sharedItemService.getSharedItemsWithinRadius(
                          userLocation: userLocation,
                          radiusInKm: radius,
                          userId: userId,
                          category: category),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<DocumentSnapshot>>
                              sharedItemSnapshot) {
                        if (sharedItemSnapshot.connectionState ==
                                ConnectionState.active &&
                            sharedItemSnapshot.hasData) {
                          if (sharedItemSnapshot.data != null) {
                            List<SharedItem?> results = sharedItemService
                                .createSharedItemList(sharedItemSnapshot.data!);
                            for (var res in results) {
                              if (res != null) {
                                res.distance = GeoUtils.calculateDistance(
                                    userLocation,
                                    GeoPoint(res.location.latitude,
                                        res.location.longitude));
                                sharedItems.add(res);
                              }
                            }
                          }

                          return FractionallySizedBox(
                            widthFactor: 1.0,
                            child: SizedBox(
                                height: 200,
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(userLocation.latitude,
                                        userLocation.longitude),
                                    zoom: 13.0 - radius / 4,
                                  ),
                                  markers: createMarkers(sharedItems),
                                )),
                          );
                        } else {
                          return FractionallySizedBox(
                            widthFactor: 1.0,
                            child: SizedBox(
                              height: 200,
                              child: Container(
                                color: Theme.of(context).colorScheme.secondaryContainer,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          );
                        }
                      })),
          const SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                ActionChip(
                  onPressed: _showCategoryDialog,
                  avatar: const Icon(Icons.tune, size: 16),
                  label: category != null
                      ? Text('Category: ${category!.name}')
                      : const Text('Category: Any'),
                ),
                const SizedBox(
                  width: 10,
                ),
                ActionChip(
                  onPressed: _showRangeDialog,
                  avatar: const Icon(Icons.location_pin, size: 16),
                  label: Text('Range (${radius.round().toString()} km)'),
                ),
                const SizedBox(
                  width: 10,
                ),
                ActionChip(
                    onPressed: _showAllergyDialog,
                    avatar: const Icon(Icons.warning),
                    label: Text('Allergies (${allergies.length})'))
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Results',
                style: Theme.of(context).textTheme.headlineMedium,
              )
            ],
          ),
          UserLocationAwareWidget(
              builder: (BuildContext context, GeoPoint userLocation) =>
                  StreamBuilder(
                      stream: sharedItemService.getSharedItemsWithinRadius(
                          userLocation: userLocation,
                          radiusInKm: radius,
                          userId: userId,
                          category: category),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<DocumentSnapshot>>
                              sharedItemSnapshot) {
                        if (sharedItemSnapshot.connectionState ==
                                ConnectionState.active &&
                            sharedItemSnapshot.hasData) {
                          if (sharedItemSnapshot.data != null) {
                            List<SharedItem?> results = sharedItemService
                                .createSharedItemList(sharedItemSnapshot.data!);
                            for (var res in results) {
                              if (res != null) {
                                res.distance = GeoUtils.calculateDistance(
                                    userLocation,
                                    GeoPoint(res.location.latitude,
                                        res.location.longitude));
                                sharedItems.add(res);
                              }
                            }
                          }

                          if (sharedItems.isEmpty) {
                            return const Center(
                                child: Text("There is no item in your area")
                            );
                          }

                          return Expanded(
                              child: ListView.separated(
                            itemCount: sharedItems.length,
                            itemBuilder: (_, index) {
                              if (sharedItems[index] != null) {
                                logger.d(
                                    'Got items: ${sharedItems[index].toJson()}');
                                return Post(postData: sharedItems[index]);
                              }
                              return null;
                            },
                            separatorBuilder: (_, index) {
                              return const Divider();
                            },
                          ));
                        } else if (sharedItemSnapshot.connectionState == ConnectionState.active) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return const Center(
                            child: Text("There is no item in your area")
                          );
                        }
                      }))
        ],
      ),
    );
  }
}

class RadiusPicker extends StatefulWidget {
  final double initialRange;

  const RadiusPicker({super.key, required this.initialRange});

  @override
  State<StatefulWidget> createState() => _RadiusPickerState();
}

class _RadiusPickerState extends State<RadiusPicker> {
  double _range = 0;

  @override
  void initState() {
    super.initState();
    _range = widget.initialRange;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Range in km'),
      content: IntrinsicHeight(
          child: Slider(
        value: _range,
        max: 20,
        min: 1,
        divisions: 4,
        label: _range.round().toString(),
        onChanged: (double newValue) {
          logger.d('Slided value to $newValue');
          setState(() {
            _range = newValue.roundToDouble();
          });
        },
      )),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () => Navigator.pop(context, _range),
            child: const Text('OK'))
      ],
    );
  }
}

class Post extends StatelessWidget {
  final SharedItem postData;

  const Post({super.key, required this.postData});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PostPage(postData: postData)));
        },
        child: FractionallySizedBox(
          widthFactor: 1.0,
          child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item name: ${postData.name}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text(
                    'Amount: ${postData.amount.nominal} ${postData.amount.unit}',
                    style: const TextStyle(color: Colors.black),
                  ),
                  Text(
                    'Distance: ${postData.distance} m',
                    style: const TextStyle(color: Colors.black),
                  )
                ],
              )),
        ));
  }
}
