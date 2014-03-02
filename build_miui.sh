#!/bin/bash
x=`date +%Y`
y=`date +.%-m.%-d`
z=${x: -1:1}
version=$z$y
GIT_APPLY=../../tools/git.apply
export PATH=$PATH:/home/$USER/android-sdk-linux/tools:/home/$USER/android-sdk-linux/platform-tools

cd ..
. build/envsetup.sh -p mi3w
cd mi3w
unzip -q MIUIPolska_cancro_$version-4.3.zip -d out

echo -e "\nPreparing frameworks.."

mkdir -p temp/tosign
cd temp

cp ../framework_ext/framework_ext.patch framework_ext.patch
'../../tools/apktool' --quiet d -f '../out/system/framework/framework_ext.jar'
$GIT_APPLY framework_ext.patch
for file in `find $2 -name *.rej`
do
    echo "$file patch failed"
    exit 1
done
'../../tools/apktool' --quiet b -f 'framework_ext.jar.out' 'framework_ext.jar'
mkdir ext
unzip -j -q 'framework_ext.jar' classes.dex -d 'ext'
cd ext
zip '../../out/system/framework/framework_ext.jar' -q 'classes.dex'
cd ..

echo -e "\nPreparing statusbar layout mod.."

cp ../MiuiSystemUI/MiuiSystemUI.patch MiuiSystemUI.patch
'../../tools/apktool' --quiet d -f '../out/system/app/MiuiSystemUI.apk'
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
zip '../../out/system/app/MiuiSystemUI.apk' -q 'classes.dex'
zip '../../out/system/app/MiuiSystemUI.apk' -q 'resources.arsc'
zip '../../out/system/app/MiuiSystemUI.apk' -q -r 'res'
cd ..

echo -e "\nPreparing strip unicode mod.."

cp ../Mms/Mms.patch Mms.patch
'../../tools/apktool' --quiet d -f '../out/system/app/Mms.apk'
cp -r ../Mms/theos0o Mms/smali/com/android/mms/
$GIT_APPLY Mms.patch
for file in `find $2 -name *.rej`
do
    echo "$file patch failed"
    exit 1
done
'../../tools/apktool' --quiet b -f 'Mms' 'Mms.apk'

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

'../../tools/apktool' --quiet d -f '../../miui/XXHDPI/system/app/Weather.apk'
cp -u -r ../../miuipolska/Polish/main/Weather.apk/* Weather
'../../tools/apktool' --quiet b -f 'Weather' 'Weather.apk'

java -jar '/home/z25/patchromv542/mi3w/other/signapk.jar' '/home/z25/patchromv542/mi3w/other/platform.x509.pem' '/home/z25/patchromv542/mi3w/other/platform.pk8' "Mms.apk" "signed-Mms.apk"
'../other/zipalign' -f 4 "signed-Mms.apk" "zipaligned-signed-Mms.apk"
java -jar '/home/z25/patchromv542/mi3w/other/signapk.jar' '/home/z25/patchromv542/mi3w/other/platform.x509.pem' '/home/z25/patchromv542/mi3w/other/platform.pk8' "Weather.apk" "signed-Weather.apk"
'../other/zipalign' -f 4 "signed-Weather.apk" "zipaligned-signed-Weather.apk"
cd ..

mv -f temp/zipaligned-signed-Mms.apk out/system/app/Mms.apk
mv -f temp/zipaligned-signed-Weather.apk out/system/app/Weather.apk

echo -e "\nPreparing icon mods.."

#cp -f other/ThemeManager.apk out/system/app/ThemeManager.apk
cp -f other/m7Parts.apk out/system/app/m7Parts.apk
cp -f other/icons out/system/media/theme/default/icons
cp -f other/miui_mod_icons/*.png out/system/media/theme/miui_mod_icons/

echo -e "\nReplacing WeatherBZ with MIUI Weather.."

rm -f out/system/app/pro.burgerz.weather_v4.9.9.beta21.apk
rm -f out/system/app/WeatherDummy.apk
rm -r temp

cd out
rm META-INF/CERT.RSA
rm META-INF/CERT.SF
rm META-INF/MANIFEST.MF

echo -e "\nCreating flashable rom.."

zip -q -r "../tosign-MIUIPolska_cancro-$version-4.3-z25.zip" "data" "META-INF" "recovery" "system" "boot.img" "emmc_appsboot.mbn" "file_contexts" "NON-HLOS.bin" "rpm.mbn" "sbl1.mbn" "sdi.mbn" "tz.mbn"
cd ..
rm -r out

echo -e "\nSigning rom.."

java -jar '/home/z25/patchromv542/mi3w/other/signapk.jar' '/home/z25/patchromv542/mi3w/other/testkey.x509.pem' '/home/z25/patchromv542/mi3w/other/testkey.pk8' "tosign-MIUIPolska_cancro-$version-4.3-z25.zip" "MIUIPolska_cancro-$version-4.3-z25.zip"
rm "tosign-MIUIPolska_cancro-$version-4.3-z25.zip"
echo -e "\n"
read -p "Done, MIUIPolska_cancro-$version-4.3-z25.zip has been created in root of mi3w directory, copy to sd and flash it!"
