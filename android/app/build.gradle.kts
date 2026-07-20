import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing is driven by android/key.properties (git-ignored — see
// android/.gitignore). Populate it from key.properties.example for a store build;
// when it is absent (local dev / CI without secrets) the release build falls back
// to debug signing so `flutter run --release` still works. Never commit real keys.
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties().apply {
    if (keystorePropertiesFile.exists()) {
        load(FileInputStream(keystorePropertiesFile))
    }
}
val hasReleaseSigning = keystorePropertiesFile.exists()

android {
    namespace = "com.qalam.qalam_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications (uses java.time on older APIs) —
        // M8, docs/40 §33.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.qalam.qalam_mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        // Real release signing — active only when key.properties is present.
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            // Store builds sign with the release keystore (key.properties); local
            // builds without it fall back to debug signing so `flutter run
            // --release` keeps working. Dart obfuscation + split-debug-info are
            // supplied at build time (see docs/46 + docs/51 release checklist).
            //
            // R8 / resource shrinking stay OFF by default (M10 decision, docs/46
            // §13) — Dart tree-shaking + `--obfuscate` cover code size and R8 can
            // strip un-vetted plugin code. To enable (needs device QA): set
            // isMinifyEnabled = true, isShrinkResources = true, and add
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"),
            //   "proguard-rules.pro"). See android/app/proguard-rules.pro.
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }

    // Build flavors mirror AppFlavor + dart_defines/<flavor>.json (docs/40 §28.1,
    // docs/51). Each flavor gets a distinct applicationId suffix so all four can be
    // installed side by side; `production` keeps the canonical id (no suffix). The
    // ${appName} manifest placeholder drives the launcher label per flavor. Pair
    // with `flutter build ... --flavor <name> --dart-define-from-file=...`.
    flavorDimensions += "env"
    productFlavors {
        create("development") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            manifestPlaceholders["appName"] = "Qalam Dev"
        }
        create("qa") {
            dimension = "env"
            applicationIdSuffix = ".qa"
            manifestPlaceholders["appName"] = "Qalam QA"
        }
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".staging"
            manifestPlaceholders["appName"] = "Qalam Staging"
        }
        create("production") {
            dimension = "env"
            // No applicationIdSuffix — production is the canonical
            // com.qalam.qalam_mobile id that the Play listing is tied to.
            manifestPlaceholders["appName"] = "Qalam"
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Core library desugaring runtime — pairs with isCoreLibraryDesugaringEnabled
    // so flutter_local_notifications' java.time usage runs on older Android (§33).
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
