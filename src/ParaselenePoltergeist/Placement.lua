ParaselenePoltergeist.Placement = {}

function ParaselenePoltergeist.Placement:Create(initData)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.furnitureId = initData.furnitureId
    newInstance.x = initData.x
    newInstance.y = initData.y
    newInstance.z = initData.z
    newInstance.pitch = initData.pitch
    newInstance.roll = initData.roll
    newInstance.yaw = initData.yaw

    return newInstance
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
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW

    local furnitureId64 = StringToId64(furnitureId)

    local x, y, z = HousingEditorGetFurnitureWorldPosition(furnitureId64)
    if not (x and y and z) then
        local message = 'Unable to get furniture position. ' ..
                        'x = ' .. (x or 'nil') .. ', ' ..
                        'y = ' .. (y or 'nil') .. ', ' ..
                        'z = ' .. (z or 'nil')
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        logger:Error(message)
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_UNABLE_TO_CAPTURE_FURNITURE), 1, 0, 0)
        return nil
    end

    local pitch, yaw, roll = HousingEditorGetFurnitureOrientation(furnitureId64)
    if not (pitch and yaw and roll) then
        local message = 'Unable to get furniture orientation. ' ..
                        'pitch = ' .. (pitch or 'nil') .. ', ' ..
                        'yaw = ' .. (yaw or 'nil') .. ', ' ..
                        'roll = ' .. (roll or 'nil')
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        logger:Error(message)
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_UNABLE_TO_CAPTURE_FURNITURE), 1, 0, 0)
        return nil
    end

    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    logger:Debug('x, y, z = ' .. x .. ', ' .. y .. ', ' .. z)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    logger:Debug('pitch, yaw, roll = ' .. pitch .. ', ' .. yaw .. ', ' .. roll)

    return ParaselenePoltergeist.Placement:Create{
        furnitureId = furnitureId,
        x = x,
        y = y,
        z = z,
        pitch = pitch % ParaselenePoltergeist.RAD360,
        roll = roll % ParaselenePoltergeist.RAD360,
        yaw = yaw % ParaselenePoltergeist.RAD360,
    }
end

function ParaselenePoltergeist.Placement:Display()
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW

    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_X) .. self.x, 0, 1, 1)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_Y) .. self.y, 0, 1, 1)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_Z) .. self.z, 0, 1, 1)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_PITCH) .. self.pitch, 0, 1, 1)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ROLL) .. self.roll, 0, 1, 1)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_YAW) .. self.yaw, 0, 1, 1)
end
