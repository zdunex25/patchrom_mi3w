#!/bin/bash
x=`date +%Y`
y=`date +.%-m.%-d`
z=${x: -1:1}
version=$z$y
GIT_APPLY=../../tools/git.apply

cd ..
. build/envsetup.sh -p mi3w
cd mi3w
unzip -q MIUIPolska_cancro_$version\_kk-4.4.zip -d out

'../tools/apktool' if 'out/system/framework/framework-res.apk'
'../tools/apktool' if 'out/system/framework/framework-miui-res.apk'

echo -e "\nPreparing frameworks.."

mkdir -p temp/tosign
cd temp

cp ../framework2/DrmManager.patch DrmManager.patch
cp ../framework2/IconCustomizer.patch IconCustomizer.patch
'../../tools/apktool' --quiet d -f '../out/system/framework/framework2.jar'
$GIT_APPLY DrmManager.patch
for file in `find $2 -name *.rej`
do
    echo "$file patch failed"
    exit 1
done
$GIT_APPLY IconCustomizer.patch
for file in `find $2 -name *.rej`
do
    echo "$file patch failed"
    exit 1
done
'../../tools/apktool' --quiet b -f 'framework2.jar.out' 'framework2.jar'
mkdir ext
unzip -j -q 'framework2.jar' classes.dex -d 'ext'
cd ext
zip '../../out/system/framework/framework2.jar' -q 'classes.dex'
cd ..

if [ ! -f ../out/system/app/m7Parts.apk ]; then
echo -e "\nPreparing statusbar layout mod.."

