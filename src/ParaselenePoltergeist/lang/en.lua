ParaselenePoltergeist.localizationStrings = {
    CAPTURE_PLACEMENT = 'Capture Furniture Placement',
    TITLE = "Paraselene's Poltergeist",
}

for stringId, stringValue in pairs(ParaselenePoltergeist.localizationStrings) do
    ZO_CreateStringId('PARASELENE_POLTERGEIST_' .. stringId, stringValue)
end
