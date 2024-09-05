ParaselenePoltergeist.House = {}

function ParaselenePoltergeist.House:Create(initData)
    local newInstance = {}
    setmetatable(newInstance, self)
    self.__index = self

    if initData.clipboard then
        newInstance.clipboard = ParaselenePoltergeist.Placement:Create(initData.clipboard)
    end

    newInstance.placements = ParaselenePoltergeist.PlacementStorage:Create(initData.placements)

    return newInstance
end

function ParaselenePoltergeist.House.Init()
    return ParaselenePoltergeist.House:Create{
        placements = ParaselenePoltergeist.PlacementStorage.Init()
    }
end

function ParaselenePoltergeist.House:Save()
    local house = {}

    if self.clipboard then
        house.clipboard = self.clipboard:Save()
    end

    house.placements = self.placements:Save()

    return house
end

function ParaselenePoltergeist.House:SetClipboard(placement)
    self.clipboard = placement
end

function ParaselenePoltergeist.House:GetClipboard()
    return self.clipboard
end

function ParaselenePoltergeist.House:ClearClipboard()
    self.clipboard = nil
end
