import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tooGoodToWaste/service/user_item_service.dart';

void main() {
  final FirebaseFirestore mockFirestore = FakeFirebaseFirestore();
  final UserItemService sut =
      UserItemService.withCustomFirestore(db: mockFirestore);

  const String USER_COLLECTION = 'users';
  const String ITEMS_COLLECTION = 'items';


  group('Get Items', () {
    setUp(() {
      mockFirestore.collection(USER_COLLECTION);
    });

    test('Getting user items normally', () {
    });
  });
}
