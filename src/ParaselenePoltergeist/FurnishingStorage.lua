ParaselenePoltergeist.FurnishingStorage = {}

function ParaselenePoltergeist.FurnishingStorage:Create(initData)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.storage = {}
    for furnitureId, furnishing in pairs(initData.storage) do
        newInstance.storage[furnitureId] = ParaselenePoltergeist.Furnishing:Create(furnishing)
    end

    newInstance.nextAvailableTag = initData.nextAvailableTag

    return newInstance
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

function ParaselenePoltergeist.FurnishingStorage:Display(furnitureId)
    if self.storage[furnitureId] then
        self.storage[furnitureId]:Display()
    end 
end
