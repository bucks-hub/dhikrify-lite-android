# Dhikrify Lite - ProGuard Rules for Release Build

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Hive database classes
-keep class * extends io.flutter.plugins.** { *; }

# Keep speech recognition classes
-keep class android.speech.** { *; }

# Keep custom classes
-keep class com.dhikrifylite.app.** { *; }

# Keep Play Core library (for Flutter deferred components)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# Don't warn about missing classes
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
