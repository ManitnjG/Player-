#!/bin/bash

# Create project folders
mkdir -p Player/app/src/main/java/com/player
mkdir -p Player/app/src/main/res/layout
mkdir -p Player/.github/workflows

# settings.gradle
cat > Player/settings.gradle << 'EOF'
rootProject.name = "Player"
include ':app'
EOF

# root build.gradle
cat > Player/build.gradle << 'EOF'
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.2.0'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
EOF

# app build.gradle
cat > Player/app/build.gradle << 'EOF'
plugins {
    id 'com.android.application'
}

android {
    namespace 'com.player'
    compileSdk 34

    defaultConfig {
        applicationId "com.player"
        minSdk 23
        targetSdk 34
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            minifyEnabled false
        }
    }
}

dependencies {
    implementation 'com.google.android.exoplayer:exoplayer:2.19.1'
}
EOF

# AndroidManifest
cat > Player/app/src/main/AndroidManifest.xml << 'EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.player">

    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        android:label="Player"
        android:theme="@android:style/Theme.Material.Light">

        <activity android:name=".MainActivity">
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

    </application>

</manifest>
EOF

# MainActivity
cat > Player/app/src/main/java/com/player/MainActivity.java << 'EOF'
package com.player;

import android.net.Uri;
import android.os.Bundle;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.exoplayer2.ExoPlayer;
import com.google.android.exoplayer2.MediaItem;

public class MainActivity extends AppCompatActivity {

    ExoPlayer player;

    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        player = new ExoPlayer.Builder(this).build();

        String url = "https://tidal.squid.wtf/stream/song.flac";

        MediaItem item = MediaItem.fromUri(Uri.parse(url));
        player.setMediaItem(item);
        player.prepare();
        player.play();
    }

    protected void onDestroy() {
        super.onDestroy();
        player.release();
    }
}
EOF

# GitHub Action
cat > Player/.github/workflows/build.yml << 'EOF'
name: Build APK

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 17

      - name: Grant Permission
        run: chmod +x gradlew

      - name: Build APK
        run: ./gradlew assembleDebug
EOF

echo "Project created successfully."
