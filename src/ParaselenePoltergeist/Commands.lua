function ParaselenePoltergeist:Print(text, red, green, blue)
    local lines = {}
    for line in string.gmatch(text, '[^\r\n]+') do
        table.insert(lines, line)
    end
    for _, line in pairs(lines) do
        self.messageWindow:AddText(line, red, green, blue)
    end
end

function ParaselenePoltergeist:PrintBlack(text)
    self:Print(text, 0, 0, 0)
end

function ParaselenePoltergeist:PrintCyan(text)
    self:Print(text, 0, 1, 1)
end

function ParaselenePoltergeist:PrintGreen(text)
    self:Print(text, 0, 1, 0)
end

function ParaselenePoltergeist:PrintRed(text)
    self:Print(text, 1, 0, 0)
end

function ParaselenePoltergeist:PrintWhite(text)
    self:Print(text, 1, 1, 1)
end

function ParaselenePoltergeist:PrintYellow(text)
    self:Print(text, 1, 1, 0)
end

function ParaselenePoltergeist:PrintCommandStart(text)
    self.logger:Info('UI Message: ' .. text)
    self:PrintWhite(text)
end

function ParaselenePoltergeist:PrintContent(text)
    self.logger:Info('UI Message: ' .. text)
    self:PrintCyan(text)
end

function ParaselenePoltergeist:PrintCommandEnd(text)
    self.logger:Info('UI Message: ' .. text)
    self:PrintGreen(text)
end

function ParaselenePoltergeist:PrintError(text)
    self.logger:Info('UI Message: ' .. text)
    self:PrintRed(text)
end

function ParaselenePoltergeist:PrintUsage(text)
    self.logger:Info('UI Message: ' .. text)
    self:PrintYellow(text)
end

function ParaselenePoltergeist:PrintCommandPath(keywords)
    local message = GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND)
    for _, keyword in pairs(keywords) do
        message = message .. ' ' .. keyword
    end
    self:PrintCommandStart(message)
end

function ParaselenePoltergeist:PrintKeywordUsage(keywordList)
    local message = GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_ADDITIONAL_KEYWORD_NEEDED)
    if #keywordList == 1 then
        message = message .. GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_ADD_KEYWORD)
    else
        message = message .. GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_ADD_ONE_OF_KEYWORDS)
    end
    for index, word in pairs(keywordList) do
        message = message .. '  ' .. word
        if index < #keywordList then
            message = message .. '\n'
        end
    end

    self:PrintUsage(message)
end

function ParaselenePoltergeist:PrintTagUsage(tagNeededMessage)
    local message = GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_ADDITIONAL_PARAMETERS_NEEDED) .. tagNeededMessage
    self.logger:Info('UI Message: ' .. message)
    self:PrintUsage(message)
end

function ParaselenePoltergeist:PrintLabelUsage(labelNeededMessage)
    local message = GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_ADDITIONAL_PARAMETERS_NEEDED) .. labelNeededMessage
    self.logger:Info('UI Message: ' .. message)
    self:PrintUsage(message)
end

function ParaselenePoltergeist:CommandComplete(result)
    self.logger:Info('CommandComplete(%s) called.', tostring(result))
    self:PrintBlack('.')  -- 1 line spacer.
    return result
end

