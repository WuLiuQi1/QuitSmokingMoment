import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
    alias(libs.plugins.ksp)
}

val signingProperties = Properties().apply {
    val file = rootProject.file("signing.properties")
    if (file.exists()) file.inputStream().use(::load)
}
val signingStoreFile = providers.gradleProperty("JIEKE_STORE_FILE").orNull
    ?: signingProperties.getProperty("storeFile")
val signingStorePassword = providers.gradleProperty("JIEKE_STORE_PASSWORD").orNull
    ?: signingProperties.getProperty("storePassword")
val signingKeyAlias = providers.gradleProperty("JIEKE_KEY_ALIAS").orNull
    ?: signingProperties.getProperty("keyAlias")
val signingKeyPassword = providers.gradleProperty("JIEKE_KEY_PASSWORD").orNull
    ?: signingProperties.getProperty("keyPassword")

android {
    namespace = "com.wuliuqi.quitmoment"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.wuliuqi.quitmoment"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "0.1.0"
    }

    signingConfigs {
        create("release") {
            if (!signingStoreFile.isNullOrBlank()) {
                storeFile = file(signingStoreFile)
                storePassword = signingStorePassword
                keyAlias = signingKeyAlias
                keyPassword = signingKeyPassword
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            signingConfig = signingConfigs.getByName("release")
        }
    }

    buildFeatures { compose = true; buildConfig = true }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
    packaging { resources.excludes += "/META-INF/{AL2.0,LGPL2.1}" }
}

dependencies {
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    implementation(libs.androidx.navigation.compose)
    implementation(libs.androidx.room.runtime)
    implementation(libs.androidx.room.ktx)
    ksp(libs.androidx.room.compiler)
    implementation(libs.androidx.datastore.preferences)
    implementation(libs.androidx.work.runtime.ktx)
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.ui.graphics)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.compose.material3)
    implementation(libs.androidx.compose.material.icons)
    debugImplementation(libs.androidx.compose.ui.tooling)
}
