XBLA Survival 2.1
-----------------
maps and gameplay by Freeverse
coding by Hopper

----------------------------------------------------------------
DESCRIPTION:

This package includes the four Survival maps and gameplay mode from the XBox Live Arcade port of Durandal. It also includes a plugin for playing Survival on any M2 or Infinity netmap. You do not need the plugin to play on the XBLA maps.

Maps: These maps were made by Freeverse specifically for the XBLA release. They have embedded scripts for a solo Survival game. The scripts should not interfere with EMFH or other multiplayer net games.

Plugin: Play solo on any M2 or Infinity netmap and beat your high score. Can you make it to Round 10? On Total Carnage? With your eyes closed?

Like the XBLA original, the plugin is solo only. For a similar co-op experience, see:

  http://simplici7y.com/items/survival-lua

----------------------------------------------------------------
COMPATIBILITY:

Marathon Infinity - Compatible
Marathon 2: Durandal - Compatible
Marathon - Not compatible
Other Aleph One scenarios - Plugin compatible if stock monsters are used

----------------------------------------------------------------
REQUIREMENTS:

- Aleph One 1.1 (release 2014-01-04) or later

----------------------------------------------------------------
HOW TO USE THE MAPS:

- Drag the "XBLA Survival.sceA" file into your Marathon 2 or Marathon Infinity scenario folder. For the most authentic experience, play in Marathon 2 with HD monsters, textures, and weapons enabled.
- Launch Aleph One, and go to "Preferences", then "Environment". Click on "Map" and select "XBLA Survival".
- For solo Survival games, use the level-select code (Ctrl+Shift+N) to pick a map to play on. Your current score and survival time are displayed at the top of the screen.
- For net games, gather like usual. Since the maps were built for solo play, they do not have a hill or ball.

----------------------------------------------------------------
HOW TO USE THE PLUGIN:

- Drag the "XBLA Survival plugin.zip" file into the "Plugins" folder inside your Marathon 2 or Marathon Infinity scenario folder. (Create a "Plugins" folder if you don't already have one.)
- Launch Aleph One, and go to "Preferences", then "Environment", then "Plugins" make sure the plugin is listed as "Enabled". You can click on it to turn it on or off.
- Use the level-select code (Ctrl+Shift+N) to pick a map to play on. Smaller netmaps are the most fun choices. Your current score and survival time are displayed at the top of the screen.

NOTE: Other solo Lua plugins or scripts, including Cheats.lua, MUST be disabled or XBLA Survival will not work.

----------------------------------------------------------------
CHANGELOG:

v2.1:
* Films should no longer go out of sync
  (thanks to treellama and Captain-Fwiffo)

v2.0:
* Now includes the original Freeverse maps!

v1.0.2:
* Avoid spawning monsters where they'll get stuck

v1.0.1:
* Monster spawning is more faithful to XBLA version
* Prevents groups of sullen, stationary aliens

v1.0:
* Initial version

----------------------------------------------------------------
SPECIAL THANKS:

Bruce Morrison - for making this possible
treellama - for adding the necessary Lua APIs

----------------------------------------------------------------
CONTACT:

If you have any questions, comments or bugs to report, you can email me:
- hopper@whpress.com