function ParaselenePoltergeist:CanonizeTag(tag)
    if (type(tag) == 'string') and (tag:match('%D') == nil) and (#tag >= 1) and (#tag <= 6) then
        tag = tonumber(tag)
    end

    if (type(tag) ~= 'number') or (tag % 1 ~= 0) or (tag < 1) or (tag > 999999) then
        self.logger:Info('tag = [' .. (tag or 'nil') .. ']')
        self:PrintError(GetString(PARASELENE_POLTERGEIST_INVALID_TAG))
        return nil
    end

    return tag
end

function ParaselenePoltergeist:CanonizeLabel(label)
    if (type(label) == 'number') or (type(label) == 'boolean') then
        label = tostring(label)
    end
    if (type(label) ~= 'string') or (#label < 1) or (#label > 100) then
        self.logger:Info('label = [' .. (label or 'nil') .. ']')
        self:PrintError(GetString(PARASELENE_POLTERGEIST_INVALID_LABEL))
        return nil
    end

    return label
end

function ParaselenePoltergeist:CaptureCommand()
    self.logger:Info('CaptureCommand() called.')
    self:PrintCommandStart(GetString(PARASELENE_POLTERGEIST_ACK_CAPTURE_PLACEMENT))

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

    self:PrintCommandEnd(GetString(PARASELENE_POLTERGEIST_RES_PLACEMENT_CAPTURED))
    return self:CommandComplete(true)
end

function ParaselenePoltergeist:ParentCommand()
    self:PrintCommandPath{}
    self:PrintKeywordUsage{
        GetString(PARASELENE_POLTERGEIST_COMMAND_CREATE),
        GetString(PARASELENE_POLTERGEIST_COMMAND_DELETE),
        GetString(PARASELENE_POLTERGEIST_COMMAND_HIDE),
        GetString(PARASELENE_POLTERGEIST_COMMAND_INVOKE),
        GetString(PARASELENE_POLTERGEIST_COMMAND_LIST),
        GetString(PARASELENE_POLTERGEIST_COMMAND_LOAD),
        GetString(PARASELENE_POLTERGEIST_COMMAND_SAVE),
        GetString(PARASELENE_POLTERGEIST_COMMAND_SHOW),
    }
    return self:CommandComplete(false)
end

function ParaselenePoltergeist:CreateCommand()
    self:PrintCommandPath{
        GetString(PARASELENE_POLTERGEIST_COMMAND_CREATE),
    }
    self:PrintKeywordUsage{
        GetString(PARASELENE_POLTERGEIST_COMMAND_ACTION),
    }
    return self:CommandComplete(false)
end

function ParaselenePoltergeist:CreateActionCommand(tag)
    self:PrintCommandPath{
        GetString(PARASELENE_POLTERGEIST_COMMAND_CREATE),
        GetString(PARASELENE_POLTERGEIST_COMMAND_ACTION),
    }
    self:PrintKeywordUsage{
        GetString(PARASELENE_POLTERGEIST_COMMAND_MOVE_ACTION),
    }
    return self:CommandComplete(false)
end

function ParaselenePoltergeist:CreateMoveActionCommand(tag)
    self.logger:Info('CreateMoveActionCommand() called.')
    self:PrintCommandStart(GetString(PARASELENE_POLTERGEIST_ACK_CREATE_MOVE_ACTION))

    -- TODO: Implement this command.

    self:PrintCommandEnd(GetString(PARASELENE_POLTERGEIST_RES_MOVE_ACTION_CREATED))
    return self:CommandComplete(true)
end

function ParaselenePoltergeist:CreateCommands(parentCommand)
    local createCommand = parentCommand:RegisterSubCommand()
    createCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_CREATE))
    createCommand:SetCallback(function() self:CreateCommand() end)
    createCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_CREATE_DESCRIPTION))

    local createActionCommand = createCommand:RegisterSubCommand()
    createActionCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_ACTION))
    createActionCommand:SetCallback(function(args) self:CreateActionCommand(args) end)
    createActionCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_CREATE_ACTION_DESCRIPTION))

    local createMoveActionCommand = createActionCommand:RegisterSubCommand()
    createMoveActionCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_MOVE_ACTION))
    createMoveActionCommand:SetCallback(function(args) self:CreateMoveActionCommand(args) end)
    createMoveActionCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_CREATE_MOVE_ACTION_DESCRIPTION))
end

function ParaselenePoltergeist:DeleteCommand()
    self:PrintCommandPath{
        GetString(PARASELENE_POLTERGEIST_COMMAND_DELETE),
    }
    self:PrintKeywordUsage{
        GetString(PARASELENE_POLTERGEIST_COMMAND_ACTION),
        GetString(PARASELENE_POLTERGEIST_COMMAND_CLIPBOARD),
        GetString(PARASELENE_POLTERGEIST_COMMAND_PLACEMENT),
    }
    return self:CommandComplete(false)
end

function ParaselenePoltergeist:DeleteActionCommand(tag)
    self.logger:Info('DeleteActionCommand() called.')
    self:PrintCommandStart(GetString(PARASELENE_POLTERGEIST_ACK_DELETE_ACTION))

    if (not tag) or (tag == '')  then
        self:PrintTagUsage(GetString(PARASELENE_POLTERGEIST_COMMAND_DELETE_ACTION_USAGE))
        return self:CommandComplete(false)
    end

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

    self:PrintCommandEnd(GetString(PARASELENE_POLTERGEIST_RES_ACTION_DELETED))
    return self:CommandComplete(true)
end

