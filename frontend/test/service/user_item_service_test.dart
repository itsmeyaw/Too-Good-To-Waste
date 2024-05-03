import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooGoodToWaste/service/user_item_service.dart';

void main() {
  final FirebaseFirestore mockFirestore = FakeFirebaseFirestore();
  final UserItemService sut =
      UserItemService.withCustomFirestore(db: mockFirestore);

  const String userCollection = 'users';
  const String itemsCollection = 'items';

  group('Get Items', () {
    setUp(() {
      mockFirestore.collection(userCollection);
    });

    test('Getting user items normally', () {});
  });
}
