function ParaselenePoltergeist:Create()
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    return newInstance
end

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

    PARASELENE_POLTERGEIST_DEBUG_LOGGER = LibDebugLogger:Create(self.name)
    local logger = PARASELENE_POLTERGEIST_DEBUG_LOGGER
    logger:SetEnabled(true)

    PARASELENE_POLTERGEIST_MESSAGE_WINDOW = LibMsgWin:CreateMsgWindow(
        'ParaselenePoltergeistMessages',
        GetString(PARASELENE_POLTERGEIST_TITLE)
    )
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW
    messageWindow:SetHidden(true)

    ZO_PreHook('Logout', function() self.savedVariables:Save() return false end)
    ZO_PreHook('ReloadUI', function() self.savedVariables:Save() return false end)
    ZO_PreHook('Quit', function() self.savedVariables:Save() return false end)

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

    self.savedVariables = ParaselenePoltergeist.SavedVariables.Load()
    self.settings = ParaselenePoltergeist.Settings.Load(self.author, self.version)

    self:UpdateClock()
end

function ParaselenePoltergeist:Capture()
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_CAPTURE_PLACEMENT), 1, 1, 1)

    local furnitureId = self.savedVariables.serverSpecific.furnishings:Capture()
    if not furnitureId then
        return
    end

    local placement = ParaselenePoltergeist.Placement.Capture(furnitureId)
    if not placement then
        return
    end

    if self.savedVariables:SetClipboard(placement) then
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_PLACEMENT_CAPTURED), 0, 1, 0)
    end

    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText('.', 0, 0, 0)
end

function ParaselenePoltergeist:SlashCommands(args)
    local logger = PARASELENE_POLTERGEIST_DEBUG_LOGGER

    local command, commandArgs = string.match(args, "^%s*(%S+)%s*(.*)$")

    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    logger:Debug('command = [' .. (command or 'nil') .. ']')
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    logger:Debug('commandArgs = [' .. (commandArgs or 'nil') .. ']')

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

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_CLEAR) then
        self:ClearCommand()
        return
    end

    if command == GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_DISPLAY) then
        self:DisplayCommand()
        return
    end
end

function ParaselenePoltergeist:ShowCommand()
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:SetHidden(false)
end

function ParaselenePoltergeist:HideCommand()
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:SetHidden(true)
end

function ParaselenePoltergeist:ClearCommand()
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_CLEAR_CLIPBOARD), 1, 1, 1)

    if self.savedVariables:ClearClipboard() then
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_CLIPBOARD_CLEARED), 0, 1, 0)
    end

    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText('.', 0, 0, 0)
end

function ParaselenePoltergeist:DisplayCommand()
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW
    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_DISPLAY_CLIPBOARD), 1, 1, 1)

    if self.savedVariables:DisplayClipboard() then
        ---@diagnostic disable-next-line: need-check-nil, undefined-field
        messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_CLIPBOARD_DISPLAYED), 0, 1, 0)
    end

    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText('.', 0, 0, 0)
end

function ParaselenePoltergeist:UpdateClock()
    local time = os.date('%Y-%m-%d %H:%M:%S')
    ParaselenePoltergeistClockLabel:SetText(time)
    zo_callLater(function() self:UpdateClock() end, 1000)
end

ParaselenePoltergeistInstance = ParaselenePoltergeist:Create()
ParaselenePoltergeistInstance:Init()
