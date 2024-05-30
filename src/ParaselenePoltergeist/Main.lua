function ParaselenePoltergeist:Clone()
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

    ZO_PreHook('Logout', function() self.savedVariables:Save() return false end)
    ZO_PreHook('ReloadUI', function() self.savedVariables:Save() return false end)
    ZO_PreHook('Quit', function() self.savedVariables:Save() return false end)

    ZO_CreateStringId(
        'SI_BINDING_NAME_PARASELENE_POLTERGEIST_CAPTURE_PLACEMENT',
        GetString(PARASELENE_POLTERGEIST_CAPTURE_PLACEMENT)
    )

    self.settings = ParaselenePoltergeist.Settings.Load(self.author, self.version)
    self.savedVariables = ParaselenePoltergeist.SavedVariables.Load()

    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_SAVED_IN_CLIPBOARD), 1, 1, 1)
    self.savedVariables:PrintClipboard()

    self:UpdateClock()
end

function ParaselenePoltergeist:Capture()
    local messageWindow = PARASELENE_POLTERGEIST_MESSAGE_WINDOW

    ---@diagnostic disable-next-line: need-check-nil, undefined-field
    messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CAPTURED_INTO_CLIPBOARD), 1, 1, 1)

    local furnitureId = self.savedVariables.serverSpecific.furnishings:Capture()
    if not furnitureId then
        return
    end

    local placement = ParaselenePoltergeist.Placement.Capture(furnitureId)
    self.savedVariables:SetClipboard(placement)
    self.savedVariables:PrintClipboard()
end

function ParaselenePoltergeist:UpdateClock()
    local time = os.date('%Y-%m-%d %H:%M:%S')
    ParaselenePoltergeistClockLabel:SetText(time)
    zo_callLater(function() self:UpdateClock() end, 1000)
end

ParaselenePoltergeistInstance = ParaselenePoltergeist:Clone()
ParaselenePoltergeistInstance:Init()
