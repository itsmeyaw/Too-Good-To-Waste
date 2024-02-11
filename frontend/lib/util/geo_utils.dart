import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class GeoUtils {
  static const double EARTH_MEAN_RADIUS = 6371.009 * 1000;

  static double calculateDistance(GeoPoint p1, GeoPoint p2) {
    return 2 *
        EARTH_MEAN_RADIUS *
        asin(sqrt(pow(sin((p2.latitude - p1.latitude) / 2), 2) +
            pow(sin((p2.longitude - p2.longitude) / 2), 2) *
                cos(p1.latitude) *
                cos(p2.latitude)));
  }
}
