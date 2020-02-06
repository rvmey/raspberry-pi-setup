@echo off
cls
echo Before you continue, format your micro SD card with "SD Memory Card Formatter" found here: 
echo https://www.sdcard.org/downloads/formatter
pause
set script_folder=%~dp0
set /p sdcard="Enter the drive letter of your SD card: "
IF "%sdcard%"=="" goto end

set /p ssid="Enter the wifi (SSID) or press enter to use a wired Ethernet connection: "
IF "%ssid%"=="" goto skipwifi
set /p wifi_pw="Enter the wifi password: "
echo ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev > %script_folder%wpa_supplicant.conf
echo update_config=1 >> %script_folder%wpa_supplicant.conf
echo country=US >> %script_folder%wpa_supplicant.conf
echo network={ >> %script_folder%wpa_supplicant.conf
echo     ssid="%ssid%" >> %script_folder%wpa_supplicant.conf
echo     key_mgmt=WPA-PSK >> %script_folder%wpa_supplicant.conf
echo     psk="%wifi_pw%" >> %script_folder%wpa_supplicant.conf
echo } >> %script_folder%wpa_supplicant.conf
:skipwifi

set pipass=raspberry
set /p pipass="Enter a password for the pi user, or press enter for the default (%pipass%): "

set /p token="Enter your TRIGGERcmd token: "

if not exist cache mkdir cache

cls
echo In 5 seconds, this script will download any prerequisites that haven't already been downloaded, and copy files to your SD card.
timeout 5

set file=tcmd_rpi_files.exe
bitsadmin /transfer %file% /download /priority normal "https://triggercmdagents.s3.amazonaws.com/raspberrypi/%file%" "%script_folder%cache\%file%"
cache\%file% -o"%script_folder%cache" -y

set file=pinn-lite.zip
if not exist cache\%file% bitsadmin /transfer %file% /download /priority normal "https://gigenet.dl.sourceforge.net/project/pinn/%file%" "%script_folder%cache\%file%"
rem mkdir "%script_folder%cache\pinn-lite"
if not exist cache\pinn-lite cache\7-Zip\7z.exe x cache\%file% -o"%script_folder%cache\pinn-lite"
xcopy /y /s cache\pinn-lite\*.* %sdcard%:\

REM Copy the sdfiles after pinn-lite because files like recovery.cmdline conflict, and you want the one in sdfiles.
xcopy /y /s cache\sdfiles\*.* %sdcard%:\

if not exist cache\Raspbian mkdir cache\Raspbian

set file=boot.tar.xz
if not exist cache\Raspbian\%file% bitsadmin /transfer %file% /download /priority normal "https://downloads.raspberrypi.org/raspbian_lite/%file%" "%script_folder%cache\Raspbian\%file%"
copy /y cache\Raspbian\%file% %sdcard%:\os\Raspbian\%file%

set file=partitions.json
if not exist cache\Raspbian\%file% bitsadmin /transfer %file% /download /priority normal "https://downloads.raspberrypi.org/raspbian_lite/%file%" "%script_folder%cache\Raspbian\%file%"
copy /y cache\Raspbian\%file% %sdcard%:\os\Raspbian\%file%

set file=root.tar.xz
if not exist cache\Raspbian\%file% bitsadmin /transfer %file% /download /priority normal "https://downloads.raspberrypi.org/raspbian_lite/%file%" "%script_folder%cache\Raspbian\%file%"
copy /y cache\Raspbian\%file% %sdcard%:\os\Raspbian\%file%

IF not "%ssid%"=="" copy /y %script_folder%wpa_supplicant.conf %sdcard%:\
del %script_folder%wpa_supplicant.conf

echo %token% > %sdcard%:\os\Raspbian\token.tkn
echo %pipass% > %sdcard%:\os\Raspbian\pipass

cls
echo Ready.  Now eject the %sdcard% drive SD card, put it in the Raspberry Pi, and boot it.
pause

:end