import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thirteenone_mobile/models/answers.dart';
import 'package:thirteenone_mobile/models/user.dart';
import 'package:url_launcher/url_launcher.dart';

/// Static lesson JSON base (R2 + public hostname). Change here when the CDN URL or API version changes.
const String _kContentBase = 'https://data.13one.site';
const String _kContentVersion = 'v2';

Uri _contentUri(String path) =>
    Uri.parse('$_kContentBase/$_kContentVersion/$path');

/// Entry for the study drawer (replaces full `GET /items/study` payload).
class StudyOverview {
  final int id;
  final String name;
  final String passage;

  StudyOverview({
    required this.id,
    required this.name,
    required this.passage,
  });

  factory StudyOverview.fromJson(Map<String, dynamic> json) {
    return StudyOverview(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      passage: (json['passage'] as String?) ?? '',
    );
  }
}

class Study {
  int id;
  String name;
  String passage;
  List<Lesson> lessons;

  Study({
    required this.id,
    required this.name,
    required this.passage,
    required this.lessons,
  });

  factory Study.fromJson(Map<String, dynamic> json) {
    return Study(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      passage: json['passage'] as String,
      lessons: (json['lessons'] as List<dynamic>)
          .map<Lesson>((lesson) => Lesson.fromJson(lesson as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<List<StudyOverview>> getStudyCatalog() async {
    final response = await http.get(_contentUri('catalog.json'), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to load catalog (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final data = decoded['data'] as List<dynamic>;
    return data
        .map((e) => StudyOverview.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<Study> getStudy(int id) async {
    final response = await http.get(_contentUri('studies/$id.json'), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to load study $id (${response.statusCode})');
    }
    return Study.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  static Future<Study> getCurrentStudy() async {
    final response = await http.get(_contentUri('current_study.json'), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to load current study (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final inner = decoded['data'] as Map<String, dynamic>;
    final studyPayload = inner['study_id'] as Map<String, dynamic>;
    return Study.fromJson(studyPayload);
  }
}

class Lesson {
  int id;
  String passage;
  String number;
  String title;
  List<Day> days;

  Lesson({
    required this.id,
    required this.passage,
    required this.number,
    required this.title,
    required this.days,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: (json['id'] as num).toInt(),
      passage: json['passage'] as String,
      number: json['number'] as String,
      title: json['title'] as String,
      days: (json['days'] as List<dynamic>)
          .map<Day>((day) => Day.fromJson(day as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Day {
  int id;
  int day;
  String prompt;
  String label;
  List<Question> questions;
  String? passage;

  Day({
    required this.id,
    required this.day,
    required this.prompt,
    required this.label,
    required this.questions,
    this.passage,
  });

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      id: (json['id'] as num).toInt(),
      day: (json['day'] as num).toInt(),
      prompt: json['prompt'] as String,
      label: json['label'] as String,
      passage: json['passage'] as String?,
      questions: (json['questions'] as List<dynamic>)
          .map<Question>(
              (question) => Question.fromJson(question as Map<String, dynamic>))
          .toList(),
    );
  }

  Widget form(BuildContext context) {
    return User().withSettings((context, user) => Center(
        child: SizedBox(
            width: MediaQuery.of(context).size.width > 700
                ? 700
                : MediaQuery.of(context).size.width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: "$label: ",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: user.preferredFontSize + 2),
                    children: [
                      TextSpan(
                        text: prompt,
                        style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: user.preferredFontSize),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                if (passage != null)
                  ElevatedButton(
                    onPressed: () async {
                      final p = passage!;
                      final uri = Uri.https('www.biblegateway.com', '/passage/', {
                        'search': p,
                        'version': user.defaultBibleTranslation,
                        'interface': 'print',
                      });
                      if (!await launchUrl(uri)) {
                        throw Exception('Could not launch $p');
                      }
                    },
                    child: const Text("Read Day's Passage"),
                  ),
                const SizedBox(height: 16.0),
                ...questions.map((question) => Column(children: [
                      question.form(),
                      const SizedBox(height: 30),
                    ])),
                const SizedBox(height: 50),
              ],
            ))));
  }
}

class Question {
  int id;
  String number;
  String text;
  String? passage;
  bool isNotAnswerable;

  Question({
    required this.id,
    required this.number,
    required this.text,
    this.passage,
    this.isNotAnswerable = false,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: (json['id'] as num).toInt(),
      number: json['number'] as String,
      text: json['text'] as String,
      passage: json['passage'] as String?,
      isNotAnswerable: json['is_not_answerable'] == true,
    );
  }

  Widget form() {
    return User().withSettings((context, user) {
      Answer answer = Answer(questionId: id);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: "$number: ",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: user.preferredFontSize + 2),
              children: [
                TextSpan(
                  text: text,
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: user.preferredFontSize),
                ),
              ],
            ),
          ),
          if (passage != null)
            TextButton(
                onPressed: () async {
                  final p = passage!;
                  final uri = Uri.https('www.biblegateway.com', '/passage/', {
                    'search': p,
                    'version': user.defaultBibleTranslation,
                    'interface': 'print',
                  });
                  if (!await launchUrl(uri)) {
                    throw Exception('Could not launch $p');
                  }
                },
                child: const Text("Read Supplemental Passage(s)")),
          if (!isNotAnswerable) const SizedBox(height: 15),
          if (!isNotAnswerable)
            TextFormField(
              initialValue: answer.answer,
              minLines: 3,
              maxLines: 10,
              onChanged: (value) {
                answer.answer = value;
              },
              style: TextStyle(fontSize: user.preferredFontSize),
              decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: 'Answer Question $number'),
            ),
        ],
      );
    });
  }
}
