import 'dart:async';

import 'package:isolate_manager/isolate_manager.dart';

import 'extension.dart';

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
class Run {
  static final _isoMan = IsolateManager.createShared();
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

  static Future<R> isolate<R, P>({
    required P param,
    required R Function(P) function,
  }) async {
    return await _isoMan.compute(function, param);
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
