ParaselenePoltergeist.SavedVariables = {
    name = 'ParaselenePoltergeistSavedVariables',
    schemaVersion = '[SCHEMA_VERSION]',
    defaults = {
        serverIndependent = {
            schemaVersion = '[SCHEMA_VERSION]',
        },
        serverSpecific = {
            furnishings = {},
            houses = {},
            schemaVersion = '[SCHEMA_VERSION]',
        },
    },
}

function ParaselenePoltergeist.SavedVariables:Clone(otherInstance)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.persisted = otherInstance.persisted
    newInstance.serverIndependent = otherInstance.serverIndependent
    newInstance.serverSpecific = otherInstance.serverSpecific

    return newInstance
end

function ParaselenePoltergeist.SavedVariables.Load()
    local persisted = {}
    persisted.serverIndependent = ZO_SavedVars:NewAccountWide(
        ParaselenePoltergeist.SavedVariables.name,
        1,
        nil,
        ParaselenePoltergeist.SavedVariables.defaults.serverIndependent,
        'ServerIndependent'
    )
    persisted.serverSpecific = ZO_SavedVars:NewAccountWide(
        ParaselenePoltergeist.SavedVariables.name,
        1,
        nil,
        ParaselenePoltergeist.SavedVariables.defaults.serverSpecific,
        GetWorldName()
    )

    -- Load/migrate persisted.serverSpecific into serverSpecific.
    local serverSpecific = {
        furnishings = ParaselenePoltergeist.FurnishingStorage.Load(persisted.serverSpecific.furnishings),
        houses = {},
        schemaVersion = '[SCHEMA_VERSION]',
    }
    for houseId, house in pairs(persisted.serverSpecific.houses) do
        serverSpecific.houses[houseId] = ParaselenePoltergeist.House.Load(house)
    end

    -- Load/migrate persisted.serverIndependent into serverIndependent.
    local serverIndependent = {
        schemaVersion = '[SCHEMA_VERSION]',
    }

    return ParaselenePoltergeist.SavedVariables:Clone{
        persisted = persisted,
        serverSpecific = serverSpecific,
        serverIndependent = serverIndependent,
    }
end

function ParaselenePoltergeist.SavedVariables:Save()
    local lastSaved = tostring(os.date('%Y-%m-%d %H:%M:%S'))

    self.persisted.serverIndependent.schemaVersion = self.serverIndependent.schemaVersion
    self.persisted.serverIndependent.lastSaved = lastSaved

    self.persisted.serverSpecific.furnishings = self.serverSpecific.furnishings:Save()

    local houses = {}
    for houseId, house in pairs(self.serverSpecific.houses) do
        houses[houseId] = house:Save()
    end
    self.persisted.serverSpecific.houses = houses

    self.persisted.serverSpecific.schemaVersion = self.serverSpecific.schemaVersion
    self.persisted.serverSpecific.lastSaved = lastSaved
end

function ParaselenePoltergeist.SavedVariables:SetClipboard(placement)
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW

    local houseId = GetCurrentZoneHouseId()
    if (houseId <= 0) or not IsOwnerOfCurrentHouse() then
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_MUST_BE_IN_OWN_HOUSE), 1, 0, 0)
        return
    end

    if not self.serverSpecific.houses[houseId] then
        self.serverSpecific.houses[houseId] = ParaselenePoltergeist.House.Load{}
    end

    self.serverSpecific.houses[houseId]:SetClipboard(placement)
end

function ParaselenePoltergeist.SavedVariables:ClearClipboard()
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW

    local houseId = GetCurrentZoneHouseId()
    if (houseId <= 0) or not IsOwnerOfCurrentHouse() then
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_MUST_BE_IN_OWN_HOUSE), 1, 0, 0)
        return
    end

    if not self.serverSpecific.houses[houseId] then
        self.serverSpecific.houses[houseId] = ParaselenePoltergeist.House.Load{}
    else
        self.serverSpecific.houses[houseId]:ClearClipboard()
    end
end

function ParaselenePoltergeist.SavedVariables:PrintClipboard()
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW

    local houseId = GetCurrentZoneHouseId()
    if (houseId <= 0) or not IsOwnerOfCurrentHouse() then
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_MUST_BE_IN_OWN_HOUSE), 1, 0, 0)
        return
    end

    if not (self.serverSpecific.houses[houseId] and self.serverSpecific.houses[houseId].clipboard) then
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 1, 0)
        return
    end

    local furnitureId = self.serverSpecific.houses[houseId].clipboard.furnitureId
    self.serverSpecific.furnishings.storage[furnitureId]:Print()
    self.serverSpecific.houses[houseId].clipboard:Print()
end