function ParaselenePoltergeist:DeleteClipboardCommand()
    self.logger:Info('DeleteClipboardCommand() called.')
    self:PrintCommandStart(GetString(PARASELENE_POLTERGEIST_ACK_DELETE_CLIPBOARD))

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if not self.HouseStorage:DeleteClipboard(houseId) then
        return self:CommandComplete(false)
    end

    self:PrintCommandEnd(GetString(PARASELENE_POLTERGEIST_RES_CLIPBOARD_DELETED))
    return self:CommandComplete(true)
end

function ParaselenePoltergeist:DeletePlacementCommand(tag)
    self.logger:Info('DeletePlacementCommand() called.')
    self:PrintCommandStart(GetString(PARASELENE_POLTERGEIST_ACK_DELETE_PLACEMENT))

    if (not tag) or (tag == '')  then
        self:PrintTagUsage(GetString(PARASELENE_POLTERGEIST_COMMAND_DELETE_PLACEMENT_USAGE))
        return self:CommandComplete(false)
    end

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

    self:PrintCommandEnd(GetString(PARASELENE_POLTERGEIST_RES_PLACEMENT_DELETED))
    return self:CommandComplete(true)
end

function ParaselenePoltergeist:DeleteCommands(parentCommand)
    local deleteCommand = parentCommand:RegisterSubCommand()
    deleteCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_DELETE))
    deleteCommand:SetCallback(function() self:DeleteCommand() end)
    deleteCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_DELETE_DESCRIPTION))

    local deleteActionCommand = deleteCommand:RegisterSubCommand()
    deleteActionCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_ACTION))
    deleteActionCommand:SetCallback(function(args) self:DeleteActionCommand(args) end)
    deleteActionCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_DELETE_ACTION_DESCRIPTION))

    local deleteClipboardCommand = deleteCommand:RegisterSubCommand()
    deleteClipboardCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_CLIPBOARD))
    deleteClipboardCommand:SetCallback(function() self:DeleteClipboardCommand() end)
    deleteClipboardCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_DELETE_CLIPBOARD_DESCRIPTION))

    local deletePlacementCommand = deleteCommand:RegisterSubCommand()
    deletePlacementCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_PLACEMENT))
    deletePlacementCommand:SetCallback(function(args) self:DeletePlacementCommand(args) end)
    deletePlacementCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_DELETE_PLACEMENT_DESCRIPTION))
end

function ParaselenePoltergeist:HideCommand()
    self:PrintCommandPath{
        GetString(PARASELENE_POLTERGEIST_COMMAND_HIDE),
    }
    self:PrintKeywordUsage{
        GetString(PARASELENE_POLTERGEIST_COMMAND_WINDOW),
    }
    return self:CommandComplete(false)
end

function ParaselenePoltergeist:HideWindowCommand()
    self.logger:Info('HideWindowCommand() called.')

    self.messageWindow:SetHidden(true)

    self.logger:Info('Command completed.')
    return true
end

function ParaselenePoltergeist:HideCommands(parentCommand)
    local hideCommand = parentCommand:RegisterSubCommand()
    hideCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_HIDE))
    hideCommand:SetCallback(function() self:HideCommand() end)
    hideCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_HIDE_DESCRIPTION))

    local hideWindowCommand = hideCommand:RegisterSubCommand()
    hideWindowCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_WINDOW))
    hideWindowCommand:SetCallback(function() self:HideWindowCommand() end)
    hideWindowCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_HIDE_WINDOW_DESCRIPTION))
end

function ParaselenePoltergeist:InvokeCommand()
    self:PrintCommandPath{
        GetString(PARASELENE_POLTERGEIST_COMMAND_INVOKE),
    }
    self:PrintKeywordUsage{
        GetString(PARASELENE_POLTERGEIST_COMMAND_ACTION),
    }
    return self:CommandComplete(false)
end

function ParaselenePoltergeist:InvokeActionCommand(tag)
    self.logger:Info('InvokeActionCommand() called.')
    self:PrintCommandStart(GetString(PARASELENE_POLTERGEIST_ACK_INVOKE_ACTION))

    if (not tag) or (tag == '')  then
        self:PrintTagUsage(GetString(PARASELENE_POLTERGEIST_COMMAND_INVOKE_ACTION_USAGE))
        return self:CommandComplete(false)
    end

    tag = self:CanonizeTag(tag)
    if not tag then
        return self:CommandComplete(false)
    end

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if not self.HouseStorage:InvokeAction(houseId, tag) then
        return self:CommandComplete(false)
    end

    self:PrintCommandEnd(GetString(PARASELENE_POLTERGEIST_RES_ACTION_INVOKED))
    return self:CommandComplete(true)
