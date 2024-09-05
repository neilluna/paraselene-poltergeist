ParaselenePoltergeist.HouseStorage = {}

function ParaselenePoltergeist.HouseStorage:Create(initData)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.storage = {}
    for houseId, house in pairs(initData.storage) do
        newInstance.storage[houseId] = ParaselenePoltergeist.House:Create(house)
    end

    return newInstance
end

function ParaselenePoltergeist.HouseStorage:Save()
    local storage = {}
    for houseId, house in pairs(self.storage) do
        storage[houseId] = house:Save()
    end

    return {
        storage = storage,
    }
end

function ParaselenePoltergeist.HouseStorage.GetHouseId()
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW

    local houseId = GetCurrentZoneHouseId()
    if (not houseId) or (houseId <= 0) or (not IsOwnerOfCurrentHouse()) then
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_MUST_BE_IN_OWN_HOUSE), 1, 0, 0)
        return nil
    end

    return houseId
end

function ParaselenePoltergeist.HouseStorage:SetClipboard(placement)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    local houseId = self.GetHouseId()
    if not houseId then
        return false
    end

    if not self.storage[houseId] then
        self.storage[houseId] = ParaselenePoltergeist.House.Init()
    end

    self.storage[houseId]:SetClipboard(placement)

    return true
end

function ParaselenePoltergeist.HouseStorage:GetClipboard()
    local houseId = self.GetHouseId()
    if not houseId then
        return false, nil
    end

    if not self.storage[houseId] then
        return true, nil
    end

    return true, self.storage[houseId]:GetClipboard()
end

function ParaselenePoltergeist.HouseStorage:ClearClipboard()
    local houseId = self.GetHouseId()
    if not houseId then
        return false
    end

    if not self.storage[houseId] then
        return true
    end

    self.storage[houseId]:ClearClipboard()

    return true
end
