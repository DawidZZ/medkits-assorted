local MA = MedkitsAssorted

LuaUserData.RegisterType("Barotrauma.FabricationRecipe")
LuaUserData.RegisterType("Barotrauma.FabricationRecipe+RequiredItem")

function MA.RepaintSource(recipe)
    local source = MA.KitRepaints[recipe.TargetItem.Identifier.Value]
    if source == nil then return nil end
    local count, matches = 0, false
    MA.ForEach(recipe.RequiredItems, function(required)
        count = count + 1
        MA.ForEach(required.ItemPrefabs, function(prefab)
            if prefab.Identifier.Value == source then matches = true end
        end)
    end)
    if count == 1 and matches then return source end
    return nil
end

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
        if ((id == MA.BasicSurgicalKit or id == MA.BasicSurgicalKitWhite) and MA.HasNTCS)
            or id == MA.LargeSurgicalKitWhite
            or (id == MA.LargeSurgicalKit and (filteringFabricator or MA.MissingTalents[MA.AlwaysPrepared]
                or instance.HasTalent(MA.AlwaysPrepared))) then
            ptable.ReturnValue = true
        end
    end)
    if not ok then MA.ReportOnce("recipes", "Error while checking a surgical kit recipe: " .. tostring(err)) end
end, Hook.HookMethodType.After)

Hook.Patch("Barotrauma.Items.Components.Fabricator", "MissingRequiredRecipe", function(instance, ptable)
    if not ptable.OriginalReturnValue then return end
    local ok, err = pcall(function()
        local recipe = ptable["fabricableItem"]
        if recipe ~= nil and recipe.TargetItem.Identifier.Value == MA.LargeSurgicalKit and MA.RepaintSource(recipe) then
            ptable.ReturnValue = false
        end
    end)
    if not ok then MA.ReportOnce("repaintrecipe", "Error while checking a repaint recipe: " .. tostring(err)) end
end, Hook.HookMethodType.After)
