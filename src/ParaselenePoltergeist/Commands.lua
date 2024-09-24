function ParaselenePoltergeist:CanonizeTag(tag)
    if (type(tag) == 'string') and (tag:match('%D') == nil) and (#tag >= 1) and (#tag <= 6) then
        tag = tonumber(tag)
    end

    if (type(tag) ~= 'number') or (tag % 1 ~= 0) or (tag < 1) or (tag > 999999) then
        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_INVALID_TAG), 1, 0, 0)
        return nil
    end

    return tag
end

function ParaselenePoltergeist:CanonizeLabel(label)
    if (type(label) == 'number') or (type(label) == 'boolean') then
        label = tostring(label)
    end
    if (type(label) ~= 'string') or (#label < 1) or (#label > 100) then
        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_INVALID_LABEL), 1, 0, 0)
        return nil
    end

    return label
end

function ParaselenePoltergeist:CommandComplete(result)
    self.logger:Info('CommandComplete(%s) called.', tostring(result))
    self.messageWindow:AddText('.', 0, 0, 0)
    return result
end

function ParaselenePoltergeist:CaptureCommand()
    self.logger:Info('CaptureCommand() called.')
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

function ParaselenePoltergeist:ParentCommand()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_USAGE), 0, 1, 0)
end

function ParaselenePoltergeist:ShowCommand()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_SHOW_USAGE), 0, 1, 0)
end

function ParaselenePoltergeist:ShowClipboardAction(tag, action)
    local taggedLabel = tag .. ' - ' .. action:GetLabel()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACTION_TAG) .. taggedLabel, 0, 1, 1)
end

function ParaselenePoltergeist:ShowClipboardPlacement(tag, placement)
    local taggedLabel = tag .. ' - ' .. placement:GetLabel()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_PLACEMENT_TAG) .. taggedLabel, 0, 1, 1)

    local furnitureId = placement:GetFurnitureId()
    local furniture = self.FurnishingStorage:GetFurniture(furnitureId)

    local taggedLink = furniture:GetTag() .. ' - ' .. furniture:GetLink()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_FURNITURE_TAG) .. taggedLink, 0, 1, 1)

    local x, y, z = placement:GetPosition()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_X) .. x, 0, 1, 1)
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_Y) .. y, 0, 1, 1)
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_Z) .. z, 0, 1, 1)

    local pitch, roll, yaw = placement:GetOrientation()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_PITCH) .. pitch, 0, 1, 1)
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ROLL) .. roll, 0, 1, 1)
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_YAW) .. yaw, 0, 1, 1)
end

function ParaselenePoltergeist:ShowClipboardCommand()
    self.logger:Info('ShowClipboardCommand() called.')
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_SHOW_CLIPBOARD), 1, 1, 1)

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if self.HouseStorage:IsClipboardEmpty(houseId) then
        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY), 0, 1, 1)
    else
        local clipboard = self.HouseStorage:GetClipboard(houseId)
        local content = clipboard:GetContent()

        if clipboard:GetType() == self.Clipboard.ACTION then
            self:ShowClipboardAction(clipboard:GetTag(), content)
        elseif clipboard:GetType() == self.Clipboard.PLACEMENT then
            self:ShowClipboardPlacement(clipboard:GetTag(), content)
        end
    end

    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_CLIPBOARD_SHOWN), 0, 1, 0)

    return self:CommandComplete(true)
end

function ParaselenePoltergeist:ShowWindowCommand()
    self.logger:Info('ShowWindowCommand() called.')
    self.messageWindow:SetHidden(false)
    self.logger:Info('Command completed.')
    return true
end

function ParaselenePoltergeist:ShowCommands(parentCommand)
    local showCommand = parentCommand:RegisterSubCommand()
    showCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_SHOW))
    showCommand:SetCallback(function() self:ShowCommand() end)
    showCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_SHOW_DESCRIPTION))

    local showClipboardCommand = showCommand:RegisterSubCommand()
    showClipboardCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_TARGET_CLIPBOARD))
    showClipboardCommand:SetCallback(function() self:ShowClipboardCommand() end)
    showClipboardCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_SHOW_CLIPBOARD_DESCRIPTION))

    local showWindowCommand = showCommand:RegisterSubCommand()
    showWindowCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_TARGET_WINDOW))
    showWindowCommand:SetCallback(function() self:ShowWindowCommand() end)
    showWindowCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_SHOW_WINDOW_DESCRIPTION))
