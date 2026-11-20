local MA = MedkitsAssorted

MA.Medkit = "mka_medkit"
MA.Ifak = "mka_ifak"

-- Clothes whose pockets accept the Medkit. Missing ones (e.g. surgeonclothes without Surgery Plus) simply never show up.
MA.MedicClothes = {
    doctorsuniform1 = true,
    doctorsuniform2 = true,
    medicseparatistsuniform1 = true,
    medicseparatistsuniform2 = true,
    surgeonclothes = true, -- NT Surgery Plus / NTCS Surgery Plus
}

-- Pocket rule the IFAK is added to
MA.PocketRuleTags = { "smallitem", "medical", "chem" }

MA.LargeSurgicalKit = "mka_largesurgicalkit"
MA.BasicSurgicalKit = "mka_basicsurgicalkit"
MA.LargeSurgicalKitWhite = "mka_largesurgicalkit_white"
MA.BasicSurgicalKitWhite = "mka_basicsurgicalkit_white"

-- Repaint recipes: target kit -> the kit it is made from (surgical_kits/repaint.lua keeps the contents)
MA.KitRepaints = {
    [MA.LargeSurgicalKit] = MA.LargeSurgicalKitWhite,
    [MA.LargeSurgicalKitWhite] = MA.LargeSurgicalKit,
    [MA.BasicSurgicalKit] = MA.BasicSurgicalKitWhite,
    [MA.BasicSurgicalKitWhite] = MA.BasicSurgicalKit,
}
MA.FirstResponder = "mka_firstresponder"
MA.AlwaysPrepared = "mka_alwaysprepared"

-- Recipes from each talent's <AddedRecipe> (Talents.xml), unlocked for everyone when the talent isn't in any tree.
-- The Large Surgical Kit (Always Prepared, NT only) is handled in surgical_kits/recipes.lua.
MA.TalentRecipes = {
    [MA.FirstResponder] = { "mka_firstrespondervest", "mka_medicalbackpack" },
    [MA.AlwaysPrepared] = { "mka_largemedicalbag" },
}

-- Tools put into a Large Surgical Kit made with the (kit) recipe (like NT's surgerytoolboxset)
MA.SurgicalKitTools = { "advscalpel", "advhemostat", "advretractors", "tweezers", "traumashears", "surgicaldrill", "surgerysaw" }
