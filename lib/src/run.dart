import 'dart:async';

import 'package:isolate_manager/isolate_manager.dart';

import 'extension.dart';

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
class Run {
  static IsolateManagerShared? _isoMan;
  static int bgThreads = 2;
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

  static Future<void> bgRestart() async {
    await _isoMan?.restart();
  }

  static Future<void> bgStop() async {
    await _isoMan?.stop();
    _isoMan = null;
  }

  static Future<R> background<R, P>({
    required P param,
    required FutureOr<R> Function(P) function,
  }) async {
    _isoMan ??= IsolateManager.createShared(concurrent: bgThreads);
    return await _isoMan!.compute(function, param);
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
