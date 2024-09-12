ParaselenePoltergeist.Settings = {
    name = 'ParaselenePoltergeistSettings',
    panel = nil,
    values = {},
}

function ParaselenePoltergeist.Settings:Load()
    local panelInfo = {
        type = 'panel',
        name = GetString(PARASELENE_POLTERGEIST_TITLE),
        displayName = GetString(PARASELENE_POLTERGEIST_SETTINGS_TITLE),
        author = ParaselenePoltergeist.author,
        version = ParaselenePoltergeist.version,
    }
    self.panel = LibAddonMenu2:RegisterAddonPanel(ParaselenePoltergeist.Settings.name, panelInfo)

    LibAddonMenu2:RegisterOptionControls(self.name, self.values)
end
