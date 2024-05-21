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
    msgWindow:AddText(GetString(PARASELENE_POLTERGEIST_ID) .. Id64ToString(self.furnishingId), 0, 1, 0)
    msgWindow:AddText(GetString(PARASELENE_POLTERGEIST_X) .. self.x, 0, 1, 0)
    msgWindow:AddText(GetString(PARASELENE_POLTERGEIST_Y) .. self.y, 0, 1, 0)
    msgWindow:AddText(GetString(PARASELENE_POLTERGEIST_Z) .. self.z, 0, 1, 0)
    msgWindow:AddText(GetString(PARASELENE_POLTERGEIST_PITCH) .. self.pitch, 0, 1, 0)
    msgWindow:AddText(GetString(PARASELENE_POLTERGEIST_ROLL) .. self.roll, 0, 1, 0)
    msgWindow:AddText(GetString(PARASELENE_POLTERGEIST_YAW) .. self.yaw, 0, 1, 0)
end

function ParaselenePoltergeist.Placement.Capture()
    local furnitureId = nil

    local editorMode = GetHousingEditorMode()
    if editorMode == HOUSING_EDITOR_MODE_PLACEMENT then
        return nil, GetString(PARASELENE_POLTERGEIST_MUST_PLACE_FURNITURE)
    end
    if not HousingEditorCanSelectTargettedFurniture() then
        return nil, GetString(PARASELENE_POLTERGEIST_MUST_TARGET_FURNITURE)
    end

    LockCameraRotation(true)
    HousingEditorSelectTargettedFurniture()
    furnitureId = HousingEditorGetSelectedFurnitureId()
    HousingEditorRequestModeChange(editorMode)
    LockCameraRotation(false)

    if not furnitureId then
        return nil, GetString(PARASELENE_POLTERGEIST_UNABLE_TO_CAPTURE_FURNITURE)
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
