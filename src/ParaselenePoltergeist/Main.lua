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

    local houseId = ParaselenePoltergeist.House.GetHouseId()
    if houseId then
        local editorMode = ParaselenePoltergeist.Furnishing.GetEditorMode()
        if editorMode and ParaselenePoltergeist.SavedVariables:Capture(houseId, editorMode) then
            self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_PLACEMENT_CAPTURED), 0, 1, 0)
        end
    end

    self.messageWindow:AddText('.', 0, 0, 0)
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
        self:ShowCommand()
        return
    end

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_HIDE) then
        self:HideCommand()
        return
    end

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_DISPLAY) then
        self:DisplayCommand()
        return
    end

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_CLEAR) then
        self:ClearCommand()
        return
    end

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_LOAD) then
        self:LoadCommand()
        return
    end

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_SAVE) then
        self:SaveCommand()
        return
    end

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_LIST) then
        self:ListCommand()
        return
    end

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_DELETE) then
        self:DeleteCommand()
        return
    end
end

function ParaselenePoltergeist:ShowCommand()
    self.messageWindow:SetHidden(false)
end

function ParaselenePoltergeist:HideCommand()
    self.messageWindow:SetHidden(true)
end

function ParaselenePoltergeist:DisplayCommand()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_DISPLAY_CLIPBOARD), 1, 1, 1)

    local houseId = ParaselenePoltergeist.House.GetHouseId()
    if houseId then
        local clipboard = ParaselenePoltergeist.SavedVariables:GetClipboard(houseId)
        if clipboard then
            local furniture = ParaselenePoltergeist.SavedVariables:GetFurniture(clipboard.placement.furnitureId)

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
        else
            self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 0, 1, 1)
        end
        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_CLIPBOARD_DISPLAYED), 0, 1, 0)
    end

    self.messageWindow:AddText('.', 0, 0, 0)
end

function ParaselenePoltergeist:ClearCommand()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_CLEAR_CLIPBOARD), 1, 1, 1)

    -- Do cool stuff here.

    self.messageWindow:AddText('.', 0, 0, 0)
end

function ParaselenePoltergeist:LoadCommand()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_LOAD_PLACEMENT), 1, 1, 1)

    -- Do cool stuff here.

    self.messageWindow:AddText('.', 0, 0, 0)
end

function ParaselenePoltergeist:SaveCommand()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_SAVE_PLACEMENT), 1, 1, 1)

    -- Do cool stuff here.

    self.messageWindow:AddText('.', 0, 0, 0)
end

function ParaselenePoltergeist:ListCommand()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_LIST_PLACEMENTS), 1, 1, 1)

    -- Do cool stuff here.

    self.messageWindow:AddText('.', 0, 0, 0)
end

function ParaselenePoltergeist:DeleteCommand()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_DELETE_PLACEMENT), 1, 1, 1)

    -- Do cool stuff here.

    self.messageWindow:AddText('.', 0, 0, 0)
end

function ParaselenePoltergeist:UpdateClock()
    local time = os.date('%Y-%m-%d %H:%M:%S')
    ParaselenePoltergeistClockLabel:SetText(time)
    zo_callLater(function() self:UpdateClock() end, 1000)
end

ParaselenePoltergeist:Init()
