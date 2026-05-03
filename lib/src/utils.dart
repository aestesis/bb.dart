class Result<T, E> {
  T? value;
  E? error;
  Result({this.value, this.error});
  static Result<T, E> success<T, E>(T value) => Result<T, E>(value: value);
  static Result<T, E> fail<T, E>(E error) => Result<T, E>(error: error);
  bool get hasSucceeded => error == null;
  bool get hasFailed => error != null;
}
