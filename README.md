# Medkits Assorted

A Barotrauma mod adding new medkits: portable containers that accept only medical items.
Works on the vanilla game and is compatible with Neurotrauma and Neurotrauma CS and their addons
(mods that change the medic talent tree need attention, see [Medic talent tree override](#medic-talent-tree-override)).

## Requirements

- **Barotrauma 1.13.5.0** or newer. No other mods are required: all items work on the vanilla game.

Optional:

| Mod | What it adds |
|---|---|
| [LuaCsForBarotrauma](https://steamcommunity.com/sharedfiles/filedetails/?id=2559634234) | Medkit and IFAK fit into uniform pockets and can be opened from there |
| [Neurotrauma](https://steamcommunity.com/sharedfiles/filedetails/?id=3190189044) or [Neurotrauma CS](https://steamcommunity.com/sharedfiles/filedetails/?id=3744761298) | Large Surgical Kit (with the Always Prepared talent); the medkits accept NT medical items |
| [Neurotrauma CS](https://steamcommunity.com/sharedfiles/filedetails/?id=3744761298) | Basic Surgical Kit, which enables the surgical tool buttons in the NTCS health menu |

## Medic talent tree override

> [!WARNING]
> The mod **overrides the whole medic talent tree** to add two talents: First Responder (an alternative to Medical
> Expertise) and Always Prepared (second row of the main tree). Their recipes unlock the First Responder Tactical Vest,
> the Medical Backpack, the Large Medical Bag and, with Neurotrauma, the Large Surgical Kit.

Barotrauma uses only one version of a talent tree. If another enabled mod also changes the medic tree (e.g.
NTCS Grafting), the game keeps the tree from the mod with the highest priority. In the mod list, mods **higher up**
take priority. Choose with the load order:

- **Medkits Assorted above the other mod**: you get this mod's talents, but the other mod's changes to the medic tree are lost.
- **Medkits Assorted below the other mod**: the other mod's tree wins. First Responder and Always Prepared can't be
  picked, so the items from their recipes can't be fabricated (the medkits themselves work as usual).

If you want the other mod's tree and every item, use [Medkits Assorted Lite](#medkits-assorted-lite) instead.

## Medkits Assorted Lite

A separate, lightweight version of this mod: pure XML, **no Lua (LuaCs) and no overrides** of game files, so it doesn't
conflict with mods that change the medic talent tree.

- Same items and identifiers (`mka_*`), except the surgical kits.
- No talents: the vest, the Medical Backpack and the Large Medical Bag can be fabricated by anyone.
- No Lua features: medkits don't fit into uniform pockets.
- Saves keep working when switching between the two versions. **Don't enable both at once**, they define the same items.

GitHub: *link coming soon* 

## Development

```bash
scripts/link-localmods.sh   # symlinks the mod to <game>/LocalMods/MedkitsAssorted
```

## License

Copyright (C) 2026 DawidZZ

This mod is free software: you can redistribute it and/or modify it under the terms of the
[GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.html) as published by the Free Software
Foundation, either version 3 of the License, or (at your option) any later version.

It is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
