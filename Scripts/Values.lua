Setting = {}

Widescreen1 = {Addr = {0x20775D0, 0x20775D0, 0x2077710, 0x20762C8}}
Widescreen2 = {Addr = {0x20789BC, 0x20789BC, 0x2078AFC, 0x2077638}}
Widescreen_GUI = {Addr = {0x208A068, 0x208A068, 0x208A1A8, 0x20884C8}}
Character =  {Addr = {0x23CDD40, 0x23CDD40, 0x23CD380, 0x23CD640}, Name = {"Mario", "DK", "Toad", "Bowser", "Peach", "Wario", "Yoshi", "Luigi", "Dry Bones", "Daisy","Waluigi", "ROB", "Shy Guy"}}
Mode = {Addr = {0x23CDCE0, 0x23CDCE0, 0x23CD320, 0x23CD5E0}, GP = 0, TimeTrials = 1, VS = 3, Battle = 2, Mission = 4 }
Minimap = {Addr = {0x22C7AE8, 0x22C7AA8, 0x22C7688, 0x22C3948}, In = 1, Out = 0} -- Not sure if it works all the time

Race = {PTR = {0x217AD18, 0x217ACF8, 0x217AD98, 0x2362490}, Addr = 0}

Item = 
{
    PTR = {0x217BC4C, 0x217BC2C, 0x217BCCC, 0x2175FCC}, Addr = 0, OnFrame = nil, LockNext = false,
    List =
    {
        {"Green Shell", "#00BF00"},
        {"Red Shell", "#FF0000"},
        {"Banana", "#E0DD00"},
        {"FIB", "#FF4F4F"},
        {"Mushroom", "#FF3030"},
        {"3 Mushrooms", "#FF3030"},
        {"Bob-omb", "#213577"},
        {"Blue Shell", "#009BFF"},
        {"Shock", "#FFFF00"},
        {"3 Green Shells", "#00BF00"},
        {"3 Bananas", "#E0DD00"},
        {"3 Red Shells", "#FF0000"},
        {"Star", "#FFDD00"},
        {"Golden Mushroom", "#FF8C00"},
        {"Bullet Bill", "#1F1F1F"},
        {"Blooper", "#EFEFEF"},
        {"Boo", "#FFFFFF"}
    }
}

Battle = {PTR = {0x217ACB4, 0x217AC94, 0x217AD34, 0x2175034}, Addr = 0}

Timer = {PTR = {0x217561C, 0x21755FC, 0x217569C, 0x216F9A0}, Addr = 0}