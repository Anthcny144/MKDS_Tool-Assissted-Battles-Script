Regions = {"EUR", "USA", "JPN", "KOR"}
if emu.gamecode() == "AMCP" then R = 1
elseif emu.gamecode() == "AMCE" then R = 2
elseif emu.gamecode() == "AMCJ" then R = 3
elseif emu.gamecode() == "AMCK" then R = 4
else input.popup("This is a MKDS script, what are you even trying to do", "ok", "error") end

if R ~= nil then
    dofile "Scripts/Helpers.lua"
    dofile "Scripts/Values.lua"
    dofile "Scripts/Functions.lua"
    dofile "Scripts/BMP.lua"
    dofile "Scripts/Main.lua"
    print("MKDS TAB: Script has started")
    emu.registerbefore(ReadPointers)
    gui.register(Main)
end