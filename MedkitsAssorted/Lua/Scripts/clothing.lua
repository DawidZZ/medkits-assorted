local MA = MedkitsAssorted

local INNER_CLOTHES = 16

local function isInnerClothesSlot(slot)
    local number = tonumber(slot)
    if number ~= nil then
        return math.floor(number / INNER_CLOTHES) % 2 == 1
    end
    if string.find(tostring(slot), "InnerClothes", 1, true) then return true end
    local ok, equal = pcall(function() return slot == InvSlotType.InnerClothes end)
    return ok and equal == true
end

local uniformCache = {}
function MA.IsUniform(item)
    local id = item.Prefab.Identifier.Value
    local cached = uniformCache[id]
    if cached ~= nil then return cached end

    local result = false
    MA.ForEach(item.AllowedSlots, function(slot)
        if isInnerClothesSlot(slot) then result = true end
    end)
    uniformCache[id] = result
    return result
end

function MA.FitsPocketOf(itemIdentifier, clothing)
    if itemIdentifier == MA.Medkit then
        return MA.MedicClothes[clothing.Prefab.Identifier.Value] == true
    elseif itemIdentifier == MA.Ifak then
        return MA.IsUniform(clothing)
    end
    return false
end
