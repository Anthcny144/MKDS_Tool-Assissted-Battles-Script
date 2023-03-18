function ReadPointers()
    Race.Addr = memory.readdword(Race.PTR[R])
    Item.Addr = memory.readdword(Item.PTR[R])
    Battle.Addr = memory.readdword(Battle.PTR[R])
    Timer.Addr = memory.readdword(Timer.PTR[R])
end

function Main()

    if memory.readdword(Widescreen1.Addr[R]) == 0x1555 then
        memory.writedword(Widescreen1.Addr[R], 0x1C71)
        memory.writedword(Widescreen2.Addr[R], 0x1C71)
        memory.writeword(Widescreen_GUI.Addr[R], 0xAAA)
    end

    if Race:IsTrackLoaded() and Timer:IsOn() and Setting:GetMode() == Mode.Battle then

        -- Load images
        if not BMP:IsLoaded(1) then
            for i = 1, 7 do -- CPUs
                BMP:New(i, "BMP/Characters/" .. Setting:GetCharacterName(i) .. ".bmp")
            end
            BMP:New(8, "BMP/Balloon1.bmp")
            BMP:New(9, "BMP/Balloon2.bmp")
            BMP:New(10, "BMP/Balloon3.bmp")
            BMP:New(11, "BMP/Items/No item.bmp")
            for i = 0, 0x10 do -- Items
                local Index = i
                if i == 5 then Index = 4 end
                if i == 9 then Index = 0 end
                if i == 0xA then Index = 2 end
                if i == 0xB then Index = 1 end
                BMP:New(i + 12, "BMP/Items/" .. Item.List[Index + 1][1] .. ".bmp")
            end
            BMP:New(29, "BMP/Items/x2.bmp")
            BMP:New(30, "BMP/Items/x3.bmp")
        end

        -- Draw images
        if Setting:GetMinimapState() == Minimap.In then
            gui.rect(0, 0, 136, 384, "#2F2F2F")
            gui.rect(136, 0, 144, 384, "#000000")
            for i = 1, 7 do -- CPU
                BMP:Draw(i, 2, 4 + (i - 1) * 40, 2)
            end
            for i = 1, 7 do
                -- CPU balloons
                for j = 0, Battle:GetLoadedBalloons(i) - 1 + Helper:Bool2Int(Battle:IsBlowingBalloon(i)) do
                    local Index = 8
                    if Battle:IsBlowingBalloon(i) and j == Battle:GetLoadedBalloons(i) then Index = 9 end
                    if (Battle:IsHit(i) or Race:IsRespawning(i) or Race:IsFallingOff(i)) and j == Battle:GetLoadedBalloons(i) - 1 then Index = 10 end
                    BMP:Draw(Index, 36, 4 + j * 10 + (i - 1) * 40, 2)
                end
                -- Info texts
                if not Battle:IsDead(i) then
                    gui.text(90, 6 + (i - 1) * 40, "Hit", Helper:GetYesNoColor(Battle:IsHit(i)))
                    gui.text(90, 16 + (i - 1) * 40, "Respawn", Helper:GetYesNoColor(Race:IsRespawning(i) or Race:IsFallingOff(i)))
                    gui.text(90, 26 + (i - 1) * 40, "State", Item:GetState(i) == 1 and Item:GetStarColor(Item:GetStarDuration(i)) or Item:GetState(i) == 2 and "#FFFFFF" or Helper:GetYesNoColor(false))
                end
                -- Roulette
                if Item:GetNext(i) ~= 0x13 then
                    BMP:Draw(11, 50, 4 + (i - 1) * 40, 2)
                end
                -- Next item
                if Item:Get(i) ~= 0x13 then
                    BMP:Draw(12 + Item:Get(i), 50, 4 + (i - 1) * 40, 2)
                end
                -- x2 or x3
                if Item:GetAmount(i) == 2 then BMP:Draw(29, 64, 22 + (i - 1) * 40, 2) end
                if Item:GetAmount(i) == 3 then BMP:Draw(30, 64, 22 + (i - 1) * 40, 2) end
            end
        end

        -- Draw kart stuff
        if Setting:GetMinimapState() == Minimap.In then
            local Speed = memory.readdwordsigned(Race.Addr + 0x2A8)
            local Boost = memory.readdword(Race.Addr + 0x238)
            local MTCharge = memory.readdwordsigned(Race.Addr + 0x30C)
            local TurningLoss = memory.readdwordsigned(Race.Addr + 0x2D4)
            local Air = memory.readbyte(Race.Addr + 0x3DD) ~= 0
            if MTCharge < -1 then MTCharge = -1 end

            gui.text(10, 290, "Speed    :") gui.text(76, 290, Speed, "#009BFF")
            gui.text(10, 300, "Turning  :") gui.text(76, 300, math.abs(TurningLoss), "#809BFF")
            gui.text(10, 310, "Boost    :") gui.text(76, 310, Boost, "#FF7F00")
            gui.text(10, 320, "MT charge:") gui.text(76, 320, MTCharge, "#FFD800")
            gui.text(10, 330, "On       :")
            if Air then gui.text(76, 330, "Air", "#7FC9FF")
            else gui.text(76, 330, "Ground", "#7F3300") end
        end

        -- Manage next item
        gui.text(12, -274, "Next     :") gui.text(80, -274, Item:IsRoulette(0) and Item.List[Item:GetNext(0) + 1][1] or "-", Item:IsRoulette(0) and Item.List[Item:GetNext(0) + 1][2] or "")
        gui.text(12, -264, "On frame :") gui.text(80, -264, Item.OnFrame ~= nil and Item.OnFrame or "-", Item.OnFrame ~= nil and "#009FFF" or "")
        gui.text(12, -254, "Roulette :") gui.text(80, -254, Item:GetNext(0) ~= 0x13 and Item:GetRouletteFrame(0) .. " / 246" or "-", Item:IsRoulette(0) and "#FFD800" or "")
        gui.text(12, -244, "Can speed:") gui.text(80, -244, Item:GetNext(0) ~= 0x13 and Helper:Bool2YesNo(Helper:IsBetween(Item:GetRouletteFrame(0), 59, 213)) or "-", Item:IsRoulette(0) and Helper:GetYesNoColor(Helper:IsBetween(Item:GetRouletteFrame(0), 59, 213)) or "")
        gui.text(12, -234, "Can use  :") gui.text(80, -234, (Item:Get(0) ~= 0x13 or Item:IsRoulette(0)) and Helper:Bool2YesNo(Item:CanUse(0)) or "-", (Item:Get(0) ~= 0x13 or Item:IsRoulette(0)) and Helper:GetYesNoColor(Item:CanUse(0)) or "")
        if Item:GetNext(0) ~= 0x13 then
            if not Item.LockNext then
                Item.LockNext = true
                Item.OnFrame = emu.framecount()
            end
        end

        -- Item special case
        if Item:Get(0) == 0xD then -- Golden
            local Duration = memory.readword(Item.Addr + 0x5C)
            gui.text(12, -224, "Duration :") gui.text(80, -224, Duration ~= 0 and Duration or "-", Duration ~= 0 and "#FF8C00" or "")
        elseif Item:GetState(0) == 1 then -- Star
            local Duration = Item:GetStarDuration(0)
            gui.text(12, -224, "Duration :") gui.text(80, -224, Duration ~= 0 and 451 - Duration or "-", Duration ~= 0 and Item:GetStarColor(Duration) or "") -- "#FFDD00"
        elseif Item:GetState(0) == 2 then -- Boo
            local Duration = Item:GetBooDuration(0)
            gui.text(12, -224, "Duration :") gui.text(80, -224, Duration ~= 0 and 451 - Duration or "-", Duration ~= 0 and "#FFFFFF" or "")
        elseif Item:GetNext(0) == 0x13 then -- No item
            Item.LockNext = false
            Item.OnFrame = nil
        end

    elseif BMP:IsLoaded(1) then
        for i = 1, 32 do BMP:Free(i) end
    end
end