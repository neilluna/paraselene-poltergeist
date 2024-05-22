ParaselenePoltergeist.SavedVariables = {
    name = 'ParaselenePoltergeistSavedVariables',
    schemaVersion = '[SCHEMA_VERSION]',
    defaults = {
        serverSpecific = {
            clipboard = {},
            schemaVersion = '[SCHEMA_VERSION]',
        },
        serverIndependent = {
            schemaVersion = '[SCHEMA_VERSION]',
        },
    },
}

function ParaselenePoltergeist.SavedVariables:Clone(otherInstance)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.persisted = otherInstance.persisted
    newInstance.serverSpecific = otherInstance.serverSpecific
    newInstance.serverIndependent = otherInstance.serverIndependent

    return newInstance
end

function ParaselenePoltergeist.SavedVariables.Load()
    local persisted = {}
    persisted.serverSpecific = ZO_SavedVars:NewAccountWide(
        ParaselenePoltergeist.SavedVariables.name,
        1,
        nil,
        ParaselenePoltergeist.SavedVariables.defaults.serverSpecific,
        GetWorldName()
    )
    persisted.serverIndependent = ZO_SavedVars:NewAccountWide(
        ParaselenePoltergeist.SavedVariables.name,
        1,
        nil,
        ParaselenePoltergeist.SavedVariables.defaults.serverIndependent,
        'ServerIndependent'
    )

    -- Load/migrate persisted.serverSpecific into serverSpecific.
    local serverSpecific = {}
    serverSpecific.clipboard = ParaselenePoltergeist.Clipboard.Load(persisted.serverSpecific.clipboard)
    -- serverSpecific.placements = nil  -- To do: Load placements.
    serverSpecific.schemaVersion = '[SCHEMA_VERSION]'

    -- Load/migrate persisted.serverIndependent into serverIndependent.
    local serverIndependent = {}
    serverIndependent.schemaVersion = '[SCHEMA_VERSION]'

    return ParaselenePoltergeist.SavedVariables:Clone{
        persisted = persisted,
        serverSpecific = serverSpecific,
        serverIndependent = serverIndependent,
    }
end

function ParaselenePoltergeist.SavedVariables:Save()
    local lastSaved = tostring(os.date('%Y-%m-%d %H:%M:%S'))

    -- Save ParaselenePoltergeist.serverSpecific into persisted.serverSpecific and persisted.serverIndependent.
    self.persisted.serverSpecific.clipboard = self.serverSpecific.clipboard:Save()
    -- self.persisted.serverSpecific.placements = nil
    self.persisted.serverSpecific.schemaVersion = self.serverSpecific.schemaVersion
    self.persisted.serverSpecific.lastSaved = lastSaved

    -- Save ParaselenePoltergeist.serverIndependent into persisted.serverIndependent.
    self.persisted.serverIndependent.schemaVersion = self.serverIndependent.schemaVersion
    self.persisted.serverIndependent.lastSaved = lastSaved
end
