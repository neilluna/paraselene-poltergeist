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

    self.msgWindow = LibMsgWin:CreateMsgWindow(
        'ParaselenePoltergeistMessages',
        GetString(PARASELENE_POLTERGEIST_TITLE)
    )

    ZO_PreHook('Logout', function() self.savedVariables:Save() return false end)
    ZO_PreHook('ReloadUI', function() self.savedVariables:Save() return false end)
    ZO_PreHook('Quit', function() self.savedVariables:Save() return false end)

    ZO_CreateStringId(
        'SI_BINDING_NAME_PARASELENE_POLTERGEIST_CAPTURE_PLACEMENT',
        GetString(PARASELENE_POLTERGEIST_CAPTURE_PLACEMENT)
    )

    self.settings = ParaselenePoltergeist.Settings.Load(self.author, self.version)
    self.savedVariables = ParaselenePoltergeist.SavedVariables.Load()

    self.msgWindow:AddText(GetString(PARASELENE_POLTERGEIST_SAVED_IN_CLIPBOARD), 1, 1, 1)
    self.savedVariables.serverSpecific.clipboard:Print(self.msgWindow)

    self:UpdateClock()
end

function ParaselenePoltergeist:CapturePlacement()
    self.msgWindow:AddText(GetString(PARASELENE_POLTERGEIST_CAPTURED_INTO_CLIPBOARD), 1, 1, 1)
    local captureSucceeded, errorMessage = self.savedVariables.serverSpecific.clipboard:Capture()
    if captureSucceeded then
        self.savedVariables.serverSpecific.clipboard:Print(self.msgWindow)
    else
        self.msgWindow:AddText(errorMessage, 1, 0, 0)
    end
end

function ParaselenePoltergeist:UpdateClock()
    local time = os.date('%Y-%m-%d %H:%M:%S')
    ParaselenePoltergeistClockLabel:SetText(time)
    zo_callLater(function() self:UpdateClock() end, 1000)
end

ParaselenePoltergeistInstance = ParaselenePoltergeist:Clone()
ParaselenePoltergeistInstance:Init()
