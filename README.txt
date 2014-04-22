Bridge Tool Version 2.1 

A bridge building tool for minetest
Author Kilarin (Donald Hines)

Extract zipfile to your minetest mod folder, and rename it to bridgetool

Crafting recipe is

steel ingot,                     ,steel ingot
           ,    steel ingot      ,
           ,mese crystal fragment,

Point the tool and right click to place nodes from the inventory stack directly to the right of the tool

Left click to change mode between
1: Build forward
2: Build diagonally down
3: Build diagonally up

Left click while holding down the "sneak" key to change the width between 1 and 3.


My son helped me with some ideas for this mod. I got a lot of code examples from the screwdriver mod in minetest_game by RealBadAngel, Maciej Kasatkin. I also copied and modified the screwdriver's mode number images for use in the bridge tool inventory images.  They are licensed CC BY-SA 3.0 http://creativecommons.org/licenses/by-sa/3.0/   The source code is licensed CC0 http://creativecommons.org/about/cc0
Topywo suggested adding wear, correcting down stair orientation, and using not_in_creative_inventory=1
Sokomine suggested adding width so that you could build 2 or 3 wide.

Changelog
--Version 2.1
Corrected fact that 3 wide stairs would sometimes orient the 3rd stair the wrong way
Modified stair orientation when using mode 1(forward) so that the stair will face down (since the only reason you would use the "forward" option with this tool and a staircase is to begin a down stair.)

---Version 2.0
Added width of 2 or 3
corrected down stair orientation
added not_in_creative_inventory=1 to all of the "mode" versions of the tool
added wear option

---Version 1.0
Initial release
