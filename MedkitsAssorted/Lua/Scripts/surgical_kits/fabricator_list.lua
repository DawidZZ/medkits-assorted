local MA = MedkitsAssorted

-- The fabricator groups recipes by the target item's category, so the repaint recipes would sit with the kits in
-- Equipment. A recipe has no category of its own (and the red kit's repaint shares its target with the regular
-- recipes), so the category filter is corrected afterwards: repaints are hidden under Equipment and shown under Misc.

local descriptor = LuaUserData.RegisterType("Barotrauma.Items.Components.Fabricator")
for _, field in ipairs({ "itemList", "availableOnlyTickBox", "availableIngredients", "nothingToShowText" }) do
    LuaUserData.MakeFieldAccessible(descriptor, field)
end
LuaUserData.MakeMethodAccessible(descriptor, "CanBeFabricated")
LuaUserData.MakeMethodAccessible(descriptor, "HideEmptyItemListCategories")

local REPAINT_CATEGORY = "Misc"

-- Recipe of a list entry, or nil for the category headers (their UserData is a MapEntityCategory)
local function recipeOf(child)
    local ok, recipe = pcall(function()
        local data = child.UserData
        if data ~= nil and data.TargetItem ~= nil then return data end
        return nil
    end)
    if ok then return recipe end
    return nil
end

local function matchesFilter(recipe, filter)
    if filter == nil or string.match(filter, "^%s*$") then return true end
    return string.find(string.lower(recipe.DisplayName.Value), string.lower(filter), 1, true) ~= nil
end

-- Same rule as the recipe unlocks in recipes.lua: the Basic Surgical Kit needs NTCS
local function unlocked(recipe)
    local target = recipe.TargetItem.Identifier.Value
    if target == MA.BasicSurgicalKit or target == MA.BasicSurgicalKitWhite then return MA.HasNTCS end
    return true
end

Hook.Patch("Barotrauma.Items.Components.Fabricator", "FilterEntities", function(instance, ptable)
    local ok, err = pcall(function()
        local category = ptable["category"]
        if category == nil then return end -- "All": nothing to correct
        local showRepaints = tostring(category) == REPAINT_CATEGORY
        local onlyAvailable = instance.availableOnlyTickBox ~= nil and instance.availableOnlyTickBox.Selected
        local changed = false
        MA.ForEach(instance.itemList.Content.Children, function(child)
            local recipe = recipeOf(child)
            if recipe == nil or MA.RepaintSource(recipe) == nil then return end
            local visible = showRepaints and unlocked(recipe) and matchesFilter(recipe, ptable["filter"])
                and (not onlyAvailable or instance.CanBeFabricated(recipe, instance.availableIngredients, Character.Controlled))
            if child.Visible ~= visible then
                child.Visible = visible
                changed = true
            end
        end)
        if not changed then return end
        instance.HideEmptyItemListCategories()
        local anyVisible = false
        MA.ForEach(instance.itemList.Content.Children, function(child)
            if child.Visible and recipeOf(child) ~= nil then anyVisible = true end
        end)
        instance.nothingToShowText.Visible = not anyVisible
    end)
    if not ok then MA.ReportOnce("repaintlist", "Error while sorting repaint recipes in the fabricator: " .. tostring(err)) end
end, Hook.HookMethodType.After)