end

function ParaselenePoltergeist:InvokeCommands(parentCommand)
    local invokeCommand = parentCommand:RegisterSubCommand()
    invokeCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_INVOKE))
    invokeCommand:SetCallback(function() self:InvokeCommand() end)
    invokeCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_INVOKE_DESCRIPTION))

    local invokeActionCommand = invokeCommand:RegisterSubCommand()
    invokeActionCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_ACTION))
    invokeActionCommand:SetCallback(function(args) self:InvokeActionCommand(args) end)
    invokeActionCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_INVOKE_ACTION_DESCRIPTION))
end

function ParaselenePoltergeist:ListCommand()
    self:PrintCommandPath{
        GetString(PARASELENE_POLTERGEIST_COMMAND_LIST),
    }
    self:PrintKeywordUsage{
        GetString(PARASELENE_POLTERGEIST_COMMAND_ACTIONS),
        GetString(PARASELENE_POLTERGEIST_COMMAND_PLACEMENTS),
    }
    return self:CommandComplete(false)
end

function ParaselenePoltergeist:ListActionsCommand()
    self.logger:Info('ListActionsCommand() called.')
    self:PrintCommandStart(GetString(PARASELENE_POLTERGEIST_ACK_LIST_ACTIONS))

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if self.HouseStorage:GetActionCount(houseId) == 0 then
        self:PrintContent(GetString(PARASELENE_POLTERGEIST_NO_ACTIONS))
    else
        self.HouseStorage:IterateActions(
            houseId,
            function(tag, action)
                self:PrintContent(tag .. ' - ' .. action:GetType() .. ' - ' .. action:GetLabel())
            end
        )
    end

    self:PrintCommandEnd(GetString(PARASELENE_POLTERGEIST_RES_ACTIONS_LISTED))
    return self:CommandComplete(true)
end

function ParaselenePoltergeist:ListPlacementsCommand()
    self.logger:Info('ListPlacementsCommand() called.')
    self:PrintCommandStart(GetString(PARASELENE_POLTERGEIST_ACK_LIST_PLACEMENTS))

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if self.HouseStorage:GetPlacementCount(houseId) == 0 then
        self:PrintContent(GetString(PARASELENE_POLTERGEIST_NO_PLACEMENTS))
    else
        self.HouseStorage:IteratePlacements(
            houseId,
            function(tag, placement)
                self:PrintContent(tag .. ' - ' .. placement:GetLabel())
            end
        )
    end

    self:PrintCommandEnd(GetString(PARASELENE_POLTERGEIST_RES_PLACEMENTS_LISTED))
    return self:CommandComplete(true)
end

function ParaselenePoltergeist:ListCommands(parentCommand)
    local listCommand = parentCommand:RegisterSubCommand()
    listCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_LIST))
    listCommand:SetCallback(function() self:ListCommand() end)
    listCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_LIST_DESCRIPTION))

    local listActionsCommand = listCommand:RegisterSubCommand()
    listActionsCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_ACTIONS))
    listActionsCommand:SetCallback(function() self:ListActionsCommand() end)
    listActionsCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_LIST_ACTIONS_DESCRIPTION))

    local listPlacementsCommand = listCommand:RegisterSubCommand()
    listPlacementsCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_PLACEMENTS))
    listPlacementsCommand:SetCallback(function() self:ListPlacementsCommand() end)
    listPlacementsCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_LIST_PLACEMENTS_DESCRIPTION))
end

function ParaselenePoltergeist:LoadCommand()
    self:PrintCommandPath{
        GetString(PARASELENE_POLTERGEIST_COMMAND_LOAD),
    }
    self:PrintKeywordUsage{
        GetString(PARASELENE_POLTERGEIST_COMMAND_ACTION),
        GetString(PARASELENE_POLTERGEIST_COMMAND_PLACEMENT),
    }
    return self:CommandComplete(false)
end

function ParaselenePoltergeist:LoadActionCommand(tag)
    self.logger:Info('LoadActionCommand() called.')
    self:PrintCommandStart(GetString(PARASELENE_POLTERGEIST_ACK_LOAD_ACTION))

    if (not tag) or (tag == '')  then
        self:PrintTagUsage(GetString(PARASELENE_POLTERGEIST_COMMAND_LOAD_ACTION_USAGE))
        return self:CommandComplete(false)
    end

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

    self:PrintCommandEnd(GetString(PARASELENE_POLTERGEIST_RES_ACTION_LOADED))
    return self:CommandComplete(true)
