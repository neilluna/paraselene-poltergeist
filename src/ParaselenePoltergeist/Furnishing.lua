ParaselenePoltergeist.Furnishing = {}

function ParaselenePoltergeist.Furnishing:Clone(otherInstance)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.tag = otherInstance.tag
    newInstance.itemId = otherInstance.itemId
    newInstance.link = otherInstance.link

    return newInstance
end

function ParaselenePoltergeist.Furnishing.Load(savedData)
    return ParaselenePoltergeist.Furnishing:Clone{
        tag = savedData.tag,
        itemId = savedData.itemId,
        link = savedData.link,
    }
end

function ParaselenePoltergeist.Furnishing:Save()
    return {
        tag = self.tag,
        itemId = self.itemId,
        link = self.link,
    }
end

function ParaselenePoltergeist.Furnishing.Capture(tag)
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW
    local logger = PARASELENE_POLTERGEIST_DEBUG_LOGGER

    local furnitureId64 = nil

    if (GetCurrentZoneHouseId() <= 0) or not IsOwnerOfCurrentHouse() then
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_MUST_BE_IN_OWN_HOUSE), 1, 0, 0)
        return nil, nil
    end

    local editorMode = GetHousingEditorMode()
    if editorMode == HOUSING_EDITOR_MODE_PLACEMENT then
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_MUST_PLACE_FURNITURE), 1, 0, 0)
        return nil, nil
    end

    if not HousingEditorCanSelectTargettedFurniture() then
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_MUST_TARGET_FURNITURE), 1, 0, 0)
        return nil, nil
    end

    LockCameraRotation(true)
    HousingEditorSelectTargettedFurniture()
    furnitureId64 = HousingEditorGetSelectedFurnitureId()
    HousingEditorRequestModeChange(editorMode)
    LockCameraRotation(false)

    if not furnitureId64 then
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        logger:Error('Unable to get furniture ID.')
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_UNABLE_TO_CAPTURE_FURNITURE), 1, 0, 0)
        return nil, nil
    end

    local link = ParaselenePoltergeist.Furnishing.GetLink(furnitureId64)
    if not link then
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        logger:Error('Unable to get furniture link.')
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_UNABLE_TO_CAPTURE_FURNITURE), 1, 0, 0)
        return nil, nil
    end

    local itemId = ParaselenePoltergeist.Furnishing.GetItemIdFromLink(link)
    if not itemId then
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        logger:Error('Unable to extract item ID from the furniture link. link = ' .. (link or 'nil'))
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_UNABLE_TO_CAPTURE_FURNITURE), 1, 0, 0)
        return nil, nil
    end

    local furnitureId = Id64ToString(furnitureId64)

    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    logger:Debug('furnitureId = ' .. furnitureId)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    logger:Debug('tag = ' .. tag)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    logger:Debug('itemId = ' .. (itemId or 'nil'))
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    logger:Debug('link = ' .. (link or 'nil'))

    return furnitureId, ParaselenePoltergeist.Furnishing.Load{
        tag = tag,
        itemId = itemId,
        link = link,
    }
end

function ParaselenePoltergeist.Furnishing:Print()
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW

    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(self.link, 0, 1, 0)
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_TAG) .. self.tag, 0, 1, 0)
end

-- Stuff from Decotrack.

-- function ParaselenePoltergeist.Furnishing.GetItemId(furnitureId64)
--     local itemId = ParaselenePoltergeist.Furnishing.GetFurnitureItemId(furnitureId64)

--     if nil ~= itemId then
--         if not ParaselenePoltergeist.Furnishing.IsItemIdCollectible(itemId) then
--             return itemId
--         end
--     end
-- end

-- function ParaselenePoltergeist.Furnishing.GetFurnitureItemId(furnitureId64)
--     local link = ParaselenePoltergeist.Furnishing.GetFurnitureLink(furnitureId64)
--     return ParaselenePoltergeist.Furnishing.GetFurnitureLinkItemId(link), link
-- end

function ParaselenePoltergeist.Furnishing.GetLink(furnitureId64)
    local link, collectibleLink = GetPlacedFurnitureLink(furnitureId64, LINK_STYLE_BRACKETS)
    if not link or (link == '') then
        link = collectibleLink
    end
    return link
end

function ParaselenePoltergeist.Furnishing.GetItemIdFromLink(link)
    if not link then
        return nil
    end

    local startIndex
    if (#link >= 10) and (string.sub(link, 4, 9) == ':item:') then
        startIndex = 10
    elseif (#link >= 17) and (string.sub(link, 4, 16) == ':collectible:') then
        startIndex = 17
    else
        return nil
    end

    local startOfId, endOfId = string.find(link, '[0-9]+', startIndex, false)
    if startOfId and (startOfId == startIndex) then
        return tonumber(string.sub(link, startOfId, endOfId))
    end

    return nil
end

-- function ParaselenePoltergeist.Furnishing.IsItemIdCollectible(itemId)
--     local collectibleId = tonumber(itemId)
--     if collectibleId then
--         local cName = GetCollectibleName(collectibleId)
--         local cLink = GetCollectibleLink(collectibleId)
--         return cName ~= '', cName, cLink
--     end
--     return false, '', ''
-- end
