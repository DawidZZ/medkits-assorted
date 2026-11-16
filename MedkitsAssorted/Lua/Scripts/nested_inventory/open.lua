local MA = MedkitsAssorted
local N = MA.Nested

local characterInventoryDescriptor = LuaUserData.RegisterType("Barotrauma.CharacterInventory")
LuaUserData.MakeMethodAccessible(characterInventoryDescriptor, "ShowSubInventory")
LuaUserData.MakeFieldAccessible(characterInventoryDescriptor, "hideSubInventories")

local function openHoveredMedkit(inventory, character, deltaTime, cam)
    local slot = Inventory.SelectedSlot
    if slot == nil or not N.IsMedkit(slot.Item) then return end
    if not N.IsInCharactersPocket(slot.Item, character) then return end

    local id = slot.Item.ID
    local entry = N.Open[id]
    if entry ~= nil and entry.container.Inventory.HideTimer >= N.ClosedBelow then return end

    local container = slot.Item.GetComponentString("ItemContainer")
    if container == nil then return end

    N.FreezeFrame(container)
    slot.Inventory = container.Inventory
    inventory.ShowSubInventory(slot, deltaTime, cam, CharacterInventory.hideSubInventories, false)
    N.Open[id] = { slot = slot, container = container }
end

local function updateOpenMedkits(character, deltaTime, cam)
    for id, entry in pairs(N.Open) do
        local item = entry.container.Item
        local pocket = entry.slot.ParentInventory
        local stillThere = N.IsMedkit(item) and N.IsInCharactersPocket(item, character)
        if stillThere then
            local inSlot = pocket.GetItemAt(entry.slot.SlotIndex)
            stillThere = inSlot ~= nil and inSlot.ID == id
        end

        if not stillThere then
            entry.container.Inventory.HideTimer = 0
            N.Open[id] = nil
        elseif entry.container.Inventory.HideTimer < N.ClosedBelow then
            N.Open[id] = nil
        else
            N.UpdateBesidePocket(entry, pocket, deltaTime, cam)
            pocket.HideTimer = 1.0
        end
    end
end

Hook.Patch("Barotrauma.CharacterInventory", "Update", { "System.Single", "Barotrauma.Camera", "System.Boolean" },
    function(instance, ptable)
        local character = Character.Controlled
        if character == nil or instance.Owner == nil or instance.Owner.ID ~= character.ID then return end

        local deltaTime, cam = ptable["deltaTime"], ptable["cam"]
        local ok, err = pcall(function()
            N.RestoreFrames(character)
            openHoveredMedkit(instance, character, deltaTime, cam)
            updateOpenMedkits(character, deltaTime, cam)
        end)
        if not ok then MA.ReportOnce("nested", "Error while opening a Medkit in a uniform pocket: " .. tostring(err)) end
    end, Hook.HookMethodType.After)
