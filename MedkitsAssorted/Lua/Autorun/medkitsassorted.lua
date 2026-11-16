MedkitsAssorted = MedkitsAssorted or {}
MedkitsAssorted.Path = table.pack(...)[1]

local function run(script)
    dofile(MedkitsAssorted.Path .. "/Lua/Scripts/" .. script .. ".lua")
end

run("config")
run("util")
run("clothing")
run("uniform_pockets")

run("surgical_kits/detect")
if MedkitsAssorted.HasNT then
    run("surgical_kits/recipes")
    if not (CLIENT and Game.IsMultiplayer) then
        run("surgical_kits/kit")
    end
    if CLIENT and MedkitsAssorted.HasNTCS then
        run("surgical_kits/health_menu")
    end
end

if CLIENT then
    run("nested_inventory/common")
    run("nested_inventory/frames")
    run("nested_inventory/layout")
    run("nested_inventory/open")
    run("nested_inventory/drag_bar")
end
