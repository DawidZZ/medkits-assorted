MedkitsAssorted = MedkitsAssorted or {}
MedkitsAssorted.Path = table.pack(...)[1]

local function run(script)
    dofile(MedkitsAssorted.Path .. "/Lua/Scripts/" .. script .. ".lua")
end

run("config")
run("util")
run("clothing")
run("uniform_pockets")

if CLIENT then
    run("nested_inventory/common")
    run("nested_inventory/frames")
    run("nested_inventory/layout")
    run("nested_inventory/open")
    run("nested_inventory/drag_bar")
end
