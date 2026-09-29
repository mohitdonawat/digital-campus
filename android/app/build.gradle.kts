plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.mohitdonawat.ies"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Must match package_name in google-services.json
        applicationId = "com.mohitdonawat.ies"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    applicationVariants.all {
        val variant = this
        variant.outputs.all {
            val output = this as? com.android.build.gradle.internal.api.BaseVariantOutputImpl
            if (output != null && variant.buildType.name == "release") {
                output.outputFileName = "Digital Campus.apk"
            }
        }
    }
}

afterEvaluate {
    tasks.findByName("assembleRelease")?.doLast {
        val apkDir = file("${project.layout.buildDirectory.get()}/outputs/flutter-apk")
        val customApk = file("$apkDir/Digital Campus.apk")
        val standardApk = file("$apkDir/app-release.apk")
        if (customApk.exists() && !standardApk.exists()) {
            customApk.copyTo(standardApk, overwrite = true)
        } else if (standardApk.exists() && !customApk.exists()) {
            standardApk.copyTo(customApk, overwrite = true)
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
