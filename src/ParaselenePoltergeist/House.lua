ParaselenePoltergeist.House = {}

function ParaselenePoltergeist.House:Create(initData)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    if initData.clipboard then
        newInstance.clipboard = ParaselenePoltergeist.Clipboard:Create(initData.clipboard)
    end

    newInstance.placements = ParaselenePoltergeist.PlacementStorage:Create(initData.placements)

    return newInstance
end

function ParaselenePoltergeist.House.Init()
    return ParaselenePoltergeist.House:Create{
        placements = ParaselenePoltergeist.PlacementStorage.Init()
    }
end

function ParaselenePoltergeist.House:Save()
    local house = {}

    if self.clipboard then
        house.clipboard = self.clipboard:Save()
    end

    house.placements = self.placements:Save()

    return house
end

function ParaselenePoltergeist.House.GetHouseId()
    local houseId = GetCurrentZoneHouseId()
    if (not houseId) or (houseId <= 0) or (not IsOwnerOfCurrentHouse()) then
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_MUST_BE_IN_OWN_HOUSE), 1, 0, 0)
        return nil
    end

    return houseId
end

function ParaselenePoltergeist.House:Capture(furnitureId)
    local placement, tag = self.placements:Capture(furnitureId)
    if not placement then
        return false
    end

    self.clipboard = ParaselenePoltergeist.Clipboard:Create{
        placement = placement,
        tag = tag,
    }

    return true
end

function ParaselenePoltergeist.House:IsClipboardEmpty()
    return self.clipboard == nil
end

function ParaselenePoltergeist.House:GetClipboard()
    if not self.clipboard then
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 0, 0)
        return nil
    end

    return self.clipboard
end

function ParaselenePoltergeist.House:ClearClipboard()
    if not self.clipboard then
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 0, 0)
        return false
    end

    self.clipboard = nil

    return true
end

function ParaselenePoltergeist.House:LoadPlacement(tag)
    local placement = self.placements:GetPlacement(tag)
    if not placement then
        return false
    end

    self.clipboard = ParaselenePoltergeist.Clipboard:Create{
        placement = placement,
        tag = tag,
    }

    return true
end

function ParaselenePoltergeist.House:SavePlacement(label)
    if not self.clipboard then
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 0, 0)
        return false
    end

    if label then
        self.clipboard.placement.label = label
    end

    self.placements:SavePlacement(self.clipboard.tag, self.clipboard.placement)

    return true
end

function ParaselenePoltergeist.House:DeletePlacement(tag)
    return self.placements:DeletePlacement(tag)
end
