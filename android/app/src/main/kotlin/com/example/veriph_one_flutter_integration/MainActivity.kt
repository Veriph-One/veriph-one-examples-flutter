package com.example.veriph_one_flutter_integration

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import one.veriph.sdk.ui.util.VerificationParams
import one.veriph.sdk.ui.util.VerificationResultContract

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "one.veriph.sdk/verification"

    private var verificationResult: MethodChannel.Result? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "startVerification") {
                val apiKey = call.argument<String>("apiKey")
                val sessionUuid = call.argument<String>("sessionUuid")

                if(apiKey == null || sessionUuid == null) {
                    result.error("INVALID_PARAMS", "Api Key or Session UUID are null.", null)
                } else {
                    launchVerification(apiKey, sessionUuid)
                    verificationResult = result
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private val startForResult =
        registerForActivityResult(VerificationResultContract()) { result: String? ->
            if (result != null) {
                // Verification has a result ready (could be successful or failed)
                verificationResult?.success(result)
            } else {
                // Verification failed or was interrupted.
                verificationResult?.error("INTERRUPTED", "Verification flow incomplete", null)
            }
        }

    private val launchVerification: (apiKey: String, sessionUuid: String) -> Unit =
        { apiKey: String, sessionUuid: String ->
            startForResult.launch(VerificationParams(sessionUuid, apiKey))
        }
}