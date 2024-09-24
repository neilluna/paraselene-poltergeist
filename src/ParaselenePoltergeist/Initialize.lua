function ParaselenePoltergeist:UpdateClock()
    local time = os.date('%Y-%m-%d %H:%M:%S')
    ParaselenePoltergeistClockLabel:SetText(time)
    zo_callLater(function() self:UpdateClock() end, 1000)
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

function ParaselenePoltergeist:Init()
    self.displayName = GetString(PARASELENE_POLTERGEIST_TITLE)
    EVENT_MANAGER:RegisterForEvent(
        self.displayName,
        EVENT_ADD_ON_LOADED,
        function(event, name) self:OnAddOnLoaded(event, name) end
    )
end

ParaselenePoltergeist:Init()
