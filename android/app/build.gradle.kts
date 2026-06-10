plugins {
    id("com.android.application")
<<<<<<< HEAD
    id("org.jetbrains.kotlin.android")
    // O plugin do Flutter deve ser o último da lista
=======
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
>>>>>>> 5acf77e61b9b720182375e2a4594b0e12d41ece0
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.docscanner"
<<<<<<< HEAD
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.docscanner"
        minSdk = flutter.minSdkVersion
        targetSdk = 36
=======
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
        applicationId = "com.example.docscanner"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
>>>>>>> 5acf77e61b9b720182375e2a4594b0e12d41ece0
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
<<<<<<< HEAD
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Força a resolução de conflitos de dependências entre plugins
    configurations.all {
        resolutionStrategy {
            force("androidx.lifecycle:lifecycle-runtime:2.8.0")
            force("androidx.lifecycle:lifecycle-common:2.8.0")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
=======
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
>>>>>>> 5acf77e61b9b720182375e2a4594b0e12d41ece0
}

flutter {
    source = "../.."
}
<<<<<<< HEAD

dependencies {
    // Garante que o ciclo de vida do Android seja compatível com a API 36
    implementation("androidx.lifecycle:lifecycle-runtime:2.8.0")
}
=======
>>>>>>> 5acf77e61b9b720182375e2a4594b0e12d41ece0
