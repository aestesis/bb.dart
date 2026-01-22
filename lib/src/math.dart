//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
class Range<T extends num> {
  final T? min;
  final T? max;
  const Range({this.min, this.max});
  const Range.at(T p, {T? margin})
    : min = (p - (margin ?? 0)) as T,
      max = (p + (margin ?? 0)) as T;
  Range<T> expand(T margin) =>
      Range(min: (min! - margin) as T, max: (max! + margin) as T);
  @override
  String toString() => 'Range<${T.runtimeType}>(min:$min, max:$max)';
  @override
  bool operator ==(Object other) =>
      other is Range<T> && min == other.min && max == other.max;
  @override
  int get hashCode => min.hashCode & max.hashCode;
  static Range<double> get zero => const Range<double>.at(0.0);
  static Range<double> get infinity =>
      const Range<double>(min: double.negativeInfinity, max: double.infinity);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
class Slope {
  double _value;
  double factor;
  double get value => _value;
  set value(double v) {
    _value = (v - _value) * factor + _value;
  }

  Slope({double value = 0, this.factor = 0.5}) : _value = value;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
