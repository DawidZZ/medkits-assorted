local MA = MedkitsAssorted

local filteringFabricator = false

if CLIENT then
    Hook.Patch("Barotrauma.Items.Components.Fabricator", "FilterEntities", function()
        filteringFabricator = true
    end, Hook.HookMethodType.Before)
    Hook.Patch("Barotrauma.Items.Components.Fabricator", "FilterEntities", function()
        filteringFabricator = false
    end, Hook.HookMethodType.After)
end

Hook.Patch("Barotrauma.Character", "HasRecipeForItem", { "Barotrauma.Identifier" }, function(instance, ptable)
    if ptable.OriginalReturnValue then return end
    local ok, err = pcall(function()
        local identifier = ptable["recipeIdentifier"]
        local id = identifier and identifier.Value
        if id == nil then return end
        if (id == MA.BasicSurgicalKit and MA.HasNTCS)
            or (id == MA.LargeSurgicalKit and (filteringFabricator or instance.HasTalent(MA.AlwaysPrepared))) then
            ptable.ReturnValue = true
        end
    end)
    if not ok then MA.ReportOnce("recipes", "Error while checking a surgical kit recipe: " .. tostring(err)) end
end, Hook.HookMethodType.After)
