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
            // supplied at build time (see docs/46 release checklist).
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
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
