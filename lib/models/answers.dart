import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Answer {
  final int questionId;

  Answer({
    required this.questionId,
  });

  String get answer => Hive.box('answers').get(questionId.toString()) ?? '';
  set answer(String value) =>
      Hive.box('answers').put(questionId.toString(), value);

  static Future<void> openBox() async {
    await Hive.openBox('answers');
  }
}
