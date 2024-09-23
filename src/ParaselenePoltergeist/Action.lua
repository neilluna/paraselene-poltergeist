ParaselenePoltergeist.Action = {}

function ParaselenePoltergeist.Action:Create(initData)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.label = initData.label

    return newInstance
end

function ParaselenePoltergeist.Action:Save()
    return {
        label = self.label,
    }
end

function ParaselenePoltergeist.Action:GetLabel()
    return self.label
end

function ParaselenePoltergeist.Action:SetLabel(label)
    self.label = label
end
