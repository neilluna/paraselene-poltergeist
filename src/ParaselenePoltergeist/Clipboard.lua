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
        msgWindow:AddText('You must be in one of your own houses.', 1, 0, 0)
        return
    end

    local houseId = GetCurrentZoneHouseId()
    if self.placementsByHouseId[houseId] then
        self.placementsByHouseId[houseId]:Print(msgWindow)
    else
        msgWindow:AddText('The clipboard for this house is empty.', 1, 1, 0)
    end

    return true, nil
end

function ParaselenePoltergeist.Clipboard:Capture()
    if not IsOwnerOfCurrentHouse() then
        return false, 'You must be in one of your own houses.'
    end

    local placement, errorMessage = ParaselenePoltergeist.Placement.Capture()
    if not placement then
        return false, errorMessage
    end

    self.placementsByHouseId[GetCurrentZoneHouseId()] = placement

    return true, nil
end
