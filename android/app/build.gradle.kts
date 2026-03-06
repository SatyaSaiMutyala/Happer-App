plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}
val kotlin_version = "1.9.22"
val desugarLibVersion = "2.1.4"
val stripeVersion = "20.20.0"

// Load key.properties file
val keystorePropertiesFile = rootProject.file("key.properties")
val properties = java.util.Properties()
if (keystorePropertiesFile.exists()) {
    properties.load(java.io.FileInputStream(keystorePropertiesFile))
}
android {
    namespace = "com.fr.happer.app"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.fr.happer.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 33 // Updated to 23 for Firebase Auth compatibility
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled =true   
        }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = properties["keyAlias"] as String
                keyPassword = properties["keyPassword"] as String
                storeFile = file(properties["storeFile"] as String)
                storePassword = properties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
        }
    }
}
dependencies {
   coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:$desugarLibVersion")

    implementation("androidx.window:window:1.0.0")
    implementation("androidx.window:window-java:1.0.0")
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version")
    implementation("androidx.multidex:multidex:2.0.1")

    // Material Design components for Stripe compatibility
    implementation("com.google.android.material:material:1.10.0")

    // Firebase using BoM
    implementation(platform("com.google.firebase:firebase-bom:32.2.0"))
    implementation("com.google.firebase:firebase-analytics-ktx")
    implementation("com.google.firebase:firebase-messaging-ktx")
    implementation("com.google.firebase:firebase-auth-ktx")

    // Stripe SDK
    implementation("com.stripe:stripe-android:$stripeVersion")
}

flutter {
    source = "../.."
}
