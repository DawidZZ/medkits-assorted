local MA = MedkitsAssorted

local function prefabExists(identifier)
    local ok, prefab = pcall(function() return ItemPrefab.Prefabs[identifier] end)
    return ok and prefab ~= nil
end

MA.HasNT = prefabExists("surgerytoolbox")
MA.HasNTCS = prefabExists("surgerykit")
