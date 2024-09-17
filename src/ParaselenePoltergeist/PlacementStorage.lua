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

function ParaselenePoltergeist.PlacementStorage:GetPlacement(tag)
    if not self.storage[tag] then
        ParaselenePoltergeist.logger:Info('Placement %d does not exist in the placement storage.', tag)
        local message = string.format(GetString(PARASELENE_POLTERGEIST_PLACEMENT_DOES_NOT_EXIST), tag)
        ParaselenePoltergeist.messageWindow:AddText(message, 1, 0, 0)
        return nil
    end

    return self.storage[tag]
end

function ParaselenePoltergeist.PlacementStorage:SetPlacement(tag, placement)
    -- The tag of a captured placement is equal to the next available tag.
    -- The tag of a previously saved placement is not equal to the next available tag.
    -- If a captured placement is being saved, then advance the next available tag.
    if tag == self.nextAvailableTag then
        ParaselenePoltergeist.logger:Info('Creating placement [%d] in the placement storage.', tag)
        self.nextAvailableTag = self.nextAvailableTag + 1
    else
        ParaselenePoltergeist.logger:Info('Saving placement [%d] in the placement storage.', tag)
    end

    self.storage[tag] = placement
end

function ParaselenePoltergeist.PlacementStorage:GetPlacementCount()
    return #self.storage
end

function ParaselenePoltergeist.PlacementStorage:IteratePlacements(placementFunction)
    local tags = {}
    for tag, _ in pairs(self.storage) do
        table.insert(tags, tag)
    end
    table.sort(tags)

    for _, tag in pairs(tags) do
        placementFunction(tag, self.storage[tag])
    end
end

function ParaselenePoltergeist.PlacementStorage:DeletePlacement(tag)
    if not self.storage[tag] then
        ParaselenePoltergeist.logger:Info('Placement %d does not exist in the placement storage.', tag)
        local message = string.format(GetString(PARASELENE_POLTERGEIST_PLACEMENT_DOES_NOT_EXIST), tag)
        ParaselenePoltergeist.messageWindow:AddText(message, 1, 0, 0)
        return false
    end

    self.storage[tag] = nil

    return true
end
