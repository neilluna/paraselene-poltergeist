ParaselenePoltergeist.House = {}

function ParaselenePoltergeist.House:Create(initData)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    if initData.clipboard then
        newInstance.clipboard = ParaselenePoltergeist.Clipboard:Create(initData.clipboard)
    end

    newInstance.actions = ParaselenePoltergeist.ActionStorage:Create(initData.actions)
    newInstance.placements = ParaselenePoltergeist.PlacementStorage:Create(initData.placements)

    return newInstance
end

function ParaselenePoltergeist.House.Init()
    return ParaselenePoltergeist.House:Create{
        actions = ParaselenePoltergeist.ActionStorage.Init(),
        placements = ParaselenePoltergeist.PlacementStorage.Init(),
    }
end

function ParaselenePoltergeist.House:Save()
    local house = {}

    if self.clipboard then
        house.clipboard = self.clipboard:Save()
    end

    house.actions = self.actions:Save()
    house.placements = self.placements:Save()

    return house
end

function ParaselenePoltergeist.House.GetHouseId()
    local houseId = GetCurrentZoneHouseId()
    if (not houseId) or (houseId <= 0) then
        ParaselenePoltergeist.logger:Warn('Invalid houseId. houseId = [' .. (houseId or 'nil') .. '].')
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_MUST_BE_IN_OWN_HOUSE), 1, 0, 0)
        return nil
    end
    ParaselenePoltergeist.logger:Info('houseId = [' .. houseId  .. '].')

    local isOwnerOfCurrectHouse = IsOwnerOfCurrentHouse()
    if isOwnerOfCurrectHouse then
        ParaselenePoltergeist.logger:Info('The player is the owner of current house.')
    else
        ParaselenePoltergeist.logger:Info('The player is not the owner of current house.')
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
        type = ParaselenePoltergeist.Clipboard.PLACEMENT,
        content = placement,
        tag = tag,
    }

    return true
end

function ParaselenePoltergeist.House:IsClipboardEmpty()
    return self.clipboard == nil
end

function ParaselenePoltergeist.House:GetClipboard()
    if not self.clipboard then
        ParaselenePoltergeist.logger:Info('The clipboard does not exist in this house.')
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 0, 0)
        return nil
    end

    return self.clipboard
end

function ParaselenePoltergeist.House:ClearClipboard()
    if not self.clipboard then
        ParaselenePoltergeist.logger:Info('The clipboard does not exist in this house.')
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 0, 0)
        return false
    end

    self.clipboard = nil

    return true
end

function ParaselenePoltergeist.House:LoadAction(tag)
    local action = self.actions:GetAction(tag)
    if not action then
        return false
    end

    self.clipboard = ParaselenePoltergeist.Clipboard:Create{
        type = ParaselenePoltergeist.Clipboard.ACTION,
        content = action,
        tag = tag,
    }

    return true
end

function ParaselenePoltergeist.House:SaveAction(label)
    if not self.clipboard then
        ParaselenePoltergeist.logger:Info('The clipboard does not exist in this house.')
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 0, 0)
        return false
    end

    if self.clipboard:GetType() ~= self.clipboard.ACTION then
        ParaselenePoltergeist.logger:Info('The clipboard does not contain an action.')
        ParaselenePoltergeist.messageWindow:AddText(
            GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_NOT_AN_ACTION),
            1, 0, 0
        )
        return false
    end

    local content = self.clipboard:GetContent()

    if label then
        content:SetLabel(label)
    end

    self.actions:SetAction(self.clipboard.tag, content)

    return true
end

function ParaselenePoltergeist.House:GetActionCount()
    return self.actions:GetActionCount()
end

function ParaselenePoltergeist.House:IterateActions(actionFunction)
    self.actions:IterateActions(actionFunction)
end

function ParaselenePoltergeist.House:InvokeAction(tag)
    return self.actions:InvokeAction(tag)
end

function ParaselenePoltergeist.House:DeleteAction(tag)
    return self.actions:DeleteAction(tag)
end

function ParaselenePoltergeist.House:LoadPlacement(tag)
    local placement = self.placements:GetPlacement(tag)
    if not placement then
        return false
    end

    self.clipboard = ParaselenePoltergeist.Clipboard:Create{
        type = ParaselenePoltergeist.Clipboard.PLACEMENT,
        content = placement,
        tag = tag,
    }

    return true
end

function ParaselenePoltergeist.House:SavePlacement(label)
    if not self.clipboard then
        ParaselenePoltergeist.logger:Info('The clipboard does not exist in this house.')
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 0, 0)
        return false
    end

    if self.clipboard:GetType() ~= self.clipboard.PLACEMENT then
        ParaselenePoltergeist.logger:Info('The clipboard does not contain a placement.')
        ParaselenePoltergeist.messageWindow:AddText(
            GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_NOT_A_PLACEMENT),
            1, 0, 0
        )
        return false
    end

    local content = self.clipboard:GetContent()

    if label then
        content:SetLabel(label)
    end

    self.placements:SetPlacement(self.clipboard.tag, content)

    return true
end

function ParaselenePoltergeist.House:GetPlacementCount()
    return self.placements:GetPlacementCount()
end

function ParaselenePoltergeist.House:IteratePlacements(placementFunction)
    self.placements:IteratePlacements(placementFunction)
end

function ParaselenePoltergeist.House:DeletePlacement(tag)
    return self.placements:DeletePlacement(tag)
end
