local MA = MedkitsAssorted

local reported = {}
function MA.ReportOnce(key, message)
    if reported[key] then return end
    reported[key] = true
    print("[Medkits Assorted] " .. tostring(message))
end

function MA.ForEach(collection, fn)
    if collection == nil then return end
    if type(collection) == "table" then
        for _, value in ipairs(collection) do fn(value) end
    else
        for value in collection do fn(value) end
    end
end

function MA.ListContains(joined, identifier)
    for id in string.gmatch(joined or "", "[^,]+") do
        if string.lower(id) == identifier then return true end
    end
    return false
end
