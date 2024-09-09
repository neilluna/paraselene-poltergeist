ParaselenePoltergeist.Placement = {}

function ParaselenePoltergeist.Placement:Create(initData)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.label = initData.label
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
        label = self.label,
        furnitureId = self.furnitureId,
        x = self.x,
        y = self.y,
        z = self.z,
        pitch = self.pitch,
        roll = self.roll,
        yaw = self.yaw,
    }
end

function ParaselenePoltergeist.Placement.Capture(furnitureId, tag)
    local logger = PARASELENE_POLTERGEIST_DEBUG_LOGGER
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW

    local furnitureId64 = StringToId64(furnitureId)

    local x, y, z = HousingEditorGetFurnitureWorldPosition(furnitureId64)
    if not (x and y and z) then
        local message = 'Unable to get the furniture position. ' ..
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
        local message = 'Unable to get the furniture orientation. ' ..
                        'pitch = ' .. (pitch or 'nil') .. ', ' ..
                        'yaw = ' .. (yaw or 'nil') .. ', ' ..
                        'roll = ' .. (roll or 'nil')
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        logger:Error(message)
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_UNABLE_TO_CAPTURE_FURNITURE), 1, 0, 0)
        return nil
    end

    local label = GetString(PARASELENE_POLTERGEIST_PLACEMENT_TAG) .. tag

    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    logger:Debug('label = ' .. label)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    logger:Debug('x, y, z = ' .. x .. ', ' .. y .. ', ' .. z)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    logger:Debug('pitch, yaw, roll = ' .. pitch .. ', ' .. yaw .. ', ' .. roll)

    return ParaselenePoltergeist.Placement:Create{
        label = label,
        furnitureId = furnitureId,
        x = x,
        y = y,
        z = z,
        pitch = pitch % ParaselenePoltergeist.RAD360,
        roll = roll % ParaselenePoltergeist.RAD360,
        yaw = yaw % ParaselenePoltergeist.RAD360,
    }
end
