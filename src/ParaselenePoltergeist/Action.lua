ParaselenePoltergeist.Action = {
    -- Action types (persisted enumeration).
    MOVE = 'Move',
}

function ParaselenePoltergeist.Action:Create(initData)
    if initData.type == self.MOVE then
        return ParaselenePoltergeist.MoveAction:Create(initData)
    end
end

function ParaselenePoltergeist.Action:CreateMoveAction(placementTag)
    return ParaselenePoltergeist.MoveAction:Create{
        type = self.MOVE,
        label = GetString(PARASELENE_POLTERGEIST_NEW_ACTION),
        placementTag = placementTag,
    }
end
