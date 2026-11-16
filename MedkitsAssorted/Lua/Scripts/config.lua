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
