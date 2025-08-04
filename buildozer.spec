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
osx.python_version = 3
osx.kivy_version = 2.2.1
fullscreen = 0

# Android specific
android.permissions = CAMERA,WRITE_EXTERNAL_STORAGE,READ_EXTERNAL_STORAGE
android.api = 33
android.minapi = 21
android.sdk = 24
android.ndk = 23b
android.archs = armeabi-v7a
p4a.branch = master

# Buildozer config
[buildozer]
log_level = 2
warn_on_root = 1