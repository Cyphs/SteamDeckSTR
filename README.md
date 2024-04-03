# SteamDeckSTR

## What is this?

This is a set of scripts based on [pikdum](https://github.com/pikdum)'s [steam-deck](https://github.com/pikdum/steam-deck) repo which is a collection of Steam Deck tools and scripts to help automate some things, starting with installing Vortex.

This version attempts to facilitate the install process specific to playing [Skyrim Together Reborn](https://www.nexusmods.com/skyrimspecialedition/mods/69993) (STR) in SteamOS on the Steam Deck. There are other ways to go about this and this might not be the best method aside from running Windows, but this aims to be a fast and simple way to enjoy Skyrim Together Reborn on your Steam Deck.

Mod Organizer 2 is my mod manager of choice on Windows, but Vortex seems more straightforward for running STR on the Deck and might be more user-friendly.

Supports only the **latest Steam version of Skyrim Special Edition** (1.6.1170) currently. Support might be added for the GOG version later. MO2 support hopefully soon.

## Install

* Before continuing, back up your Skyrim saves, make sure you've read through the official STR [Wiki](https://wiki.tiltedphoques.com/tilted-online/general-information/faq) and the [Playguide](https://wiki.tiltedphoques.com/tilted-online/general-information/playguide).
* After installing Skyrim Special Edition from Steam, [Delete all Creation Club content](https://wiki.tiltedphoques.com/tilted-online/guides/troubleshooting/disabling-the-anniversary-editions-creation-club-content) from the Data folder, as well as the 2 _ResourcePack files. Installing Vortex with the script will automatically do this for you, but you should double check. If you own the Anniversary Upgrade DLC, make sure to disable it under the DLC tab in the game's Properties on Steam. Failing to follow these steps may result in bugs and crashes during your playthrough. 
* Next, run the game normally to generate the necessary data. You can also add `SteamDeck=0 %command%` to the Launch Options under General in the Properties for the game on Steam before running to change the graphics settings. For best performance it might be a good idea to lower it down to High from Ultra. Remove the launch option afterwards.

SteamDeckSTR:

1. Right click and save as [this install.desktop link](https://raw.githubusercontent.com/Cyphs/SteamDeckSTR/tests/install.desktop)
2. Go to the Downloads folder or wherever you saved it, and double click `install.desktop` to run it

OR type this in the terminal (Konsole):

``` bash
curl https://raw.githubusercontent.com/Cyphs/SteamDeckSTR/tests/install.sh | bash -s --
```

## Vortex

After installing the SteamDeckSTR scripts, you should have a shortcut on the desktop to install Vortex. Double click it to run.

This will automatically:

1. Install SteamLinuxRuntime Sniper
2. Install [pikdum/vortex-linux](https://github.com/pikdum/vortex-linux)
3. Use ./vortex-linux to set up Vortex
4. Add a 'Skyrim Post-Deploy' shortcut to desktop
   * This will set up various things for STR and mods to run correctly when ran through Steam
5. Map J: to Internal games and K: to SD Card games in Vortex
   * E: Is the SD Card root

**This may take a few minutes!**

After installing Skyrim Together Reborn, Address Library (AE), and optionally other mods* in Vortex then running the Skyrim Post-Deploy script, you can start the game normally through Game Mode rather than launching through Vortex. SkyrimTogether.exe will replace SkyrimSELauncher.exe and SkyrimSELauncher.exe will be renamed to _SkyrimSELauncher.exe

*Other mods are not recommended for stability!

### Adding a game

* Will need to manually set the location, use either the J: or K: drives
  * J: Is internal storage games, K: Is SD Card games. It is highly recommended to use the internal storage.
* Vortex may pop up some warnings about: staging location & deployment method
   * If it does:
      * Walk through their fixes
      * Staging folder needs to be on the same drive as the game
        * Suggested path works here
      * Deployment method should be hardlinks
   * If it doesn't:
      * Go to Settings -> Mods
      * Set the **Base Path** to:
        * `K:\vortex_mods\{GAME}` if your games are on the SD Card
        * `J:\vortex_mods\{GAME}` if your games are on the internal drive
      * Press **Apply**
      * **Deployment Method** will now allow you to select `Hardlink deployment`
      * Press **Apply** again

### (Optional) Download with Vortex button link handler

It's recommended to just download the mods in the web browser manually and then drag and dropping into the Mods section of Vortex. In case you mess up or need to reinstall everything, you won't have to download them again.

If you still want the Download with Vortex button from Nexus Mods to work:

* Might work out of the box, unless you've installed Vortex before
* If it doesn't work, edit these lines in ~~`~/.local/share/applications/mimeapps.list`~~ `~/.config/mimeapps.list`
```
x-scheme-handler/nxm=vortex.desktop
x-scheme-handler/nxm-protocol=vortex.desktop
```
* Run `update-mime-database ~/.local/share/mime/`
* Might need to reboot
* If still issues, make sure your browser is using the default app

### What is the Skyrim Post Deploy shortcut?

It automates things like:

* Copying required files from Vortex's Documents folder to the game's Documents folder
  * plugins.txt, loadorder.txt, etc. for mods to be enabled
* Setting up Skyrim Together Reborn to launch through Steam when running the game normally and setting the Registry paths.

### How to open vanilla launcher to change settings afterwards

* After running skyrim-post-deploy, the game will replace the vanilla launcher (SkyrimSELauncher.exe) with the Skyrim Together Reborn executable.
* To open the vanilla Skyrim Special Edition Launcher, install protontricks and launch the underscore-prefixed launcher .exe with it. Alternatively, just temporarily rename them back. You can add `SteamDeck=0 %command%` to the Launch Options under General in the Properties for the game on Steam before running to change the graphics settings.

## Uninstall

1. Run Undo-STR on the desktop
2. Open Vortex and Stop Managing the game to remove the mods
3. Copy and paste the terminal (Konsole) commands below to get rid of SteamDeckSTR and Vortex

```bash
# remove these tools
rm -rf ~/.Cyphs/
# remove vortex
rm -rf ~/.vortex-linux/
rm -rf ~/.local/share/applications/vortex.*
# manually remove desktop icons
```
