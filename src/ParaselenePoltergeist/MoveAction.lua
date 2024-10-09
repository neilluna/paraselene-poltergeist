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

function ParaselenePoltergeist.MoveAction:Invoke(house)
    local placement = house.placements:GetPlacement(self.placementTag)
    if not placement then
        return false
    end

    local furnitureId = placement:GetFurnitureId()
    ParaselenePoltergeist.logger:Info('furnitureId = [' .. furnitureId .. '].')

    local furnitureId64 = StringToId64(furnitureId)
    local x, y, z = placement:GetPosition()
    local pitch, yaw, roll = placement:GetOrientation()

    local result = HousingEditorRequestChangePositionAndOrientation(furnitureId64, x, y, z, pitch, yaw, roll)
    if result ~= HOUSING_REQUEST_RESULT_SUCCESS then
        ParaselenePoltergeist.logger:Warn('Unable to move the furniture. result = [' .. (result or 'nil') .. '].')
        ParaselenePoltergeist:PrintError(GetString(PARASELENE_POLTERGEIST_UNABLE_TO_MOVE_FURNITURE))
        return false
    end

    local message = 'Moved furniture to x = [' .. x .. '], y = [' .. y .. '], z = [' .. z .. '].'
    ParaselenePoltergeist.logger:Info(message)

    message = 'Rotated furniture to pitch = [' .. pitch .. '], yaw = [' .. yaw .. '], roll = [' .. roll .. '].'
    ParaselenePoltergeist.logger:Info(message)

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
