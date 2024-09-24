ParaselenePoltergeist.Clipboard = {
    -- Content types (persisted enumeration).
    ACTION = 'Action',
    PLACEMENT = 'Placement',
}

function ParaselenePoltergeist.Clipboard:Create(initData)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.type = initData.type

    if newInstance.type == self.ACTION then
        newInstance.content = ParaselenePoltergeist.Action:Create(initData.content)
    elseif newInstance.type == self.PLACEMENT then
        newInstance.content = ParaselenePoltergeist.Placement:Create(initData.content)
    else
        ParaselenePoltergeist.logger:Warn('Invalid clipboard type [%s].', newInstance.type)
        return nil
    end

    newInstance.tag = initData.tag

    return newInstance
end

function ParaselenePoltergeist.Clipboard:Save()
    return {
        type = self.type,
        content = self.content:Save(),
        tag = self.tag,
    }
end

function ParaselenePoltergeist.Clipboard:GetType()
    return self.type
end

function ParaselenePoltergeist.Clipboard:GetContent()
    return self.content
end

function ParaselenePoltergeist.Clipboard:GetTag()
    return self.tag
end
