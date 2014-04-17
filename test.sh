#!/bin/bash

apps=( $(ls out/system/app) )
frame=( $(ls out/system/framework/*.apk) )

for APK in "${apps[@]}"; do
    xxhdpi=( $(unzip -l out/system/app/$APK | grep -w 'drawable-xxhdpi' | cut -d "/" -f3) )
    for PNG in "${xxhdpi[@]}"; do
	zip -d out/system/app/$APK res/drawable-xhdpi/$PNG
	zip -d out/system/app/$APK res/drawable-hdpi/$PNG
    done
done

for APK in "${apps[@]}"; do
    xhdpi=( $(unzip -l out/system/app/$APK | grep -w 'drawable-xhdpi' | cut -d "/" -f3) )
    for PNG in "${xhdpi[@]}"; do
	zip -d out/system/app/$APK res/drawable-hdpi/$PNG
    done
done

for APK in "${frame[@]}"; do
    xxhdpi=( $(unzip -l $APK | grep -w 'drawable-xxhdpi' | cut -d "/" -f3) )
    for PNG in "${xxhdpi[@]}"; do
	zip -d $APK res/drawable-xhdpi/$PNG
	zip -d $APK res/drawable-hdpi/$PNG
    done
done

for APK in "${frame[@]}"; do
    xhdpi=( $(unzip -l $APK | grep -w 'drawable-xhdpi' | cut -d "/" -f3) )
    for PNG in "${xhdpi[@]}"; do
	zip -d $APK res/drawable-hdpi/$PNG
    done
done


