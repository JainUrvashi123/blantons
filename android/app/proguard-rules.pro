# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# CachedNetworkImage and Flutter Cache Manager
-keep class com.baseflow.firebase_core.** { *; }
-keep class com.baseflow.fluttercachemanager.** { *; }
-keep class com.github.baseflow.** { *; }

# Also keep OkHttp if used (often used by network plugins)
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**
-keep interface okhttp3.** { *; }

# Generic Keep for any classes that might be accessed via reflection
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }

# Fix for Play Core missing classes
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
