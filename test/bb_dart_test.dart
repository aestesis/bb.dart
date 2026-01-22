import 'package:bb_dart/bb_dart.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('GeoPoint', () {
      final p = GeoPoint.fromJson({'lat': 10, 'lng': 8});
      expect(p, equals(GeoPoint(lat: 10, lng: 10)));
      final j = p.toJson();
      expect(j['lat'], equals(10));
      expect(j['lng'], equals(8));
    });

    test('GeoRect', () {});
  });
}
