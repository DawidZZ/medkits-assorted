local MA = MedkitsAssorted

local function controlledHasBasicKit()
    local character = Character.Controlled
    if character == nil or character.Inventory == nil then return false end
    return character.Inventory.FindItemByIdentifier(MA.BasicSurgicalKit, true) ~= nil
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
            local ok, result = pcall(function()
                return instance.FindItemByIdentifier(MA.BasicSurgicalKit, ptable["recursive"])
            end)
            if ok and result ~= nil then ptable.ReturnValue = result end
        end, Hook.HookMethodType.After)
end
