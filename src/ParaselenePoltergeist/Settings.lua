ParaselenePoltergeist.Settings = {
    name = 'ParaselenePoltergeistSettings',
}

function ParaselenePoltergeist.Settings:Clone(otherInstance)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.values = otherInstance.values

    return newInstance
end

function ParaselenePoltergeist.Settings.Load(author, version)
    local panelInfo = {
        type = 'panel',
        name = GetString(PARASELENE_POLTERGEIST_TITLE),
        displayName = GetString(PARASELENE_POLTERGEIST_SETTINGS_TITLE),
        author = author,
        version = version,
    }
    local panel = LibAddonMenu2:RegisterAddonPanel(ParaselenePoltergeist.Settings.name, panelInfo)

    local values = {}
    LibAddonMenu2:RegisterOptionControls(ParaselenePoltergeist.Settings.name, values)

    return ParaselenePoltergeist.Settings:Clone{
        values = values,
    }
end