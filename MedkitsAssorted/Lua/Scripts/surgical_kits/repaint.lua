local MA = MedkitsAssorted

local fabricatorDescriptor = LuaUserData.RegisterType("Barotrauma.Items.Components.Fabricator")
LuaUserData.MakeFieldAccessible(fabricatorDescriptor, "fabricatedItem")
LuaUserData.MakeMethodAccessible(fabricatorDescriptor, "CancelFabricating")

local function contentsBySlot(kit)
    local contents = {}
    local inventory = kit.OwnInventory
    if inventory == nil then return contents end
    for slot = 0, inventory.Capacity - 1 do
        MA.ForEach(inventory.GetItemsAt(slot), function(item)
            table.insert(contents, { item = item, slot = slot })
        end)
    end
    return contents
end

local function moveContents(oldKit, newKit)
    for _, entry in ipairs(contentsBySlot(oldKit)) do
        local item = entry.item
        local moved = newKit.OwnInventory ~= nil
            and (newKit.OwnInventory.TryPutItem(item, entry.slot, false, true, nil)
                or newKit.OwnInventory.TryPutItem(item, nil))
        if not moved then
            item.Drop(nil)
            MA.ReportOnce("repaint:drop", "An item didn't fit into the repainted kit and was dropped: " .. item.Name)
        end
    end
end

local function finishRepaint(oldKit, newKit)
    if oldKit.Removed then
        Entity.Spawner.AddItemToRemoveQueue(newKit)
        MA.ReportOnce("repaint:gone", "The kit being repainted disappeared before the new one spawned; the new kit was removed.")
        return
    end
    local moveOk, moveErr = pcall(moveContents, oldKit, newKit)
    if not moveOk then MA.ReportOnce("repaint:move", "Error while moving the contents into the repainted kit: " .. tostring(moveErr)) end
    for _, entry in ipairs(contentsBySlot(oldKit)) do
        pcall(function() entry.item.Drop(nil) end)
    end
    Entity.Spawner.AddItemToRemoveQueue(oldKit)
end

local function findInput(fabricator, identifier)
    local found = nil
    MA.ForEach(fabricator.InputContainer.Inventory.AllItems, function(item)
        if found == nil and not item.Removed and item.Prefab.Identifier.Value == identifier then found = item end
    end)
    return found
end

Hook.Patch("Barotrauma.Items.Components.Fabricator", "Fabricate", function(instance, ptable)
    local ok, err = pcall(function()
        local recipe = instance.fabricatedItem
        if recipe == nil then return end
        local source = MA.RepaintSource(recipe)
        if source == nil then return end
        local oldKit = findInput(instance, source)
        if oldKit == nil then return end 

        instance.CancelFabricating(nil)
        ptable.PreventExecution = true
        local function onSpawned(newKit)
            local spawnOk, spawnErr = pcall(finishRepaint, oldKit, newKit)
            if not spawnOk then MA.ReportOnce("repaint:finish", "Error while finishing a repaint: " .. tostring(spawnErr)) end
        end
        local prefab = recipe.TargetItem
        local output = instance.OutputContainer.Inventory
        if output.HowManyCanBePut(prefab, oldKit.Condition) > 0 then
            Entity.Spawner.AddItemToSpawnQueue(prefab, output, oldKit.Condition, oldKit.Quality, onSpawned)
        else
            local fabricator = instance.Item
            Entity.Spawner.AddItemToSpawnQueue(prefab, fabricator.Position, fabricator.Submarine, oldKit.Condition, oldKit.Quality, onSpawned)
        end
    end)
    if not ok then MA.ReportOnce("repaint", "Error while repainting a surgical kit: " .. tostring(err)) end
end, Hook.HookMethodType.Before)
