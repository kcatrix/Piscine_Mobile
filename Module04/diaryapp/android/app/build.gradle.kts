plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter Gradle Plugin après les autres
}

android {
    namespace = "com.example.diaryapp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.diaryapp"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion

        // Ajout de Auth0 selon la doc
        manifestPlaceholders["auth0Domain"] = "dev-vekudtrpuzp0gs3i.eu.auth0.com"
        manifestPlaceholders["auth0Scheme"] = "https"

        versionCode = flutter.versionCode
        versionName = flutter.versionName
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
