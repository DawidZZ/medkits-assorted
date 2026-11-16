local MA = MedkitsAssorted

LuaUserData.RegisterType("Barotrauma.Inventory+SlotReference")
LuaUserData.RegisterType("Barotrauma.VisualSlot")

local N = {}
MA.Nested = N

N.ClosedBelow = 0.25
N.Open = {}
N.Frozen = {}

function N.IsMedkit(item)
    if item == nil or item.Removed then return false end
    local id = item.Prefab.Identifier.Value
    return id == MA.Medkit or id == MA.Ifak
end

function N.IsInCharactersPocket(item, character)
    local pocket = item.ParentInventory
    if pocket == nil or not LuaUserData.IsTargetType(pocket, "Barotrauma.ItemInventory") then return false end
    local clothing = pocket.Owner
    if clothing == nil or not LuaUserData.IsTargetType(clothing, "Barotrauma.Item") then return false end
    if not MA.FitsPocketOf(item.Prefab.Identifier.Value, clothing) then return false end
    local owner = clothing.ParentInventory and clothing.ParentInventory.Owner
    return owner ~= nil and owner.ID == character.ID
end
