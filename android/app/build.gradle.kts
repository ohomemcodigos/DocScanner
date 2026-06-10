plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // O plugin do Flutter deve ser o último da lista
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.docscanner"
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
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
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
}

flutter {
    source = "../.."
}

dependencies {
    // Garante que o ciclo de vida do Android seja compatível com a API 36
    implementation("androidx.lifecycle:lifecycle-runtime:2.8.0")
}
