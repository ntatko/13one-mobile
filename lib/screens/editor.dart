import 'package:flutter/material.dart';
import 'package:thirteenone_mobile/models/study.dart';
import 'package:thirteenone_mobile/models/user.dart';

class EditorScreen extends StatefulWidget {
  final Lesson lesson;

  const EditorScreen({super.key, required this.lesson});

  @override
  EditorScreenState createState() => EditorScreenState();
}

class EditorScreenState extends State<EditorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson.passage),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => User().showSettingsDialog(context),
          ),
        ],
      ),
      body: ListView(
          padding: const EdgeInsets.only(left: 8, right: 8),
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  widget.lesson.title,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                ),
                Text(widget.lesson.passage,
                    style: const TextStyle(fontSize: 22)),
              ],
            ),
            const SizedBox(height: 20),
            ...widget.lesson.days.map((e) => e.form(context)).toList(),
          ]),
    );
  }
}
