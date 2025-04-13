#!/usr/bin/env bash

cd ./edcb
cp ./wine-mount.example.sh ./wine-mount.sh
echo 'ln -s "/mnt/hdd/" "d:"' >> ./wine-mount.sh
cp ./EDCB/Common.example.ini ./EDCB/Common.ini
cp ./EDCB/EpgDataCap_Bon.example.ini ./EDCB/EpgDataCap_Bon.ini
cp ./EDCB/EpgTimerSrv.example.ini ./EDCB/EpgTimerSrv.ini
cp ./EDCB/RecName/RecName_Macro.dll.example.ini ./EDCB/RecName/RecName_Macro.dll.ini
nano ./wine-mount.sh
cd ../