end

function ParaselenePoltergeist:HideCommand()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_HIDE_USAGE), 0, 1, 0)
end

function ParaselenePoltergeist:HideWindowCommand()
    self.logger:Info('HideWindowCommand() called.')

    self.messageWindow:SetHidden(true)

    self.logger:Info('Command completed.')

    return true
end

function ParaselenePoltergeist:HideCommands(parentCommand)
    local hideCommand = parentCommand:RegisterSubCommand()
    hideCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_HIDE))
    hideCommand:SetCallback(function() self:HideCommand() end)
    hideCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_HIDE_DESCRIPTION))

    local hideWindowCommand = hideCommand:RegisterSubCommand()
    hideWindowCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_TARGET_WINDOW))
    hideWindowCommand:SetCallback(function() self:HideWindowCommand() end)
    hideWindowCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_HIDE_WINDOW_DESCRIPTION))
end

function ParaselenePoltergeist:LoadCommand()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_LOAD_USAGE), 0, 1, 0)
end

function ParaselenePoltergeist:LoadActionCommand(tag)
    self.logger:Info('LoadActionCommand() called.')
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_LOAD_ACTION), 1, 1, 1)

    tag = self:CanonizeTag(tag)
    if not tag then
        return self:CommandComplete(false)
    end

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if not self.HouseStorage:LoadAction(houseId, tag) then
        return self:CommandComplete(false)
    end

    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_ACTION_LOADED), 0, 1, 0)

    return self:CommandComplete(true)
end

function ParaselenePoltergeist:LoadPlacementCommand(tag)
    self.logger:Info('LoadPlacementCommand() called.')
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

function ParaselenePoltergeist:LoadCommands(parentCommand)
    local loadCommand = parentCommand:RegisterSubCommand()
    loadCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_LOAD))
    loadCommand:SetCallback(function() self:LoadCommand() end)
    loadCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_LOAD_DESCRIPTION))

    local loadActionCommand = loadCommand:RegisterSubCommand()
    loadActionCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_TARGET_ACTION))
    loadActionCommand:SetCallback(function(args) self:LoadActionCommand(args) end)
    loadActionCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_LOAD_ACTION_DESCRIPTION))

    local loadPlacementCommand = loadCommand:RegisterSubCommand()
    loadPlacementCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_TARGET_PLACEMENT))
    loadPlacementCommand:SetCallback(function(args) self:LoadPlacementCommand(args) end)
    loadPlacementCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_LOAD_PLACEMENT_DESCRIPTION))
end

function ParaselenePoltergeist:SaveCommand()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_SAVE_USAGE), 0, 1, 0)
end

function ParaselenePoltergeist:SaveActionCommand(label)
    self.logger:Info('SaveActionCommand() called.')
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_SAVE_ACTION), 1, 1, 1)

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

    if not self.HouseStorage:SaveAction(houseId, label) then
        return self:CommandComplete(false)
    end

    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_ACTION_SAVED), 0, 1, 0)

    return self:CommandComplete(true)
end

function ParaselenePoltergeist:SavePlacementCommand(label)
    self.logger:Info('SavePlacementCommand() called.')
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

function ParaselenePoltergeist:SaveCommands(parentCommand)
    local saveCommand = parentCommand:RegisterSubCommand()
    saveCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_SAVE))
    saveCommand:SetCallback(function() self:SaveCommand() end)
    saveCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_SAVE_DESCRIPTION))

    local saveActionCommand = saveCommand:RegisterSubCommand()
    saveActionCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_TARGET_ACTION))
    saveActionCommand:SetCallback(function(args) self:SaveActionCommand(args) end)
    saveActionCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_SAVE_ACTION_DESCRIPTION))

    local savePlacementCommand = saveCommand:RegisterSubCommand()
    savePlacementCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_TARGET_PLACEMENT))
    savePlacementCommand:SetCallback(function(args) self:SavePlacementCommand(args) end)
    savePlacementCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_SAVE_PLACEMENT_DESCRIPTION))
end

function ParaselenePoltergeist:ListCommand()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_LIST_USAGE), 0, 1, 0)
end

