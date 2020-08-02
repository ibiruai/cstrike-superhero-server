---
layout: default
language: en
---

English \| [Русский](../ru/index.html)
{: .languages }

# Evileye.eu.org SuperHero Server

Evileye.eu.org SuperHero Server is a CS 1.6 server with SuperHero mod.

Server address: **95.142.47.100:27015**

Сonnect to the server with **connect 95.142.47.100:27015** in your game console or [join via Steam](steam://connect/95.142.47.100:27015).

Git: <https://github.com/ibiruai/cstrike-superhero-server>

## News

02 Feb 2019 - The server was launched. English and Russian languages are available.

## Server status

[![Current server status](https://cache.gametracker.com/server_info/95.142.47.100:27015/b_560_95_1.png)](https://www.gametracker.com/server_info/95.142.47.100:27015/){: .gametracker }

## SuperHero Mod Help

As you kill opponents you gain Experience Points (XP). The higher the level of the person you kill the more XP you get. Once you have accumulated enough for a level up you will be able to choose a hero. The starting point is level 0 and you cannot select any heroes on this level.

Contents:

1. [Say commands](#say-commands)
2. [How to use powers?](#how-to-use-powers)
3. [List of powers](#list-of-powers)

### Say commands

Press \[ **I** \] or say **/shmenu** to open the main menu. Most of things below are available from the main menu, so there is no need to remember any of those say commands.

say /help | This help page
say /showmenu | Displays Select Super Power menu
say /herolist | Lets you see [a list of heroes and powers](#list-of-powers) (you can also use \"herolist\" in the console)
say /myheroes | Displays your heroes
say /clearpowers | Clears ALL powers
say /drop \<hero\> | Drop one power so you can pick another
say /whohas \<hero\> | Shows you who has a particular hero
say /playerskills \[@ALL\|@CT\|@T\|name\] | Shows you what heroes other players have chosen
say /playerlevels \[@ALL\|@CT\|@T\|name\] | Shows you what levels other players are
say /automenu | Enable/Disable auto-show of Select Super Power menu
say /helpon | Enable HUD Help message (enabled by default)
say /helpoff | Disable HUD Help message

### How to use powers?

<span class="passive-power">Passive powers</span> are used automatically. To use <span class="active-power">active powers</span> you have to bind a key to +power#. In order to bind a key, you must open your console and use the bind command: bind \"key\" \"command\". In this case, the command is \"+power#\". Here are some examples:

- bind f +power1
- bind mouse3 +power2

You can have only up to 3 <span class="active-power">active powers</span>. You can have 10 superpowers in total (you get one slot each level).

### List of powers

{% include herolist.html %}
