import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:thirteenone_mobile/models/answers.dart';
import 'package:thirteenone_mobile/models/study.dart';
import 'package:thirteenone_mobile/screens/lessons.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String path = "/assets/db";
  if (!kIsWeb) {
    var appDocDir = await getApplicationDocumentsDirectory();
    path = appDocDir.path;
  }
  Hive.init(path);
  await Answer.openBox();

  Study current = await Study.getCurrentStudy();

  runApp(MyApp(currentStudy: current));
}

class MyApp extends StatelessWidget {
  final Study currentStudy;

  const MyApp({super.key, required this.currentStudy});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '13one',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: MediaQuery.of(context).platformBrightness,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: LessonsScreen(currentStudy: currentStudy),
    );
  }
}
