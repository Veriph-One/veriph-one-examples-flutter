# Veriph.One's Flutter integration example

This project was created using [Flutter](https://flutter.dev) and contains a barebones mobile application that integrates with Veriph.One's native SDK. It showcases a simple phone number capture flow.

## Getting Started

1. Ensure you have reviewed the developer documentation to understand how to integrate phone-based verification into your web app. Developer docs can be found [here](https://developer.veriph.one/docs/intro).

2. This is a sample project with an incomplete implementation. It is limited to showing how to integrate the native Veriph.One SDK into your Flutter projects. As such, if you run the project as is, the verification flow will show an error screen due to a lack of an API Key and session UUID (see `lib/main.dart`). The session UUID must be obtained from your server's API by leveraging your Start and Result endpoints.

3. Regarding your API Key, there are several ways of securely feeding it to the SDK; you can use a Remote Secret manager or some mechanism that ensures your information is secure. IMPORTANT: never commit your API Keys to your repositories; doing so can expose you to data leaks and unexpected charges.

> Note: To run this project on an iOS device, you must select a development team in Xcode.

## Implement the SDK in your own app

Ready to integrate the Veriph.One SDK into your app? First, you'll need to create a Method Channel on your Flutter code and then perform the setup for each platform you are working with:

### Create a Method Channel

Use the IDE of your preference for Flutter development to add these files:

1. Create a MethodChannel to bind the SDK to your Flutter code using `lib/src/channel/veriph_one_channel.dart` as an example:

   ```dart
   import 'package:flutter/services.dart';

   class VeriphOneChannel {
   static const platform = MethodChannel('one.veriph.sdk/verification');

   static Future<String?> subscribeToVerificationEvent(String apiKey, String sessionUuid) async {
         try {
            return await platform
               .invokeMethod<String?>('startVerification', <String, String>{
            'apiKey': apiKey,
            'sessionUuid': sessionUuid,
            });
         } on PlatformException {
            return null;
         }
      }
   }
   ```

5. Look at `lib/main.dart` lines 47 to 67 to understand how to call the SDK from your Flutter code and subscribe to a result notification using the MethodChannel you created in the previous step.

   ```dart
   ElevatedButton(
      onPressed: () {
         // Under normal conditions, you wouldn't call the SDK first. You should make a call to your
         // server's Start Endpoint (https://developer.veriph.one/docs/server/start-endpoint), then
         // obtain a Session UUID and finally call the SDK using the code below.
         // As part of that request, you can also pass additional data to your server, like the
         // current locale, so the verification flow is kept in the same language; or a transaction
         // ID to identify the operation.
         VeriphOneChannel.subscribeToVerificationEvent(
               "YOUR API KEY GOES HERE", "YOUR SESSION UUID GOES HERE")
            .then((result) => {
                  if (result == null)
                     {
                     // The flow was interrupted by the user or finished unsuccessfully
                     showMessage(
                           context,
                           "Verification failed or was interrupted!",
                           true)
                     }
                  else
                     {
                     // Ask your server via a request to the Result Endpoint for a result and
                     // instructions on what to do next. Remember, the SDK won't give you the
                     // result outright to ensure data can't be tampered with.
                     showMessage(context,
                           "Verification was successful! 🎉🎉", false)
                     }
               });
      },
      child: const Text('Start verification flow'),
   )
   ```

### Android

We recommend you perform this process in Android Studio, which helps with the upgrade. Open your `/android` folder as a project and follow these instructions.

1. (Recommended) Run Android Studio's AGP upgrade assistant if prompted by it. As of this writing, Flutter uses AGP 7.3.0 and might be incompatible with some of the latest Jetpack Compose dependencies.

2. Go to this project's `android/app/build.gradle` and copy lines 31 to 37 (`compileOptions` and `kotlinOptions`) to ensure the ones in your app's Android gradle file (same path) match them. Do the same process with lines 59 to 61 and ensure you are using the latest version of our SDK (e.g., `implementation("one.veriph:veriph-one-android-sdk:1.0.10")`).

3. Add lines 8-11 from this project's `/android/build.gradle` to your app's project level gradle file (same path) to ensure you are using the correct minimum Kotlin version.

4. In your `/android/settings.gradle` file, add line 22 (`id "org.jetbrains.kotlin.android" version "1.9.0" apply false`) from this project's same file to your list of plugins.

5. Go to your `/android/gradle/wrapper/gradle-wrapper.properties` file and make sure you are running a newer version of the gradle plugin by updating the `distributionUrl` to `distributionUrl=https\://services.gradle.org/distributions/gradle-8.10-bin.zip`. Then execute a gradle sync to ensure everything is working properly.

6. Using this example's `android/app/src/main/kotlin/com/example/veriph_one_flutter_integration/MainActivity.kt` file, copy its code or merge it with your own to create the native binding to the Veriph.One SDK. Important: note that we use `FlutterFragmentActivity` instead of the traditional `FlutterActivity`; the latter is missing some key features needed for the SDK's lifecycle.

### Testing your integration
After you have finalized the integration of each platform you'll use, go back to the IDE you use for Flutter development and use the code samples to connect your Start and Result endpoint calls to finish the integration.

Once you run the project using Flutter's platform, the integration will be fully functional on all platforms.

## Need support? Want more examples?

We can gladly help out. Get in touch through [our website](https://www.veriph.one/contact).
