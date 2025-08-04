[app]
title = Gate Survey App
package.name = gatesurvey
package.domain = org.gatesurvey
source.dir = .
source.include_exts = py,png,jpg,kv
source.include_patterns = assets/*
version = 1.0.0
requirements = python3,kivy==2.2.1,reportlab,plyer,android
orientation = portrait
fullscreen = 0

# Android specific
android.permissions = CAMERA,WRITE_EXTERNAL_STORAGE,READ_EXTERNAL_STORAGE
android.api = 33
android.minapi = 21
android.sdk = 33
android.ndk = 23b
android.ndk_path = 
android.sdk_path = 
android.archs = armeabi-v7a
p4a.branch = master

# Build tools
android.build_tools = 33.0.1
android.accept_sdk_license = True

[buildozer]
log_level = 2
warn_on_root = 1