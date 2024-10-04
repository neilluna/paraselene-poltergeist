ParaselenePoltergeist.ActionStorage = {}

function ParaselenePoltergeist.ActionStorage:Create(initData)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.storage = {}
    for tag, action in pairs(initData.storage) do
        newInstance.storage[tag] = ParaselenePoltergeist.Action:Create(action)
    end

    newInstance.nextAvailableTag = initData.nextAvailableTag

    return newInstance
end

function ParaselenePoltergeist.ActionStorage.Init()
    return ParaselenePoltergeist.ActionStorage:Create{
        storage = {},
        nextAvailableTag = 1,
    }
end

function ParaselenePoltergeist.ActionStorage:Save()
    local storage = {}
    for tag, action in pairs(self.storage) do
        storage[tag] = action:Save()
    end

    return {
        storage = storage,
        nextAvailableTag = self.nextAvailableTag,
    }
end

function ParaselenePoltergeist.ActionStorage:CreateMoveAction(placementTag)
    return ParaselenePoltergeist.Action:CreateMoveAction(placementTag), self.nextAvailableTag
end

function ParaselenePoltergeist.ActionStorage:GetAction(tag)
    if not self.storage[tag] then
        ParaselenePoltergeist.logger:Info('Action %d does not exist in the action storage.', tag)
        local message = string.format(GetString(PARASELENE_POLTERGEIST_ACTION_DOES_NOT_EXIST), tag)
        ParaselenePoltergeist:PrintError(message)
        return nil
    end

    return self.storage[tag]
end

function ParaselenePoltergeist.ActionStorage:SetAction(tag, action)
    -- The tag of a newly created action is equal to the next available tag.
    -- The tag of a previously saved action is not equal to the next available tag.
    -- If a newly created action is being saved, then advance the next available tag.
    if tag == self.nextAvailableTag then
        ParaselenePoltergeist.logger:Info('Creating action [%d] in the action storage.', tag)
        self.nextAvailableTag = self.nextAvailableTag + 1
    else
        ParaselenePoltergeist.logger:Info('Saving action [%d] in the action storage.', tag)
    end

    self.storage[tag] = action
end

function ParaselenePoltergeist.ActionStorage:GetActionCount()
    return #self.storage
end

function ParaselenePoltergeist.ActionStorage:IterateActions(actionFunction)
    local tags = {}
    for tag, _ in pairs(self.storage) do
        table.insert(tags, tag)
    end
    table.sort(tags)

    for _, tag in pairs(tags) do
        actionFunction(tag, self.storage[tag])
    end
end

function ParaselenePoltergeist.ActionStorage:InvokeAction(tag, placement)
    if not self.storage[tag] then
        ParaselenePoltergeist.logger:Info('Action %d does not exist in the action storage.', tag)
        local message = string.format(GetString(PARASELENE_POLTERGEIST_ACTION_DOES_NOT_EXIST), tag)
        ParaselenePoltergeist:PrintError(message)
        return false
    end

    return self.storage[tag]:Invoke(placement)
end

function ParaselenePoltergeist.ActionStorage:DeleteAction(tag)
    if not self.storage[tag] then
        ParaselenePoltergeist.logger:Info('Action %d does not exist in the action storage.', tag)
        local message = string.format(GetString(PARASELENE_POLTERGEIST_ACTION_DOES_NOT_EXIST), tag)
        ParaselenePoltergeist:PrintError(message)
        return false
    end

    self.storage[tag] = nil

    return true
end
