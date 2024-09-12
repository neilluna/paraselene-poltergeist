ParaselenePoltergeist.FurnishingStorage = {
    storage = {},
    nextAvailableTag = 1,
}

function ParaselenePoltergeist.FurnishingStorage:Load(initData)
    for furnitureId, furnishing in pairs(initData.storage) do
        self.storage[furnitureId] = ParaselenePoltergeist.Furnishing:Create(furnishing)
    end

    self.nextAvailableTag = initData.nextAvailableTag
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

function ParaselenePoltergeist.FurnishingStorage:Capture(editorMode)
    local furnitureId, furnishing = ParaselenePoltergeist.Furnishing.Capture(editorMode, self.nextAvailableTag)
    if not furnitureId then
        return nil
    end

    if not self.storage[furnitureId] then
        self.storage[furnitureId] = furnishing
        self.nextAvailableTag = self.nextAvailableTag + 1
    end

    return furnitureId
end

function ParaselenePoltergeist.FurnishingStorage:GetFurniture(furnitureId)
    if not self.storage[furnitureId] then
        return nil
    end

    return self.storage[furnitureId]
end
