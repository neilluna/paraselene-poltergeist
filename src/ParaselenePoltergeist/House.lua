ParaselenePoltergeist.House = {}

function ParaselenePoltergeist.House:Clone(otherInstance)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    if otherInstance.clipboard then
        newInstance.clipboard = ParaselenePoltergeist.Placement:Clone(otherInstance.clipboard)
    end

    newInstance.placements = ParaselenePoltergeist.PlacementStorage:Clone(otherInstance.placements)

    return newInstance
end

function ParaselenePoltergeist.House.Load(savedData)
    local clipboard = nil
    if savedData.clipboard then
        clipboard = ParaselenePoltergeist.Placement.Load(savedData.clipboard)
    end

    local placementData = savedData.placements or {}
    return ParaselenePoltergeist.House:Clone{
        clipboard = clipboard,
        placements = ParaselenePoltergeist.PlacementStorage.Load(placementData),
    }
end

function ParaselenePoltergeist.House:Save()
    local clipboardData = nil
    if self.clipboard then
        clipboardData = self.clipboard:Save()
    end

    return {
        clipboard = clipboardData,
        placements = self.placements:Save(),
    }
end

function ParaselenePoltergeist.House:SetClipboard(placement)
    self.clipboard = placement
end

function ParaselenePoltergeist.House:ClearClipboard()
    self.clipboard = nil
end
