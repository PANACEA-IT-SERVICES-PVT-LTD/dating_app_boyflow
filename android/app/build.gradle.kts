plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
        // Enable ABI splits to reduce APK size per architecture
        // ABI splits disabled: only a single universal APK will be built
        splits {
            abi {
                isEnable = false
            }
        }
    namespace = "com.example.Boy_flow"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"  // Ensure this matches the NDK version required

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.Boy_flow"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // Only add the externalNativeBuild section if you are working with native C++ code.
    // If not, you can remove this section completely.
    externalNativeBuild {
        cmake {
            // Only needed if you have C++ code
            // cppFlags "-DANDROID_STL=c++_shared"
        }
    }
}

flutter {
    source = "../.."
}
