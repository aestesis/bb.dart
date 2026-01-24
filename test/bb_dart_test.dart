import 'package:bb_dart/bb_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Geo Tests', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('GeoPoint', () {
      final p = GeoPoint.fromJson({'lat': 10, 'lng': 8});
      expect(p, equals(GeoPoint(lat: 10, lng: 8)));
      final j = p.toJson();
      expect(j['lat'], equals(10));
      expect(j['lng'], equals(8));
      final g = GeoPoint.fromJson(p.toGeoJson());
      expect(g, equals(p));
    });

    test('GeoRect', () {
      final p0 = GeoPoint(lat: 1, lng: 2);
      final p1 = GeoPoint(lat: 3, lng: 4);
      final r0 = GeoRect.boundsFromPoints([p0, p1]);
      expect(r0.isNotEmpty, equals(true));
      final r1 = GeoRect.fromJson(r0.toGeoJson());
      expect(r1, equals(r0));
      final r2 = GeoRect.fromJson(r0.toJson());
      expect(r2, equals(r0));
    });
  });

  group('Math Tests', () {
    test('Permuations', () async {
      const t0 = [1, 2, 3, 4, 5];
      final sc = t0.permutations().length;
      int ac = 0;
      await for (final t in t0.permutationStream()) {
        ac++;
      }
      expect(sc, equals(ac));
    });
  });
}
