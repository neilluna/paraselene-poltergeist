ParaselenePoltergeist.FurnishingStorage = {}

function ParaselenePoltergeist.FurnishingStorage:Clone(otherInstance)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.storage = {}
    for furnitureId, furnishing in pairs(otherInstance.storage) do
        newInstance.storage[furnitureId] = ParaselenePoltergeist.Furnishing:Clone(furnishing)
    end
    newInstance.nextAvailableTag = otherInstance.nextAvailableTag

    return newInstance
end

function ParaselenePoltergeist.FurnishingStorage.Load(savedData)
    local storage = {}
    if savedData.storage then
        for furnitureId, furnishing in pairs(savedData.storage) do
            storage[furnitureId] = ParaselenePoltergeist.Furnishing.Load(furnishing)
        end
    end

    local nextAvailableTag = savedData.nextAvailableTag
    if not nextAvailableTag then
        nextAvailableTag = 1
    end

    return ParaselenePoltergeist.FurnishingStorage:Clone{
        storage = storage,
        nextAvailableTag = nextAvailableTag,
    }
end

function ParaselenePoltergeist.FurnishingStorage:Save()
    local storage = {}
    for furnitureId, furnishing in pairs(self.storage) do
        storage[furnitureId] = furnishing:Save()
    end

    return {
        storage = storage,
        nextAvailableTag = self.nextAvailableTag,
    }
end

function ParaselenePoltergeist.FurnishingStorage:Capture()
    local furnitureId, furnishing = ParaselenePoltergeist.Furnishing.Capture(self.nextAvailableTag)
    if not furnitureId then
        return nil
    end

    if not self.storage[furnitureId] then
        self.storage[furnitureId] = furnishing
        self.nextAvailableTag = self.nextAvailableTag + 1
    end

    return furnitureId
end
