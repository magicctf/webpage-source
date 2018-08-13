Content:A content documentation.
Content
=======

__Note : Some details may be left entirely out, as we don't have time to maintain the docs really well.__

Texture Packs
-------------

It is planned to add multiple texture packs by just filtering the textures.
Currently there is only a [High Contrast Texture Pack](releases.html).

Crafting Recipes
----------------

No crafting recipes will be included in this content documentation, as it's irrelevant - in-game, there's a crafting guide.


Tiers
-----

Following, **Tiers** stands for those material ranks/tiers : 
* Mithril
* Galvorn
* Diamond
* Mese
* Bronze
* Steel
* Stone
* Wood

In relation to the tiers, __"more precious"__ means higher tier, eg Mithril is more precious than Galvorn.


Mod compatibility
-----------------

As this is a subgame, most mods depend on other mods' functions. Therefore, it may not be easy to extract certain mods.


Status
------

If not otherwise stated, you may assume that every contained mod is considered __finished__, eg most likely won't be improved in future versions.


Skill selection(select_skills)
------------------------------

When you join a Magic-CTF server, a popup formspec will **force** you to configurate your skills.
It consist out of 3 control buttons : 
* Cancel(red X) : Reset current config
* Ready(green checkmark) : Approve config and start playing. Can only be used if all skill points have been used.
* Load last config(yellow arrow) : Load last configuration

Many skill buttons : Click on one to select that skill.
A `+` and a `-` button to improve/downgrade certain skills.


Skills
------

Registers the skills. If certain skills give you items, such as Magic Wands/Staves, you won't be able to drop them. Also, they won't be dropped on death.


Bones(bones)
------------

Added a flag for items which are not to be dropped on death.


Screwdriver(screwdriver)
------------------------

Only obtainable in creative.


Player Regeneration(player_regen)
---------------------------------

Title says it all : Gives health regen to all players.


Advanced Firearms(adv_arms)
---------------------------

This mod adds the following firearms to Magic-CTF : 

Launchers : 
* Single
* Dual
* Hedgehog

Types :
* Grenades
   * Smoke
   * Blend
   * Gas
   * Normal/Explosive
* Rockets
   * Small, fast
   * Medium, moderate speed
   * Large, slow
* TNTA Bombs
   * All TNTA Bombs/Explosives

Guns : 
* Laser Guns, Laser **Beam** Guns
  * Small
  * Medium
  * Large
* Normal Guns

Variations :
* High reload, lack of accuracy, good speed
* High accuracy, bad reload, better speed

Bows : 
* Shortbow
* Longbow - better shortbow
* Crossbow - faster than longbow but worse reload

Arrows come in **all tiers**. They can't break blocks; when they hit a block, they either break or can be picked up by punching them. Less precious arrows have a higher chance of breaking.

How they work : 
* Place ammo on the left side of them
* Click to make them reload
* If you want to get the ammo out of them **during** reloading, right-click
* To abort the reload, just switch wield item **before** reloading has finished. You can still get the ammo out with the method mentioned above.

Maybe further stuff will get added to this...


Advanced Boats(adv_boats)
-------------------------

Advanced Boats are a fork of the default Minetest boat Mod.

As in real life, it's not possible to obtain a boat once placed.
To prevent players from spamming boats, placing a boat takes time.
While placing a boat, player must wield boat item. Else, he has to restart the placing process.

There are the following boat tiers : 

* Steel - 0.8x speed, 20 hp
* Bronze - 0.7x speed, 25 hp
* Mese - 1.1x speed, 40 hp
* Diamond - 1.2x speed, 45 hp
* Galvorn - 0.8x speed, 50 hp
* Mithril - 1.5x speed, 60 hp

Each boat can take up to **3 people**, with one of them being the driver.
People can only join a boat if they are in the same team as the driver, eg a blue player cant join a boat if the driver is red.


Gliders(airships)
-----------------

Gliders work pretty much like boats. The only difference is that they can accelerate on water, land and in-air.
On water, they can accelerate the fastest, slower on land, and slowest in air.

Once they have accelerated enough, they will rise high.
But they will always lose speed due to friction.

Plus, down key doesnt work as "backwards" anymore - its kinda brake.


Potions(potions)
----------------

Adds potions with Tiers(Strength) from 1 to 3 and Level(Duration) from 5s to 15s.
HUD Bars show you your potion stats. You can drink up to 5 potions at a time.
**Particle Effects appear when somebody uses a potion.**

Potions : 
* Antigravity
* Jump
* Speed
* Regen

**More potions are planned.**



Advanced Traps(adv_traps)
-------------------------

### Spikes

Spikes come in all **Tiers**. The higher the tier, the harder they are to dig and the more damage they deal.

### Parasite Egg

Parasite Eggs are triggered if an enemy goes next to them or a **Rune Signal** reaches them.

### Drainers

Drainers lower enemies' stats in radius.

There are two drainers : 
* Mana
* HP

