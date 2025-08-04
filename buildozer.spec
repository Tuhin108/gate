[app]
title = Gate Survey App
package.name = gatesurvey
package.domain = org.gatesurvey
source.dir = .
source.include_exts = py,png,jpg,kv
source.include_patterns = assets/*
version = 1.0.0
requirements = python3,kivy==2.3.0,reportlab,plyer,android
orientation = portrait
fullscreen = 0

# Android specific
android.permissions = CAMERA,WRITE_EXTERNAL_STORAGE,READ_EXTERNAL_STORAGE
android.api = 34
android.minapi = 21
android.ndk = 25b
android.sdk = 34
android.archs = arm64-v8a,armeabi-v7a
p4a.branch = master

# Build tools
android.build_tools = 34.0.0
android.accept_sdk_license = True

[buildozer]
log_level = 2
warn_on_root = 1
env = REPORTLAB_RTL_EXTENSIONS=0  # ADD THIS LINE