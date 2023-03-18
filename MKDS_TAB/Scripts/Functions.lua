-- IMPORTANT: for indexes, 0 is yourself, 7 is CPU7

-- Returns trie if the track is loaded, false otherwise
function Race:IsTrackLoaded()
    return memory.readdword(Race.PTR[R]) ~= 0
end

-- Returns item of a player
function Item:Get(Index)
    return memory.readbyte(Item.Addr + 0x4C + Index * 0x210)
end

-- Returns number of items the player is holding (1 for single items, 3 for triple, 2 for 2 shrooms)
function Item:GetAmount(Index)
    return memory.readbyte(Item.Addr + 0x54 + Index * 0x210)
end

-- Returns item that the player is going to have in the current item box
function Item:GetNext(Index)
    return memory.readbyte(Item.Addr + 0x2C + Index * 0x210)
end

-- Returns true if the item roulette of a player is spinning, false otherwise
function Item:IsRoulette(Index)
    return memory.readdword(Item.Addr + 0x2C + Index * 0x210) ~= 0x13
end

-- Returns roulette progression of a player (in frames)
function Item:GetRouletteFrame(Index)
    local Value = memory.readbyte(Item.Addr + 0x20 + Index * 0x210) + (memory.readbyte(Item.Addr + 0x1C + Index * 0x210) - 1) * 0xD5 + (memory.readbyte(Item.Addr + 0x1C + Index * 0x210) - 1)
    if Value < 0 then Value = 0 end
    return Value
end

-- Returns true if the player holds an item that can be used, false otherwise
function Item:CanUse(Index)
    return Item:Get(Index) ~= 0x13 or Item:GetRouletteFrame(Index) == 246
end

-- Returns a RBG string color depending on the current duration of the Star
function Item:GetStarColor(Duration)
    local Value = math.floor(Duration * (255 / 74)) - math.floor(Duration / 75) * 0xFF
    if Value > 0xFF then Value = 0xFF end
    if Value < 0 then Value = 0 end
    if Helper:IsBetween(Duration, 1, 74) then return "#FF" .. Helper:Hex(Value, 2) .. "00"
    elseif Helper:IsBetween(Duration, 75, 149) then return "#" .. Helper:Hex(0xFF - Value, 2) .. "FF00"
    elseif Helper:IsBetween(Duration, 150, 224) then return "#00FF" .. Helper:Hex(Value, 2)
    elseif Helper:IsBetween(Duration, 225, 299) then return "#00" .. Helper:Hex(0xFF - Value, 2) .. "FF"
    elseif Helper:IsBetween(Duration, 300, 374) then return "#" .. Helper:Hex(Value, 2) .. "00FF"
    elseif Helper:IsBetween(Duration, 375, 449) then return "#FF00" .. Helper:Hex(0xFF - Value, 2)
    else return "#FF0000" end
end

-- Returns 1 when player is in Star, 2 when in Boo, 0 otherwise
function Item:GetState(Index)
    return memory.readbyte(Race.Addr + 0x29C + Index * 0x5A8)
end

function Item:GetGoldenMushroomDuration(Index)
end

-- Returns current Star duration of a player (in frames), does not reset when Star ends
function Item:GetStarDuration(Index)
    return memory.readword(Race.Addr + 0x53E + Index * 0x5A8)
end

-- Returns current Boo duration of a player (in frames), does not reset when Boo ends
function Item:GetBooDuration(Index)
    return memory.readword(Race.Addr + 0x548 + Index * 0x5A8)
end

-- Returns mode being played
function Setting:GetMode()
    return memory.readbyte(Mode.Addr[R])
end

-- Returns current state of the mini map
function Setting:GetMinimapState()
    return memory.readbyte(Minimap.Addr[R])
end

-- Returns player's character's name
function Setting:GetCharacterName(ID)
    return Character.Name[memory.readbyte(Character.Addr[R] + ID * 0x30) + 1]
end

-- Returns number of balloons loaded (above the player's head)
function Battle:GetLoadedBalloons(Index)
    local Value = memory.readbyte(Battle.Addr + 0x4C + Index * 0x70)
    if Value == 0xFF then Value = 0 end
    return Value
end

-- Returns number of balloons in stock, ready to be blew
function Battle:GetStockedBalloons(Index)
    return memory.readbyte(Battle.Addr + 0x50 + Index * 0x70)
end

-- Returns true if player is blowing a balloon, false otherwise
function Battle:IsBlowingBalloon(Index)
    if Index == 0 then return memory.readbyte(Battle.Addr + 0x68 + Index * 0x70) == 1 end
    return memory.readbyte(Battle.Addr + 0x6C + Index * 0x70) == 1
end

-- Returns true if player is in the hit animation, false otherwise
function Battle:IsHit(Index)
    return memory.readbyte(Battle.Addr + Index * 0x70) == 1
end

-- Returns true if player is into the fall off animation, false otherwise
function Race:IsFallingOff(Index)
    return memory.readdword(Race.Addr + 0x3C4 + Index * 0x5A8) ~= 0xFFFFFFFF
end

-- Returns true if player is in the respawn animation, false otherwise
function Race:IsRespawning(Index)
    return memory.readword(Race.Addr + 0x240 + Index * 0x5A8) == 0x1000
end

-- Returns true if player is eliminated, false otherwise
function Battle:IsDead(Index)
    return memory.readbyte(Battle.Addr + 0x8 + Index * 0x70) == 2
end

-- Returns true if timer has started, false otherwise
function Timer:IsOn()
    return memory.readdword(Timer.Addr + 4) == 1 and memory.readbyte(Timer.Addr + 0x14) == 0
end