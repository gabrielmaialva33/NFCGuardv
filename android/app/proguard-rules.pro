# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# NFC Manager plugin rules
-keep class com.nfcmanager.** { *; }
-dontwarn com.nfcmanager.**

# Riverpod rules
-keep class * extends riverpod.** { *; }
-keep class **.*Provider { *; }

# Brazilian validation rules  
-keep class br.com.all_validations.** { *; }

# Keep all classes with @JsonSerializable annotation
-keep @com.google.gson.annotations.SerializedName class * { *; }
-keep class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep JSON serialization classes
-keep class **.*$_$* { *; }
-keepclassmembers class * {
  *** toJson();
  *** fromJson(...);
}

# Google Play Core classes (to fix missing class errors)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Flutter deferred components (Play Store Split)
-dontwarn io.flutter.embedding.android.FlutterPlayStoreSplitApplication
-dontwarn io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager { *; }

# Device info plus plugin
-keep class dev.fluttercommunity.plus.device_info.** { *; }
-dontwarn dev.fluttercommunity.plus.device_info.**

# Secure storage plugin  
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# NTP plugin
-keep class hu.webarticum.** { *; }
-dontwarn hu.webarticum.**

# Crypto related classes
-keep class javax.crypto.** { *; }
-keep class java.security.** { *; }
-dontwarn javax.crypto.**
-dontwarn java.security.**