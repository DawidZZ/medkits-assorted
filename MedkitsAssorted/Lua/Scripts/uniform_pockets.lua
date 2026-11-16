local MA = MedkitsAssorted

LuaUserData.RegisterType("Barotrauma.RelatedItem")

local function addToRule(rule, identifier)
    local joined = rule.JoinedIdentifiers
    if not MA.ListContains(joined, identifier) then
        rule.JoinedIdentifiers = (joined ~= nil and joined ~= "") and (joined .. "," .. identifier) or identifier
    end
end

local function isPocketRule(rule)
    local joined = rule.JoinedIdentifiers
    for _, tag in ipairs(MA.PocketRuleTags) do
        if MA.ListContains(joined, tag) then return true end
    end
    return false
end

local function allowKitsInPockets(container)
    if container == nil or container.Item == nil then return end
    local clothing = container.Item
    local medic = MA.MedicClothes[clothing.Prefab.Identifier.Value] == true
    local uniform = MA.IsUniform(clothing)
    if not medic and not uniform then return end

    MA.ForEach(container.ContainableItems, function(rule)
        if medic then addToRule(rule, MA.Medkit) end
        if uniform and isPocketRule(rule) then
            addToRule(rule, MA.Ifak)
            MA.ReportOnce("ifak:" .. clothing.Prefab.Identifier.Value,
                "IFAK fits the pockets of: " .. clothing.Prefab.Identifier.Value)
        end
    end)
end

Hook.Patch("Barotrauma.Items.Components.ItemContainer", "OnItemLoaded", function(instance, ptable)
    local ok, err = pcall(allowKitsInPockets, instance)
    if not ok then MA.ReportOnce("pockets", "Failed to add medkits to uniform pockets: " .. tostring(err)) end
end, Hook.HookMethodType.Before)

MA.ForEach(Item.ItemList, function(item)
    local container = item.GetComponentString("ItemContainer")
    if container ~= nil then
        local ok, err = pcall(allowKitsInPockets, container)
        if not ok then MA.ReportOnce("pockets", "Failed to add medkits to uniform pockets: " .. tostring(err)) end
    end
end)
