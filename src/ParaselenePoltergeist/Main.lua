function ParaselenePoltergeist:Init()
    self.displayName = GetString(PARASELENE_POLTERGEIST_TITLE)
    EVENT_MANAGER:RegisterForEvent(
        self.displayName,
        EVENT_ADD_ON_LOADED,
        function(event, name) self:OnAddOnLoaded(event, name) end
    )
end

function ParaselenePoltergeist:OnAddOnLoaded(event, name)
    if name ~= self.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(self.displayName, EVENT_ADD_ON_LOADED)

    self.logger = LibDebugLogger:Create(self.name)
    self.logger:SetEnabled(true)
    self.logger:Info('OnAddOnLoaded() called.')

    self.messageWindow = LibMsgWin:CreateMsgWindow(
        'ParaselenePoltergeistMessages',
        GetString(PARASELENE_POLTERGEIST_TITLE)
    )
    self.messageWindow:SetHidden(true)

    ZO_PreHook('Logout', function() self.SavedVariables:Save() return false end)
    ZO_PreHook('ReloadUI', function() self.SavedVariables:Save() return false end)
    ZO_PreHook('Quit', function() self.SavedVariables:Save() return false end)

    ZO_CreateStringId(
        'SI_BINDING_NAME_PARASELENE_POLTERGEIST_CAPTURE_PLACEMENT',
        GetString(PARASELENE_POLTERGEIST_CAPTURE_PLACEMENT)
    )
    self:CreateSlashCommands()

    self.SavedVariables:Load()
    self.Settings:Load()

    self:UpdateClock()
end

function ParaselenePoltergeist:CreateSlashCommands()
    self.lsc = LibSlashCommander
    local command = self.lsc:Register(
        {
            GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_FULL),
            GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_SHORT),
            GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_ABBR),
        },
        function(args) self:ToggleWindow() end,
        GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_LSC_HELP)
    )

    local subCommand = command:RegisterSubCommand()
    subCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_SHOW_WINDOW))
    subCommand:SetCallback(function() self:ShowWindow() end)
    subCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_SHOW_WINDOW_LSC_HELP))

    subCommand = command:RegisterSubCommand()
    subCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_HIDE_WINDOW))
    subCommand:SetCallback(function() self:HideWindow() end)
    subCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_HIDE_WINDOW_LSC_HELP))

    subCommand = command:RegisterSubCommand()
    subCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_TOGGLE_WINDOW))
    subCommand:SetCallback(function() self:ToggleWindow() end)
    subCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_TOGGLE_WINDOW_LSC_HELP))

    subCommand = command:RegisterSubCommand()
    subCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_SHOW_CLIPBOARD))
    subCommand:SetCallback(function() self:ShowClipboard() end)
    subCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_SHOW_CLIPBOARD_LSC_HELP))

    subCommand = command:RegisterSubCommand()
    subCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_CLEAR_CLIPBOARD))
    subCommand:SetCallback(function() self:ClearClipboard() end)
    subCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_CLEAR_CLIPBOARD_LSC_HELP))

    subCommand = command:RegisterSubCommand()
    subCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_LOAD_PLACEMENT))
    subCommand:SetCallback(function(args) self:LoadPlacement(args) end)
    subCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_LOAD_PLACEMENT_LSC_HELP))

    subCommand = command:RegisterSubCommand()
    subCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_SAVE_PLACEMENT))
    subCommand:SetCallback(function(args) self:SavePlacement(args) end)
    subCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_SAVE_PLACEMENT_LSC_HELP))

    subCommand = command:RegisterSubCommand()
    subCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_LIST_PLACEMENTS))
    subCommand:SetCallback(function() self:ListPlacements() end)
    subCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_LIST_PLACEMENTS_LSC_HELP))

    subCommand = command:RegisterSubCommand()
    subCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_DELETE_PLACEMENT))
    subCommand:SetCallback(function(args) self:DeletePlacement(args) end)
    subCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_DELETE_PLACEMENT_LSC_HELP))
end

function ParaselenePoltergeist:Capture()
    self.logger:Info('Capture() called.')
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_CAPTURE_PLACEMENT), 1, 1, 1)

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    local editorMode = self.Furnishing.GetEditorMode()
    if not editorMode then
        return self:CommandComplete(false)
    end

    local furnitureId = self.FurnishingStorage:Capture(editorMode)
    if not furnitureId then
        return self:CommandComplete(false)
    end

    if not self.HouseStorage:Capture(houseId, furnitureId) then
        return self:CommandComplete(false)
    end

    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_PLACEMENT_CAPTURED), 0, 1, 0)

    return self:CommandComplete(true)
end

function ParaselenePoltergeist:ShowWindow()
    self.logger:Info('ShowWindow() called.')

    self.messageWindow:SetHidden(false)

    self.logger:Info('Command completed.')

    return true
end

function ParaselenePoltergeist:HideWindow()
    self.logger:Info('HideWindow() called.')

    self.messageWindow:SetHidden(true)

    self.logger:Info('Command completed.')

    return true
end

function ParaselenePoltergeist:ToggleWindow()
    self.logger:Info('ToggleWindow() called.')

    if self.messageWindow:IsHidden() then
        self.messageWindow:SetHidden(false)
    else
        self.messageWindow:SetHidden(true)
    end

    self.logger:Info('Command completed.')

    return true
