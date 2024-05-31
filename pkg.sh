#!/bin/sh
if [ -d XBLA_Survival ]; then rm -r XBLA_Survival; fi
if [ -f XBLA_Survival.zip ]; then rm XBLA_Survival.zip; fi
mkdir XBLA_Survival
cp pkg-readme.txt XBLA_Survival/"Read Me.txt"

plugindir=XBLA_Survival/"XBLA Survival plugin"
mkdir "$plugindir"
cp pkg-readme.txt "$plugindir/Read Me.txt"
cp Aleph_One_Previous_AI.mml "$plugindir/Aleph_One_Previous_AI.mml"
cp Plugin.xml "$plugindir/Plugin.xml"
cp XBLA_Survival.lua "$plugindir/XBLA_Survival.lua"

mkdir XBLA_Survival/map
for rawdir in map/*; do
  mkdir XBLA_Survival/"$rawdir"
  cp "$rawdir"/*.sceA Aleph_One_Previous_AI.mml XBLA_Survival.lua XBLA_Survival/"$rawdir"
done
atquem XBLA_Survival/map XBLA_Survival/"XBLA Survival.sceA"
rm -r XBLA_Survival/map

zip -r -X XBLA_Survival.zip XBLA_Survival
rm -r XBLA_Survival
