package com.dhikrifylite.app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.dhikrifylite.app/transcription"
    private val EVENT_CHANNEL = "com.dhikrifylite.app/transcription_stream"

    private var transcriptionService: ContinuousTranscriptionService? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        transcriptionService = ContinuousTranscriptionService(this)

        // Method channel for control commands
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    val initialized = transcriptionService?.initialize() ?: false
                    result.success(initialized)
                }
                "startListening" -> {
                    val locale = call.argument<String>("locale") ?: "ar-SA"
                    transcriptionService?.startListening(locale)
                    result.success(null)
                }
                "stopListening" -> {
                    transcriptionService?.stopListening()
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // Event channel for transcription stream
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    transcriptionService?.setEventSink(events)
                }

                override fun onCancel(arguments: Any?) {
                    transcriptionService?.setEventSink(null)
                }
            }
        )
    }

    override fun onDestroy() {
        transcriptionService?.destroy()
        super.onDestroy()
    }
}
