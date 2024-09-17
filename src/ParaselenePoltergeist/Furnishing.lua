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
    if type(editorMode) ~= 'number' then
        ParaselenePoltergeist.logger:Warn('Unable to get the editor mode.')
        return nil
    end
    ParaselenePoltergeist.logger:Info(
        'editorMode = [%d] (%s).', editorMode, ParaselenePoltergeist.Furnishing.EditorModeToString(editorMode)
    )

    if editorMode ~= HOUSING_EDITOR_MODE_SELECTION then
        ParaselenePoltergeist.messageWindow:AddText(
            GetString(PARASELENE_POLTERGEIST_MUST_BE_IN_SELECTION_MODE),
            1, 0, 0
        )
        return nil
    end

    if HousingEditorCanSelectTargettedFurniture() then
        ParaselenePoltergeist.logger:Info('The player can select targetted furniture.')
    else
        ParaselenePoltergeist.logger:Info('The player cannot select targetted furniture.')
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_MUST_TARGET_FURNITURE), 1, 0, 0)
        return nil
    end

    return editorMode
end

function ParaselenePoltergeist.Furnishing.EditorModeToString(editorMode)
    if editorMode == HOUSING_EDITOR_MODE_BROWSE then
        return 'HOUSING_EDITOR_MODE_BROWSE'
    elseif editorMode == HOUSING_EDITOR_MODE_DISABLED then
        return 'HOUSING_EDITOR_MODE_DISABLED'
    elseif editorMode == HOUSING_EDITOR_MODE_LINK then
        return 'HOUSING_EDITOR_MODE_LINK'
    elseif editorMode == HOUSING_EDITOR_MODE_NODE_PLACEMENT then
        return 'HOUSING_EDITOR_MODE_NODE_PLACEMENT'
    elseif editorMode == HOUSING_EDITOR_MODE_PATH then
        return 'HOUSING_EDITOR_MODE_PATH'
    elseif editorMode == HOUSING_EDITOR_MODE_PLACEMENT then
        return 'HOUSING_EDITOR_MODE_PLACEMENT'
    elseif editorMode == HOUSING_EDITOR_MODE_SELECTION then
        return 'HOUSING_EDITOR_MODE_SELECTION'
    end

    return 'Unknown'
end

function ParaselenePoltergeist.Furnishing.Capture(editorMode, tag)
    local furnitureId64 = nil

    LockCameraRotation(true)
    HousingEditorSelectTargettedFurniture()
    furnitureId64 = HousingEditorGetSelectedFurnitureId()
    HousingEditorRequestModeChange(editorMode)
    LockCameraRotation(false)

    if not furnitureId64 then
        ParaselenePoltergeist.logger:Warn('Unable to get the furniture ID.')
        ParaselenePoltergeist.messageWindow:AddText(
            GetString(PARASELENE_POLTERGEIST_UNABLE_TO_CAPTURE_FURNITURE),
            1, 0, 0
        )
        return nil, nil
    end

    local furnitureId = Id64ToString(furnitureId64)
    ParaselenePoltergeist.logger:Info('furnitureId = [' .. furnitureId .. '].')

    local link = ParaselenePoltergeist.Furnishing.GetLinkFromFurnitureId(furnitureId64)
    if not link then
        ParaselenePoltergeist.messageWindow:AddText(
            GetString(PARASELENE_POLTERGEIST_UNABLE_TO_CAPTURE_FURNITURE),
            1, 0, 0
        )
        return nil, nil
    end

    local itemId = ParaselenePoltergeist.Furnishing.GetItemIdFromLink(link)
    if not itemId then
        ParaselenePoltergeist.messageWindow:AddText(
            GetString(PARASELENE_POLTERGEIST_UNABLE_TO_CAPTURE_FURNITURE),
            1, 0, 0
        )
        return nil, nil
    end

    return furnitureId, ParaselenePoltergeist.Furnishing:Create{
        tag = tag,
        itemId = itemId,
        link = link,
    }
end

function ParaselenePoltergeist.Furnishing.GetLinkFromFurnitureId(furnitureId64)
    local link, collectibleLink = GetPlacedFurnitureLink(furnitureId64, LINK_STYLE_BRACKETS)
    ParaselenePoltergeist.logger:Info('link = [' .. (link or 'nil') .. ']')
    ParaselenePoltergeist.logger:Info('collectibleLink = [' .. (collectibleLink or 'nil') .. ']')

    if not link or (link == '') then
        ParaselenePoltergeist.logger:Info('Using the collectibleLink as link.')
        link = collectibleLink
    end

    if not link then
        ParaselenePoltergeist.logger:Warn('Unable to use either the furniture link or the collectibleLink.')
        return nil
    end

    return link
end

function ParaselenePoltergeist.Furnishing.GetItemIdFromLink(link)
    local startIndex
    if (#link >= 10) and (string.sub(link, 4, 9) == ':item:') then
        startIndex = 10
        ParaselenePoltergeist.logger:Info('The link type is [item].')
    elseif (#link >= 17) and (string.sub(link, 4, 16) == ':collectible:') then
        startIndex = 17
        ParaselenePoltergeist.logger:Info('The link type is [collectible].')
    else
        ParaselenePoltergeist.logger:Warn('Unable to determine the link type.')
        return nil
    end

    local startOfId, endOfId = string.find(link, '[0-9]+', startIndex, false)

    if (not startOfId) or (startOfId ~= startIndex) then
        ParaselenePoltergeist.logger:Warn('Unable to get the item ID from the link or collectibleLink.')
        return nil
    end

    local itemId = tonumber(string.sub(link, startOfId, endOfId))
    ParaselenePoltergeist.logger:Info('itemId = [' .. itemId .. ']')

    return itemId
end

function ParaselenePoltergeist.Furnishing:GetLink()
    return self.link
end

function ParaselenePoltergeist.Furnishing:GetTag()
    return self.tag
end
