ParaselenePoltergeist.SavedVariables = {
    name = 'ParaselenePoltergeistSavedVariables',
    schemaVersion = '[SCHEMA_VERSION]',

    serverIndependent = {
        schemaVersion = '[SCHEMA_VERSION]',
        lastSaved = '2024-01-01 01:00:00',
    },
    serverSpecific = {
        furnishings = {
            storage = {},
            nextAvailableTag = 1,
        },
        houses = {
            storage = {},
        },
        schemaVersion = '[SCHEMA_VERSION]',
        lastSaved = '2024-01-01 01:00:00',
    },
}

function ParaselenePoltergeist.SavedVariables:Load()
    self.serverIndependent = ZO_SavedVars:NewAccountWide(
        self.name,
        1,
        nil,
        self.serverIndependent,
        'ServerIndependent'
    )
    -- If self.serverIndependent is an old schema, migrate it here.
    self.serverIndependent.schemaVersion = '[SCHEMA_VERSION]'
    -- Load server-independent data here.

    self.serverSpecific = ZO_SavedVars:NewAccountWide(
        self.name,
        1,
        nil,
        self.serverSpecific,
        GetWorldName()
    )
    -- If self.serverSpecific is an old schema, migrate it here.
    self.serverSpecific.schemaVersion = '[SCHEMA_VERSION]'

    ParaselenePoltergeist.FurnishingStorage:Load(self.serverSpecific.furnishings)
    ParaselenePoltergeist.HouseStorage:Load(self.serverSpecific.houses)
end

function ParaselenePoltergeist.SavedVariables:Save()
    local lastSaved = tostring(os.date('%Y-%m-%d %H:%M:%S'))

    self.serverIndependent.lastSaved = lastSaved

    self.serverSpecific.furnishings = ParaselenePoltergeist.FurnishingStorage:Save()
    self.serverSpecific.houses = ParaselenePoltergeist.HouseStorage:Save()
    self.serverSpecific.lastSaved = lastSaved
end
