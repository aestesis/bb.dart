import 'package:bb_dart/bb_dart.dart';

void main(List<String> arguments) async {
  Debug.info('VroOOoooom!!');
  final t0 = List<int>.generate(3, (i) => i);
  final t = Run.time;
  int count = 0;
  List<List<int>> stack = [];
  await for (final t in t0.permutations()) {
    stack.add(t);
    count++;
  }
  Debug.info(stack);
  Debug.info(
    '$count permutations in ${Duration(seconds: (Run.time - t).toInt()).toHumanString()}',
  );
}
