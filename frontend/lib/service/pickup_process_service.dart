import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:tooGoodToWaste/service/shared_items_service.dart';

import '../dto/pickup_process.dart';
import '../dto/shared_item_model.dart';

class PickupProcessService {
  static const String PICKUP_COLLECTION = "pickups";
  final Logger logger = Logger();
  FirebaseFirestore db = FirebaseFirestore.instance;
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final SharedItemService sharedItemService = SharedItemService();

  /// Create a pickup Process for shared item with id @param sharedItemId in
  /// database, return the pickUpProcessId
  Future<String> createPickUpProcess(String sharedItemId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Authentication required to start a pickup process');
    }
    analytics.logEvent(name: 'Start Pick Up');

    final SharedItem? sharedItem =
        await sharedItemService.getSharedItem(sharedItemId);

    if (sharedItem == null || !sharedItem.isAvailable) {
      throw Exception('Shared item $sharedItemId is not available');
    }

    sharedItemService.setSharedItemIsAvailable(sharedItemId, false);

    PickupProcess pickupProcess = PickupProcess(
        receiver: user.uid,
        giver: sharedItem.user,
        sharedItemId: sharedItemId,
        isActive: true);

    DocumentReference docRef =
        await db.collection(PICKUP_COLLECTION).add(pickupProcess.toJson());

    return docRef.id;
  }

  Future<PickupProcess> getPickupProcess(String pickUpProcessId) {
    return db
        .collection(PICKUP_COLLECTION)
        .doc(pickUpProcessId)
        .get()
        .then((snapshot) {
      PickupProcess pickupProcess =
          PickupProcess.fromJson(snapshot.data() as Map<String, dynamic>);
      pickupProcess.id = snapshot.id;

      return pickupProcess;
    });
  }

  /// Only the receiver can successfully end a pickup process
  Future<void> endPickupProcess(String pickUpProcessId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated for ending a pickup process');
    }
    analytics.logEvent(name: 'End Pick Up');

    final PickupProcess pickUpProcess = await getPickupProcess(pickUpProcessId);
    if (!pickUpProcess.isActive) {
      logger.w('Pick Up Process $pickUpProcessId is already ended');
    }

    if (user.uid != pickUpProcess.receiver) {
      throw Exception('User is not receiver');
    }

    await db
        .collection(PICKUP_COLLECTION)
        .doc(pickUpProcessId)
        .update({'is_active': false});
  }

  Future<void> prematurelyEndPickUpProcess(
      String pickUpProcessId, String reason) async {
    // Both receiver and giver can prematurely end a pickup process
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated for ending a pickup process');
    }
    analytics.logEvent(name: 'Prematurely End Pick Up');

    final PickupProcess pickUpProcess = await getPickupProcess(pickUpProcessId);
    if (!pickUpProcess.isActive) {
      logger.w('Pick Up Process $pickUpProcessId is already ended');
    }

    if (user.uid != pickUpProcess.receiver && user.uid != pickUpProcess.giver) {
      throw Exception('User is neither receiver nor giver');
    }

    await db
        .collection(PICKUP_COLLECTION)
        .doc(pickUpProcessId)
        .update({'is_active': false});
  }
}
