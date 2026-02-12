plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.Boy_flow"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    defaultConfig {
        applicationId = "com.example.Boy_flow"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        ndk {
            // abiFilters.add("armeabi-v7a") // Removed to reduce size to <60MB
            abiFilters.add("arm64-v8a")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    packagingOptions {
        // Exclude unnecessary native libraries for x86/x86_64
        jniLibs {
            excludes += setOf(
                "**/x86/**",
                "**/x86_64/**",
                "**/mips/**",
                "**/mips64/**",
                "**/armeabi-v7a/**", // Forcefully exclude armeabi-v7a
                // Exclude unused Agora extensions to reduce APK size
                // Aggressive Agora exclusions
                 "**/libagora-ffmpeg.so", // ~6MB
                 "**/libagora_screen_capture_extension.so",
                 "**/libagora_video_quality_analyzer_extension.so",
                 "**/libagora_video_decoder_extension.so",
                 "**/libagora_video_encoder_extension.so",
                 "**/libagora_ai_echo_cancellation_ll_extension.so",
                 
                 "**/libagora_lip_sync_extension.so",
                 "**/libagora_spatial_audio_extension.so",
                 "**/libagora_video_av1_decoder_extension.so",
                 "**/libagora_video_av1_encoder_extension.so",
                 "**/libagora_segmentation_extension.so",
                 "**/libagora_clear_vision_extension.so",
                 "**/libagora_content_inspect_extension.so",
                 "**/libagora_face_capture_extension.so",
                 "**/libagora_face_detection_extension.so",
                 "**/libagora_audio_beauty_extension.so",
                 "**/libagora_ai_echo_cancellation_extension.so",
                 "**/libagora_ai_noise_suppression_extension.so",
                 "**/libagora_ai_noise_suppression_ll_extension.so"
            )
        }
        
        // Remove duplicate files
        resources {
            excludes += setOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/license.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt",
                "META-INF/notice.txt",
                "META-INF/*.kotlin_module"
            )
        }
    }

    externalNativeBuild {
        cmake {
            // cppFlags "-DANDROID_STL=c++_shared"
        }
    }
}

dependencies {
    // Import the Firebase BoM
    implementation(platform("com.google.firebase:firebase-bom:34.8.0"))
    
    // Removed firebase-analytics to reduce APK size
    // Only keeping essential Firebase for messaging
    
    // Add core library desugaring
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}