end

function ParaselenePoltergeist:LoadPlacementCommand(tag)
    self.logger:Info('LoadPlacementCommand() called.')
    self:PrintCommandStart(GetString(PARASELENE_POLTERGEIST_ACK_LOAD_PLACEMENT))

    if (not tag) or (tag == '')  then
        self:PrintTagUsage(GetString(PARASELENE_POLTERGEIST_COMMAND_LOAD_PLACEMENT_USAGE))
        return self:CommandComplete(false)
    end

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

    self:PrintCommandEnd(GetString(PARASELENE_POLTERGEIST_RES_PLACEMENT_LOADED))
    return self:CommandComplete(true)
end

function ParaselenePoltergeist:LoadCommands(parentCommand)
    local loadCommand = parentCommand:RegisterSubCommand()
    loadCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_LOAD))
    loadCommand:SetCallback(function() self:LoadCommand() end)
    loadCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_LOAD_DESCRIPTION))

    local loadActionCommand = loadCommand:RegisterSubCommand()
    loadActionCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_ACTION))
    loadActionCommand:SetCallback(function(args) self:LoadActionCommand(args) end)
    loadActionCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_LOAD_ACTION_DESCRIPTION))

    local loadPlacementCommand = loadCommand:RegisterSubCommand()
    loadPlacementCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_PLACEMENT))
    loadPlacementCommand:SetCallback(function(args) self:LoadPlacementCommand(args) end)
    loadPlacementCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_LOAD_PLACEMENT_DESCRIPTION))
end

function ParaselenePoltergeist:SaveCommand()
    self:PrintCommandPath{
        GetString(PARASELENE_POLTERGEIST_COMMAND_SAVE),
    }
    self:PrintKeywordUsage{
        GetString(PARASELENE_POLTERGEIST_COMMAND_ACTION),
        GetString(PARASELENE_POLTERGEIST_COMMAND_PLACEMENT),
    }
    return self:CommandComplete(false)
end

function ParaselenePoltergeist:SaveActionCommand(label)
    self.logger:Info('SaveActionCommand() called.')
    self:PrintCommandStart(GetString(PARASELENE_POLTERGEIST_ACK_SAVE_ACTION))

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

    self:PrintCommandEnd(GetString(PARASELENE_POLTERGEIST_RES_ACTION_SAVED))
    return self:CommandComplete(true)
end

function ParaselenePoltergeist:SavePlacementCommand(label)
    self.logger:Info('SavePlacementCommand() called.')
    self:PrintCommandStart(GetString(PARASELENE_POLTERGEIST_ACK_SAVE_PLACEMENT))

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

    self:PrintCommandEnd(GetString(PARASELENE_POLTERGEIST_RES_PLACEMENT_SAVED))
    return self:CommandComplete(true)
end

function ParaselenePoltergeist:SaveCommands(parentCommand)
    local saveCommand = parentCommand:RegisterSubCommand()
    saveCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_SAVE))
    saveCommand:SetCallback(function() self:SaveCommand() end)
    saveCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_SAVE_DESCRIPTION))

    local saveActionCommand = saveCommand:RegisterSubCommand()
    saveActionCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_ACTION))
    saveActionCommand:SetCallback(function(args) self:SaveActionCommand(args) end)
    saveActionCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_SAVE_ACTION_DESCRIPTION))

    local savePlacementCommand = saveCommand:RegisterSubCommand()
    savePlacementCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_PLACEMENT))
    savePlacementCommand:SetCallback(function(args) self:SavePlacementCommand(args) end)
    savePlacementCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_SAVE_PLACEMENT_DESCRIPTION))
end

function ParaselenePoltergeist:ShowCommand()
    self:PrintCommandPath{
        GetString(PARASELENE_POLTERGEIST_COMMAND_SHOW),
    }
    self:PrintKeywordUsage{
        GetString(PARASELENE_POLTERGEIST_COMMAND_CLIPBOARD),
        GetString(PARASELENE_POLTERGEIST_COMMAND_WINDOW),
    }
    return self:CommandComplete(false)
end

function ParaselenePoltergeist:ShowClipboardMoveActionData(action)
    local type = action:GetType()
    local placementTag = action:GetPlacementTag()
    local message = type .. ' - ' .. GetString(PARASELENE_POLTERGEIST_PLACEMENT_TAG) .. ' ' .. placementTag
    self:PrintContent(message)
