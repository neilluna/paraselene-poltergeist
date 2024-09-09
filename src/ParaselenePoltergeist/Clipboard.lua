ParaselenePoltergeist.Clipboard = {}

function ParaselenePoltergeist.Clipboard:Create(initData)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.placement = ParaselenePoltergeist.Placement:Create(initData.placement)
    newInstance.tag = initData.tag

    return newInstance
end

function ParaselenePoltergeist.Clipboard:Save()
    return {
        placement = self.placement:Save(),
        tag = self.tag,
    }
end
