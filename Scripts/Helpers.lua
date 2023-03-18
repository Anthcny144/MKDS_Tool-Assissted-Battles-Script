Helper = {}

-- Returns the hex value of an int input
function Helper:Hex(IntValue, Length)
    if Length == nil then Length = 8 end
    local HexValue = string.format("%x", IntValue)
    local ToAdd = Length - #HexValue
    local Zeros = ""
    for i = 1, ToAdd, 1 do Zeros = Zeros .. "0" end
    return string.upper(Zeros .. HexValue)
end

-- Return true if specified value is >= the minimum and <= the maximum
function Helper:IsBetween(Value, Min, Max) return Value >= Min and Value <= Max end

-- Returns true if specified value is an address, false otherwise
function Helper:IsAddress(Value) return Value >= 0x2000000 and Value <= 0x3000000 end

-- Returns "Yes" for true bool and "No" for false bool
function Helper:Bool2YesNo(Bool)
    if Bool then return "Yes" end
    return "No"
end

-- Returns 1 if the bool is true, 0 otherwise
function Helper:Bool2Int(Bool)
    if Bool then return 1 end
    return 0
end

-- Returns a green / red color depending on the bool
function Helper:GetYesNoColor(Bool)
    if Bool then return "#70FF70" end
    return "#FF7070"
end