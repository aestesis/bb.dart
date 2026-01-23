import 'dart:async';

import 'extension.dart';

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
class Run {
  static double get time =>
      DateTime.now().millisecondsSinceEpoch.toDouble() / 1000;
  static Timer periodic(Duration tick, void Function(Timer timer) callback) =>
      Timer.periodic(tick, callback);
  static Timer once(Duration wait, VoidCallback callback) =>
      Timer(wait, callback);
  static Timer now(VoidCallback callback) => Timer(Duration.zero, callback);
  static Future<void> sleep({
    Duration duration = const Duration(milliseconds: 1),
  }) {
    final c = Completer();
    Timer(duration, () {
      c.complete();
    });
    return c.future;
  }

  // TODO: add isolate run
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
