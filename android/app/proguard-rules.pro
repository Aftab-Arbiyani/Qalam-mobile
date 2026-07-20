# ─────────────────────────────────────────────────────────────────────────────
# Qalam — R8 / ProGuard keep rules (SEAM; NOT ACTIVE BY DEFAULT).
#
# R8 code shrinking, obfuscation, and resource shrinking are intentionally OFF
# (M10 decision — docs/46 §13, docs/51). Dart tree-shaking + `--obfuscate`
# already cover code size, and R8 can silently strip reflection-driven plugin
# code, so enabling it is a release checklist item gated on device QA.
#
# This file exists so the rules are curated and version-controlled ahead of time.
# It has NO effect until R8 is turned on in android/app/build.gradle.kts:
#
#   buildTypes {
#       release {
#           isMinifyEnabled = true          // enable R8 code shrinking + obfuscation
#           isShrinkResources = true        // strip unused resources (needs minify)
#           proguardFiles(
#               getDefaultProguardFile("proguard-android-optimize.txt"),
#               "proguard-rules.pro",
#           )
#           // ...existing signingConfig...
#       }
#   }
#
# After enabling, do a full device QA pass (esp. notifications, secure storage,
# image picker, connectivity) before shipping — a missing keep rule surfaces as a
# runtime ClassNotFound / NoSuchMethod only in the shrunk release build.
# ─────────────────────────────────────────────────────────────────────────────

# ── Flutter engine + embedding ────────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ── Kotlin / coroutines metadata (reflection-safe) ────────────────────────────
-keep class kotlin.Metadata { *; }
-keepclassmembers class **$WhenMappings { <fields>; }
-dontwarn kotlin.**
-dontwarn kotlinx.**

# ── Core library desugaring (java.time on older APIs — see build.gradle.kts) ──
-dontwarn com.google.android.gms.**
-dontwarn java.time.**

# ── flutter_local_notifications (M8, docs/40 §33) — uses Gson + reflection ─────
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
# Gson type tokens / serialized model fields must survive shrinking.
-keepattributes Signature
-keepattributes *Annotation*
-keep class * extends com.google.gson.reflect.TypeToken { *; }
-keep class * implements com.google.gson.TypeAdapterFactory { *; }
-keep class * implements com.google.gson.JsonSerializer { *; }
-keep class * implements com.google.gson.JsonDeserializer { *; }

# ── flutter_secure_storage (Keystore-backed) ──────────────────────────────────
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# ── connectivity_plus / device_info_plus / package_info_plus ──────────────────
-keep class dev.fluttercommunity.plus.** { *; }

# ── Firebase seam (only relevant once firebase_messaging / remote_config land) ─
# Phase-2 seams (docs/40 §31, §32). Harmless to keep ahead of activation.
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# ── Application entry points (keep so R8 never renames the launcher activity) ──
-keep class com.qalam.qalam_mobile.** { *; }