function ParaselenePoltergeist:ListActionsCommand()
    self.logger:Info('ListActionsCommand() called.')
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_LIST_ACTIONS), 1, 1, 1)

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if self.HouseStorage:GetActionCount(houseId) == 0 then
        self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_NO_ACTIONS), 0, 1, 1)
    else
        self.HouseStorage:IterateActions(
            houseId,
            function(tag, action)
                self.messageWindow:AddText(tag .. ' - ' .. action.label, 0, 1, 1)
            end
        )
    end

    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_ACTIONS_LISTED), 0, 1, 0)

    return self:CommandComplete(true)
end

function ParaselenePoltergeist:ListPlacementsCommand()
    self.logger:Info('ListPlacementsCommand() called.')
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

function ParaselenePoltergeist:ListCommands(parentCommand)
    local listCommand = parentCommand:RegisterSubCommand()
    listCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_LIST))
    listCommand:SetCallback(function() self:ListCommand() end)
    listCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_LIST_DESCRIPTION))

    local listActionsCommand = listCommand:RegisterSubCommand()
    listActionsCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_TARGET_ACTIONS))
    listActionsCommand:SetCallback(function() self:ListActionsCommand() end)
    listActionsCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_LIST_ACTIONS_DESCRIPTION))

    local listPlacementsCommand = listCommand:RegisterSubCommand()
    listPlacementsCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_TARGET_PLACEMENTS))
    listPlacementsCommand:SetCallback(function() self:ListPlacementsCommand() end)
    listPlacementsCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_LIST_PLACEMENTS_DESCRIPTION))
end

function ParaselenePoltergeist:DeleteCommand()
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_DELETE_USAGE), 0, 1, 0)
end

function ParaselenePoltergeist:DeleteActionCommand(tag)
    self.logger:Info('DeleteActionCommand() called.')
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_DELETE_ACTION), 1, 1, 1)

    tag = self:CanonizeTag(tag)
    if not tag then
        return self:CommandComplete(false)
    end

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if not self.HouseStorage:DeleteAction(houseId, tag) then
        return self:CommandComplete(false)
    end

    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_ACTION_DELETED), 0, 1, 0)

    return self:CommandComplete(true)
end

function ParaselenePoltergeist:DeleteClipboardCommand()
    self.logger:Info('DeleteClipboardCommand() called.')
    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_ACK_DELETE_CLIPBOARD), 1, 1, 1)

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if not self.HouseStorage:DeleteClipboard(houseId) then
        return self:CommandComplete(false)
    end

    self.messageWindow:AddText(GetString(PARASELENE_POLTERGEIST_RES_CLIPBOARD_DELETED), 0, 1, 0)

    return self:CommandComplete(true)
end

function ParaselenePoltergeist:DeletePlacementCommand(tag)
    self.logger:Info('DeletePlacementCommand() called.')
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

function ParaselenePoltergeist:DeleteCommands(parentCommand)
    local deleteCommand = parentCommand:RegisterSubCommand()
    deleteCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_DELETE))
    deleteCommand:SetCallback(function() self:DeleteCommand() end)
    deleteCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_VERB_DELETE_DESCRIPTION))

    local deleteActionCommand = deleteCommand:RegisterSubCommand()
    deleteActionCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_TARGET_ACTION))
    deleteActionCommand:SetCallback(function(args) self:DeleteActionCommand(args) end)
    deleteActionCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_DELETE_ACTION_DESCRIPTION))

    local deleteClipboardCommand = deleteCommand:RegisterSubCommand()
    deleteClipboardCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_TARGET_CLIPBOARD))
    deleteClipboardCommand:SetCallback(function() self:DeleteClipboardCommand() end)
    deleteClipboardCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_DELETE_CLIPBOARD_DESCRIPTION))

    local deletePlacementCommand = deleteCommand:RegisterSubCommand()
    deletePlacementCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_TARGET_PLACEMENT))
    deletePlacementCommand:SetCallback(function(args) self:DeletePlacementCommand(args) end)
    deletePlacementCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_DELETE_PLACEMENT_DESCRIPTION))
end

function ParaselenePoltergeist:CreateCommands()
    self.lsc = LibSlashCommander
    local parentCommand = self.lsc:Register(
        GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND),
        function() self:ParentCommand() end,
        GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_DESCRIPTION)
    )

    self:ShowCommands(parentCommand)
    self:HideCommands(parentCommand)
    self:LoadCommands(parentCommand)
    self:SaveCommands(parentCommand)
    self:ListCommands(parentCommand)
    self:DeleteCommands(parentCommand)
end
