local MA = MedkitsAssorted

local basicKits = { MA.BasicSurgicalKit, MA.BasicSurgicalKitWhite }

local function findBasicKit(inventory, recursive)
    for _, identifier in ipairs(basicKits) do
        local kit = inventory.FindItemByIdentifier(identifier, recursive)
        if kit ~= nil then return kit end
    end
    return nil
end

local function controlledHasBasicKit()
    local character = Character.Controlled
    if character == nil or character.Inventory == nil then return false end
    return findBasicKit(character.Inventory, true) ~= nil
end

local patchedNtcs = pcall(function()
    Hook.Patch("Neurotrauma.ClientSource.ButtonsHUI", "HasRequiredItem", function(instance, ptable)
        if ptable.OriginalReturnValue then return end
        local ok, result = pcall(controlledHasBasicKit)
        if ok and result then ptable.ReturnValue = true end
    end, Hook.HookMethodType.After)
end)

if not patchedNtcs then
    Hook.Patch("Barotrauma.Inventory", "FindItemByIdentifier", { "Barotrauma.Identifier", "System.Boolean" },
        function(instance, ptable)
            if ptable.OriginalReturnValue ~= nil then return end
            local identifier = ptable["identifier"]
            if identifier == nil or identifier.Value ~= "surgerykit" then return end
            local ok, result = pcall(findBasicKit, instance, ptable["recursive"])
            if ok and result ~= nil then ptable.ReturnValue = result end
        end, Hook.HookMethodType.After)
end
