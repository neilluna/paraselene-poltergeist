ParaselenePoltergeist.Placement = {}

function ParaselenePoltergeist.Placement:Clone(otherInstance)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.furnishingId = otherInstance.furnishingId
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
        furnishingId = StringToId64(savedData.furnishingId),
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
        furnishingId = Id64ToString(self.furnishingId),
        x = self.x,
        y = self.y,
        z = self.z,
        pitch = self.pitch,
        roll = self.roll,
        yaw = self.yaw,
    }
end

function ParaselenePoltergeist.Placement:Print(msgWindow)
    msgWindow:AddText('ID: ' .. Id64ToString(self.furnishingId), 1, 1, 1)
    msgWindow:AddText('x: ' .. self.x, 1, 1, 1)
    msgWindow:AddText('y: ' .. self.y, 1, 1, 1)
    msgWindow:AddText('z: ' .. self.z, 1, 1, 1)
    msgWindow:AddText('pitch: ' .. self.pitch, 1, 1, 1)
    msgWindow:AddText('roll: ' .. self.roll, 1, 1, 1)
    msgWindow:AddText('yaw: ' .. self.yaw, 1, 1, 1)
end

function ParaselenePoltergeist.Placement.Capture()
    local furnitureId = nil

    local editorMode = GetHousingEditorMode()
    if editorMode == HOUSING_EDITOR_MODE_PLACEMENT then
        return nil, 'You must place the furniture before capturing its placement.'
    end
    if not HousingEditorCanSelectTargettedFurniture() then
        return nil, 'You must target the furniture before capturing its placement.'
    end

    LockCameraRotation(true)
    HousingEditorSelectTargettedFurniture()
    furnitureId = HousingEditorGetSelectedFurnitureId()
    HousingEditorRequestModeChange(editorMode)
    LockCameraRotation(false)

    if not furnitureId then
        return nil, 'Unable to capture the furniture placement.'
    end

    local x, y, z = HousingEditorGetFurnitureWorldPosition(furnitureId)
    local pitch, yaw, roll = HousingEditorGetFurnitureOrientation(furnitureId)

    return ParaselenePoltergeist.Placement.Load{
        furnishingId = Id64ToString(furnitureId),
        x = x,
        y = y,
        z = z,
        pitch = pitch % ParaselenePoltergeist.RAD360,
        roll = roll % ParaselenePoltergeist.RAD360,
        yaw = yaw % ParaselenePoltergeist.RAD360,
    }
end

-- function ParaselenePoltergeist.GetItemId(furnitureId)
--     local itemId = ParaselenePoltergeist.GetFurnitureItemId(furnitureId)

--     if nil ~= itemId then
--         if not ParaselenePoltergeist.IsItemIdCollectible(itemId) then
--             return itemId
--         end
--     end
-- end

-- function ParaselenePoltergeist.GetFurnitureItemId(furnitureId)
--     local link = ParaselenePoltergeist.GetFurnitureLink(furnitureId)
--     return ParaselenePoltergeist.GetFurnitureLinkItemId(link), link
-- end

-- function ParaselenePoltergeist.GetFurnitureLink(furnitureId)
--     local link, collectibleLink = GetPlacedFurnitureLink(furnitureId, LINK_STYLE_BRACKETS )
--     if (link == nil) or (link == '') then
--         return collectibleLink
--     end
--     return link
-- end

-- function ParaselenePoltergeist.GetFurnitureLinkItemId(link)
--     local startIndex
--     if string.sub( link, 4, 9 ) == ":item:" then
--         startIndex = 10
--     elseif string.sub( link, 4, 16 ) == ":collectible:" then
--         startIndex = 17
--     else
--         return link
--     end

--     local colonIndex = string.find( link, ":", startIndex + 1 )
--     local pipeIndex = string.find( link, "|", startIndex + 1 )

--     if (colonIndex == nil) and (pipeIndex == nil) then
--         return nil
--     end
--     if (colonIndex ~= nil) and (pipeIndex ~= nil) then
--         colonIndex = math.min(colonIndex, pipeIndex)
--     end

--     return tonumber(string.sub(link, startIndex, ((colonIndex ~= nil) and colonIndex or pipeIndex) - 1))
-- end

-- function ParaselenePoltergeist.IsItemIdCollectible(itemId)
--     local collectibleId = tonumber(itemId)
--     if collectibleId then
--         local cName = GetCollectibleName(collectibleId)
--         local cLink = GetCollectibleLink(collectibleId)
--         return cName ~= '', cName, cLink
--     end
--     return false, '', ''
-- end
