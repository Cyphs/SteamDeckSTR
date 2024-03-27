# SteamDeckSTR

## What is this?

This is a fork of [pikdum](https://github.com/pikdum)'s [steam-deck](https://github.com/pikdum/steam-deck) repo which is a collection of Steam Deck tools and scripts to help automate some things, starting with installing Vortex.

This version attempts to simplify the process for playing [Skyrim Together Reborn](https://www.nexusmods.com/skyrimspecialedition/mods/69993) (STR) in SteamOS.

Mod Organizer 2 is my mod manager of choice in Windows, but Vortex seems less problematic for running STR on the Deck and might be more beginner-friendly.

Supports only the **latest Steam version of Skyrim Special Edition** (1.6.1170) currently. Support might be added for the GOG version later. MO2 support possibly in the future.

## Install

* Before continuing, back up your Skyrim saves, make sure you've read through the official STR [Wiki](https://wiki.tiltedphoques.com/tilted-online/general-information/faq) and the [Playguide](https://wiki.tiltedphoques.com/tilted-online/general-information/playguide).
* After installing Skyrim Special Edition on Steam, [Delete all Creation Club content](https://wiki.tiltedphoques.com/tilted-online/guides/troubleshooting/disabling-the-anniversary-editions-creation-club-content) from the Data folder, as well as the 2 _ResourcePack files. If you own the Anniversary Upgrade DLC, make sure to disable it under the DLC tab in the game's Properties on Steam. Failing to follow these steps may result in bugs and crashes during your playthrough.

1. Right click and save as [this install.desktop link](https://raw.githubusercontent.com/Cyphs/steam-deck/master/install.desktop)
2. Go to the Downloads folder, move the `install.desktop` file to the desktop, and double click to run it

OR

``` bash
curl https://raw.githubusercontent.com/Cyphs/steam-deck/master/install.sh | bash -s --
```

## Vortex

After installing, you should have a shortcut on the desktop to install Vortex.

This will:

0. Install SteamLinuxRuntime Sniper
1. Install pikdum/vortex-linux
2. Use ./vortex-linux to set up Vortex
3. Add a 'Skyrim Post-Deploy' shortcut to desktop
   * Needs to be run every time after you change mods in Vortex
4. Map J: to internal games and K: to sd card games
   * E: is the sd card root

After modding, run games normally through Game Mode rather than launching through Vortex.

### Adding a game

* Will need to manually set the location, use either the J: or K: drives
  * J: is internal storage games, K: is sd card games
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

### What is the post-deploy shortcut?

These are for games that need a bit extra to get things working after modding in Vortex

They automate things like:

* Copying required files from Vortex's Documents folder to the game's Documents folder
  * plugins.txt, loadorder.txt, etc.
* Setting up script extenders to launch through Steam

The game's post-deploy script should be ran every time after modding in Vortex.

> **Note:** If you know what you're doing, you could set up symlinks instead for this.  
> That way it only needs to be set up once, before starting modding.  

### How to open vanilla launcher to change settings afterwards

Using Skyrim as an example:

* After running post-deploy, the game will replace the vanilla launcher with the Skyrim Together Reborn executable.
* To open the vanilla Skyrim Special Edition Launcher, install protontricks and launch the underscore-prefixed launcher .exe with it

## Uninstall

```bash
# remove these tools
rm -rf ~/.Cyphs/
# remove vortex
rm -rf ~/.vortex-linux/
rm -rf ~/.local/share/applications/vortex.*
# manually remove desktop icons
```

## old version uninstall

```bash
# remove steamtinkerlaunch
rm -rf ~/stl/
rm -rf ~/.config/steamtinkerlaunch/
# remove these tools
rm -rf ~/.Cyphs/
rm -rf ~/.local/share/applications/pikdum-vortex.desktop
```