cp ../MiuiSystemUI/MiuiSystemUI.patch MiuiSystemUI.patch
'../../tools/apktool' --quiet d -f '../out/system/priv-app/MiuiSystemUI.apk'
cp -r ../MiuiSystemUI/res/layout/* MiuiSystemUI/res/layout
$GIT_APPLY MiuiSystemUI.patch
for file in `find $2 -name *.rej`
do
    echo "$file patch failed"
    exit 1
done
'../../tools/apktool' --quiet b -f 'MiuiSystemUI' 'patched-MiuiSystemUI.apk'
mkdir -p ui/res/layout
mkdir ui/res/xml
unzip -j -q 'patched-MiuiSystemUI.apk' classes.dex -d 'ui'
unzip -j -q 'patched-MiuiSystemUI.apk' resources.arsc -d 'ui'
cd ui/res
unzip -j -q '../../patched-MiuiSystemUI.apk' res/xml/advanced_settings.xml -d 'xml'
unzip -j -q '../../patched-MiuiSystemUI.apk' res/layout/signal_cluster_view_ios.xml -d 'layout'
unzip -j -q '../../patched-MiuiSystemUI.apk' res/layout/status_bar_center.xml -d 'layout'
unzip -j -q '../../patched-MiuiSystemUI.apk' res/layout/status_bar_ios.xml -d 'layout'
unzip -j -q '../../patched-MiuiSystemUI.apk' res/layout/status_bar_simple.xml -d 'layout'
unzip -j -q '../../patched-MiuiSystemUI.apk' res/layout/super_status_bar_center.xml -d 'layout'
unzip -j -q '../../patched-MiuiSystemUI.apk' res/layout/super_status_bar_ios.xml -d 'layout'
cd ..
zip '../../out/system/priv-app/MiuiSystemUI.apk' -q 'classes.dex'
zip '../../out/system/priv-app/MiuiSystemUI.apk' -q 'resources.arsc'
zip '../../out/system/priv-app/MiuiSystemUI.apk' -q -r 'res'
cd ..
cp -f ../other/m7Parts.apk ../out/system/app/m7Parts.apk
fi

#echo -e "\nPreparing miui searchbox fix.."
#
#cp ../QuickSearchBox/QuickSearchBox.patch QuickSearchBox.patch
#'../../tools/apktool' --quiet d -f '../out/system/priv-app/QuickSearchBox.apk'
#$GIT_APPLY QuickSearchBox.patch
#for file in `find $2 -name *.rej`
#do
#    echo "$file patch failed"
#    exit 1
#done
#'../../tools/apktool' --quiet b -f 'QuickSearchBox' 'patched-QuickSearchBox.apk'
#mkdir gp
#unzip -j -q 'patched-QuickSearchBox.apk' classes.dex -d 'gp'
#cd gp
#zip '../../out/system/priv-app/QuickSearchBox.apk' -q 'classes.dex'
#cd ..
#
echo -e "\nPreparing strip unicode mod.."

cp ../Mms/Mms.patch Mms.patch
'../../tools/apktool' --quiet d -f '../out/system/priv-app/Mms.apk'
cp -r ../Mms/theos0o Mms/smali/com/android/mms/
$GIT_APPLY Mms.patch
for file in `find $2 -name *.rej`
do
    echo "$file patch failed"
    exit 1
done
'../../tools/apktool' --quiet b -f 'Mms' 'Mms.apk'

#echo -e "\nPreparing secutiry notification mod.."
#
#'../../tools/apktool' --quiet d -f '../out/system/priv-app/Settings.apk'
#cp -r ../Settings/res/layout/* Settings/res/layout
#'../../tools/apktool' --quiet b -f 'Settings' 'patched-Settings.apk'
#mkdir -p nf/res/layout
#mkdir -p nf/res/drawable-pl-xxhdpi
#cd nf/res
#unzip -j -q '../../patched-Settings.apk' res/layout/m_notification_remoteview.xml -d 'layout'
#cp -r '../../../Settings/res/drawable-pl-xxhdpi/*' 'drawable-pl-xxhdpi'
#cd ..
#zip '../../out/system/priv-app/Settings.apk' -q -r 'res'
#cd ..
#
echo -e "\nPreparing theme mod.."

cp ../ThemeManager/ThemeManager.patch ThemeManager.patch
'../../tools/apktool' --quiet d -f '../out/system/app/ThemeManager.apk'
$GIT_APPLY ThemeManager.patch
for file in `find $2 -name *.rej`
do
    echo "$file patch failed"
    exit 1
done
'../../tools/apktool' --quiet b -f 'ThemeManager' 'patched-ThemeManager.apk'
mkdir mc
unzip -j -q 'patched-ThemeManager.apk' classes.dex -d 'mc'
cd mc
zip '../../out/system/app/ThemeManager.apk' -q 'classes.dex'
cd ..

#'../../tools/apktool' --quiet d -f '../../miui/XXHDPI/system/app/Weather.apk'
#cp -u -r ../../miuipolska/Polish/main/Weather.apk/* Weather
#'../../tools/apktool' --quiet b -f 'Weather' 'Weather.apk'

java -jar "$PORT_ROOT/tools/signapk.jar" "$PORT_ROOT/build/security/platform.x509.pem" "$PORT_ROOT/build/security/platform.pk8" "Mms.apk" "signed-Mms.apk"
'../other/zipalign' -f 4 "signed-Mms.apk" "zipaligned-signed-Mms.apk"
#java -jar "$PORT_ROOT/tools/signapk.jar" "$PORT_ROOT/build/security/platform.x509.pem" "$PORT_ROOT/build/security/platform.pk8" "Weather.apk" "signed-Weather.apk"
#'../other/zipalign' -f 4 "signed-Weather.apk" "zipaligned-signed-Weather.apk"
cd ..

mv -f temp/zipaligned-signed-Mms.apk out/system/priv-app/Mms.apk
#mv -f temp/zipaligned-signed-Weather.apk out/system/app/Weather.apk

echo -e "\nPreparing icon mods.."

#cp -f other/ThemeManager.apk out/system/app/ThemeManager.apk
cp -f other/icons out/system/media/theme/default/icons
#cp -f other/miui_mod_icons/*.png out/system/media/theme/miui_mod_icons/

#echo -e "\nReplacing WeatherBZ with MIUI Weather.."
#
#rm -f out/system/app/FancyWeatherIconsTheme.apk
#rm -f out/system/app/pro.burgerz.weather*.apk
#rm -f out/system/app/WeatherDummy.apk
#

echo -e "\nRemoving Xperia keyboard.."
rm -f out/system/app/XperiaKeyboard.apk
rm -rf out/system/usr/xt9

echo -e "\nRemoving live wallpaper examples.."
rm -f out/system/app/BasicDreams.apk
rm -f out/system/app/HoloSpiralWallpaper.apk
rm -f out/system/app/MagicSmokeWallpapers.apk
rm -f out/system/app/PhaseBeam.apk

echo -e "\nInit app_process for WSM.."
mv out/system/bin/app_process out/system/bin/app_process.orig
cp other/app_process_xposed_sdk16 out/system/bin/app_process

rm -r temp

cd out
rm META-INF/CERT.RSA
rm META-INF/CERT.SF
rm META-INF/MANIFEST.MF

echo -e "\nCreating flashable rom.."

zip -q -r "../tosign-MIUIPolska_cancro_$version-4.4-z25.zip" "data" "META-INF" "recovery" "system" "boot.img" "emmc_appsboot.mbn" "file_contexts" "NON-HLOS.bin" "rpm.mbn" "sbl1.mbn" "sdi.mbn" "tz.mbn"
cd ..
rm -r out

echo -e "\nSigning rom.."

java -Xmx2048m -jar "$PORT_ROOT/tools/signapk.jar" -w "$PORT_ROOT/build/security/testkey.x509.pem" "$PORT_ROOT/build/security/testkey.pk8" "tosign-MIUIPolska_cancro_$version-4.4-z25.zip" "MIUIPolska_cancro_$version-4.4-z25.zip"
rm "tosign-MIUIPolska_cancro_$version-4.4-z25.zip"
echo -e "\n"

grep -v 'aapt: warning: string*' 'miui_log.log' >> 'miui_log_mi3w.log'
rm miui_log.log

read -p "Done, MIUIPolska_cancro_$version-4.4-z25.zip has been created in root of mi3w directory, copy to sd and flash it!"
