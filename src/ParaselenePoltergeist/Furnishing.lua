ParaselenePoltergeist.Furnishing = {}

function ParaselenePoltergeist.Furnishing:Create(initData)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    newInstance.tag = initData.tag
    newInstance.itemId = initData.itemId
    newInstance.link = initData.link

    return newInstance
end

function ParaselenePoltergeist.Furnishing:Save()
    return {
        tag = self.tag,
        itemId = self.itemId,
        link = self.link,
    }
end

function ParaselenePoltergeist.Furnishing.GetEditorMode()
    local editorMode = GetHousingEditorMode()
    if editorMode == HOUSING_EDITOR_MODE_PLACEMENT then
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_MUST_PLACE_FURNITURE), 1, 0, 0)
        return nil
    end

    if not HousingEditorCanSelectTargettedFurniture() then
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_MUST_TARGET_FURNITURE), 1, 0, 0)
        return nil
    end

    return editorMode
end

function ParaselenePoltergeist.Furnishing.Capture(editorMode, tag)
    local furnitureId64 = nil

    LockCameraRotation(true)
    HousingEditorSelectTargettedFurniture()
    furnitureId64 = HousingEditorGetSelectedFurnitureId()
    HousingEditorRequestModeChange(editorMode)
    LockCameraRotation(false)

    if not furnitureId64 then
        ParaselenePoltergeist.logger:Error('Unable to get the furniture ID.')
        ParaselenePoltergeist.messageWindow:AddText(
            GetString(PARASELENE_POLTERGEIST_UNABLE_TO_CAPTURE_FURNITURE),
            1, 0, 0
        )
        return nil, nil
    end

    local link = ParaselenePoltergeist.Furnishing.GetLink(furnitureId64)
    if not link then
        ParaselenePoltergeist.logger:Error('Unable to get the furniture link.')
        ParaselenePoltergeist.messageWindow:AddText(
            GetString(PARASELENE_POLTERGEIST_UNABLE_TO_CAPTURE_FURNITURE),
            1, 0, 0
        )
        return nil, nil
    end

    local itemId = ParaselenePoltergeist.Furnishing.GetItemIdFromLink(link)
    if not itemId then
        ParaselenePoltergeist.logger:Error(
            'Unable to extract the item ID from the furniture link. link = ' .. (link or 'nil')
        )
        ParaselenePoltergeist.messageWindow:AddText(
            GetString(PARASELENE_POLTERGEIST_UNABLE_TO_CAPTURE_FURNITURE),
            1, 0, 0
        )
        return nil, nil
    end

    local furnitureId = Id64ToString(furnitureId64)

    ParaselenePoltergeist.logger:Debug('furnitureId = ' .. furnitureId)
    ParaselenePoltergeist.logger:Debug('tag = ' .. tag)
    ParaselenePoltergeist.logger:Debug('itemId = ' .. (itemId or 'nil'))
    ParaselenePoltergeist.logger:Debug('link = ' .. (link or 'nil'))

    return furnitureId, ParaselenePoltergeist.Furnishing:Create{
        tag = tag,
        itemId = itemId,
        link = link,
    }
end

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
