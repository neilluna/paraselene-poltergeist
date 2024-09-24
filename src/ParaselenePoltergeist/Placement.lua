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

function ParaselenePoltergeist.Placement.Capture(furnitureId)
    local label = GetString(PARASELENE_POLTERGEIST_NEW_PLACEMENT)
    ParaselenePoltergeist.logger:Info('label = ['  .. label .. '].')

    local furnitureId64 = StringToId64(furnitureId)

    local x, y, z = HousingEditorGetFurnitureWorldPosition(furnitureId64)
    if not (x and y and z) then
        local message = 'Unable to get the furniture position. ' ..
                        'x = [' .. (x or 'nil') .. '], ' ..
                        'y = [' .. (y or 'nil') .. '], ' ..
                        'z = [' .. (z or 'nil') .. '].'
        ParaselenePoltergeist.logger:Warn(message)
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_UNABLE_TO_CAPTURE_FURNITURE), 1, 0, 0)
        return nil
    end
    ParaselenePoltergeist.logger:Info('x, y, z = [' .. x .. '], [' .. y .. '], [' .. z .. '].')

    local pitch, yaw, roll = HousingEditorGetFurnitureOrientation(furnitureId64)
    if not (pitch and yaw and roll) then
        local message = 'Unable to get the furniture orientation. ' ..
                        'pitch = [' .. (pitch or 'nil') .. '], ' ..
                        'yaw = [' .. (yaw or 'nil') .. '], ' ..
                        'roll = [' .. (roll or 'nil') .. '].'
        ParaselenePoltergeist.logger:Warn(message)
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_UNABLE_TO_CAPTURE_FURNITURE), 1, 0, 0)
        return nil
    end
    ParaselenePoltergeist.logger:Info('pitch, yaw, roll = [' .. pitch .. '], [' .. yaw .. '], [' .. roll .. '].')

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

function ParaselenePoltergeist.Placement:GetLabel()
    return self.label
end

function ParaselenePoltergeist.Placement:SetLabel(label)
    self.label = label
end

function ParaselenePoltergeist.Placement:GetFurnitureId()
    return self.furnitureId
end

function ParaselenePoltergeist.Placement:GetPosition()
    return self.x, self.y, self.z
end

function ParaselenePoltergeist.Placement:GetOrientation()
    return self.pitch, self.yaw, self.roll
end
