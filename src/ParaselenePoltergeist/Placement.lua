ParaselenePoltergeist.Placement = {}

function ParaselenePoltergeist.Placement:Clone(otherInstance)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.furnitureId = otherInstance.furnitureId
    newInstance.x = otherInstance.x
    newInstance.y = otherInstance.y
    newInstance.z = otherInstance.z
    newInstance.pitch = otherInstance.pitch
    newInstance.roll = otherInstance.roll
    newInstance.yaw = otherInstance.yaw

    return newInstance
end

function ParaselenePoltergeist.Placement.Load(savedData)
    return ParaselenePoltergeist.Placement:Clone{
        furnitureId = savedData.furnitureId,
        x = savedData.x,
        y = savedData.y,
        z = savedData.z,
        pitch = savedData.pitch,
        roll = savedData.roll,
        yaw = savedData.yaw,
    }
end

function ParaselenePoltergeist.Placement:Save()
    return {
        furnitureId = self.furnitureId,
        x = self.x,
        y = self.y,
        z = self.z,
        pitch = self.pitch,
        roll = self.roll,
        yaw = self.yaw,
    }
end

function ParaselenePoltergeist.Placement.Capture(furnitureId)
    local logger = PARASELENE_POLTERGEIST_DEBUG_LOGGER

    local furnitureId64 = StringToId64(furnitureId)
    local x, y, z = HousingEditorGetFurnitureWorldPosition(furnitureId64)
    local pitch, yaw, roll = HousingEditorGetFurnitureOrientation(furnitureId64)

    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    logger:Debug('x, y, z = ' .. x .. ', ' .. y .. ', ' .. z)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    logger:Debug('pitch, yaw, roll = ' .. pitch .. ', ' .. yaw .. ', ' .. roll)

    return ParaselenePoltergeist.Placement.Load{
        furnitureId = furnitureId,
        x = x,
        y = y,
        z = z,
        pitch = pitch % ParaselenePoltergeist.RAD360,
        roll = roll % ParaselenePoltergeist.RAD360,
        yaw = yaw % ParaselenePoltergeist.RAD360,
    }
end

function ParaselenePoltergeist.Placement:Print()
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW

    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_X) .. self.x, 0, 1, 0)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_Y) .. self.y, 0, 1, 0)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_Z) .. self.z, 0, 1, 0)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_PITCH) .. self.pitch, 0, 1, 0)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ROLL) .. self.roll, 0, 1, 0)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_YAW) .. self.yaw, 0, 1, 0)
end
