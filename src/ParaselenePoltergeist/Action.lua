ParaselenePoltergeist.Action = {
    -- Action types (persisted enumeration).
    MOVE = 'Move',
}

function ParaselenePoltergeist.Action:Create(initData)
    if initData.type == self.MOVE then
        return ParaselenePoltergeist.MoveAction:Create(initData)
    end
end
