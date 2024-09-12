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

function ParaselenePoltergeist.HouseStorage:GetClipboard(houseId)
    if not self.storage[houseId] then
        return nil
    end

    return self.storage[houseId]:GetClipboard()
end
