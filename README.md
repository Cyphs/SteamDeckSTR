# Steam Deck STR

![SDSTR](https://raw.githubusercontent.com/Cyphs/SteamDeckSTR/tests/files/Steam%20Deck%20STR.png)

## What is this?

This is a set of scripts based on [pikdum](https://github.com/pikdum)'s [steam-deck](https://github.com/pikdum/steam-deck) repo which is a collection of Steam Deck tools and scripts to help automate some things, starting with installing Vortex.

SteamDeckSTR attempts to facilitate the install process specific to playing [Skyrim Together Reborn](https://www.nexusmods.com/skyrimspecialedition/mods/69993) (STR) in SteamOS on the Steam Deck. There are other ways to go about this and this might not be the best method aside from running Windows, but this aims to be a fast and simple way to enjoy Skyrim Together Reborn on your Steam Deck.

Supports only the **latest Steam version of Skyrim Special Edition** (1.7.104) and the latest Skyrim Together Reborn (1.8.2) currently.

**Important Note:** Skyrim Together only provides support for Windows on their official social media spaces (Discord, Reddit, etc.) If you have issues using this, do not ask for support there. You can [check or submit an issue here](https://github.com/Cyphs/SteamDeckSTR/issues) or message me on Discord: internalerrorx. The desktop shortcuts save their full output in `~/.Cyphs/logs/`, so attach the log from there when reporting a problem.

# Install

The scripts find Skyrim Special Edition through Steam's own library list, so it can be on the Internal storage (recommended) or an SD card, including a SteamLibrary folder added in Desktop mode.

* Before continuing, back up your Skyrim saves (just in case anything goes wrong), make sure you've read through the official STR [Wiki](https://wiki.tiltedphoques.com/tilted-online/general-information/faq) and the [Playguide](https://wiki.tiltedphoques.com/tilted-online/general-information/playguide).

* It's recommended to start with a fresh installation, so uninstall the game if currently installed first. If you own the Anniversary Upgrade DLC, make sure to [disable it under the DLC tab](https://raw.githubusercontent.com/Cyphs/SteamDeckSTR/tests/files/image.gif) in the game's Properties on Steam before installing. It is recommended to use the Internal drive for guaranteed better performance with multiplayer. If you have other Creations, be sure to [uninstall them](https://help.bethesda.net/#en/answer/36378) as well.

* After reinstalling Skyrim Special Edition from Steam, **don't run it yet**. Failing to follow these steps exactly as written may result in bugs and crashes during your playthrough!

**An installation video is also available on YouTube:**
https://www.youtube.com/watch?v=hMkb8LXlerI

## SteamDeckSTR:

1. Right click and save as [this install.desktop link](https://raw.githubusercontent.com/Cyphs/SteamDeckSTR/master/install.desktop)
2. Go to the Downloads folder or wherever you saved it, and double click `install.desktop` to run it

OR paste this in the terminal (Konsole):

``` bash
curl https://raw.githubusercontent.com/Cyphs/SteamDeckSTR/master/install.sh | bash -s --
```

## Vortex

After installing the SteamDeckSTR scripts, you should have a shortcut on the desktop to install Vortex. **Double click it to run (execute).** If you accidentally Open it, it won't run, it'll just open the script in a text editor and do nothing.

This will automatically:

1. Install [umu-launcher](https://github.com/Open-Wine-Components/umu-launcher), which runs Vortex with its own Proton (UMU-Proton)
2. Install GE-Proton10-34 and select it for Skyrim Special Edition in Steam (GE-Proton 11 closes Skyrim Together Reborn right after launch)
3. Install Vortex 2.7.0
4. Add an 'STR Post-Deploy' shortcut to desktop
5. Map J: to Internal games, and K: to the SD card library if Skyrim is installed there, in Vortex
6. Set up Vortex for Skyrim Special Edition: game folder, Steam as the game store, staging folder on the same drive, Hardlink deployment, new plugins enabled, and no automatic updates
7. [Delete all included Creation Club content](https://wiki.tiltedphoques.com/tilted-online/guides/troubleshooting/disabling-the-anniversary-editions-creation-club-content) (Survival, Fishing, etc.) to reduce bugs and crashes with STR
   * They'll be backed up to `/home/deck/.Cyphs/SteamDeckSTR-master/CC Backup/` in case you need them again, but can also be restored by verifying game files on Steam.

**This may take a few minutes! Steam will automatically restart when done if it completed properly.**

**Note:** Install Vortex turns off Vortex's automatic updates so it stays on the version these scripts were tested with (2.7.0). Newer versions may work too, but haven't been tested yet.

### Already installed SteamDeckSTR before?

Double click **Update SteamDeckSTR** on the desktop. It upgrades Vortex to 2.7.0 and switches it over to umu-launcher, installs GE-Proton10-34 and selects it for Skyrim Special Edition in Steam, keeping your Vortex mods and settings. Anything that's already up to date is skipped, and Steam only restarts if it needs to. Then update Skyrim Together Reborn and Address Library in Vortex (choose Replace when Vortex asks about the old version), and run STR Post-Deploy again. The Update window shows these steps at the end too.

## Generate the Game Data

* Install Vortex already selected GE-Proton10-34 for Skyrim Special Edition. If it isn't selected under Properties > Compatibility in Steam, check Force the use of a specific Steam Play compatibility tool and pick GE-Proton10-34 (it's at the bottom of the list).

* Run the game normally through Steam so it can generate all necessary data for it to work correctly and to synchronize your save data from Steam cloud.  

* You can start a new character now if not already done since it's recommended to create one without mods, CC content/Anniversary Upgrade DLC **removed**, and play alone until at least escaping from Helgen and exiting the cave. Creating a character with other mods or CC content and then removing them later can cause major issues, so make sure that those are removed first!

* Exit the game if running and proceed to running Vortex for the first time.

## Setting up Vortex

* Launch Vortex then find/search Skyrim Special Edition in Games to Manage it.

* Install Vortex already set the game folder, staging folder and Hardlink deployment for you, so Skyrim Special Edition switches to managed right away.
* If Vortex still asks for the game folder, use the J: drive for Internal storage games or the K: drive for SD card games, then choose **Steam** as the game store.

### Download with Vortex button

Vortex sets itself up for the Mod Manager Download button on Nexus Mods the first time it starts, so it should work. It's still recommended to download the mods manually in your web browser and drag and drop them into the Mods section of Vortex, so you won't have to download them again if you need to reinstall everything.

## Install the STR Requirements

After installing [Skyrim Together Reborn](https://www.nexusmods.com/skyrimspecialedition/mods/69993?tab=files), [Address Library](https://www.nexusmods.com/skyrimspecialedition/mods/32444?tab=files), and optionally other mods* in Vortex **then running the STR Post-Deploy script on the Desktop**, you can start the game normally through Game Mode. SkyrimTogether.exe will replace SkyrimSELauncher.exe, and the original is kept as _SkyrimSELauncher.exe so Undo STR can put it back.
Make sure you have downloaded the latest **All in One** file of Address Library (it covers 1.7.104). It's the main file on the download page for Address Library. SKSE is not required for this, despite the name.

*Other mods are not recommended for stability!
  * If you want to use Skyrim Script Extender (SKSE), just extract it to the game folder root, in the same place where SkyrimSE.exe usually is. Do not use it to start the game. Skyrim Together Reborn automatically detects and loads it. If you see "Skyrim Together is not running!" after adding SKSE, run STR Post-Deploy again, or delete skse64_loader.exe from the game folder. Please be aware that SKSE can cause bugs and possibly increase the chance of crashes. Recommended that you manually download and extract it from [their website here](https://skse.silverlock.org). Make sure you get **Current Anniversary Edition build** for the latest version of the game on Steam, even if you have just Skyrim Special Edition (look at the game version, 1.7.X, not the name!)
    * If you use a keyboard and mouse with your Steam Deck, [Auto Input Switch](https://www.nexusmods.com/skyrimspecialedition/mods/54309) lets the game switch between the controller and keyboard/mouse on the fly. It needs SKSE, so install that first, and make sure the mod supports your game version.

### STR Post-Deploy desktop shortcut

It automates things like:

* Copying plugins.txt and loadorder.txt from Vortex to the game so your mods are enabled, and making sure the Skyrim Together Reborn plugins are turned on
* Setting up Skyrim Together Reborn to launch through Steam when running the game normally and setting the Registry paths for STR to automatically locate SkyrimSE.exe
* Cleaning up files left over from older Skyrim Together Reborn versions, and fixing the launcher again after a Skyrim update
* Adding `SteamGameId=302190` to the game's Launch Options in Steam so the F3 and F4 keys work (see Currently Known Issues below). Anything else you have in Launch Options is kept, and Undo STR removes it again.
* Making sure GE-Proton starts Skyrim Together Reborn, not SKSE's loader, when SKSE is installed

**Make sure to execute this after installing the mods in Vortex, and again whenever you change your mods in Vortex.**

* To use the vanilla Skyrim Special Edition launcher (for example to change graphics settings), run Undo STR, then run STR Post-Deploy again afterwards.
* If the game doesn't start, try restarting your Steam Deck first.

### How to Play Single Player without Uninstalling Everything

* Run Undo STR
* Disable Skyrim Together Reborn in Vortex and Deploy in Vortex
* Play as usual
* (To activate Skyrim Together Reborn again: re-enable it in Vortex, Deploy if asked, and then run STR Post-Deploy on the Desktop)

## Currently Known Issues

* [SD card installs](https://github.com/Cyphs/SteamDeckSTR/issues/1) are now detected through Steam's library list, but they're less tested than the internal storage. If something doesn't work on an SD card, please report it in that issue.

* ~~Using the Steam virtual keyboard in Gaming Mode then closing it crashes the game.~~ Fixed by the latest Skyrim Special Edition update, so the Creations menu workaround is no longer needed.

* ~~The F3 (debug UI) and F4 (reveal players) keys don't work on Linux.~~ Fixed: STR Post-Deploy adds `SteamGameId=302190` to the game's Launch Options in Steam. Proton 10 hides those key presses from all but a couple of games, and this makes Proton treat Skyrim like one of them. F4 can also be done with the **Reveal Players** button in the F2 menu.
  * Other Linux setups (Vortex, Mod Organizer 2 or anything else, launched through Steam with Proton 10 or GE-Proton 10): add `SteamGameId=302190 %command%` to the Launch Options for Skyrim Special Edition. If you already have launch options, put it in front, for example `SteamGameId=302190 SteamDeck=0 %command%`.
  * Heroic, Lutris or anything else using umu-launcher: set the environment variable `GAMEID=umu-302190` instead (umu overwrites SteamGameId).

## Uninstall

1. Run Undo-STR on the desktop (This will also restore the Creation Club content to the Data folder, unless you've deleted them manually before this script did it for you.)
2. Open Vortex and Stop Managing the game to remove the mods
3. Copy and paste the terminal (Konsole) commands below to get rid of SteamDeckSTR and Vortex

```bash
# Remove SteamDeckSTR and Vortex
rm -rf ~/.Cyphs/
rm -rf ~/.vortex-linux/
rm -rf ~/.local/share/applications/vortex.*
# Manually delete desktop icons
```

Optionally, to also remove the mod staging folder Vortex made next to the game, and the Proton builds and runtime that were downloaded:

```bash
rm -rf ~/.steam/steam/steamapps/common/"Vortex Mods"
# If Skyrim is on the SD card, the staging folder is on the card instead:
rm -rf /run/media/deck/*/steamapps/common/"Vortex Mods" /run/media/deck/*/SteamLibrary/steamapps/common/"Vortex Mods"
rm -rf ~/.steam/root/compatibilitytools.d/GE-Proton10-34/
rm -rf ~/.steam/root/compatibilitytools.d/UMU-Proton-*/
rm -rf ~/.local/share/umu/
rm -f ~/.config/protonfixes/localfixes/489830.py
```
