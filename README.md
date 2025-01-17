# Steam Deck STR

![SDSTR](https://raw.githubusercontent.com/Cyphs/SteamDeckSTR/tests/files/Steam%20Deck%20STR.png)

## What is this?

This is a set of scripts based on [pikdum](https://github.com/pikdum)'s [steam-deck](https://github.com/pikdum/steam-deck) repo which is a collection of Steam Deck tools and scripts to help automate some things, starting with installing Vortex.

SteamDeckSTR attempts to facilitate the install process specific to playing [Skyrim Together Reborn](https://www.nexusmods.com/skyrimspecialedition/mods/69993) (STR) in SteamOS on the Steam Deck. There are other ways to go about this and this might not be the best method aside from running Windows, but this aims to be a fast and simple way to enjoy Skyrim Together Reborn on your Steam Deck.

Mod Organizer 2 is my mod manager of choice on Windows, but Vortex seems more straightforward for running STR on the Deck and might be more user-friendly.

Supports only the **latest Steam version of Skyrim Special Edition** (1.6.1170) currently. Support might be added for the GOG version later. MO2 support hopefully soon.

**Important Note:** Skyrim Together only provides support for Windows on their official social media spaces (Discord, Reddit, etc.) If you have issues using this, do not ask for support there. You can [submit an issue here](https://github.com/Cyphs/SteamDeckSTR/issues/new/choose) or message me on Discord: internalerrorx

# Install

These scripts assume that the game is in the default location on either the Internal storage (recommended) or an SD card. For now, please leave it as default. This might become more interactive and configurable for other locations in the future.

* Before continuing, back up your Skyrim saves (just in case anything goes wrong), make sure you've read through the official STR [Wiki](https://wiki.tiltedphoques.com/tilted-online/general-information/faq) and the [Playguide](https://wiki.tiltedphoques.com/tilted-online/general-information/playguide).

* It's recommended to start with a fresh installation, so uninstall the game if currently installed first. If you own the Anniversary Upgrade DLC, make sure to [disable it under the DLC tab](https://raw.githubusercontent.com/Cyphs/SteamDeckSTR/tests/files/image.gif) in the game's Properties on Steam before installing. It is recommended to use the Internal drive for guaranteed better performance with multiplayer; and because SD card setups are not configured properly for this script yet. If you have other Creations, be sure to [uninstall them](https://help.bethesda.net/#en/answer/36378) as well.

* After reinstalling Skyrim Special Edition from Steam, **don't run it yet**. Failing to follow these steps exactly as written may result in bugs and crashes during your playthrough!

**An installation video is also available on YouTube:**
https://www.youtube.com/watch?v=hMkb8LXlerI

Proceed to installing SteamDeckSTR. 

## SteamDeckSTR:

1. Right click and save as [this install.desktop link](https://raw.githubusercontent.com/Cyphs/SteamDeckSTR/master/install.desktop)
2. Go to the Downloads folder or wherever you saved it, and double click `install.desktop` to run it

OR paste this in the terminal (Konsole):

``` bash
curl https://raw.githubusercontent.com/Cyphs/SteamDeckSTR/master/install.sh | bash -s --
```

## Vortex

After installing the SteamDeckSTR scripts, you should have a shortcut on the desktop to install Vortex. *Double click it to run (execute).** If you accidentally Open it, it won't run, it'll just open the script in a text editor and do nothing.

This will automatically:

1. Install SteamLinuxRuntime Sniper
2. Install [pikdum/vortex-linux](https://github.com/pikdum/vortex-linux)
3. Use ./vortex-linux to set up Vortex
4. Add an 'STR Post-Deploy' shortcut to desktop
   * This will set up various things for STR and mods to run correctly when ran through Steam
5. Map J: to Internal games ~~or K: to SD Card games~~ in Vortex
   * E: Is the SD Card root
6. [Delete all included Creation Club content](https://wiki.tiltedphoques.com/tilted-online/guides/troubleshooting/disabling-the-anniversary-editions-creation-club-content) (Survival, Fishing, etc.) to reduce bugs and crashes with STR
   * They'll be backed up to `/home/deck/.Cyphs/SteamDeckSTR-master/CC Backup/` in case you need them again, but can also be restored by verifying game files on Steam.

**This may take a few minutes! Steam will automatically restart when done if it completed properly.**

## Generate the Game Data

* After installing Vortex, **don't run it yet**. In the Steam Library: right-click on Skyrim Special Edition, go to Properties > Compatibility > Force it to use GE-Proton8-27. It may be auto-selected for you.

* Run the game normally through Steam so it can generate all necessary data for it to work correctly and to synchronize your save data from Steam cloud.  

* You can start a new character now if not already done since it's recommended to create one without mods, CC content/Anniversary Upgrade DLC **removed**, and play alone until at least escaping from Helgen and exiting the cave. Creating a character with other mods or CC content and then removing them later can cause major issues, so make sure that those are removed first!

* Exit the game if running and proceed to running Vortex for the first time.

## Setting up Vortex

* Launch Vortex then find/search Skyrim Special Edition in Games to Manage it.

* You'll need to manually set the location, use the J: drive for Internal storage games.
  * J: is internal storage games, K: is SD Card games. It is highly recommended to use the internal storage. (SD card unsupported at this time due to errors with the script.)
* Vortex may pop up some warnings about: Staging location & Deployment Method
   * When it does:
      * Walk through their fixes (Note: Skyrim Script Extender (SKSE64) is NOT required nor recommended; you may ignore that one!)
      * Staging folder needs to be on the same drive as the game
        * Suggested path works here
      * Deployment method should be Hardlinks
   * If it doesn't:
      * Go to Settings -> Mods
      * Set the **Base Path** to:
        * ~~`K:\vortex_mods\{GAME}` if your games are on the SD Card~~
        * `J:\vortex_mods\{GAME}` if your games are on the internal drive
      * Press **Apply**
      * **Deployment Method** will now allow you to select `Hardlink deployment`
      * Press **Apply** again

### (Optional) Download with Vortex button link handler

**It's recommended to just download the mods from Nexus Mods in your web browser manually and then drag and drop into the Mods section of Vortex. In case you mess up or need to reinstall everything, you won't have to download them again.**

If you still want the Download with Vortex button from Nexus Mods to work:

* Might work out of the box, unless you've installed Vortex before
* If it doesn't work, edit these lines in ~~`~/.local/share/applications/mimeapps.list`~~ `~/.config/mimeapps.list`
```
x-scheme-handler/nxm=vortex.desktop
x-scheme-handler/nxm-protocol=vortex.desktop
```
* Run `update-mime-database ~/.local/share/mime/`
* Might need to reboot
* If issues persist, make sure your browser is using the default app

## Install the STR Requirements

After installing [Skyrim Together Reborn](https://www.nexusmods.com/skyrimspecialedition/mods/69993?tab=files), [Address Library (1.6.X)](https://www.nexusmods.com/skyrimspecialedition/mods/32444?tab=files), and optionally other mods* in Vortex **then running the STR Post-Deploy script on the Desktop**, you can start the game normally through Game Mode. SkyrimTogether.exe will replace SkyrimSELauncher.exe and SkyrimSELauncher.exe will be renamed to _SkyrimSELauncher.exe in case you wish to Undo this later.
Make sure you have downloaded the latest Address Library **1.6.X**, NOT 1.5.X. It's the second file on the download page for Address Library. SKSE is not required for this, despite the name.

*Other mods are not recommended for stability!
  * If you want to use Skyrim Script Extender (SKSE), just extract it to the game folder root, in the same place where SkyrimSE.exe usually is. Do not use it to start the game. Skyrim Together Reborn should automatically detect and load it. Please be aware that SKSE can cause bugs and possibly increase the chance of crashes. Recommended that you manually download and extract it from [their website here](https://skse.silverlock.org). Make sure you get **Current Anniversary Edition build** for the latest version of the game on Steam, even if you have just Skyrim Special Edition (look at the game version, 1.6.X, not the name!)

### STR Post-Deploy desktop shortcut

It automates things like:

* Copying required files from Vortex's AppData folder to the game's AppData folder
  * plugins.txt, loadorder.txt, etc. for mods to be enabled
* Setting up Skyrim Together Reborn to launch through Steam when running the game normally and setting the Registry paths for STR to automatically locate SkyrimSE.exe

**Make sure to execute this after installing the mods in Vortex.**

* After running STR Post-Deploy, the game will replace the vanilla launcher (SkyrimSELauncher.exe) with the Skyrim Together Reborn executable.
* (***Optional***): If you need to open the vanilla Skyrim Special Edition Launcher, install protontricks and launch the underscore-prefixed launcher .exe with it. Alternatively, just temporarily rename them back. You can add `SteamDeck=0 %command%` to the Launch Options under General in the Properties for the game on Steam before running to change the graphics settings, but note that this command causes issues with the virtual keyboard from working, and the settings don't persist when removing it because the game has its own Steam Deck-specific configuration (Steam Deck verified btw...)
* If the game doesn't start, try restarting your Steam Deck first.

### How to Play Single Player without Uninstalling Everything

* Run Undo STR
* Disable Skyrim Together Reborn in Vortex and Deploy in Vortex
* Play as usual
* (To activate Skyrim Together Reborn again: re-enable it in Vortex, Deploy if asked, and then run STR Post-Deploy on the Desktop)

## Currently Known Issues

* [This is not configured properly when installed to an SD card.](https://github.com/Cyphs/SteamDeckSTR/issues/1) Install the game on internal storage until resolved at a later time.

* Using the Steam virtual keyboard in Gaming Mode then closing it crashes the game. This may prevent you from using the text chat without an external keyboard connected. You might also need an external keyboard or remote desktop program at least once to enter a private server's IP address. It should be saved in the UI the next time it's launched.
  * Apparently, this happens with the game on the Steam Deck in general, not just with Skyrim Together Reborn. I've found a temporary solution until there's a real fix. Each time you play, open the Creations menu before loading your save and press LB to search. Close it, then load your save. The virtual keyboard won't crash now until next restart. Make sure `SteamDeck=0 %command%` is **removed** from Steam Launch Options or this won't work! Video: https://youtu.be/Km5ZJ2fAzC8

* The F3 key for the debug UI overlay does not work. This may prevent you from using things like the quest debugger as the Party Leader to advance through bugged quests.
* The F4 key, for revealing other players with the glow effect, similarly does not work in Linux by default.

## Uninstall

1. Run Undo-STR on the desktop (This will also restore the Creation Club content to the Data folder, unless you've deleted them manually before this script did it for you.)
2. Open Vortex and Stop Managing the game to remove the mods
3. Copy and paste the terminal (Konsole) commands below to get rid of SteamDeckSTR and Vortex

```bash
# Remove SteamDeckSTR and Vortex 
rm -rf ~/.Cyphs/
# remove vortex
rm -rf ~/.vortex-linux/
rm -rf ~/.local/share/applications/vortex.*
# Manually delete desktop icons
```
