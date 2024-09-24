ParaselenePoltergeist.HouseStorage = {
    storage = {},
}

function ParaselenePoltergeist.HouseStorage:Load(initData)
    self.storage = {}
    for houseId, house in pairs(initData.storage) do
        self.storage[houseId] = ParaselenePoltergeist.House:Create(house)
    end
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

function ParaselenePoltergeist.HouseStorage:Capture(houseId, furnitureId)
    if not self.storage[houseId] then
        ParaselenePoltergeist.logger:Info('Creating house %d in the house storage.', houseId)
        self.storage[houseId] = ParaselenePoltergeist.House.Init()
    end

    return self.storage[houseId]:Capture(furnitureId)
end

function ParaselenePoltergeist.HouseStorage:IsClipboardEmpty(houseId)

    if not self.storage[houseId] then
        ParaselenePoltergeist.logger:Info('House %d does not exist in the house storage.', houseId)
        return true
    end

    return self.storage[houseId]:IsClipboardEmpty()
end

function ParaselenePoltergeist.HouseStorage:GetClipboard(houseId)
    if not self.storage[houseId] then
        ParaselenePoltergeist.logger:Info('House %d does not exist in the house storage.', houseId)
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 0, 0)
        return nil
    end

    return self.storage[houseId]:GetClipboard()
end

function ParaselenePoltergeist.HouseStorage:DeleteClipboard(houseId)
    if not self.storage[houseId] then
        ParaselenePoltergeist.logger:Info('House %d does not exist in the house storage.', houseId)
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 0, 0)
        return false
    end

    return self.storage[houseId]:ClearClipboard()
end

function ParaselenePoltergeist.HouseStorage:LoadAction(houseId, tag)
    if not self.storage[houseId] then
        ParaselenePoltergeist.logger:Info('House %d does not exist in the house storage.', houseId)
        local message = string.format(GetString(PARASELENE_POLTERGEIST_ACTION_DOES_NOT_EXIST), tag)
        ParaselenePoltergeist.messageWindow:AddText(message, 1, 0, 0)
        return false
    end

    return self.storage[houseId]:LoadAction(tag)
end

function ParaselenePoltergeist.HouseStorage:SaveAction(houseId, label)
    if not self.storage[houseId] then
        ParaselenePoltergeist.logger:Info('House %d does not exist in the house storage.', houseId)
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 0, 0)
        return false
    end

    return self.storage[houseId]:SaveAction(label)
end

function ParaselenePoltergeist.HouseStorage:GetActionCount(houseId)
    if not self.storage[houseId] then
        ParaselenePoltergeist.logger:Info('House %d does not exist in the house storage.', houseId)
        return 0
    end

    return self.storage[houseId]:GetActionCount()
end

function ParaselenePoltergeist.HouseStorage:IterateActions(houseId, actionFunction)
    if not self.storage[houseId] then
        ParaselenePoltergeist.logger:Info('House %d does not exist in the house storage.', houseId)
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_NO_ACTIONS), 1, 0, 0)
        return false
    end

    self.storage[houseId]:IterateActions(actionFunction)

    return true
end

function ParaselenePoltergeist.HouseStorage:InvokeAction(houseId, tag)
    if not self.storage[houseId] then
        ParaselenePoltergeist.logger:Info('House %d does not exist in the house storage.', houseId)
        local message = string.format(GetString(PARASELENE_POLTERGEIST_ACTION_DOES_NOT_EXIST), tag)
        ParaselenePoltergeist.messageWindow:AddText(message, 1, 0, 0)
        return false
    end

    return self.storage[houseId]:InvokeAction(tag)
end

function ParaselenePoltergeist.HouseStorage:DeleteAction(houseId, tag)
    if not self.storage[houseId] then
        ParaselenePoltergeist.logger:Info('House %d does not exist in the house storage.', houseId)
        local message = string.format(GetString(PARASELENE_POLTERGEIST_ACTION_DOES_NOT_EXIST), tag)
        ParaselenePoltergeist.messageWindow:AddText(message, 1, 0, 0)
        return false
    end

    return self.storage[houseId]:DeleteAction(tag)
end

function ParaselenePoltergeist.HouseStorage:LoadPlacement(houseId, tag)
    if not self.storage[houseId] then
        ParaselenePoltergeist.logger:Info('House %d does not exist in the house storage.', houseId)
        local message = string.format(GetString(PARASELENE_POLTERGEIST_PLACEMENT_DOES_NOT_EXIST), tag)
        ParaselenePoltergeist.messageWindow:AddText(message, 1, 0, 0)
        return false
    end

    return self.storage[houseId]:LoadPlacement(tag)
end

function ParaselenePoltergeist.HouseStorage:SavePlacement(houseId, label)
    if not self.storage[houseId] then
        ParaselenePoltergeist.logger:Info('House %d does not exist in the house storage.', houseId)
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 0, 0)
        return false
    end

    return self.storage[houseId]:SavePlacement(label)
end

function ParaselenePoltergeist.HouseStorage:GetPlacementCount(houseId)
    if not self.storage[houseId] then
        ParaselenePoltergeist.logger:Info('House %d does not exist in the house storage.', houseId)
        return 0
    end

    return self.storage[houseId]:GetPlacementCount()
end

function ParaselenePoltergeist.HouseStorage:IteratePlacements(houseId, placementFunction)
    if not self.storage[houseId] then
        ParaselenePoltergeist.logger:Info('House %d does not exist in the house storage.', houseId)
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_NO_PLACEMENTS), 1, 0, 0)
        return false
    end

    self.storage[houseId]:IteratePlacements(placementFunction)

    return true
end

function ParaselenePoltergeist.HouseStorage:DeletePlacement(houseId, tag)
    if not self.storage[houseId] then
        ParaselenePoltergeist.logger:Info('House %d does not exist in the house storage.', houseId)
        local message = string.format(GetString(PARASELENE_POLTERGEIST_PLACEMENT_DOES_NOT_EXIST), tag)
        ParaselenePoltergeist.messageWindow:AddText(message, 1, 0, 0)
        return false
    end

    return self.storage[houseId]:DeletePlacement(tag)
end
