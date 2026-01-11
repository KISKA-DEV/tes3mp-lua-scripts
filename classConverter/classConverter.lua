-- classConverter.lua

-- by KISKA_DEV from Morrowind Classic RP server (russian language)

-- https://discord.gg/Ad5XR4JNZb

-- 2026 CC BY-NC-SA 4.0

-- sometimes i think "why tes3mp even need dafault classes..."

-- so i get rid of them XD


-- Don't forget this thing in customScripts:

-- classConverter = require("custom.classConverter")


-- === conv data (ID -> Name) ===

local skillIdToName = {
    [0] = "Block", [1] = "Armorer", [2] = "Mediumarmor", [3] = "Heavyarmor",
    [4] = "Bluntweapon", [5] = "Longblade", [6] = "Axe", [7] = "Spear",
    [8] = "Athletics", [9] = "Enchant", [10] = "Destruction", [11] = "Alteration",
    [12] = "Illusion", [13] = "Conjuration", [14] = "Mysticism", [15] = "Restoration",
    [16] = "Alchemy", [17] = "Unarmored", [18] = "Security", [19] = "Sneak",
    [20] = "Acrobatics", [21] = "Lightarmor", [22] = "Shortblade", [23] = "Marksman",
    [24] = "Mercantile", [25] = "Speechcraft", [26] = "Handtohand"
}

local attrIdToName = {
    [0] = "Strength", [1] = "Intelligence", [2] = "Willpower",
    [3] = "Agility", [4] = "Speed", [5] = "Endurance",
    [6] = "Personality", [7] = "Luck"
}

-- === default classes data ===

-- can translate on ur lang here

local StandartClasses = {
    ["acrobat"] = {
        name = "Acrobat", specialization = 2, 
        attributes = {3, 5}, major = {20, 8, 23, 19, 17}, minor = {25, 11, 7, 26, 21}
    },
    ["agent"] = {
        name = "Agent", specialization = 2,
        attributes = {6, 3}, major = {25, 19, 20, 21, 22}, minor = {24, 13, 0, 17, 12}
    },
    ["archer"] = {
        name = "Archer", specialization = 0,
        attributes = {3, 0}, major = {23, 5, 0, 8, 21}, minor = {17, 7, 15, 19, 2}
    },
    ["assassin"] = {
        name = "Assassin", specialization = 2,
        attributes = {4, 1}, major = {19, 23, 21, 22, 20}, minor = {18, 5, 16, 0, 8}
    },
    ["barbarian"] = {
        name = "Barbarian", specialization = 0,
        attributes = {0, 4}, major = {6, 2, 4, 8, 0}, minor = {20, 21, 1, 23, 17}
    },
    ["bard"] = {
        name = "Bard", specialization = 2,
        attributes = {6, 1}, major = {25, 8, 20, 5, 0}, minor = {24, 12, 2, 9, 18}
    },
    ["battlemage"] = {
        name = "Battlemage", specialization = 1,
        attributes = {1, 0}, major = {11, 10, 13, 6, 3}, minor = {14, 5, 23, 9, 8}
    },
    ["crusader"] = {
        name = "Crusader", specialization = 0,
        attributes = {3, 0}, major = {4, 5, 10, 3, 0}, minor = {15, 1, 26, 2, 8}
    },
    ["healer"] = {
        name = "Healer", specialization = 1,
        attributes = {2, 6}, major = {15, 14, 11, 26, 25}, minor = {12, 16, 17, 21, 4}
    },
    ["knight"] = {
        name = "Knight", specialization = 0,
        attributes = {0, 6}, major = {5, 6, 25, 3, 0}, minor = {15, 24, 2, 9, 1}
    },
    ["mage"] = {
        name = "Mage", specialization = 1,
        attributes = {1, 2}, major = {14, 10, 11, 12, 15}, minor = {9, 16, 17, 22, 13}
    },
    ["monk"] = {
        name = "Monk", specialization = 2,
        attributes = {3, 2}, major = {26, 17, 8, 20, 19}, minor = {0, 23, 21, 15, 4}
    },
    ["nightblade"] = {
        name = "Nightblade", specialization = 1,
        attributes = {2, 4}, major = {14, 12, 11, 19, 22}, minor = {21, 17, 10, 23, 18}
    },
    ["pilgrim"] = {
        name = "Pilgrim", specialization = 2,
        attributes = {6, 5}, major = {25, 24, 23, 15, 2}, minor = {12, 26, 22, 0, 16}
    },
    ["rogue"] = {
        name = "Rogue", specialization = 0,
        attributes = {4, 6}, major = {22, 24, 6, 21, 26}, minor = {0, 2, 25, 8, 5}
    },
    ["scout"] = {
        name = "Scout", specialization = 0,
        attributes = {4, 5}, major = {19, 5, 2, 8, 0}, minor = {23, 16, 11, 21, 17}
    },
    ["sorcerer"] = {
        name = "Sorcerer", specialization = 1,
        attributes = {1, 5}, major = {9, 13, 14, 10, 11}, minor = {12, 2, 3, 23, 22}
    },
    ["spellsword"] = {
        name = "Spellsword", specialization = 1,
        attributes = {2, 5}, major = {0, 15, 5, 10, 11}, minor = {4, 9, 16, 2, 6}
    },
    ["thief"] = {
        name = "Thief", specialization = 2,
        attributes = {4, 3}, major = {18, 19, 20, 21, 22}, minor = {23, 25, 26, 24, 8}
    },
    ["warrior"] = {
        name = "Warrior", specialization = 0,
        attributes = {0, 5}, major = {5, 2, 3, 8, 0}, minor = {1, 7, 23, 6, 4}
    },
    ["witchhunter"] = {
        name = "Witchhunter", specialization = 1,
        attributes = {1, 3}, major = {13, 9, 16, 21, 23}, minor = {17, 0, 4, 19, 14}
    }
}

local function IdsToNames(ids, map)
    local names = {}
    for _, id in ipairs(ids) do
        table.insert(names, map[id] or "Unknown")
    end
    return table.concat(names, ", ")
end


local function ConvertStandartClass(pid)
    if not Players[pid] or not Players[pid].data or not Players[pid].data.character then return end

    local cv = Players[pid].data
    local className = string.lower(cv.character.class)

    if className == "custom" then return end

    if StandartClasses[className] then
        local classDef = StandartClasses[className]

        local newCustomClass = {
            name = classDef.name,
            description = "Standart Class Converted",
            specialization = classDef.specialization,
            majorAttributes = IdsToNames(classDef.attributes, attrIdToName),
            majorSkills = IdsToNames(classDef.major, skillIdToName),
            minorSkills = IdsToNames(classDef.minor, skillIdToName)
        }

        cv.character.class = "custom"
        cv.customClass = newCustomClass

        Players[pid]:Save()
        
        -- tes3mp.SendMessage(pid, color.Green .. "System: class '" .. classDef.name .. "' adapted.\n", false)
    end
end


customEventHooks.registerHandler("OnPlayerAuthentified", function(eventStatus, pid)
    if not Players[pid] then return end
    ConvertStandartClass(pid)
end)

customEventHooks.registerHandler("OnPlayerEndCharGen", function(eventStatus, pid)
    if not Players[pid] then return end
    ConvertStandartClass(pid)
end)