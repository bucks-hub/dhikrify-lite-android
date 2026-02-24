package com.dhikrifylite.app

import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import io.flutter.plugin.common.EventChannel
import java.util.Locale

class ContinuousTranscriptionService(private val context: Context) : RecognitionListener {
    private var speechRecognizer: SpeechRecognizer? = null
    private var eventSink: EventChannel.EventSink? = null
    private var isListening = false
    private var locale: String = "ar-SA"

    fun setEventSink(sink: EventChannel.EventSink?) {
        eventSink = sink
    }

    fun initialize(): Boolean {
        return try {
            if (!SpeechRecognizer.isRecognitionAvailable(context)) {
                return false
            }
            speechRecognizer = SpeechRecognizer.createSpeechRecognizer(context)
            speechRecognizer?.setRecognitionListener(this)
            true
        } catch (e: Exception) {
            android.util.Log.e("TranscriptionService", "Error initializing: ${e.message}")
            false
        }
    }

    fun startListening(locale: String) {
        this.locale = locale
        if (isListening) {
            return
        }
        isListening = true
        startRecognition()
    }

    private fun startRecognition() {
        if (!isListening) return

        try {
            val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE, locale)
                putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, locale)
                putExtra(RecognizerIntent.EXTRA_ONLY_RETURN_LANGUAGE_PREFERENCE, locale)
                putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true)
                putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS, 10000L)
                putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS, 800L)
                putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, 800L)
            }

            speechRecognizer?.startListening(intent)
            android.util.Log.d("TranscriptionService", "Started recognition")
        } catch (e: Exception) {
            android.util.Log.e("TranscriptionService", "Error starting recognition: ${e.message}")
            // Retry after a delay
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                if (isListening) {
                    startRecognition()
                }
            }, 500)
        }
    }

    fun stopListening() {
        isListening = false
        try {
            speechRecognizer?.stopListening()
            speechRecognizer?.cancel()
        } catch (e: Exception) {
            android.util.Log.e("TranscriptionService", "Error stopping: ${e.message}")
        }
    }

    fun destroy() {
        stopListening()
        speechRecognizer?.destroy()
        speechRecognizer = null
    }

    // RecognitionListener implementations
    override fun onReadyForSpeech(params: Bundle?) {
        android.util.Log.d("TranscriptionService", "Ready for speech")
    }

    override fun onBeginningOfSpeech() {
        android.util.Log.d("TranscriptionService", "Speech began")
    }

    override fun onRmsChanged(rmsdB: Float) {
        // Audio level changed - not needed for now
    }

    override fun onBufferReceived(buffer: ByteArray?) {
        // Audio buffer received - not needed
    }

    override fun onEndOfSpeech() {
        android.util.Log.d("TranscriptionService", "Speech ended")
    }

    override fun onError(error: Int) {
        val errorMessage = when (error) {
            SpeechRecognizer.ERROR_AUDIO -> "Audio recording error"
            SpeechRecognizer.ERROR_CLIENT -> "Client error"
            SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "Insufficient permissions"
            SpeechRecognizer.ERROR_NETWORK -> "Network error"
            SpeechRecognizer.ERROR_NETWORK_TIMEOUT -> "Network timeout"
            SpeechRecognizer.ERROR_NO_MATCH -> "No match"
            SpeechRecognizer.ERROR_RECOGNIZER_BUSY -> "Recognizer busy"
            SpeechRecognizer.ERROR_SERVER -> "Server error"
            SpeechRecognizer.ERROR_SPEECH_TIMEOUT -> "Speech timeout"
            else -> "Unknown error"
        }
        android.util.Log.e("TranscriptionService", "Recognition error: $errorMessage ($error)")

        // Auto-restart on most errors, except permissions and client errors
        if (isListening && error != SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS &&
            error != SpeechRecognizer.ERROR_CLIENT) {
            // Restart after a short delay
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                if (isListening) {
                    startRecognition()
                }
            }, 300)
        }
    }

    override fun onResults(results: Bundle?) {
        results?.let {
            val matches = it.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            if (!matches.isNullOrEmpty()) {
                val text = matches[0]
                android.util.Log.d("TranscriptionService", "Final result: $text")
                eventSink?.success(text)
            }
        }

        // Automatically restart listening for continuous recognition
        if (isListening) {
            android.os.Handler(android.os.Looper.getMainLooper()).postDelayed({
                if (isListening) {
                    startRecognition()
                }
            }, 100)
        }
    }

    override fun onPartialResults(partialResults: Bundle?) {
        // Log partial results but don't send to Flutter to avoid over-counting
        partialResults?.let {
            val matches = it.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            if (!matches.isNullOrEmpty()) {
                val text = matches[0]
                android.util.Log.d("TranscriptionService", "Partial result: $text (not counted)")
            }
        }
    }

    override fun onEvent(eventType: Int, params: Bundle?) {
        // Not used
    }
}
