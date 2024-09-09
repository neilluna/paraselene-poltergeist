ParaselenePoltergeist.SavedVariables = {
    name = 'ParaselenePoltergeistSavedVariables',
    schemaVersion = '[SCHEMA_VERSION]',
    defaults = {
        serverIndependent = {
            schemaVersion = '[SCHEMA_VERSION]',
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
        },
    },
}

function ParaselenePoltergeist.SavedVariables:Create(initData)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.persisted = initData.persisted
    newInstance.serverIndependent = initData.serverIndependent
    newInstance.serverSpecific = initData.serverSpecific

    return newInstance
end

function ParaselenePoltergeist.SavedVariables.Load()
    local persisted = {}

    -- Load/migrate persisted.serverIndependent into serverIndependent.
    persisted.serverIndependent = ZO_SavedVars:NewAccountWide(
        ParaselenePoltergeist.SavedVariables.name,
        1,
        nil,
        ParaselenePoltergeist.SavedVariables.defaults.serverIndependent,
        'ServerIndependent'
    )
    local serverIndependent = {
        schemaVersion = '[SCHEMA_VERSION]',
    }

    -- Load/migrate persisted.serverSpecific into serverSpecific.
    persisted.serverSpecific = ZO_SavedVars:NewAccountWide(
        ParaselenePoltergeist.SavedVariables.name,
        1,
        nil,
        ParaselenePoltergeist.SavedVariables.defaults.serverSpecific,
        GetWorldName()
    )
    local serverSpecific = {
        furnishings = ParaselenePoltergeist.FurnishingStorage:Create(persisted.serverSpecific.furnishings),
        houses = ParaselenePoltergeist.HouseStorage:Create(persisted.serverSpecific.houses),
        schemaVersion = '[SCHEMA_VERSION]',
    }

    return ParaselenePoltergeist.SavedVariables:Create{
        persisted = persisted,
        serverIndependent = serverIndependent,
        serverSpecific = serverSpecific,
    }
end

function ParaselenePoltergeist.SavedVariables:Save()
    local lastSaved = tostring(os.date('%Y-%m-%d %H:%M:%S'))

    self.persisted.serverIndependent.schemaVersion = self.serverIndependent.schemaVersion
    self.persisted.serverIndependent.lastSaved = lastSaved

    self.persisted.serverSpecific.furnishings = self.serverSpecific.furnishings:Save()
    self.persisted.serverSpecific.houses = self.serverSpecific.houses:Save()
    self.persisted.serverSpecific.schemaVersion = self.serverSpecific.schemaVersion
    self.persisted.serverSpecific.lastSaved = lastSaved
end

function ParaselenePoltergeist.SavedVariables:Capture(houseId, editorMode)
    local furnitureId = self.serverSpecific.furnishings:Capture(editorMode)
    if not furnitureId then
        return false
    end

    return self.serverSpecific.houses:Capture(houseId, furnitureId)
end

function ParaselenePoltergeist.SavedVariables:GetClipboard(houseId)
    return self.serverSpecific.houses:GetClipboard(houseId)
end

function ParaselenePoltergeist.SavedVariables:GetFurniture(furnitureId)
    return self.serverSpecific.furnishings:GetFurniture(furnitureId)
end
