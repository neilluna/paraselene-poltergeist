ParaselenePoltergeist.Clipboard = {}

function ParaselenePoltergeist.Clipboard:Clone(otherInstance)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.placementsByHouseId = otherInstance.placementsByHouseId

    return newInstance
end

function ParaselenePoltergeist.Clipboard.Load(savedData)
    local placementsByHouseId = {}
    for houseId, placementData in pairs(savedData) do
        placementsByHouseId[houseId] = ParaselenePoltergeist.Placement.Load(placementData)
    end

    return ParaselenePoltergeist.Clipboard:Clone{
        placementsByHouseId = placementsByHouseId,
    }
end

function ParaselenePoltergeist.Clipboard:Save()
    local savedData = {}
    for houseId, placement in pairs(self.placementsByHouseId) do
        savedData[houseId] = placement:Save()
    end

    return savedData
end

function ParaselenePoltergeist.Clipboard:IsEmpty()
    local next = next
    return next(self.placementsByHouseId) == nil
end

function ParaselenePoltergeist.Clipboard:Print(msgWindow)
    if not IsOwnerOfCurrentHouse() then
        msgWindow:AddText(GetString(PARASELENE_POLTERGEIST_MUST_BE_IN_OWN_HOUSE), 1, 0, 0)
        return
    end

    local houseId = GetCurrentZoneHouseId()
    if self.placementsByHouseId[houseId] then
        self.placementsByHouseId[houseId]:Print(msgWindow)
    else
        msgWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 1, 0)
    end

    return true, nil
end

function ParaselenePoltergeist.Clipboard:Capture()
    if not IsOwnerOfCurrentHouse() then
        return false, GetString(PARASELENE_POLTERGEIST_MUST_BE_IN_OWN_HOUSE)
    end

    local placement, errorMessage = ParaselenePoltergeist.Placement.Capture()
    if not placement then
        return false, errorMessage
    end

    self.placementsByHouseId[GetCurrentZoneHouseId()] = placement

    return true, nil
end
