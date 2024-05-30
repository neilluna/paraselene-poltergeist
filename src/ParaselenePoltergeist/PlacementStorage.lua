ParaselenePoltergeist.PlacementStorage = {}

function ParaselenePoltergeist.PlacementStorage:Clone(otherInstance)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.storage = {}
    for tag, placement in pairs(otherInstance.storage) do
        newInstance.storage[tag] = ParaselenePoltergeist.Placement:Clone(placement)
    end
    newInstance.nextAvailableTag = otherInstance.nextAvailableTag

    return newInstance
end

function ParaselenePoltergeist.PlacementStorage.Load(savedData)
    local storage = {}
    if savedData.storage then
        for tag, placement in pairs(savedData.storage) do
            storage[tag] = ParaselenePoltergeist.Placement.Load(placement)
        end
    end

    local nextAvailableTag = savedData.nextAvailableTag
    if not nextAvailableTag then
        nextAvailableTag = 1
    end

    return ParaselenePoltergeist.PlacementStorage:Clone{
        storage = storage,
        nextAvailableTag = nextAvailableTag,
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

function ParaselenePoltergeist.PlacementStorage:Add(placement)
    self.storage[self.nextAvailableTag] = placement
    self.nextAvailableTag = self.nextAvailableTag + 1
end
