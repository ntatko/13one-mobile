# thirteenone_mobile

A mobile version of the [13one](https://13one.org) website.

## Getting Started

### Prerequisites

This is a [Flutter](https://flutter.dev) project, so you will need to have Flutter installed on your machine. You can find instructions on how to install Flutter [here](https://flutter.dev/docs/get-started/install).

To build the project, you will need to have either an Android or iOS emulator installed on your machine. You can find instructions on how to set up an Android emulator [here](https://developer.android.com/studio/run/emulator) and how to set up an iOS emulator [here](https://flutter.dev/docs/get-started/install/macos#set-up-the-ios-simulator).

### Fork and Clone the project

To get started, fork the repository and clone it to your local machine.

### Installing

To install the project, clone the repository and run `flutter pub get` in the project directory to install the dependencies.

### Running the project

To run the project, run `flutter run` in the project directory. This will start the app on the emulator you have set up. If you have multiple emulators set up, you can specify which one to use by running `flutter run -d <device_id>`, where `<device_id>` is the ID of the device you want to use.

## Deployment

### Build for Android

The Google Play Console accepts Android App Bundles, which are files that include all of your app's compiled code and resources, but defer APK generation and signing to Google Play. To build an Android App Bundle, run `flutter build appbundle` in the project directory. This will generate an `.aab` file in the `build/app/outputs/bundle/release` directory.

```bash
flutter build appbundle --release
```

### Build for iOS

You will need xcode to make an archive the app. This is done in the `project` section of xcode.

## Contributing

If you would like to contribute to this project, please fork the repository and submit a pull request. If you have any questions, please feel free to submit an issue with a question. If you find a bug, please submit an issue with a detailed description of the bug and how to reproduce it.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE.md) file for details.
