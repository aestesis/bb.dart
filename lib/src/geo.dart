import 'dart:ffi';
import 'dart:math';

import 'package:bb_dart/bb_dart.dart';
import 'package:collection/collection.dart';

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
class GeoPoint extends Point<double> {
  double get lng => x;
  double get longitude => x;
  double get lat => y;
  double get latitude => y;
  List<double> get coordinates => [lng, lat];
  String get text => '$lat,$lng';
  GeoCell get cell => GeoCell.fromPoint(this);
  GeoPoint({double lng = 0, double lat = 0}) : super(lng, lat);
  static GeoPoint fromPoint(Point<double> o) => GeoPoint(lat: o.y, lng: o.x);
  static GeoPoint fromJson(Map<String, dynamic> json) {
    double lng = 0;
    double lat = 0;
    if (json.containsKey('type') && json['type'] == 'Point') {
      lng = jsonDouble(json['coordinates'][0]);
      lat = jsonDouble(json['coordinates'][1]);
      return GeoPoint(lng: lng, lat: lat);
    }
    if (json.containsKey('lat')) {
      lat = jsonDouble(json['lat']);
    } else if (json.containsKey('latitude')) {
      lat = jsonDouble(json['latitude']);
    }
    if (json.containsKey('lng')) {
      lng = jsonDouble(json['lng']);
    } else if (json.containsKey('longitude')) {
      lng = jsonDouble(json['longitude']);
    }
    return GeoPoint(lng: lng, lat: lat);
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
  Map<String, dynamic> toGeoJson() => {
    'type': 'Point',
    'coordinates': coordinates,
  };
  @override
  GeoPoint operator +(Point other) {
    return GeoPoint(lng: x + other.x, lat: y + y);
  }

  @override
  GeoPoint operator -(Point other) {
    return GeoPoint(lng: x - other.x, lat: y - other.y);
  }

  static GeoPoint get lorient => GeoPoint(lng: -3.370, lat: 47.74);
  static GeoPoint get paris => GeoPoint(lng: 2.3522, lat: 48.8566);
  static GeoPoint get zero => GeoPoint(lng: 0, lat: 0);
  GeoRect rect({double lat = 0, double lng = 0}) => GeoRect(
    GeoPoint(lat: this.lat - lat, lng: this.lng - lng),
    GeoPoint(lat: this.lat + lat, lng: this.lng + lng),
  );
  @override
  String toString() => 'GeoPoint(lat:$lat, lng:$lng)';
  Distance distance(GeoPoint p) {
    const double earthRadius = 6371000;
    double degreesToRadians(double degrees) {
      return degrees * (pi / 180);
    }

    final dLat = degreesToRadians(p.lat - lat);
    final dLng = degreesToRadians(p.lng - lng);
    final a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(degreesToRadians(lat)) *
            cos(degreesToRadians(p.lat)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return Distance(meters: earthRadius * c);
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
class GeoRect extends Rectangle<double> {
  GeoPoint get southWest => GeoPoint(lng: left, lat: top);
  GeoPoint get northEast => GeoPoint(lng: right, lat: bottom);
  GeoPoint get sw => GeoPoint(lng: left, lat: top);
  GeoPoint get ne => GeoPoint(lng: right, lat: bottom);
  String get query => '${sw.lng},${sw.lat},${ne.lng},${ne.lat}';
  GeoRect(GeoPoint sw, GeoPoint ne)
    : super(sw.lng, sw.lat, ne.lng - sw.lng, ne.lat - sw.lat);
  static GeoRect get empty {
    return GeoRect(GeoPoint.zero, GeoPoint.zero);
  }

  bool get isEmpty => width <= 0 || height <= 0;
  bool get isNotEmpty => width > 0 && height > 0;
  GeoRect extand({int margin = 0}) {
    final m = GeoCell.size * margin.toDouble();
    return GeoRect(
      GeoPoint(lng: sw.lng - m, lat: sw.lat - m),
      GeoPoint(lng: ne.lng + m, lat: ne.lat + m),
    );
  }

  GeoRect append(GeoPoint p) => boundsFromPoints([p, sw, ne]);

  static GeoRect boundsFromPoints(Iterable<GeoPoint> points) {
    if (points.isEmpty) return GeoRect.empty;
    final double minLatitude = points.map((e) => e.latitude).min;
    final double maxLatitude = points.map((e) => e.latitude).max;
    final double minLongitude = points.map((e) => e.longitude).min;
    final double maxLongitude = points.map((e) => e.longitude).max;
    return GeoRect(
      GeoPoint(lat: minLatitude, lng: minLongitude),
      GeoPoint(lat: maxLatitude, lng: maxLongitude),
    );
  }

  Map<String, dynamic> toGeoJson() => {
    'type': 'Polygon',
    'coordinates': [
      [
        [sw.lng, sw.lat],
        [sw.lng, ne.lat],
        [ne.lng, ne.lat],
        [ne.lng, sw.lat],
      ],
    ],
  };
  Map<String, dynamic> toJson() => {'sw': sw.toJson(), 'ne': ne.toJson()};

  static GeoRect fromJson(Map<String, dynamic> json) {
    if (json.containsKey('northeast') && json.containsKey('southwest')) {
      final ne = GeoPoint.fromJson(json['northeast']);
      final sw = GeoPoint.fromJson(json['southwest']);
      return GeoRect(sw, ne);
    }
    if (json.containsKey('ne') && json.containsKey('sw')) {
      final ne = GeoPoint.fromJson(json['ne']);
      final sw = GeoPoint.fromJson(json['sw']);
      return GeoRect(sw, ne);
    }
    if (json.containsKey('type') &&
        json.containsKey('coordinates') &&
        json['type'] == 'Polygon' &&
        json['coordinates'] is List) {
      final points = <GeoPoint>[
        ...((json['coordinates'] as List)[0]).map(
          (jc) => GeoPoint(lng: jc[0], lat: jc[1]),
        ),
      ];
      return GeoRect.boundsFromPoints(points);
    }
    throw Exception('not implemented');
  }

  GeoPoint get center =>
      GeoPoint(lat: (sw.lat + ne.lat) / 2, lng: (sw.lng + ne.lng) / 2);
  Distance get radius => sw.distance(ne) * 0.5;

  Set<GeoCell> cells({int margin = 0}) {
    Set<GeoCell> cells = {};
    final sw = this.sw.cell;
    final ne = this.ne.cell;
    for (var lat = sw.lat! - margin; lat <= ne.lat! + margin; lat++) {
      for (var lng = sw.lng! - margin; lng <= ne.lng! + margin; lng++) {
        cells.add(GeoCell(lng, lat));
      }
    }
    return cells;
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
class GeoCell {
  static const double size = 0.0025;
  static const double isize = 1 / size;
  int? lat;
  int? lng;
  GeoCell(this.lng, this.lat);
  GeoCell.fromPoint(GeoPoint p) {
    lat = (p.lat * isize).floor();
    lng = (p.lng * isize).floor();
  }
  GeoRect get bounds {
    var p = GeoPoint(lng: lng! * size, lat: lat! * size);
    return GeoRect(p, p + GeoPoint(lng: size, lat: size));
  }

  @override
  bool operator ==(Object other) {
    return other is GeoCell && other.lat == lat && other.lng == lng;
  }

  @override
  int get hashCode => Object.hash(lng, lat);

  @override
  String toString() {
    return 'GeoCell(lat:$lat,lng:$lng)';
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
class Distance {
  static const zero = Distance(meters: 0);
  static const infinity = Distance(meters: double.infinity);
  static const double _metersByMile = 1609.34;
  static const double _metersByKilometer = 1000;
  final double _meters;
  const Distance._fromMeters(double meters) : _meters = meters;
  const Distance({double miles = 0, double kilometers = 0, double meters = 0})
    : _meters =
          miles * _metersByMile + kilometers * _metersByKilometer + meters;
  double get meters => _meters;
  double get miles => _meters / _metersByMile;
  double get km => _meters / _metersByKilometer;
  double get kilometers => _meters / _metersByKilometer;
  Distance operator +(Distance other) {
    return Distance._fromMeters(_meters + other._meters);
  }

  Distance operator -(Distance other) {
    return Distance._fromMeters(_meters - other._meters);
  }

  Distance operator *(num factor) {
    return Distance._fromMeters(_meters * factor);
  }

  bool operator <(Distance other) => _meters < other._meters;
  bool operator <=(Distance other) => _meters <= other._meters;
  bool operator >(Distance other) => _meters > other._meters;
  bool operator >=(Distance other) => _meters >= other._meters;
  @override
  bool operator ==(Object other) =>
      other is Distance && _meters == other._meters;
  @override
  int get hashCode => _meters.hashCode;
  int compareTo(Distance other) => _meters.compareTo(other._meters);

  @override
  String toString() => '$_meters meters';
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
