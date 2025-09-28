plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.bookapp_customer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.bookapp_customer"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        // Only package English and Arabic resources from dependencies
        resConfigs("en", "ar")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // TODO: replace with your real release signing config
            signingConfig = signingConfigs.getByName("debug")
            // Temporarily disable lint vital to work around file locking issue
            // You can re-enable after resolving external process locking JARs.
            isCrunchPngs = false
        }
    }

    lint {
        abortOnError = false
        checkReleaseBuilds = false // disable fatal lint on release assembly
        warningsAsErrors = false
    }

    // Note: Do not enable Gradle splits here because Flutter tooling may set ndk.abiFilters
    // for faster builds, which conflicts with splits. To produce per-ABI APKs, use:
    //   flutter build apk --release --split-per-abi
}

flutter {
    source = "../.."
}

repositories {
    google()
    mavenCentral()
    maven { url = uri("https://phonepe.jfrog.io/artifactory/maven") }
}

/**
 * Force Guava’s Android artifact everywhere.
 * This prevents pulling the JRE flavor that references java.lang.reflect.AnnotatedType.
 */
configurations.all {
    resolutionStrategy {
        force("com.google.guava:guava:33.2.1-android")
    }
}

dependencies {
    // Firebase BoM — keep Firebase libs aligned
    implementation(platform("com.google.firebase:firebase-bom:33.1.2"))
    implementation("com.google.firebase:firebase-messaging")


    // Desugaring (meets flutter_local_notifications requirement >= 2.1.4)
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")

    // (Optional explicit add; the force() above already pins this)
    implementation("com.google.guava:guava:33.2.1-android")

    implementation("androidx.appcompat:appcompat:1.4.0")
}