end

function ParaselenePoltergeist:ShowClipboard()
    self.logger:Info('ShowClipboard() called.')
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_SHOW_CLIPBOARD), 1, 1, 1)

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if self.HouseStorage:IsClipboardEmpty(houseId) then
        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 0, 1, 1)
    else
        local clipboard = self.HouseStorage:GetClipboard(houseId)
        local placement = clipboard:GetPlacement()

        local taggedPlacementLabel = clipboard:GetTag() .. ' - ' .. placement:GetLabel()
        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_PLACEMENT_TAG) .. taggedPlacementLabel, 0, 1, 1)

        local furnitureId = placement:GetFurnitureId()
        local furniture = self.FurnishingStorage:GetFurniture(furnitureId)

        local taggedFurnitureLink = furniture:GetTag() .. ' - ' .. furniture:GetLink()
        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_FURNITURE_TAG) .. taggedFurnitureLink, 0, 1, 1)

        local x, y, z = placement:GetPosition()
        local pitch, roll, yaw = placement:GetOrientation()

        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_X) .. x, 0, 1, 1)
        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_Y) .. y, 0, 1, 1)
        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_Z) .. z, 0, 1, 1)
        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_PITCH) .. pitch, 0, 1, 1)
        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ROLL) .. roll, 0, 1, 1)
        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_YAW) .. yaw, 0, 1, 1)
    end

    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_CLIPBOARD_SHOWN), 0, 1, 0)

    return self:CommandComplete(true)
end

function ParaselenePoltergeist:ClearClipboard()
    self.logger:Info('ClearClipboard() called.')
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_CLEAR_CLIPBOARD), 1, 1, 1)

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if not self.HouseStorage:ClearClipboard(houseId) then
        return self:CommandComplete(false)
    end

    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_CLIPBOARD_CLEARED), 0, 1, 0)

    return self:CommandComplete(true)
end

function ParaselenePoltergeist:LoadPlacement(tag)
    self.logger:Info('LoadPlacement() called.')
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_LOAD_PLACEMENT), 1, 1, 1)

    tag = self:CanonizeTag(tag)
    if not tag then
        return self:CommandComplete(false)
    end

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if not self.HouseStorage:LoadPlacement(houseId, tag) then
        return self:CommandComplete(false)
    end

    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_PLACEMENT_LOADED), 0, 1, 0)

    return self:CommandComplete(true)
end

function ParaselenePoltergeist:SavePlacement(label)
    self.logger:Info('SavePlacement() called.')
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_SAVE_PLACEMENT), 1, 1, 1)

    if label ~= nil then
        label = self:CanonizeLabel(label)
        if not label then
            return self:CommandComplete(false)
        end
    end

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if not self.HouseStorage:SavePlacement(houseId, label) then
        return self:CommandComplete(false)
    end

    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_PLACEMENT_SAVED), 0, 1, 0)

    return self:CommandComplete(true)
end

function ParaselenePoltergeist:ListPlacements()
    self.logger:Info('ListPlacements() called.')
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_LIST_PLACEMENTS), 1, 1, 1)

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if self.HouseStorage:GetPlacementCount(houseId) == 0 then
        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_NO_PLACEMENTS), 0, 1, 1)
    else
        self.HouseStorage:IteratePlacements(
            houseId,
            function(tag, placement)
                self.messageWindow:AddText(tag .. ' - ' .. placement.label, 0, 1, 1)
            end
        )
    end

    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_PLACEMENTS_LISTED), 0, 1, 0)

    return self:CommandComplete(true)
end

function ParaselenePoltergeist:DeletePlacement(tag)
    self.logger:Info('DeletePlacement() called.')
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_DELETE_PLACEMENT), 1, 1, 1)

    tag = self:CanonizeTag(tag)
    if not tag then
        return self:CommandComplete(false)
    end

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if not self.HouseStorage:DeletePlacement(houseId, tag) then
        return self:CommandComplete(false)
    end

    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_PLACEMENT_DELETED), 0, 1, 0)

    return self:CommandComplete(true)
end

function ParaselenePoltergeist:CanonizeTag(tag)
    if (type(tag) == 'string') and (tag:match('%D') == nil) and (#tag >= 1) and (#tag <= 6) then
        tag = tonumber(tag)
    end

    if (type(tag) ~= 'number') or (tag % 1 ~= 0) or (tag < 1) or (tag > 999999) then
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_INVALID_TAG), 1, 0, 0)
        return nil
    end

    return tag
end

function ParaselenePoltergeist:CanonizeLabel(label)
    if (type(label) == 'number') or (type(label) == 'boolean') then
        label = tostring(label)
    end
    if (type(label) ~= 'string') or (#label < 1) or (#label > 100) then
        ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_INVALID_LABEL), 1, 0, 0)
        return nil
    end

    return label
end

function ParaselenePoltergeist:CommandComplete(result)
    self.logger:Info('CommandComplete(%s) called.', tostring(result))
    self.messageWindow:AddText('.', 0, 0, 0)
    return result
end

function ParaselenePoltergeist:UpdateClock()
    local time = os.date('%Y-%m-%d %H:%M:%S')
    ParaselenePoltergeistClockLabel:SetText(time)
    zo_callLater(function() self:UpdateClock() end, 1000)
end

ParaselenePoltergeist:Init()
