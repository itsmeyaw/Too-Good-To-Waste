import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:tooGoodToWaste/dto/item_allergies_enum.dart';
import 'package:tooGoodToWaste/dto/item_category_enum.dart';
import 'package:tooGoodToWaste/dto/shared_item_model.dart';
import 'package:tooGoodToWaste/dto/user_model.dart';
import 'package:tooGoodToWaste/dto/user_preference_model.dart';
import 'package:tooGoodToWaste/service/user_service.dart';
import 'package:tooGoodToWaste/util/geo_utils.dart';
import 'package:tooGoodToWaste/widgets/allergies_picker.dart';
import 'package:tooGoodToWaste/widgets/category_picker.dart';
import 'package:tooGoodToWaste/widgets/food_preference_picker.dart';
import 'package:tooGoodToWaste/widgets/posts_card.dart';
import 'package:tooGoodToWaste/widgets/user_location_aware_widget.dart';
import 'package:tooGoodToWaste/dto/category_icon_map.dart';
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
  final UserService userService = UserService();

  double radius = 1;
  ItemCategory? category;
  FoodPreference? foodPreference;
  List<ItemAllergy> allergies = [];
  List<SharedItem> sharedItems = [];
  bool showLikedPosts = false;


  @override
  void initState() {
    super.initState();
    _getInitFoodPreference();
  }

  Future<void> _getInitFoodPreference() async {
    TGTWUser userData = await userService.getUserData(userId);
    foodPreference = userData.userPreference.foodPreference;
  }

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
        builder: (context) => CategoryPicker(
              initialCategory: category,
              isClear: true,
            ));

    setState(() {
      _resetSharedItems();
      category = selectedCategory;
    });
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

  Future<void> _showLikedPosts() async {
    //final List<SharedItem> likedItems = await sharedItemService.getLikedItems(userId);
    setState(() {
      showLikedPosts = true;
    });
  }

  Future<void> _showFoodPreferenceDialog(FoodPreference? initPref) async {
    final FoodPreference? foodPreference = await showDialog<FoodPreference>(
        context: context,
        builder: (context) => FoodPreferencePicker(
              initialFoodPreference: initPref,
            ));

    setState(() {
      _resetSharedItems();
      this.foodPreference = foodPreference;
      userService.setUserFoodPreference(foodPreference);
    });
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
                      height: 180,
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
                          category: category,
                          showLiked: showLikedPosts),
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
                                height: 180,
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
                              height: 180,
                              child: Container(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
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
          FutureBuilder(
              future: userService.getUserData(userId),
              builder: (BuildContext context,
                  AsyncSnapshot<TGTWUser> userDataSnapshot) {
                if (userDataSnapshot.connectionState == ConnectionState.done &&
                    userDataSnapshot.hasData) {
                  TGTWUser userData = userDataSnapshot.requireData;
                  return SingleChildScrollView(
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
                          label:
                              Text('Range (${radius.round().toString()} km)'),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        ActionChip(
                            onPressed: _showAllergyDialog,
                            avatar: const Icon(Icons.warning),
                            label: Text('Allergies (${allergies.length})')),
                        const SizedBox(
                          width: 10,
                        ),
                        ActionChip(
                            onPressed: () {
                              _showFoodPreferenceDialog(this.foodPreference ??
                                  userData.userPreference.foodPreference);
                            },
                            avatar: const Icon(Icons.rice_bowl),
                            label: Text('Preference (${foodPreference?.name ?? "None"})')),
                        ActionChip(
                            onPressed: _showLikedPosts,
                            avatar: const Icon(Icons.favorite),
                            label: Text('Liked Posts (${allergies.length})'))
                      ],
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              }),
          const SizedBox(
            height: 10,
          ),
          UserLocationAwareWidget(
              builder: (BuildContext context, GeoPoint userLocation) =>
                  StreamBuilder(
                      stream: sharedItemService.getSharedItemsWithinRadius(
                          userLocation: userLocation,
                          radiusInKm: radius,
                          userId: userId,
                          category: category,
                          showLiked: showLikedPosts),
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
                                child: Text("There is no item in your area"));
                          }

                          return Expanded(
                              child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 4.0,
                              mainAxisSpacing: 4.0,
                            ),
                            itemCount: sharedItems.length,
                            itemBuilder: (_, index) {
                              if (sharedItems[index] != null) {
                                logger.d(
                                    'Got items: ${sharedItems[index].toJson()}');
                                return Post(postData: sharedItems[index]);
                              }
                              return null;
                            },
                          ));
                        } else if (sharedItemSnapshot.connectionState ==
                            ConnectionState.active) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return const Center(
                              child: Text("There is no item in your area"));
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

class Post extends StatefulWidget {
  final SharedItem postData;

  const Post({super.key, required this.postData});

  @override
  State<StatefulWidget> createState() => _PostState();
}

class _PostState extends State<Post> {
  final SharedItemService sharedItemService = SharedItemService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;


  @override
  Widget build(BuildContext context) {
    String? categoryIconImagePath;

    int remainDays = DateTime.fromMillisecondsSinceEpoch(widget.postData.expireDate)
        .difference(DateTime.now())
        .inDays;
    if (GlobalCateIconMap[widget.postData.category.name] == null) {
      categoryIconImagePath = GlobalCateIconMap["Others"];
    } else {
      categoryIconImagePath = GlobalCateIconMap[widget.postData.category.name];
    }

    final String userId = FirebaseAuth.instance.currentUser!.uid;

    bool isLiked = widget.postData.likedBy.contains(userId);return foodItem(
      widget.postData,
      remainDays,
      onTapped: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PostPage(postData: widget.postData)));
      },onLike: () {
        sharedItemService.setLikedBy(widget.postData.id!, userId);
        setState(() {
          isLiked = !isLiked;
        });
    },
      isLiked: isLiked,
    );
  }
}
