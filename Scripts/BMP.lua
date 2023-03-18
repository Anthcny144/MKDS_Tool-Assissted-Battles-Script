BMP = {GTRIndex = 0, FileName = {}, FileX = {}, FileY = {}, FileSize = {}, PixelPointer = {}, Signature = {}, Pixels = {}}

-- Load an image
function BMP:New(Index, FileName, Print)
    if BMP.FileName[Index] ~= nil then return end
    if Print == nil then Print = false end

    local File = io.open(FileName, "rb")
    if File == nil then
        BMP:Error(nil, nil, FileName .. " does not exist")
        return
    end

    BMP.FileName[Index] = FileName
    BMP.FileSize[Index] = BMP:GetSize(nil, FileName)
    BMP.FileX[Index] = BMP:GetWidth(nil, FileName)
    BMP.FileY[Index] = BMP:GetHeight(nil, FileName)
    BMP.PixelPointer[Index] = BMP:GetPixelPointer(nil, FileName)
    BMP.Signature[Index] = BMP:GetSignature(nil, FileName)
    if BMP.GTRIndex < Index then BMP.GTRIndex = Index end

    local HeaderBytes = {0x4D42, 0x4142, 0x4943, 0x5043, 0x4349, 0x5450}
    local HeaderStrings = {"BM", "BA", "CI", "CP", "IC", "PT"}
    if BMP.Signature[Index] ~= HeaderBytes[1] then
        for i = 2, 6, 1 do
            if BMP.Signature[Index] == HeaderBytes[i] then
                BMP:Error(File, Index, "Invalid file header (" .. HeaderStrings[i] ..  ") for " .. FileName .. ". The script only works with the BM header.")
                return
            end
        end
        BMP:Error(File, Index, FileName .. " is an invalid BMP file.")
        return
    end

    local Bits = BMP:GetBitDepth(nil, FileName)
    if Bits ~= 32 then
        BMP:Error(File, Index, "Invalid bit depths for " .. FileName .. " (" .. Bits .. " instead of 32)")
        return
    end

    BMP.Pixels[Index] = {}
    -- Read pixels and add them in a table
    File:read(BMP.PixelPointer[Index]) -- Go to PixelPointer. We don't use BMP:Read here to avoid opening, reading from scratch and closing the file, which may be a bit unoptimized?
    for i = 1, (BMP.FileSize[Index] - BMP.PixelPointer[Index]) / 4, 1 do
        local PixelString = File:read(4)
        local PixelHex = {Helper:Hex(PixelString:byte(3), 2), Helper:Hex(PixelString:byte(2), 2), Helper:Hex(PixelString:byte(1), 2), Helper:Hex(PixelString:byte(4), 2)} -- R, G, B, Alpha in order
        table.insert(BMP.Pixels[Index], PixelHex[1] .. PixelHex[2] .. PixelHex[3] .. PixelHex[4])
    end
    io.close(File)
    if Print then print("Loaded " .. FileName .. " at index " .. Index) end
end

-- Draw loaded BMP loaded at index
function BMP:Draw(Index, X, Y, Scale)
    if BMP.FileName[Index] == nil then return end
    if Scale == nil then Scale = 0
    else Scale = Scale - 1 end
    local OffsetX, OffsetY, Line = 0, 0, 0
    for i = 1, #BMP.Pixels[Index], 1 do
        if i % BMP.FileX[Index] == 1 and i ~= 1 then -- Change line
            OffsetX = 0
            OffsetY = OffsetY + 1 + Scale
            Line = Line + 1
        end
        local Index_ = #BMP.Pixels[Index] + i - ((BMP.FileX[Index] * 2) * Line) - BMP.FileX[Index] -- Formula to get the correct index of pixel to print. BMP doesn't store pixel from top left to bottom right
        local X_ = X + OffsetX
        local Y_ = Y + OffsetY
        if BMP.Pixels[Index][Index_] ~= "00000000" then
            gui.rect(X_, Y_, X_ + Scale, Y_ + Scale, "#" .. BMP.Pixels[Index][Index_], "#" .. BMP.Pixels[Index][Index_])
        end
        OffsetX = OffsetX + 1 + Scale
    end
end

-- Unload a loaded image at index
function BMP:Free(Index, Print)
    if BMP.FileName[Index] == nil then return end
    if Print == nil then Print = false end
    if Print then print("Unload " .. BMP.FileName[Index] .. " at index " .. Index) end
    BMP.FileName[Index] = nil
    BMP.FileX[Index] = nil
    BMP.FileY[Index] = nil
    BMP.FileSize[Index] = nil
    BMP.PixelPointer[Index] = nil
    BMP.Pixels[Index] = nil

    if Index == BMP.GTRIndex then
        for i = 1, BMP.GTRIndex, 1 do
            if BMP:IsLoaded(BMP.GTRIndex - i) then BMP.GTRIndex = BMP.GTRIndex - i end
        end
    end
end

-- Function you might use
function BMP:GetName(Index) return BMP.FileName[Index] end
function BMP:GetWidth(Index, FileName) return BMP:Read(Index ~= nil and BMP:GetName(Index) or FileName, 0x12, 4) end
function BMP:GetHeight(Index, FileName) return BMP:Read(Index ~= nil and BMP:GetName(Index) or FileName, 0x16, 4) end
function BMP:GetSize(Index, FileName) return BMP:Read(Index ~= nil and BMP:GetName(Index) or FileName, 0x2, 4, true) end
function BMP:GetBitDepth(Index, FileName) return BMP:Read(Index ~= nil and BMP:GetName(Index) or FileName, 0x1C, 2) end

function BMP:IsLoaded(Index, FileName)
    if Index ~= nil then return BMP.FileName[Index] ~= nil end
    local Loaded = {}
    for i = 1, BMP.GTRIndex, 1 do
        if BMP.FileName[i] == FileName then Loaded[i] = true
        else Loaded[i] = false
        end
    end
    return Loaded
end

function BMP:GetLoadedAmount()
    local Loaded = 0
    for i = 1, BMP.GTRIndex, 1 do
        if BMP.FileName[i] ~= nil then Loaded = Loaded + 1 end
    end
    return Loaded
end

-- Functions bellow are used for the BMP functions so ignore them
function BMP:GetPixelPointer(Index, FileName) return BMP:Read(Index ~= nil and BMP:GetName(Index) or FileName, 0xA, 2) end
function BMP:GetSignature(Index, FileName) return BMP:Read(Index ~= nil and BMP:GetName(Index) or FileName, 0, 2) end

-- Get rid of the image that is causing the error (if any) and prints the error message
function BMP:Error(File, Index, Message)
    if File ~= nil then io.close(File) end
    if Index ~= nil then BMP:Free(Index) end
    print("ERROR: " .. Message)
end

-- Returns read bytes from an address of a file
function BMP:Read(FileName, Address, Bytes)
    local File = io.open(FileName, "rb")
    if File == nil then return end
    File:read(Address)
    local Temp = 0
    local Bytes_ = {} -- Hex string of each read byte
    local Multipliers = {0x1, 0x100, 0x10000, 0x1000000}
    for i = 1, Bytes, 1 do
        if i > 4 then break end
        Temp = File:read(1)
        Bytes_[i] = Temp:byte(1) * Multipliers[i]
    end
    local Value = 0
    for i = 1, #Bytes_, 1 do
        Value = Value + Bytes_[i]
    end
    io.close(File)
    return Value
end