ParaselenePoltergeist.HouseStorage = {
    storage = {},
}

function ParaselenePoltergeist.HouseStorage:Load(initData)
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
        self.storage[houseId] = ParaselenePoltergeist.House.Init()
    end

    return self.storage[houseId]:Capture(furnitureId)
end

function ParaselenePoltergeist.HouseStorage:IsClipboardEmpty(houseId)
    return (not self.storage[houseId]) or self.storage[houseId]:IsClipboardEmpty()
end

function ParaselenePoltergeist.HouseStorage:GetClipboard(houseId)
    if not self.storage[houseId] then
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 0, 0)
        return nil
    end

    return self.storage[houseId]:GetClipboard()
end

function ParaselenePoltergeist.HouseStorage:ClearClipboard(houseId)
    if not self.storage[houseId] then
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 0, 0)
        return false
    end

    return self.storage[houseId]:ClearClipboard()
end

function ParaselenePoltergeist.HouseStorage:LoadPlacement(houseId, tag)
    if not self.storage[houseId] then
        local template = GetString(PARASELENE_POLTERGEIST_PLACEMENT_DOES_NOT_EXIST)
        local message = template:gsub('<tag>', tag)
        ParaselenePoltergeist.messageWindow:AddText(message, 1, 0, 0)
        return false
    end

    return self.storage[houseId]:LoadPlacement(tag)
end

function ParaselenePoltergeist.HouseStorage:SavePlacement(houseId, label)
    if not self.storage[houseId] then
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 1, 0, 0)
        return false
    end

    return self.storage[houseId]:SavePlacement(label)
end

function ParaselenePoltergeist.HouseStorage:DeletePlacement(houseId, tag)
    if not self.storage[houseId] then
        local template = GetString(PARASELENE_POLTERGEIST_PLACEMENT_DOES_NOT_EXIST)
        local message = template:gsub('<tag>', tag)
        ParaselenePoltergeist.messageWindow:AddText(message, 1, 0, 0)
        return false
    end

    return self.storage[houseId]:DeletePlacement(tag)
end
