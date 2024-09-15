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
        local template = GetString(PARASELENE_POLTERGEIST_PLACEMENT_DOES_NOT_EXIST)
        local message = template:gsub('<tag>', tag)
        ParaselenePoltergeist.messageWindow:AddText(message, 1, 0, 0)
        return nil
    end

    return self.storage[tag]
end

function ParaselenePoltergeist.PlacementStorage:SavePlacement(tag, placement)
    self.storage[tag] = placement

    -- The tag of a captured placement is equal to the next available tag.
    -- The tag of a previously saved placement is not equal to the next available tag.
    -- If you are saving a captured placement, then advance the next available tag.
    if tag == self.nextAvailableTag then
        self.nextAvailableTag = self.nextAvailableTag + 1
    end
end

function ParaselenePoltergeist.PlacementStorage:DeletePlacement(tag)
    if not self.storage[tag] then
        local template = GetString(PARASELENE_POLTERGEIST_PLACEMENT_DOES_NOT_EXIST)
        local message = template:gsub('<tag>', tag)
        ParaselenePoltergeist.messageWindow:AddText(message, 1, 0, 0)
        return false
    end

    self.storage[tag] = nil

    return true
end