### Rune Signal System

A rune ore, comparable to coal, can be dug to craft Rune Stones.
Rune Signals can trigger : 
* Rune Stones
* Advanced TNT Bombs
* Parasite Eggs

**It is planned to add more features.**

There are the following Rune Stones : 
* Connector - will trigger nearby Rune Stones when triggered - kinda wiring
* And-Gate - will only trigger Rune Stones below and above if **all** x-z Plane nearby Rune Stones are one, like a logic and.
* Not-Gate - triggers when a Rune Stone above/below switches off.
* Stepper - triggers when somebody steps on **or** when it is right clicked
* Detector - triggers when somebody is in radius **or** when it is right clicked
* Disappear Block - becomes invisible when triggered. Reappears when triggered again.

Advanced TNT(tnta)
------------------

A well-known and quite popular mod by KGM, modified by LMD.

It adds lots of explosives : 

* Bombs - the well-known bomb. It explodes, deals damage to nearby players and blasts 'em away.
* Blenders - did you ever want to make your enemy see nothing ? If your enemy sees the bright light, he'll be blind for some time(uses `minetest.line_of_sight`)
* Smoke Bombs - smoke particles allow you to prevent everybody from seeing too muchn radius
* Gas Bombs - no explosion, sorry - but major damage dealt to anybody in radius

And many of them come in different types.


World Edit(worldedit, worldedit_(short-)commands)
-------------------------------------------------

**Mods by the WorldEdit Team.**
Provides a reliable and easy to use voxel manipulation mod. Really useful for map-making, and therefore included herein.
Please note that the GUI is not present.


3D Armor(3d_armor, 3d_armor_sfinv, shields)
-------------------------------------------

**Mods by stu.**
3d_armor_sfinv was left idle.
Provides armor to protect the player from taking damage. A popular and well known mod.
If you want to look at it's documentation, visit MT Forum : [deadlink](mt forum)
Was slightly modified by LMD to add Galvorn Armor, add magical protection and alter Mithril Armor textures. Some stats were tweaked, too, and a "Wear" label was added, showing the player how much his armor will last.

__I unfortunately had to disable the preview as I couldn't get it to work with MT texture modifiers...__

Hudbars & Mana(hudbars, mana)
-----------------------------

**Mods by Wuzzy.**
Improves hudbar look. A mana bar is added, too.
If you want to look at it's documentation, visit MT Forum : [deadlink](mt forum)


Sprint(sprint)
--------------

**Mod by GunshipPenguin.**
Adds a sprint bar. Allows you to sprint while pressing E if you have enough stamina. Was slightly modified to make it compatible with potions.


Kill History(deathlist)
-----------------------

Shows kill messages : 
<Player X> <Used item> killed <Player Y>

Also handles ELO & K/D System.

Furthermore, handles **knockback**.



Magic Tables(magicbooks)
------------------------

CTF core. Provides Magic Tables, responsible for messages, map system, etc.

### Magic Tables

Magic Tables are all-in-one : 
* Item Spawner
* Team Chest
* Flag

The inventory has got three sections : 
* A shared one, which can be acessed by every team member.
* A low-elo section(3x4 slots) - can only be accessed & seen by low elo players
* A high-elo section(2x4 slots) - can only be accessed & seen by high elo players

The flag equivalent are __magic books__.
The item spawning works similar as for **Treasure Spawners**.

CTF mechanics work pretty common : When the flag holder is killed, the flag returns. You can only score if your flag is at home.
**It's not possible to punch a player next to his magic table.**

Colored messages will tell you what to do in-game.

### Message System

Messaging works pretty easy : 
* When you type something, it becomes a secret message, which only your team can see.
* If you want to write a global message, use @all before your message : `@all Hello everybody !`
* If you want to write a message to a certain player, use @playername : `@singleplayer How is it goin', singleplayer ?`

### Health Rune

A rune on your front showing your health. Can be hidden using armor(chestplate).

### Crafting Guide

An intuitive crafting guide, using sfinv. Entirely made by LMD.



Player Nametags(playertags)
---------------------------

Shows player names above players.


More Weapons(more_weapons)
--------------------------

More Weapons ! An altered version of some code by KGM. Adds : 

New materials : 

* Mithril
* Galvorn

And new tools using all materials : 

* Spears
* Battleaxes
* Scythe
* Warhammer
* Mace
* Halberd


Treasure Chests(treasure_chests)
--------------------------------

Adds : 

* Treasure Chest Spawners for map-making
* Treasure Chests, which come in the following tiers : 
   * Golden(4x8 slots)
   * Iron(2x8 slots)
   * Wooden(1x8 slots)

A price calculation system estimates the price of items which is the chance of obtaining them.
Precious items are the ones that are more rare.



Treasure Spawners(treasure_spawners)
------------------------------------

Adds Treasure Spawners. Uses same "price calculation" system as Treasure Chests. When they spawn treasure, a green particle effect appears.