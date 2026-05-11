import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class User {
  static const String _boxName = 'user_preferences';
  static const String _fontSizeKey = 'preferred_font_size';
  static const String _bibleTranslationKey = 'default_bible_translation';

  // Default values
  static const double _defaultFontSize = 16.0;
  static const String _defaultBibleTranslation = 'NIV';

  // Available translations
  static const List<String> availableTranslations = [
    'NIV',
    'ESV',
    'KJV',
    'NASB',
    'NLT',
    'NKJV',
  ];

  // Notifier for settings changes
  final ValueNotifier<void> _settingsChanged = ValueNotifier(null);

  // Singleton instance
  static final User _instance = User._internal();
  factory User() => _instance;
  User._internal();

  // Getters and setters for preferences
  double get preferredFontSize =>
      Hive.box(_boxName).get(_fontSizeKey, defaultValue: _defaultFontSize);

  set preferredFontSize(double value) {
    Hive.box(_boxName).put(_fontSizeKey, value);
    _settingsChanged.value = null; // Trigger rebuild
  }

  String get defaultBibleTranslation => Hive.box(_boxName)
      .get(_bibleTranslationKey, defaultValue: _defaultBibleTranslation);

  set defaultBibleTranslation(String value) {
    Hive.box(_boxName).put(_bibleTranslationKey, value);
    _settingsChanged.value = null; // Trigger rebuild
  }

  // Initialize the Hive box
  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  // Show settings dialog
  Future<void> showSettingsDialog(BuildContext context) async {
    double tempFontSize = preferredFontSize;
    String tempTranslation = defaultBibleTranslation;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Settings'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Font Size'),
                  Slider(
                    value: tempFontSize,
                    min: 12.0,
                    max: 24.0,
                    divisions: 12,
                    label: tempFontSize.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        tempFontSize = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Bible Translation'),
                  DropdownButton<String>(
                    value: tempTranslation,
                    isExpanded: true,
                    items: availableTranslations.map((String translation) {
                      return DropdownMenuItem<String>(
                        value: translation,
                        child: Text(translation),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          tempTranslation = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    preferredFontSize = tempFontSize;
                    defaultBibleTranslation = tempTranslation;
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper method to create a ValueListenableBuilder
  Widget withSettings(
      Widget Function(BuildContext context, User user) builder) {
    return ValueListenableBuilder(
      valueListenable: _settingsChanged,
      builder: (context, _, __) => builder(context, this),
    );
  }
}
