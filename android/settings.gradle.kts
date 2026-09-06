pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            val localPropertiesFile = file("local.properties")
            if (localPropertiesFile.exists()) {
                localPropertiesFile.inputStream().use { properties.load(it) }
            }

            var sdkPath = properties.getProperty("flutter.sdk")
            if (sdkPath == null) {
                sdkPath = System.getenv("FLUTTER_SDK")
            }
            if (sdkPath == null) {
                sdkPath = System.getenv("FLUTTER_ROOT")
            }

            if (sdkPath == null) {
                throw GradleException("flutter.sdk not set in local.properties or FLUTTER_SDK/FLUTTER_ROOT environment variable")
            }

            sdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
