# SteamDeckSTR

## What is this?

This is a fork of [pikdum](https://github.com/pikdum)'s [steam-deck](https://github.com/pikdum/steam-deck) repo which is a collection of Steam Deck tools and scripts to help automate some things, starting with installing Vortex.

This version attempts to simplify the process for playing [Skyrim Together Reborn](https://www.nexusmods.com/skyrimspecialedition/mods/69993) (STR) in SteamOS. There are other ways to go about this and this might not be the best method, but this aims to be a fast and simple way to enjoy Skyrim Together Reborn on your Steam Deck.

Mod Organizer 2 is my mod manager of choice on Windows, but Vortex seems less problematic for running STR on the Deck and might be more beginner-friendly.

Supports only the **latest Steam version of Skyrim Special Edition** (1.6.1170) currently. Support might be added for the GOG version later. MO2 support hopefully soon.

## Status: WIP
* Works for quickly setting up and playing STR. Need to fix symlinks and permissions later. I'm a bit of a noob so suggestions are welcome.

## Install

* Before continuing, back up your Skyrim saves, make sure you've read through the official STR [Wiki](https://wiki.tiltedphoques.com/tilted-online/general-information/faq) and the [Playguide](https://wiki.tiltedphoques.com/tilted-online/general-information/playguide).
* After installing Skyrim Special Edition from Steam, [Delete all Creation Club content](https://wiki.tiltedphoques.com/tilted-online/guides/troubleshooting/disabling-the-anniversary-editions-creation-club-content) from the Data folder, as well as the 2 _ResourcePack files. If you own the Anniversary Upgrade DLC, make sure to disable it under the DLC tab in the game's Properties on Steam. Failing to follow these steps may result in bugs and crashes during your playthrough.
* Install ProtonUp-Qt from the Discover app (Software Center) and use it to install the latest GE-Proton (9-2). then restart Steam. In the Properties for the game, go to Compatibility and force it to use that version. This will prevent crashes. If you know a different Proton version works better, you can try it instead.
* Run the game normally to generate the necessary data. You can also add `SteamDeck=0 %command%` to the Launch Options under General in the Properties for the game on Steam before running to change the graphics settings. For best performance it might be a good idea to lower it down to High from Ultra. Remove the launch option afterwards.

This script will need to run some commands as sudo to make sure it has the necessary permissions to set everything properly. Always use caution when running things as sudo, but this is safe. 
1. Open the terminal (Konsole) and type `passwd` to set a password for running things as sudo. Keep this password safe, you might need it for other things eventually!
2. Right click and save as [this install.desktop link](https://raw.githubusercontent.com/Cyphs/SteamDeckSTR/master/install.desktop)
3. Go to the Downloads folder, move the `install.desktop` file to the desktop, and double click to run it

OR type this in the terminal (Konsole):

``` bash
curl https://raw.githubusercontent.com/Cyphs/SteamDeckSTR/master/install.sh | bash -s --
```

## Vortex

After installing, you should have a shortcut on the desktop to install Vortex.

This will:

0. Install SteamLinuxRuntime Sniper
1. Install [pikdum/vortex-linux](https://github.com/pikdum/vortex-linux)
2. Use ./vortex-linux to set up Vortex
3. Add a 'Skyrim Post-Deploy' shortcut to desktop
   * Needs to be run every time after you change mods in Vortex
4. Map J: to internal games and K: to sd card games
   * E: is the sd card root

**This may take a few minutes!**

After installing Skyrim Together Reborn, Address Library (AE), and optionally other mods in Vortex then running the Skyrim Post-Deploy, you can start the game normally through Game Mode rather than launching through Vortex. Symbolic links from the SkyrimTogetherReborn folder will enter the main install folder. SkyrimTogether.exe will replace SkyrimSELauncher.exe and SkyrimSELauncher.exe will be renamed to _SkyrimSELauncher.exe

### Adding a game

* Will need to manually set the location, use either the J: or K: drives
  * J: is internal storage games, K: is sd card games. It is highly recommended to use the internal storage.
* Vortex may pop up some warnings about: staging location, deployment method
   * If it does:
      * walk through their fixes
      * staging folder needs to be on the same drive as the game
        * suggested path works here
      * deployment method should be hardlinks
   * If it doesn't:
      * go to Settings -> Mods
      * set the **Base Path** to:
        * `K:\vortex_mods\{GAME}` if your games are on the sd card
        * `J:\vortex_mods\{GAME}` if your games are on the internal drive
      * Press **Apply**
      * **Deployment Method** will now allow you to select `Hardlink deployment`
      * Press **Apply** again

### Download with Vortex button link handler

* Might work out of the box, unless you've installed Vortex before
* If it doesn't work, edit these lines in ~~`~/.local/share/applications/mimeapps.list`~~ `~/.config/mimeapps.list`
```
x-scheme-handler/nxm=vortex.desktop
x-scheme-handler/nxm-protocol=vortex.desktop
```
* Run `update-mime-database ~/.local/share/mime/`
* Might need to reboot
* If still issues, make sure your browser is using the default app

I recommend just downloading the mods in the web browser manually and then dragging and dropping into the Mods section of Vortex. In case you mess up or need to reinstall everything, you won't have to download them again.
### What is the post-deploy shortcut?

These are for games that need a bit extra to get things working after modding in Vortex

They automate things like:

* Copying required files from Vortex's Documents folder to the game's Documents folder
  * plugins.txt, loadorder.txt, etc.
* Setting up SkyrimTogether to launch through Steam when running the game normally.

The game's post-deploy script should be ran every time after modding in Vortex.

> **Note:** If you know what you're doing, you could set up symlinks instead for this.  
> That way it only needs to be set up once, before starting modding.  

### How to open vanilla launcher to change settings afterwards

* After running post-deploy, the game will replace the vanilla launcher with the Skyrim Together Reborn executable.
* To open the vanilla Skyrim Special Edition Launcher, install protontricks and launch the underscore-prefixed launcher .exe with it. Alternatively, just temporarily rename them back. You can add `SteamDeck=0 %command%` to the Launch Options under General in the Properties for the game on Steam before running to change the graphics settings.

## Uninstall

* Run Undo-STR on the desktop
* Open Vortex and Stop Managing the game to remove the mods
* Use the terminal commands below to get rid of SteamDeckSTR and Vortex

```bash
# remove these tools
rm -rf ~/.Cyphs/
# remove vortex
rm -rf ~/.vortex-linux/
rm -rf ~/.local/share/applications/vortex.*
# manually remove desktop icons
```
