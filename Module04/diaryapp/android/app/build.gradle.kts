plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.diaryapp"
    compileSdk = 35  // Modification de 34 à 35
    ndkVersion = "26.1.10909125"  // Dernière version stable du NDK

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.diaryapp"
        minSdk = 24
        targetSdk = 35  // Mettre également à jour targetSdk à 35
        versionCode = 1
        versionName = "1.0"

        manifestPlaceholders["auth0Domain"] = "dev-vekudtrpuzp0gs3i.eu.auth0.com"
        manifestPlaceholders["auth0Scheme"] = "https"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
