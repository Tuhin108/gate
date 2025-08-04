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
android.permissions = CAMERA,WRITE_EXTERNAL_STORAGE,READ_EXTERNAL_STORAGE
android.api = 33
android.minapi = 21
android.ndk = 23b
p4a.branch = master
android.arch = armeabi-v7a