end

function ParaselenePoltergeist:ShowClipboardAction(tag, action)
    local taggedLabel = tag .. ' - ' .. action:GetLabel()
    self:PrintContent(GetString(PARASELENE_POLTERGEIST_ACTION_TAG) .. ' ' .. taggedLabel)

    if action:GetType() == ParaselenePoltergeist.Action.MOVE then
        self:ShowClipboardMoveActionData(action)
    end
end

function ParaselenePoltergeist:ShowClipboardPlacement(tag, placement)
    local taggedLabel = tag .. ' - ' .. placement:GetLabel()
    self:PrintContent(GetString(PARASELENE_POLTERGEIST_PLACEMENT_TAG) .. ' ' .. taggedLabel)

    local furnitureId = placement:GetFurnitureId()
    local furniture = self.FurnishingStorage:GetFurniture(furnitureId)

    local taggedLink = furniture:GetTag() .. ' - ' .. furniture:GetLink()
    self:PrintContent(GetString(PARASELENE_POLTERGEIST_FURNITURE_TAG) .. ' ' .. taggedLink)

    local x, y, z = placement:GetPosition()
    self:PrintContent(GetString(PARASELENE_POLTERGEIST_X) .. x)
    self:PrintContent(GetString(PARASELENE_POLTERGEIST_Y) .. y)
    self:PrintContent(GetString(PARASELENE_POLTERGEIST_Z) .. z)

    local pitch, roll, yaw = placement:GetOrientation()
    self:PrintContent(GetString(PARASELENE_POLTERGEIST_PITCH) .. pitch)
    self:PrintContent(GetString(PARASELENE_POLTERGEIST_ROLL) .. roll)
    self:PrintContent(GetString(PARASELENE_POLTERGEIST_YAW) .. yaw)
end

function ParaselenePoltergeist:ShowClipboardCommand()
    self.logger:Info('ShowClipboardCommand() called.')
    self:PrintCommandStart(GetString(PARASELENE_POLTERGEIST_ACK_SHOW_CLIPBOARD))

    local houseId = self.House.GetHouseId()
    if not houseId then
        return self:CommandComplete(false)
    end

    if self.HouseStorage:IsClipboardEmpty(houseId) then
        self:PrintContent(GetString(PARASELENE_POLTERGEIST_CLIPBOARD_IS_EMPTY))
    else
        local clipboard = self.HouseStorage:GetClipboard(houseId)
        local content = clipboard:GetContent()

        if clipboard:GetType() == self.Clipboard.ACTION then
            self:ShowClipboardAction(clipboard:GetTag(), content)
        elseif clipboard:GetType() == self.Clipboard.PLACEMENT then
            self:ShowClipboardPlacement(clipboard:GetTag(), content)
        end
    end

    self:PrintCommandEnd(GetString(PARASELENE_POLTERGEIST_RES_CLIPBOARD_SHOWN))
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
    showCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_SHOW))
    showCommand:SetCallback(function() self:ShowCommand() end)
    showCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_SHOW_DESCRIPTION))

    local showClipboardCommand = showCommand:RegisterSubCommand()
    showClipboardCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_CLIPBOARD))
    showClipboardCommand:SetCallback(function() self:ShowClipboardCommand() end)
    showClipboardCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_SHOW_CLIPBOARD_DESCRIPTION))

    local showWindowCommand = showCommand:RegisterSubCommand()
    showWindowCommand:AddAlias(GetString(PARASELENE_POLTERGEIST_COMMAND_WINDOW))
    showWindowCommand:SetCallback(function() self:ShowWindowCommand() end)
    showWindowCommand:SetDescription(GetString(PARASELENE_POLTERGEIST_COMMAND_SHOW_WINDOW_DESCRIPTION))
end

function ParaselenePoltergeist:CreateSlashCommands()
    self.lsc = LibSlashCommander
    local parentCommand = self.lsc:Register(
        GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND),
        function() self:ParentCommand() end,
        GetString(PARASELENE_POLTERGEIST_SLASH_COMMAND_DESCRIPTION)
    )

    self:CreateCommands(parentCommand)
    self:DeleteCommands(parentCommand)
    self:HideCommands(parentCommand)
    self:InvokeCommands(parentCommand)
    self:ListCommands(parentCommand)
    self:LoadCommands(parentCommand)
    self:SaveCommands(parentCommand)
    self:ShowCommands(parentCommand)
end
