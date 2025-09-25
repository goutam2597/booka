pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        // PhonePe Intent SDK Maven repository
        maven { url = uri("https://phonepe.jfrog.io/artifactory/maven") }
        gradlePluginPortal()
    }
}

// Ensure dependency resolution (for module dependencies) can use PhonePe repo
// Some Gradle setups rely on settings-level repositories for resolving plugin/module deps
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // Flutter engine/artifacts repository
        maven(url = uri("https://storage.googleapis.com/download.flutter.io"))
        maven(url = uri("https://phonepe.jfrog.io/artifactory/maven")) {
            metadataSources {
                mavenPom()
                artifact()
            }
            content { includeGroup("phonepe.intentsdk.android.release") }
        }
        maven(url = uri("https://phonepe.jfrog.io/artifactory/libs-release-local")) {
            content { includeGroup("phonepe.intentsdk.android.release") }
        }
        // Optional offline fallback: local Maven repo (place AAR/POM under android/maven-local)
        maven(url = uri("${rootDir}/maven-local")) {
            content { includeGroup("phonepe.intentsdk.android.release") }
        }
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    // START: FlutterFire Configuration
    id("com.google.gms.google-services") version("4.3.15") apply false
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
