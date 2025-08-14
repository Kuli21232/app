plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties
import java.io.FileInputStream

// === Подпись релиза из keystore.properties ===
val keystoreProps = Properties()
val keystorePropsFile = rootProject.file("keystore.properties")
val hasReleaseKeystore = keystorePropsFile.exists()
if (hasReleaseKeystore) {
    keystoreProps.load(FileInputStream(keystorePropsFile))
}

android {
    namespace = "com.example.motiva"          // TODO: поставь финальный пакет и больше его не меняй
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    // AGP требует Java 17
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.motiva"  // == namespace; для обновлений должен оставаться тем же
        minSdk = 23
        targetSdk = 35
        versionCode = 1                        // ↑ увеличивай при каждом обновлении (120, 121, ...)
        versionName = "1.0.0"                  // произвольная строка версии (1.2.0 и т.п.)
    }

    signingConfigs {
        // Конфиг релизной подписи из keystore.properties
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystoreProps["storeFile"] as String)
                storePassword = keystoreProps["storePassword"] as String
                keyAlias = keystoreProps["keyAlias"] as String
                keyPassword = keystoreProps["keyPassword"] as String
            }
        }
    }

    buildTypes {
        getByName("release") {
            // Если есть keystore — используем его; иначе фолбек на debug, чтобы сборка не ломалась
            signingConfig = if (hasReleaseKeystore)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")

            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
