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
