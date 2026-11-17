local MA = MedkitsAssorted

MA.MissingTalents = {}
local freeRecipes = {}
local anyFree = false

local talentTreesOk, TalentTree = pcall(function()
    LuaUserData.RegisterType("Barotrauma.TalentTree")
    return LuaUserData.CreateStatic("Barotrauma.TalentTree", true)
end)
if not talentTreesOk then
    MA.ReportOnce("talenttree", "Error while reading the talent trees: " .. tostring(TalentTree))
    return
end

local function isInAnyTree(talent)
    local found = false
    MA.ForEach(TalentTree.JobTalentTrees, function(tree)
        if not found and tree.TalentIsInTree(talent) then found = true end
    end)
    return found
end

for talent, recipes in pairs(MA.TalentRecipes) do
    local ok, result = pcall(isInAnyTree, talent)
    if not ok then
        MA.ReportOnce("talenttree", "Error while checking the talent trees: " .. tostring(result))
    elseif not result then
        MA.MissingTalents[talent] = true
        for _, recipe in ipairs(recipes) do
            freeRecipes[recipe] = true
            anyFree = true
        end
        print("[Medkits Assorted] Talent " .. talent .. " isn't in any talent tree (another mod overrides the medic tree), "
            .. "its recipes are unlocked for everyone.")
    end
end

if anyFree then
    Hook.Patch("Barotrauma.Character", "HasRecipeForItem", { "Barotrauma.Identifier" }, function(_, ptable)
        if ptable.OriginalReturnValue then return end
        local identifier = ptable["recipeIdentifier"]
        if identifier ~= nil and freeRecipes[identifier.Value] then ptable.ReturnValue = true end
    end, Hook.HookMethodType.After)
end
