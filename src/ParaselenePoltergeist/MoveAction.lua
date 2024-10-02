ParaselenePoltergeist.MoveAction = {}

function ParaselenePoltergeist.MoveAction:Create(initData)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.type = initData.type
    newInstance.label = initData.label
    newInstance.placementTag = initData.placementTag

    return newInstance
end

function ParaselenePoltergeist.MoveAction:Save()
    return {
        type = self.type,
        label = self.label,
        placementTag = self.placementTag,
    }
end

function ParaselenePoltergeist.MoveAction:Invoke()
    ParaselenePoltergeist.logger:Info('TODO: Invoke action [%s], [%s], [%d].', self.type, self.label, self.placementTag)
    return true
end

function ParaselenePoltergeist.MoveAction:GetLabel()
    return self.label
end

function ParaselenePoltergeist.MoveAction:SetLabel(label)
    self.label = label
end

function ParaselenePoltergeist.MoveAction:GetType()
    return self.type
end

function ParaselenePoltergeist.MoveAction:GetPlacementTag()
    return self.placementTag
end
