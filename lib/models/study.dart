import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thirteenone_mobile/models/answers.dart';
import 'package:url_launcher/url_launcher.dart';

const String baseUrl = 'https://homiletics-directus.cloud.plodamouse.com/items';
const String includes = '?fields=*.*.*.*.*';

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
      id: json['id'],
      name: json['name'],
      passage: json['passage'],
      lessons: json['lessons']
          .map<Lesson>((lesson) => Lesson.fromJson(lesson))
          .toList(),
    );
  }

  static Future<List<Study>> getStudies() async {
    final response =
        await http.get(Uri.parse("$baseUrl/study$includes"), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data']
          .map<Study>((study) => Study.fromJson(study))
          .toList();
    } else {
      throw Exception('Failed to load studies');
    }
  }

  static Future<Study> getStudy(int id) async {
    final response =
        await http.get(Uri.parse("$baseUrl/study/$id$includes"), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return Study.fromJson(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to load study');
    }
  }

  static Future<Study> getCurrentStudy() async {
    final response =
        await http.get(Uri.parse("$baseUrl/current_study$includes"), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return Study.fromJson(jsonDecode(response.body)['data']['study_id']);
    } else {
      throw Exception('Failed to load current study');
    }
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
      id: json['id'],
      passage: json['passage'],
      number: json['number'],
      title: json['title'],
      days: json['days'].map<Day>((day) => Day.fromJson(day)).toList(),
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
      id: json['id'],
      day: json['day'],
      prompt: json['prompt'],
      label: json['label'],
      passage: json['passage'],
      questions: json['questions']
          .map<Question>((question) => Question.fromJson(question))
          .toList(),
    );
  }

  Widget form(BuildContext context) {
    return Center(
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
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                    children: [
                      TextSpan(
                        text: prompt,
                        style: const TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                if (passage != null)
                  ElevatedButton(
                    onPressed: () async {
                      if (!await launchUrl(Uri.parse(
                          "https://www.biblegateway.com/passage/?search=${passage}"))) {
                        throw Exception('Could not launch $passage');
                      }
                    },
                    child: const Text("Read Day's Passage"),
                  ),
                const SizedBox(height: 16.0),
                ...questions
                    .map((question) => Column(children: [
                          question.form(),
                          const SizedBox(height: 30),
                        ]))
                    .toList(),
                const SizedBox(height: 50),
              ],
            )));
  }
}

class Question {
  int id;
  String number;
  String text;
  String? passage;

  Question({
    required this.id,
    required this.number,
    required this.text,
    this.passage,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      number: json['number'],
      text: json['text'],
      passage: json['passage'],
    );
  }

  Widget form() {
    Answer answer = Answer(questionId: id);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: "$number: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            children: [
              TextSpan(
                text: text,
                style: const TextStyle(fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        if (passage != null)
          TextButton(
              onPressed: () async {
                if (!await launchUrl(Uri.parse(
                    "https://www.biblegateway.com/passage/?search=${passage}"))) {
                  throw Exception('Could not launch $passage');
                }
              },
              child: const Text("Read Supplemental Passage(s)")),
        const SizedBox(height: 15),
        TextFormField(
          initialValue: answer.answer,
          minLines: 3,
          maxLines: 10,
          onChanged: (value) {
            answer.answer = value;
          },
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              labelText: 'Answer Question $number'),
        ),
      ],
    );
  }
}
