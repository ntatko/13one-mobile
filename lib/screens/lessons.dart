import 'package:flutter/material.dart';
import 'package:thirteenone_mobile/models/study.dart';
import 'package:thirteenone_mobile/screens/editor.dart';

class LessonsScreen extends StatefulWidget {
  final Study currentStudy;
  const LessonsScreen({super.key, required this.currentStudy});

  @override
  LessonsScreenState createState() => LessonsScreenState();
}

class LessonsScreenState extends State<LessonsScreen> {
  int _selectedStudyId = 1;

  @override
  void initState() {
    super.initState();
    _selectedStudyId = widget.currentStudy.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Lessons'),
        ),
        drawer: Drawer(
            child: FutureBuilder<List<Study>>(
          future: Study.getStudies(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView(
                children: snapshot.data!
                    .map((study) => ListTile(
                          selected: study.id == _selectedStudyId,
                          title: Text(study.name),
                          subtitle: Text(study.passage),
                          onTap: () {
                            setState(() {
                              _selectedStudyId = study.id;
                            });
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              );
            } else if (snapshot.hasError) {
              return ListTile(
                title: Text('Error: ${snapshot.error}'),
              );
            } else {
              return const ListTile(
                title: Text('Loading...'),
              );
            }
          },
        )),
        body: FutureBuilder<Study>(
          future: Study.getStudy(_selectedStudyId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (snapshot.hasData) {
              if (snapshot.data!.lessons.isEmpty) {
                return const Center(
                  child: Text('No lessons here yet... Find them on 13one.org!'),
                );
              }
              return ListView(
                children: snapshot.data!.lessons
                    .map((Lesson lesson) => ListTile(
                          leading: Text(
                            lesson.number.toString(),
                            style: const TextStyle(fontSize: 20),
                          ),
                          title: Text(lesson.title),
                          subtitle: Text(lesson.passage),
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return EditorScreen(lesson: lesson);
                            }));
                          },
                        ))
                    .toList(),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }
}
