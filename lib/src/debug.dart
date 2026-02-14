import 'dart:core';

import 'package:stack_trace/stack_trace.dart';
import 'dart:core' as core;

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
class Debug {
  static String prefix = '';
  static bool Function(String error)? onError;
  static final _log = StringBuffer();
  static void _print(String text) => core.print(text);
  static void print(Object? object) {
    _log.write('${object.toString()}\r\n');
    int defaultPrintLength = 700;
    if (object == null || object.toString().length <= defaultPrintLength) {
      _print(object.toString());
    } else {
      String log = object.toString();
      int start = 0;
      int endIndex = defaultPrintLength;
      int logLength = log.length;
      int tmpLogLength = log.length;
      while (endIndex < logLength) {
        _print(log.substring(start, endIndex));
        endIndex += defaultPrintLength;
        start += defaultPrintLength;
        tmpLogLength -= defaultPrintLength;
      }
      if (tmpLogLength > 0) _print(log.substring(start, logLength));
    }
  }

  static String _callerLocation(StackTrace stack) {
    try {
      final frames = Trace.from(stack).frames;
      int i = 0;
      while (i < frames.length) {
        final f = frames[i];
        i++;
        if (f.location.contains('debug.dart')) {
          if (i < frames.length) return frames[i].location;
          return '';
        }
      }
    } catch (_) {}
    return '';
  }

  static void info(Object object) {
    final l = _callerLocation(StackTrace.current);
    if (object is Error) {
      _print('$l $object');
      _print(object.stackTrace.toString());
    } else {
      _print('$l $object');
    }
  }

  static void warning(Object object) {
    final l = _callerLocation(StackTrace.current);
    if (object is Error) {
      print('$l $object');
      print(object.stackTrace);
    } else {
      print('$l $object');
    }
  }

  static void error(Object object) {
    final l = _callerLocation(StackTrace.current);
    print('--------------------------------------------');
    if (object is Error) {
      print('$l $object');
      print(object.stackTrace);
    } else {
      print('$l $object');
    }
    try {
      if (onError != null && onError!(_log.toString())) _log.clear();
    } catch (error) {
      // do nothing
    }
  }

  static void log(Object object) {
    print(object);
    try {
      if (onError != null) onError!(object.toString());
    } catch (error) {
      // do nothing
    }
  }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////
