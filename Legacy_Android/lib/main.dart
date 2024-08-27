import 'package:flutter/material.dart';
import 'package:veriph_one_legacy_android/src/channel/veriph_one_channel.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  showMessage(context, String message, bool isError) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.orange : Colors.lightBlue,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Hello World!'),
            const SizedBox(height: 30),
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
            ),
          ],
        ),
      ),
    );
  }
}
