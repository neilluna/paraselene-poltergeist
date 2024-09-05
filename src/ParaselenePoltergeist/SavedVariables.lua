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

function ParaselenePoltergeist.SavedVariables:SetClipboard(placement)
    return self.serverSpecific.houses:SetClipboard(placement)
end

function ParaselenePoltergeist.SavedVariables:GetClipboard()
    local success, clipboard = self.serverSpecific.houses:GetClipboard()
    return success, clipboard
end

function ParaselenePoltergeist.SavedVariables:ClearClipboard()
    return self.serverSpecific.houses:ClearClipboard()
end


function ParaselenePoltergeist.SavedVariables:DisplayClipboard()
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW

    local houseId = ParaselenePoltergeist.HouseStorage.GetHouseId()
    if not houseId then
        return false
    end

    local success, placement = self:GetClipboard()
    if not success then
        return false
    end

    if not placement then
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 0, 1, 1)
        return true
    end
    
    local furnitureId = placement.furnitureId
    self.serverSpecific.furnishings:Display(furnitureId)
    placement:Display()

    return true
end
