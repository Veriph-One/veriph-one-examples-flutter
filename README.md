# Veriph.One's Flutter integration example

This project was created using [Flutter](https://flutter.dev) and contains a barebones mobile application that integrates with Veriph.One's native SDK. It showcases a simple phone number capture flow.

> Note: This example is currently limited to Android. iOS integration coming soon.

## Getting Started

1. Ensure you have gone through the developer documentation to understand how to integrate phone-based verification to your web app. Developer docs can be found [here](https://developer.veriph.one/docs/intro).

2. This is sample code with an incomplete implementation, it is limited to show how to integrate the native Veriph.One SDK into your Flutter projects. As such, you can run the project as is and the verification flow will show an error screen due to a lack of an API Key and session UUID (see `lib/main.dart`). The session UUID must be obtained from your server's API by leveraging your Start and Result endpoints.

3. Regarding your API Key, there are several ways of securely feeding it to the SDK; you can use a Remote Secret manager or some mechanism that ensures your information is secure. IMPORTANT: never commit your API Keys to your repositories, doing so can expose you to data leaks and unexpected charges.

## Implement the SDK in your own app

Ready to integrate the Veriph.One SDK into your app? Follow these steps to do so:

### Android

We recommend you perform this process in Android Studio, as it helps with the upgrade. Open your `/android` folder as a project and follow these instructions.

1. Go to this project's `android/app/build.gradle` and copy lines 31 to 38 to replace them to your own app's Android gradle file (same path). Do the same process with lines 60 to 62 and ensure you are using the latest version of our SDK (e.g. `implementation("one.veriph:veriph-one-android-sdk:1.0.10")`).

2. If your app is using Kotlin 2.0.0 or higher skip this step. Otherwise, you'll need to update your dependencies as follows:

   - Go to `android/settings.gradle` and copy lines 21 and 22 to your own version of the file. Usually, Android Studio shows a notification on the lower right corner to inform you that you need to upgrade AGP, this will automate part of this process for you. If you are not getting this message, do a gradle sync to refresh the build.
   - Using this project's `android/gradle.properties` as a reference, ensure that Android Studio's upgrade process added lines 4 to 6 (if not, ensure your file matches this project's).
   - Similarly, ensure your `android/gradle/wrapper/gradle-wrapper.properties` file matches this project's, particularly on line 5. Your gradle version should be updated.
   - Once everything is updated, do a Gradle sync and try to run your project using the IDE you use for Flutter development. It should compile and run normally.
   - In some cases, if your Flutter project has outdated configuation, you might need to update the `ndkVersion` declared in `~/flutter/packages/flutter_tools/gradle/src/main/groovy/flutter.groovy` to one compatible with the newer Kotlin, Gradle and AGP versions.

3. Using this example's `android/app/src/main/kotlin/com/example/veriph_one_flutter_integration/MainActivity.kt` file, copy its code or merge it with your own in order to create the native binding to the Veriph.One SDK. Important: note that we use `FlutterFragmentActivity` instead of the traditional `FlutterActivity`, the latter is missing some key features needed for the SDK's lifecycle.

At this point, you can go back to the IDE of your preference for Flutter development.

4. Create a MethodChannel to bind the SDK to your Flutter code using `lib/src/channel/veriph_one_channel.dart` as an example:

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

5. Take a look at `lib/main.dart` lines 47 to 67 to understand how to call the SDK from your Flutter code and subscribe to a result notification using the MethodChannel you created in the previous step.

   ```dart
   ElevatedButton(
      onPressed: () {
         // Under normal conditions, you wouldn't call the SDK first. You should make a call to your
         // server's Start Endpoint (https://developer.veriph.one/docs/server/start-endpoint), then
         // obtain a Session UUID and finally call the SDK using the code below.
         // As part of that request, you can also pass additional data to your server: like the
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
                     // result outright to ensure data can't be tampered.
                     showMessage(context,
                           "Verification was successful! 🎉🎉", false)
                     }
               });
      },
      child: const Text('Start verification flow'),
   )
   ```

6. Use this code samples to connect to your Start and Result endpoint calls to finish the integration.

## Need support? Want more examples?

We can gladly help out. Get in touch through [our website](https://www.veriph.one/contact).
