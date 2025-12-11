import java.util.Properties
import org.gradle.api.Project

fun getLocalProperties(rootProject: Project): Properties {
    // 1. We no longer need 'java.util' due to the import
    val localProperties = Properties()

    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.inputStream().use { inputStream ->
            // 2. We call load() on the localProperties object explicitly,
            //    rather than relying on an implicit receiver.
            localProperties.load(inputStream)
        }
    }
    return localProperties
}

val localProperties = getLocalProperties(rootProject)

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:34.5.0"))
    implementation(platform("com.facebook.android:facebook-android-sdk:4.42.0"))
}

android {
    namespace = "com.example.volunteer_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.volunteer.volunteer_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["googleMapsApiKey"] = localProperties.getProperty("googleMapsApiKey", "")
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
