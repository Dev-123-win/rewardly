plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.supreet.rewardly"
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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.supreet.rewardly"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Define product flavors for each Firebase project
    flavorDimensions += "app_environment"
    productFlavors {
        create("prod01") {
            dimension = "app_environment"
            applicationIdSuffix = ".prod01"
            // Point to the specific google-services.json file for this flavor
            // This assumes the file is located at android/app/google_services/google-services-prod-01.json
            // The google-services plugin will automatically pick it up if named correctly
            // or if a custom source set is configured.
            // For this setup, we'll rely on the existing structure and the plugin's default behavior.
        }
        create("prod02") {
            dimension = "app_environment"
            applicationIdSuffix = ".prod02"
        }
        create("prod03") {
            dimension = "app_environment"
            applicationIdSuffix = ".prod03"
        }
        create("prod04") {
            dimension = "app_environment"
            applicationIdSuffix = ".prod04"
        }
        create("prod05") {
            dimension = "app_environment"
            applicationIdSuffix = ".prod05"
        }
        // Add a new flavor for prod06
        create("prod06") {
            dimension = "app_environment"
            applicationIdSuffix = ".prod06"
        }
        // Add new flavors for prod07 through prod10
        create("prod07") {
            dimension = "app_environment"
            applicationIdSuffix = ".prod07"
        }
        create("prod08") {
            dimension = "app_environment"
            applicationIdSuffix = ".prod08"
        }
        create("prod09") {
            dimension = "app_environment"
            applicationIdSuffix = ".prod09"
        }
        create("prod10") {
            dimension = "app_environment"
            applicationIdSuffix = ".prod10"
        }
        // Add new flavors for prod11 through prod15
        create("prod11") {
            dimension = "app_environment"
            applicationIdSuffix = ".prod11"
        }
        create("prod12") {
            dimension = "app_environment"
            applicationIdSuffix = ".prod12"
        }
        create("prod13") {
            dimension = "app_environment"
            applicationIdSuffix = ".prod13"
        }
        create("prod14") {
            dimension = "app_environment"
            applicationIdSuffix = ".prod14"
        }
        create("prod15") {
            dimension = "app_environment"
            applicationIdSuffix = ".prod15"
        }
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

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics-ktx")
}
