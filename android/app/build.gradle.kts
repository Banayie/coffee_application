plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.coffee_application"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "29.0.13113456"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        //isCoreLibraryDesugaringEnabled = true //Thêm mới
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.coffeeapp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
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

dependencies {
    // BoM để tự đồng bộ phiên bản Firebase
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))

    // Các Firebase module cụ thể
    implementation("com.google.firebase:firebase-auth-ktx")

    // Thêm dòng này:
    //coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
