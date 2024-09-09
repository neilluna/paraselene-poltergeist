ParaselenePoltergeist.PlacementStorage = {}

function ParaselenePoltergeist.PlacementStorage:Create(initData)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.storage = {}
    for tag, placement in pairs(initData.storage) do
        newInstance.storage[tag] = ParaselenePoltergeist.Placement:Create(placement)
    end

    newInstance.nextAvailableTag = initData.nextAvailableTag

    return newInstance
end

function ParaselenePoltergeist.PlacementStorage.Init()
    return ParaselenePoltergeist.PlacementStorage:Create{
        storage = {},
        nextAvailableTag = 1,
    }
end

function ParaselenePoltergeist.PlacementStorage:Save()
    local storage = {}
    for tag, placement in pairs(self.storage) do
        storage[tag] = placement:Save()
    end

    return {
        storage = storage,
        nextAvailableTag = self.nextAvailableTag,
    }
end

function ParaselenePoltergeist.PlacementStorage:Capture(furnitureId)
    return ParaselenePoltergeist.Placement.Capture(furnitureId, self.nextAvailableTag), self.nextAvailableTag
end
