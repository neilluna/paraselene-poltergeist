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

    self.messageWindow = LibMsgWin:CreateMsgWindow(
        'ParaselenePoltergeistMessages',
        GetString(PARASELENE_POLTERGEIST_TITLE)
    )
    self.messageWindow:SetHidden(true)

    ZO_PreHook('Logout', function() ParaselenePoltergeist.SavedVariables:Save() return false end)
    ZO_PreHook('ReloadUI', function() ParaselenePoltergeist.SavedVariables:Save() return false end)
    ZO_PreHook('Quit', function() ParaselenePoltergeist.SavedVariables:Save() return false end)

    ZO_CreateStringId(
        'SI_BINDING_NAME_PARASELENE_POLTERGEIST_CAPTURE_PLACEMENT',
        GetString(PARASELENE_POLTERGEIST_CAPTURE_PLACEMENT)
    )

    local slash_command_full = GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_FULL)
    local slash_command_short = GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_SHORT)
    local slash_command_abbreviation = GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_ABBREVIATION)

    SLASH_COMMANDS[slash_command_full] = function(args) self:SlashCommands(args) end
	SLASH_COMMANDS[slash_command_short] = function(args) self:SlashCommands(args) end
	SLASH_COMMANDS[slash_command_abbreviation] = function(args) self:SlashCommands(args) end

    self.SavedVariables:Load()
    self.Settings:Load()

    self:UpdateClock()
end

function ParaselenePoltergeist:Capture()
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

function ParaselenePoltergeist:SlashCommands(args)
    local command, commandArgs = string.match(args, "^%s*(%S+)%s*(.*)$")

    self.logger:Debug('command = [' .. (command or 'nil') .. ']')
    self.logger:Debug('commandArgs = [' .. (commandArgs or 'nil') .. ']')

    if not command then
        return
    end

    command = string.lower(command)

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_SHOW) then
        return self:ShowCommand()
    end

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_HIDE) then
        return self:HideCommand()
    end

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_DISPLAY) then
        return self:DisplayCommand()
    end

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_CLEAR) then
        return self:ClearCommand()
    end

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_LOAD) then
        return self:LoadCommand(commandArgs)
    end

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_SAVE) then
        return self:SaveCommand(commandArgs)
    end

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_LIST) then
        return self:ListCommand()
    end

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_DELETE) then
        return self:DeleteCommand(commandArgs)
    end
end

function ParaselenePoltergeist:ShowCommand()
    self.messageWindow:SetHidden(false)
    return true
end

function ParaselenePoltergeist:HideCommand()
    self.messageWindow:SetHidden(true)
    return true
end

function ParaselenePoltergeist:DisplayCommand()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_DISPLAY_CLIPBOARD), 1, 1, 1)

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if self.HouseStorage:IsClipboardEmpty(houseId) then
        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 0, 1, 1)
        return self:CommandComplete(true)
    end

    local clipboard = self.HouseStorage:GetClipboard(houseId)
    local furniture = self.FurnishingStorage:GetFurniture(clipboard.placement.furnitureId)

    local taggedPlacementLabel = clipboard.tag .. ' - ' .. clipboard.placement.label
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_PLACEMENT_TAG) .. taggedPlacementLabel, 0, 1, 1)

    local taggedFurnitureLink = furniture.tag .. ' - ' .. furniture.link
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_FURNITURE_TAG) .. taggedFurnitureLink, 0, 1, 1)

    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_X) .. clipboard.placement.x, 0, 1, 1)
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_Y) .. clipboard.placement.y, 0, 1, 1)
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_Z) .. clipboard.placement.z, 0, 1, 1)
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_PITCH) .. clipboard.placement.pitch, 0, 1, 1)
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ROLL) .. clipboard.placement.roll, 0, 1, 1)
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_YAW) .. clipboard.placement.yaw, 0, 1, 1)

    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_CLIPBOARD_DISPLAYED), 0, 1, 0)

    return self:CommandComplete(true)
end

function ParaselenePoltergeist:ClearCommand()
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

function ParaselenePoltergeist:LoadCommand(tag)
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

function ParaselenePoltergeist:SaveCommand(label)
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

function ParaselenePoltergeist:ListCommand()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_LIST_PLACEMENTS), 1, 1, 1)

    -- Do cool stuff here.
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_PLACEMENTS_LISTED), 0, 1, 0)

    return self:CommandComplete(true)
end

function ParaselenePoltergeist:DeleteCommand(tag)
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

function ParaselenePoltergeist:UpdateClock()
    local time = os.date('%Y-%m-%d %H:%M:%S')
    ParaselenePoltergeistClockLabel:SetText(time)
    zo_callLater(function() self:UpdateClock() end, 1000)
end

function ParaselenePoltergeist:CommandComplete(result)
    self.messageWindow:AddText('.', 0, 0, 0)
    return result
end

function ParaselenePoltergeist:CanonizeTag(tag)
    if (type(tag) == 'string') and (tag:match('%D') == nil) and (#tag >= 1) and (#tag <= 7) then
        tag = tonumber(tag)
    end
    if (type(tag) == 'number') and (tag % 1 == 0) and (tag >= 1) and (tag <= 1000000) then
        return tag
    end

    ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_INVALID_TAG), 1, 0, 0)

    return nil
end

function ParaselenePoltergeist:CanonizeLabel(label)
    if (type(label) == 'number') or (type(label) == 'boolean') then
        label = tostring(label)
    end
    if (type(label) == 'string') and (#label >= 1) and (#label <= 100) then
        return label
    end

    ParaselenePoltergeist.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_INVALID_LABEL), 1, 0, 0)

    return nil
end

ParaselenePoltergeist:Init()
