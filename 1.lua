_G.SetFOV110=function()

    local GameplayData=require("GameLua.GameCore.Data.GameplayData")

    local player=GameplayData.GetPlayerCharacter()

    if not slua.isValid(player) then
        return
    end

    local camera=player.ThirdPersonCameraComponent

    if not camera then
        return
    end

    camera:SetFieldOfView(110)

end

pcall(_G.SetFOV110)