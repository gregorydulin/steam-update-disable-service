# steam-update-disable-service
Windows service to disable Steam game auto-updates

## What is it?
--------------
A Windows Service which keeps your Steam apps from auto-updating

## How does it work?
--------------------
Every hour, it searches for Steam app config files, and modifies them, telling
Steam to not auto-update that application

## How do I install it?
-----------------------
1. [Download this codebase as a .zip file](https://github.com/gregorydulin/steam-update-disable-service/archive/main.zip)
2. Unzip it
3. Right-Click `install.bat`
4. Run as administrator

## I don't like it.  How do I uninstall it?
-------------------------------------------
1. Right-click `uninstall.bat`
2. Run as administrator

## I want to restore whatever auto-update settings were there before I installed the service
--------------------------------------------------------------------------------------------
1. Right-click `restore-from-backup.bat`
2. Run as administrator

## I think this could be better
-------------------------------
1. [Open a new issue](https://github.com/gregorydulin/steam-update-disable-service/issues/new/choose)
