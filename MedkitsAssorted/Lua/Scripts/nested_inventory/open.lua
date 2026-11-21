local MA = MedkitsAssorted
local N = MA.Nested

local characterInventoryDescriptor = LuaUserData.RegisterType("Barotrauma.CharacterInventory")
LuaUserData.MakeMethodAccessible(characterInventoryDescriptor, "ShowSubInventory")
LuaUserData.MakeFieldAccessible(characterInventoryDescriptor, "hideSubInventories")
local inventoryDescriptor = LuaUserData.RegisterType("Barotrauma.Inventory")
LuaUserData.MakeFieldAccessible(inventoryDescriptor, "highlightedSubInventorySlots")
LuaUserData.RegisterType("System.Collections.Generic.HashSet`1[[Barotrauma.Inventory+SlotReference, Barotrauma]]")

local function closeMedkit(id)
    local entry = N.Open[id]
    if entry == nil then return end
    N.Open[id] = nil
    entry.container.Inventory.HideTimer = 0
    Inventory.highlightedSubInventorySlots.Remove(entry.slot)
end

local function openHoveredMedkit(inventory, character, deltaTime, cam)
    local slot = Inventory.SelectedSlot
    if slot == nil or not N.IsMedkit(slot.Item) then return end
    if not N.IsInCharactersPocket(slot.Item, character) then return end

    local id = slot.Item.ID
    local entry = N.Open[id]
    if entry ~= nil and entry.container.Inventory.HideTimer >= N.ClosedBelow then return end

    local container = slot.Item.GetComponentString("ItemContainer")
    if container == nil then return end

    for otherId in pairs(N.Open) do
        if otherId ~= id then closeMedkit(otherId) end
    end

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
            closeMedkit(id)
        elseif entry.container.Inventory.HideTimer < N.ClosedBelow then
            N.Open[id] = nil
        else
            local subInventory = entry.container.Inventory
            local hideTimer = subInventory.HideTimer
            subInventory.HideTimer = 1.0
            subInventory.OpenState = 1.0
            N.UpdateBesidePocket(entry, pocket, deltaTime, cam)
            subInventory.HideTimer = hideTimer
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
