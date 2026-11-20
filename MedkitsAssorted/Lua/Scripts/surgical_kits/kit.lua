local MA = MedkitsAssorted

local fabricatorDescriptor = LuaUserData.RegisterType("Barotrauma.Items.Components.Fabricator")
LuaUserData.MakeFieldAccessible(fabricatorDescriptor, "fabricatedItem")

local function countOf(collection)
    local n = 0
    MA.ForEach(collection, function() n = n + 1 end)
    return n
end

local function kitIdsIn(inventory)
    local ids = {}
    MA.ForEach(inventory.AllItems, function(item)
        if item.Prefab.Identifier.Value == MA.LargeSurgicalKit then ids[item.ID] = true end
    end)
    return ids
end

local function fillNewKits(inventory, before)
    MA.ForEach(inventory.AllItems, function(kit)
        if kit.Removed or kit.Prefab.Identifier.Value ~= MA.LargeSurgicalKit or before[kit.ID] then return end
        if kit.OwnInventory == nil or countOf(kit.OwnInventory.AllItems) > 0 then return end
        before[kit.ID] = true
        for _, identifier in ipairs(MA.SurgicalKitTools) do
            local ok, err = pcall(function()
                Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(identifier), kit.OwnInventory, nil, nil, nil)
            end)
            if not ok then MA.ReportOnce("kitfill:" .. identifier, "Failed to put " .. identifier .. " into the kit: " .. tostring(err)) end
        end
    end)
end

Hook.Patch("Barotrauma.Items.Components.Fabricator", "Fabricate", function(instance, ptable)
    local ok, err = pcall(function()
        local recipe = instance.fabricatedItem
        if recipe == nil or recipe.TargetItem.Identifier.Value ~= MA.LargeSurgicalKit then return end
        if countOf(recipe.RequiredItems) <= 1 then return end
        local inventory = instance.OutputContainer.Inventory
        local before = kitIdsIn(inventory)
        Timer.Wait(function() 
            local fillOk, fillErr = pcall(fillNewKits, inventory, before)
            if not fillOk then MA.ReportOnce("kitfill", "Error while equipping the kit: " .. tostring(fillErr)) end
        end, 500)
    end)
    if not ok then MA.ReportOnce("kitfab", "Error while fabricating a surgical kit: " .. tostring(err)) end
end, Hook.HookMethodType.Before)
