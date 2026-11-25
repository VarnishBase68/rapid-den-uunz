-- ═══════════════════════════════════════════════════════════════════════════
-- DOOMSENSE v2.4
-- ═══════════════════════════════════════════════════════════════════════════

-- Services
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local TweenService        = game:GetService("TweenService")
local Workspace           = game:GetService("Workspace")
local CoreGui             = game:GetService("CoreGui")
local Lighting            = game:GetService("Lighting")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local StatsService        = game:GetService("Stats")
local SoundService        = game:GetService("SoundService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Debris              = game:GetService("Debris")
local TeleportService     = game:GetService("TeleportService")
local CollectionService   = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

-- FILE SYSTEM & LMS PATHS
local LMS_DIR = "Doomsense/CustomLms"

task.spawn(function()
    if isfolder and makefolder then
        if not isfolder("Doomsense") then makefolder("Doomsense") end
        if not isfolder("Doomsense/cfg") then makefolder("Doomsense/cfg") end
        if not isfolder("Doomsense/cfg/settings") then makefolder("Doomsense/cfg/settings") end
        if not isfolder(LMS_DIR) then makefolder(LMS_DIR) end
    end
end)

-- Libraries
local Fluent           = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager      = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ═══════════════════════════════════════════════════════════════════════════
-- FIX: SaveManager Slider String & Autoload Trimming Patch
-- ═══════════════════════════════════════════════════════════════════════════
if SaveManager and SaveManager.Parser then
    if SaveManager.Parser.Slider then
        SaveManager.Parser.Slider.Load = function(idx, data)
            if SaveManager.Options and SaveManager.Options[idx] then
                local numVal = tonumber(data.value)
                SaveManager.Options[idx]:SetValue(numVal ~= nil and numVal or data.value)
            end
        end
    end

    local oldLoad = SaveManager.Load
    SaveManager.Load = function(self, name)
        if type(name) == "string" then
            name = name:gsub("[\r\n\t]+", ""):match("^%s*(.-)%s*$")
        end
        return oldLoad(self, name)
    end
end

-- MODEL DATABASE
local MODEL_DATABASE = {
    ["Survivors"] = {
        ["Silver"]     = {["Default"] = {["Studs"] = {["X"] = 5.15, ["Y"] = 8.48, ["Z"] = 6.95}}},
        ["Knuckles"]   = {["Default"] = {["Studs"] = {["X"] = 3.92, ["Y"] = 6.41, ["Z"] = 7.18}}},
        ["Sonic"]      = {["Default"] = {["Studs"] = {["X"] = 6.49, ["Y"] = 6.74, ["Z"] = 4.92}}},
        ["Blaze"]      = {["Default"] = {["Studs"] = {["X"] = 3.61, ["Y"] = 7.56, ["Z"] = 6.02}}},
        ["Eggman"]     = {
            ["Default"]  = {["Studs"] = {["X"] = 14.93, ["Y"] = 9.34, ["Z"] = 7.65}},
            ["WIDENICK"] = {["Studs"] = {["X"] = 14.93, ["Y"] = 9.79, ["Z"] = 7.65}}
        },
        ["Tails"]      = {["Default"] = {["Studs"] = {["X"] = 9.72, ["Y"] = 6.63, ["Z"] = 7.08}}},
        ["Cream"]      = {["Default"] = {["Studs"] = {["X"] = 5.41, ["Y"] = 6.80, ["Z"] = 3.00}}},
        ["Amy"]        = {["Default"] = {["Studs"] = {["X"] = 8.73, ["Y"] = 6.77, ["Z"] = 5.32}}},
        ["MetalSonic"] = {["Default"] = {["Studs"] = {["X"] = 3.71, ["Y"] = 7.38, ["Z"] = 3.48}}}
    },
    ["EXE"] = {
        ["2011x"] = {
            ["miku"]           = {["Studs"] = {["X"] = 5.15,  ["Y"] = 8.60, ["Z"] = 11.69}},
            ["FeelstheRabbit"] = {["Studs"] = {["X"] = 11.69, ["Y"] = 8.11, ["Z"] = 3.83}},
            ["OozingX"]        = {["Studs"] = {["X"] = 5.15,  ["Y"] = 8.60, ["Z"] = 11.69}},
            ["RETRO"]          = {["Studs"] = {["X"] = 8.26,  ["Y"] = 7.41, ["Z"] = 5.07}},
            ["Default"]        = {["Studs"] = {["X"] = 11.69, ["Y"] = 8.60, ["Z"] = 5.15}},
            ["gihun"]          = {["Studs"] = {["X"] = 12.51, ["Y"] = 8.34, ["Z"] = 4.83}}
        },
        ["Kolossos"] = {
            ["Default"] = {["Studs"] = {["X"] = 15.99, ["Y"] = 10.98, ["Z"] = 7.76}},
            ["Forest"]  = {["Studs"] = {["X"] = 7.76,  ["Y"] = 14.35, ["Z"] = 15.99}}
        },
        ["Fleetway"] = {
            ["Default"]  = {["Studs"] = {["X"] = 5.83, ["Y"] = 7.60, ["Z"] = 7.68}},
            ["Yourself"] = {["Studs"] = {["X"] = 5.83, ["Y"] = 7.60, ["Z"] = 7.68}}
        },
        ["TailsDoll"] = {
            ["Glorbwire"] = {["Studs"] = {["X"] = 8.92, ["Y"] = 5.72, ["Z"] = 4.73}},
            ["sirmartin"]  = {["Studs"] = {["X"] = 3.65, ["Y"] = 6.49, ["Z"] = 4.00}},
            ["Default"]    = {["Studs"] = {["X"] = 4.32, ["Y"] = 5.71, ["Z"] = 8.92}}
        }
    }
}

-- Global Config
local GlobalConfig = {
    IsFlying    = false,
    IsSpeeding  = false,
    FlySpeed    = 60,
    WalkSpeed   = 45,
    AutoRing    = false,
    NoCDJump    = false,
    
    Main = {
        FlyUpKey    = "Space",
        FlyDownKey  = "LeftShift",
        NoclipMode  = "Off",
    },

    Visuals = {},

    AH = {
        Enabled           = false,
        Mode              = "Nearest",
        ManualTarget      = false,
        TargetChar        = "None",
        Color             = Color3.fromRGB(255, 0, 0),
        Delay             = 0.05,
        Height            = 0,
        Distance          = 0,
        RotX              = 0,
        RotY              = 0,
        RotZ              = 0,
        Noclip            = true,
        SmartAttack       = true,
        IndicatorSize     = 110,
        IndicatorTransp   = 0,
        IndicatorRotate   = true,
        IndicatorSpeed    = 5,
        IndicatorDir      = "Right",
        IndicatorDecal    = "Target Crosshair",
        IndicatorCustomID = "",
    },

    Vote = {
        Enabled    = false,
        SurvTarget = "Silver",
        ExeTarget  = "2011x",
        Randomize  = false,
        Delay      = 1,
    },

    LMS = {
        Enabled      = false,
        Volume       = 1.2,
        StartDelay   = 2.3,
        StartEffect  = "None",
        EffectVolume = 1,
        LoopTrack    = true,
        Track        = "None",
        ClassTracks  = { Survivor = "None", EXE = "None" },
    },

    Anim = {
        AutoDetect  = false,
        CurrentChar = "R6",
        CurrentName = "Dance 1",
        MuteSound   = false,
        Volume      = 2,
    },

    ShowMobileBtn = true,
}

-- Global State
local GlobalState = {
    ScriptActive    = true,
    SelectedPlayer  = nil,
    TeleportBind    = Enum.KeyCode.V,
    UpdateMobileBtn = nil,
    CurrentPing     = 0,

    Silver = {
        IsRecording = false,
        IsRewinding = false,
        Points      = {},
        LastPos     = nil,
        MaxPoints   = 20,
        MinDist     = 10,
    },

    AH = {
        Target             = nil,
        LockedRandomTarget = nil,
        LastAttack         = 0,
        DownedDB           = {},
        Keys               = {"W", "A", "S", "D"},
        Visual             = nil,
        History            = setmetatable({}, { __mode = "k" }),
        ActiveNoclipParts  = {},
    },

    Noclip = {
        ActiveObstacles = {},
        PendingExit     = {},
    },

    Vote = {
        VotedInRound = false,
        Phase        = "idle",
        Timer        = 0,
    },

    ART = {
        HandledThisRound  = false,
        SavedRingCF       = nil,
        LastTeleportTime  = 0,
    },

    LMS = {
        IsCapturing        = false,
        StopRoutineRunning = false,
        VisualPlayed       = false,
        CachedFolder       = nil,
        TrackFinished      = false,
        LmsCounter         = 0,
        RoundActive        = false
    },

    Vis = {
        PadCache       = {},
        HighlightCache = {},
        TagCache       = {},
        TrapCache      = {},
        LightCache     = {},
        HasScannedPads = false,
    },

    Anim = {
        Track = nil,
        Sound = nil,
    },
}

local Options = Fluent.Options
local AHCharDropdownControl   = nil
local AnimCharDropdownControl = nil
local AnimNameDropdownControl = nil

-- Optimization Caches
local CachedEscapeZones = {}
local CachedLobbyPos = Vector3.new(0, 5000, 0)
local LastMapScanState = ""

-- Safe FX ScreenGui Re-creator
local FX_Gui = nil
local function GetFXGui()
    if not FX_Gui or not FX_Gui.Parent then
        FX_Gui = Instance.new("ScreenGui")
        FX_Gui.Name           = "Doomsense_LMS_FX"
        FX_Gui.ResetOnSpawn   = false
        FX_Gui.IgnoreGuiInset = true
        FX_Gui.DisplayOrder   = 100
        FX_Gui.Parent         = CoreGui
    end
    return FX_Gui
end

local function SafeSetDropdownValues(control, values, defaultVal)
    if not control or type(values) ~= "table" then return end
    pcall(function()
        if typeof(control.SetValues) == "function" then
            control:SetValues(values)
        elseif typeof(control.Refresh) == "function" then
            control:Refresh(values)
        end
        if defaultVal and typeof(control.SetValue) == "function" then
            control:SetValue(defaultVal)
        end
    end)
end

-- DETECT EXE HELPERS
local GAME_EXE_NAMES = {
    "tailsdoll", "kolossos", "2011x", "fleetway", "furnace",
    "lord x", "exe", "tripwire", "rewrite", "eyx", "2017x",
    "executor", "legacyfurnace", "sonico", "steve", "bear5",
    "chara", "v1"
}

local function IsGameEXE(model)
    if not model or not model.Parent then return false end
    local charAttr = model:GetAttribute("Character") or model:GetAttribute("CharName")
    local targetName = string.lower(tostring(charAttr or model.Name or ""))
    for _, k in ipairs(GAME_EXE_NAMES) do
        if string.find(targetName, k) then return true end
    end
    return false
end

local RAGE_IDS = { "72233377540950", "9057530869" }
local function IsRageCheck(model)
    if not model or not model.Parent then return false end
    local n = tostring(model:GetAttribute("Character") or model:GetAttribute("CharName") or model.Name or "")
    if string.find(string.lower(n), "2011x") then
        if model:GetAttribute("RageMode") or model:GetAttribute("Rage") or model:FindFirstChild("RageFill", true) then 
            return true 
        end
        for _, s in pairs(SoundService:GetDescendants()) do
            if s:IsA("Sound") and s.Playing then
                for _, id in pairs(RAGE_IDS) do 
                    if string.find(s.SoundId, id) then return true end 
                end
            end
        end
    end
    return false
end

local VoteLists = {
    EXE = { "TailsDoll", "Kolossos", "2011x", "Fleetway" },
    Survivor = { "Tails", "Sonic", "Silver", "Blaze", "Cream", "MetalSonic", "Eggman", "Knuckles", "Amy" }
}

local function GetPlayerList()
    local list = {}
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then table.insert(list, v.Name) end
    end
    return list
end

local function GetGameState()
    if Workspace:FindFirstChild("GameProperties") and Workspace.GameProperties:FindFirstChild("State") then
        return Workspace.GameProperties.State.Value
    end
    return "UNKNOWN"
end

local function FindLobbySpawn()
    local candidates = {
        Workspace:FindFirstChild("Lobby"),
        Workspace:FindFirstChild("Maps"),
        Workspace:FindFirstChild("Map")
    }
    for _, parent in ipairs(candidates) do
        if parent then
            local sp = parent:FindFirstChild("SpawnLocation", true) or parent:FindFirstChild("Spawn", true)
            if sp and sp:IsA("BasePart") then return sp.CFrame end
        end
    end
    
    local globalSpawn = Workspace:FindFirstChildOfClass("SpawnLocation")
    if globalSpawn then return globalSpawn.CFrame end
    
    return CFrame.new(0, 50, 0)
end

local function UpdateMapCaches()
    local spawnCF = FindLobbySpawn()
    if spawnCF then CachedLobbyPos = spawnCF.Position end

    table.clear(CachedEscapeZones)
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("MeshPart") and v.MeshId == "rbxassetid://106058960373684" then
            table.insert(CachedEscapeZones, v.Position)
        elseif v:IsA("BasePart") and (v.Name == "2EscapePart" or v.Name == "1EscapePart" or v.Name == "3EscapePart" or v.Name == "EscapePart") then
            table.insert(CachedEscapeZones, v.Position)
        end
    end
end
task.spawn(UpdateMapCaches)

local function IsInLobbyArea(pos)
    if not pos then return false end
    local dist3D = (pos - CachedLobbyPos).Magnitude
    local diffY  = math.abs(pos.Y - CachedLobbyPos.Y)
    return (dist3D <= 250 and diffY <= 80)
end

local function IsNearEscapeZone(pos)
    if not pos then return true end
    for _, zonePos in ipairs(CachedEscapeZones) do
        if (zonePos - pos).Magnitude <= 12 then return true end
    end
    return false
end

-- ═══════════════════════════════════════════════════════════════════════════
-- ENTITY CLASSIFICATION & CHARACTER RESOLVER
-- ═══════════════════════════════════════════════════════════════════════════
local SURVIVOR_CANON_NAMES = {
    ["sonic"] = "Sonic", ["tails"] = "Tails", ["knuckles"] = "Knuckles",
    ["amy"] = "Amy", ["cream"] = "Cream", ["eggman"] = "Eggman",
    ["silver"] = "Silver", ["blaze"] = "Blaze", ["metalsonic"] = "MetalSonic",
    ["metal sonic"] = "MetalSonic", ["shadow"] = "Shadow", ["supersonic"] = "SuperSonic",
    ["super sonic"] = "SuperSonic"
}

local EXE_CANON_NAMES = {
    ["2011x"] = "2011x", ["kolossos"] = "Kolossos", ["fleetway"] = "Fleetway",
    ["tailsdoll"] = "TailsDoll", ["tripwire"] = "TailsDoll", ["tails doll"] = "TailsDoll",
    ["furnace"] = "Furnace", ["lord x"] = "Lord X", ["2017x"] = "2017x",
    ["executor"] = "Executor", ["legacyfurnace"] = "LegacyFurnace"
}

local EntityInfoCache = setmetatable({}, { __mode = "k" })

local function ResolveEntityInfo(target)
    local plr, char = nil, nil
    if typeof(target) == "Instance" then
        if target:IsA("Player") then
            plr = target
            char = plr.Character
        elseif target:IsA("Model") then
            char = target
            plr = Players:GetPlayerFromCharacter(char) or Players:FindFirstChild(char.Name)
        end
    end

    if char and EntityInfoCache[char] then
        return EntityInfoCache[char]
    end

    local isExe = false
    if char then
        isExe = IsGameEXE(char) or (char:GetAttribute("Team") == "EXE")
    elseif plr then
        isExe = (plr.Team and string.find(string.lower(plr.Team.Name), "exe")) and true or false
    end

    local rawCharName = ""
    if char then
        local attr = char:GetAttribute("Character") or char:GetAttribute("CharName") or char:GetAttribute("SelectedCharacter")
        if attr and attr ~= "" and attr ~= "Default" then
            rawCharName = tostring(attr)
        else
            local valObj = char:FindFirstChild("Character") or char:FindFirstChild("CharName")
            if valObj and valObj:IsA("ValueBase") and tostring(valObj.Value) ~= "" then
                rawCharName = tostring(valObj.Value)
            end
        end
    end

    if rawCharName == "" and plr and plr:FindFirstChild("leaderstats") and plr.leaderstats:FindFirstChild("Character") then
        rawCharName = tostring(plr.leaderstats.Character.Value)
    end

    local canonCharName = nil
    local cleanKey = string.lower(rawCharName):gsub("[%s_%-]+", "")

    if isExe then
        for k, canon in pairs(EXE_CANON_NAMES) do
            local kClean = string.lower(k):gsub("[%s_%-]+", "")
            if cleanKey == kClean then
                canonCharName = canon
                break
            end
        end
        if not canonCharName then
            for k, canon in pairs(EXE_CANON_NAMES) do
                local kClean = string.lower(k):gsub("[%s_%-]+", "")
                if string.find(cleanKey, kClean, 1, true) then
                    canonCharName = canon
                    break
                end
            end
        end
        if not canonCharName then canonCharName = "2011x" end
    else
        if string.find(cleanKey, "metalsonic") or string.find(cleanKey, "metal") then
            canonCharName = "MetalSonic"
        elseif string.find(cleanKey, "supersonic") or string.find(cleanKey, "super") then
            canonCharName = "SuperSonic"
        else
            for k, canon in pairs(SURVIVOR_CANON_NAMES) do
                local kClean = string.lower(k):gsub("[%s_%-]+", "")
                if cleanKey == kClean then
                    canonCharName = canon
                    break
                end
            end
            if not canonCharName then
                for k, canon in pairs(SURVIVOR_CANON_NAMES) do
                    local kClean = string.lower(k):gsub("[%s_%-]+", "")
                    if string.find(cleanKey, kClean, 1, true) then
                        canonCharName = canon
                        break
                    end
                end
            end
        end
        if not canonCharName then canonCharName = "Tails" end
    end

    local rawPlayerName = (plr and plr.Name and plr.Name ~= "") and plr.Name or (isExe and "2011X" or "ALAN")

    local result = {
        Player    = plr,
        Character = char,
        IsEXE     = isExe,
        Role      = isExe and "EXE" or "SURV",
        CharName  = canonCharName,
        RawName   = rawPlayerName,
        UserName  = "@" .. rawPlayerName
    }

    if char then
        EntityInfoCache[char] = result
    end

    return result
end

local function GetCharacterName(target)
    local info = ResolveEntityInfo(target)
    return info.CharName
end

local function GetPlayerExactHealth(char, player)
    if player then
        local playersFolder = Workspace:FindFirstChild("Players")
        local pModel = playersFolder and playersFolder:FindFirstChild(player.Name)
        if pModel then
            local hObj = pModel:FindFirstChild("Health")
            if hObj then
                if hObj:IsA("ValueBase") then
                    return hObj.Value
                elseif typeof(hObj.Value) == "number" then
                    return hObj.Value
                end
            end
        end
    end

    if char then
        local hObj = char:FindFirstChild("Health")
        if hObj and hObj:IsA("ValueBase") then return hObj.Value end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then return hum.Health end
    end

    return 100
end

local function IsPlayerEscaped(player, char)
    local escapedFolder = ReplicatedStorage:FindFirstChild("EscapedList")
    if player and escapedFolder and escapedFolder:FindFirstChild(player.Name) then
        return true
    end
    if char then
        if char:GetAttribute("Escaped") == true or tostring(char:GetAttribute("State") or ""):lower() == "escaped" then
            return true
        end
        if escapedFolder and escapedFolder:FindFirstChild(char.Name) then
            return true
        end
    end
    return false
end

local function ScanDownedAssets()
    table.clear(GlobalState.AH.DownedDB)
    local rs = ReplicatedStorage
    local ca = rs:FindFirstChild("ClientAssets")
    if not ca then return end
    local chars = ca:FindFirstChild("Characters")
    local survFolder = chars and chars:FindFirstChild("Survivor")
    if survFolder then
        for _, charModel in pairs(survFolder:GetChildren()) do
            local charName = charModel.Name
            GlobalState.AH.DownedDB[charName] = {}
            local ss    = charModel:FindFirstChild("scriptstuff")
            local ani   = ss and ss:FindFirstChild("Animate")
            local anims = ani and ani:FindFirstChild("Anims")
            local downed = anims and anims:FindFirstChild("Downed")
            if downed then
                for _, track in pairs(downed:GetChildren()) do
                    if track:IsA("Animation") and track.AnimationId then
                        GlobalState.AH.DownedDB[charName][track.AnimationId] = true
                    end
                end
            end
        end
    end
end
task.spawn(ScanDownedAssets)

local function IsStunned(char, player)
    if not char or not char.Parent then return false end
    if CollectionService:HasTag(char, "Stunned") or CollectionService:HasTag(char, "Grapple") or CollectionService:HasTag(char, "Carried") or CollectionService:HasTag(char, "Grabbed") or char:FindFirstChild("grab") then
        return true
    end
    if char:GetAttribute("State") == "stunned" or char:GetAttribute("Stunned") == true then
        return true
    end
    return false
end

local function IsDowned(char, player)
    if not char or not char.Parent then return false end

    local cName = string.lower(GetCharacterName(char, player))
    if string.find(cName, "metalsonic") or string.find(cName, "metal sonic") then
        return false
    end

    if char:GetAttribute("State") == "downed" or char:GetAttribute("Downed") == true or char:GetAttribute("IsDowned") == true then 
        return true 
    end
    
    if CollectionService:HasTag(char, "Downed") then
        return true
    end

    if string.find(cName, "eggman") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and (hum:GetState() == Enum.HumanoidStateType.Ragdoll or hum:GetState() == Enum.HumanoidStateType.Physics) and char:GetAttribute("State") == "downed" then
            return true
        end
    end

    return false
end

local function IsDead(char, player)
    if not char or not char.Parent then return true end

    if char:GetAttribute("State") == "dead" or char:GetAttribute("IsDead") == true or CollectionService:HasTag(char, "Dead") or CollectionService:HasTag(char, "Die") then 
        return true 
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 then return true end

    return false
end

local function IsLastLife(char, player)
    if not char or not char.Parent then return false end
    if IsGameEXE(char) then return false end

    local cName = string.lower(GetCharacterName(char, player))
    if string.find(cName, "metalsonic") or string.find(cName, "metal sonic") or string.find(cName, "supersonic") or string.find(cName, "super sonic") then
        return false
    end

    if char:GetAttribute("LastLife") == true or CollectionService:HasTag(char, "LastLife") then
        return true
    end

    local downCount = char:GetAttribute("DownCount") or char:GetAttribute("LivesLost") or 0
    if downCount >= 1 then
        return true
    end

    return false
end

local function IsTargetValid(char, player)
    if not char or not char.Parent or not char:IsDescendantOf(Workspace) then return false end
    if not player or not player.Parent then return false end

    if IsPlayerEscaped(player, char) then return false end

    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then return false end

    if IsDead(char, player) or IsDowned(char, player) then return false end

    if IsGameEXE(char) then return false end
    if IsInLobbyArea(root.Position) then return false end
    if IsNearEscapeZone(root.Position) then return false end

    if GlobalConfig.AH.ManualTarget and GlobalConfig.AH.TargetChar ~= "None" then
        local cName = GetCharacterName(char, player)
        if cName ~= GlobalConfig.AH.TargetChar then return false end
    end

    return true
end

local function AnalyzeLMSState()
    local activeStandingSurvs = {}
    local downedOrStunSurvs   = {}
    local escapedSurvs        = {}
    local activeEXEs          = {}

    local escapedFolder = ReplicatedStorage:FindFirstChild("EscapedList")
    local escapedNames = {}
    if escapedFolder then
        for _, child in ipairs(escapedFolder:GetChildren()) do
            escapedNames[child.Name] = true
            table.insert(escapedSurvs, child.Name)
        end
    end

    local playersFolder = Workspace:FindFirstChild("Players")
    local searchList = {}
    if playersFolder then
        for _, c in ipairs(playersFolder:GetChildren()) do table.insert(searchList, c) end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and not table.find(searchList, p.Character) then
            table.insert(searchList, p.Character)
        end
    end

    for _, char in ipairs(searchList) do
        if char:IsA("Model") then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local plr = Players:GetPlayerFromCharacter(char) or Players:FindFirstChild(char.Name)
            local pName = plr and plr.Name or char.Name
            local health = GetPlayerExactHealth(char, plr)

            if health > 0 and not IsDead(char, plr) then
                local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                local rootPos = root and root.Position

                if escapedNames[pName] or IsPlayerEscaped(plr, char) then
                    if not escapedNames[pName] then
                        escapedNames[pName] = true
                        table.insert(escapedSurvs, pName)
                    end
                elseif not IsInLobbyArea(rootPos) then
                    local isExe = IsGameEXE(char) or (char:GetAttribute("Team") == "EXE")
                    local entInfo = ResolveEntityInfo(char)
                    local entityData = {
                        Player    = plr,
                        Character = char,
                        Name      = pName,
                        CharName  = entInfo.CharName or GetCharacterName(char)
                    }

                    if isExe then
                        table.insert(activeEXEs, entityData)
                    else
                        local isDown = IsDowned(char, plr) or (char:GetAttribute("State") == "downed") or CollectionService:HasTag(char, "Downed")
                        if isDown then
                            table.insert(downedOrStunSurvs, entityData)
                        else
                            table.insert(activeStandingSurvs, entityData)
                        end
                    end
                end
            end
        end
    end

    return activeStandingSurvs, downedOrStunSurvs, escapedSurvs, activeEXEs
end

local function FindLMSPlayers()
    local activeSurvs, _, _, activeEXEs = AnalyzeLMSState()
    return activeSurvs, activeEXEs
end

local function GetActiveCustomTrack()
    local myChar = LocalPlayer.Character
    local role = (myChar and IsGameEXE(myChar)) and "EXE" or "Survivor"
    
    local track = GlobalConfig.LMS.ClassTracks and GlobalConfig.LMS.ClassTracks[role]
    if track and track ~= "None" and track ~= "" then
        return track
    end
    
    return "None"
end

local BodyVel, BodyGyro
local function CleanPhysics()
    if BodyVel then BodyVel:Destroy(); BodyVel = nil end
    if BodyGyro then BodyGyro:Destroy(); BodyGyro = nil end

    local char = LocalPlayer.Character
    if char then
        local hum  = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
        if root and (GlobalConfig.IsFlying or GlobalConfig.IsSpeeding) then
            root.Velocity = Vector3.zero
        end
        if hum then hum.PlatformStand = false end
        char:SetAttribute("State", "default")
    end
end

local function SetFeatureState(toggleId, state)
    if Options and Options[toggleId] and typeof(Options[toggleId].SetValue) == "function" then
        pcall(function() Options[toggleId]:SetValue(state) end)
    end
end

local PriorityList = {
    ["Cream"] = 9, ["Tails"] = 8, ["Eggman"] = 7, ["Metal Sonic"] = 6,
    ["Amy"] = 5, ["Blaze"] = 4, ["Knuckles"] = 3, ["Silver"] = 2, ["Sonic"] = 1
}

-- UI Window Setup
local Window = Fluent:CreateWindow({
    Title       = "DOOMSENSE v2.4",
    SubTitle    = "Fluent " .. Fluent.Version,
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 460),
    Acrylic     = false,
    Theme       = "Darker",
    MinimizeKey = Enum.KeyCode.Insert
})

local Tabs = {
    Main       = Window:AddTab({ Title = "Main",       Icon = "home" }),
    Teleport   = Window:AddTab({ Title = "Teleport",   Icon = "map" }),
    Combat     = Window:AddTab({ Title = "Auto Hunt",  Icon = "sword" }),
    AutoVote   = Window:AddTab({ Title = "Auto Vote",  Icon = "check-square" }),
    Animations = Window:AddTab({ Title = "Animations", Icon = "clapperboard" }),
    Visuals    = Window:AddTab({ Title = "Visuals",    Icon = "eye" }),
    NightMode  = Window:AddTab({ Title = "Night Mode", Icon = "moon" }),
    LMS        = Window:AddTab({ Title = "MUSIC", Icon = "music" }),
    Mobile     = Window:AddTab({ Title = "Mobile",     Icon = "smartphone" }),
    Settings   = Window:AddTab({ Title = "Settings",   Icon = "settings" }),
}

-- UI: Main Tab
local TabMain = Tabs.Main

TabMain:AddSection("Flight Control")

TabMain:AddToggle("FlyTog", {
    Title       = "Enable Flight",
    Description = "Fly freely through the map",
    Default     = false,
    Callback    = function(v)
        GlobalConfig.IsFlying = v
        if v then
            local char = LocalPlayer.Character
            if char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart) then
                local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
                CleanPhysics()
                BodyVel = Instance.new("BodyVelocity", root)
                BodyVel.Name = "DoomVel"
                BodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
                BodyGyro = Instance.new("BodyGyro", root)
                BodyGyro.Name = "DoomGyro"
                BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
                BodyGyro.P = 10000
                char:FindFirstChildOfClass("Humanoid").PlatformStand = true
            end
        else
            CleanPhysics()
        end
        if GlobalState.UpdateMobileBtn then GlobalState.UpdateMobileBtn("Fly", v) end
    end
})

TabMain:AddKeybind("FlyBind", {
    Title = "Flight Keybind", Default = "G", Mode = "Toggle",
    Callback = function() SetFeatureState("FlyTog", not (Options.FlyTog and Options.FlyTog.Value)) end
})

TabMain:AddSlider("FlySpeed", {
    Title = "Flight Speed", Default = 60, Min = 20, Max = 300, Rounding = 1,
    Callback = function(v) GlobalConfig.FlySpeed = v end
})

TabMain:AddDropdown("Main_Noclip", {
    Title       = "Noclip Mode",
    Description = "Bypasses walls collision only while Flying or in Auto Hunt",
    Values      = { "Off", "On" },
    Default     = "Off",
    Callback    = function(v) GlobalConfig.Main.NoclipMode = v end
})

TabMain:AddSection("Speed Control")

TabMain:AddToggle("SpeedTog", {
    Title       = "Enable Speed",
    Description = "Modify walking velocity",
    Default     = false,
    Callback    = function(v)
        GlobalConfig.IsSpeeding = v
        if GlobalState.UpdateMobileBtn then GlobalState.UpdateMobileBtn("Speed", v) end
    end
})

TabMain:AddKeybind("SpeedBind", {
    Title = "Speed Keybind", Default = "C", Mode = "Toggle",
    Callback = function() SetFeatureState("SpeedTog", not (Options.SpeedTog and Options.SpeedTog.Value)) end
})

TabMain:AddSlider("WalkSpeed", {
    Title = "Walk Speed", Default = 45, Min = 16, Max = 200, Rounding = 1,
    Callback = function(v) GlobalConfig.WalkSpeed = v end
})

TabMain:AddSection("Other")

TabMain:AddToggle("ARTTog", {
    Title       = "Auto Ring Teleport (ART)",
    Description = "Teleport to Ring/Exit at 80s mark",
    Default     = false,
    Callback    = function(v)
        GlobalConfig.AutoRing = v
        if GlobalState.UpdateMobileBtn then GlobalState.UpdateMobileBtn("ART", v) end
    end
})

TabMain:AddKeybind("ARTBind", {
    Title = "ART Keybind", Default = "T", Mode = "Toggle",
    Callback = function() SetFeatureState("ARTTog", not (Options.ARTTog and Options.ARTTog.Value)) end
})

TabMain:AddToggle("NoCDJump", {
    Title       = "No Jump Cooldown",
    Description = "Spam jump without limits",
    Default     = false,
    Callback    = function(v) GlobalConfig.NoCDJump = v end
})

-- UI: Teleport Tab
local TabTeleport = Tabs.Teleport

local function TeleportToLobby()
    local spawnCF = FindLobbySpawn()
    if LocalPlayer.Character then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.PrimaryPart
        if root then
            LocalPlayer.Character:PivotTo(spawnCF + Vector3.new(0, 5, 0))
            Fluent:Notify({ Title = "Lobby", Content = "Teleported to Spawn", Duration = 2 })
            return
        end
    end
    Fluent:Notify({ Title = "Error", Content = "Player Character not found!", Duration = 2 })
end

local function SmartTeleport()
    if GlobalState.SelectedPlayer then
        local target = Players:FindFirstChild(GlobalState.SelectedPlayer)
        if target and target.Character then
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart") or target.Character.PrimaryPart
            if tRoot and LocalPlayer.Character then
                local cf = tRoot.CFrame * CFrame.new(0, 2, 3)
                LocalPlayer.Character:PivotTo(cf)
                Fluent:Notify({ Title = "Teleport", Content = "To: " .. target.Name, Duration = 1 })
                return
            end
        else
            Fluent:Notify({ Title = "Error", Content = "Target not found/spawned", Duration = 2 })
            return
        end
    end
    TeleportToLobby()
end

local function CreateSilverPoint(cframe, isStart)
    local part = Instance.new("Part")
    part.Name         = isStart and "SilverStart" or "SilverTrail"
    part.Anchored     = true
    part.CanCollide   = false
    part.CanQuery     = false
    part.CastShadow   = false
    part.Transparency = 1
    part.Size          = Vector3.new(0.1, 0.1, 0.1)
    part.CFrame        = cframe - Vector3.new(0, 2.8, 0)
    part.Parent        = Workspace

    local bb = Instance.new("BillboardGui")
    bb.Adornee         = part
    bb.Parent           = part
    bb.AlwaysOnTop      = true
    bb.LightInfluence   = 0
    bb.Size = isStart and UDim2.new(6, 0, 6, 0) or UDim2.new(3, 0, 3, 0)

    local img = Instance.new("ImageLabel")
    img.Parent               = bb
    img.BackgroundTransparency = 1
    img.Size                 = UDim2.fromScale(1, 1)
    img.Image                = isStart and "rbxassetid://99162408431074" or "rbxassetid://137317577738708"
    img.ImageColor3          = isStart and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 255)

    TweenService:Create(img, TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), { Rotation = 360 }):Play()
    return part
end

local function ClearSilver()
    for _, p in pairs(GlobalState.Silver.Points) do
        if p and p.Parent then p:Destroy() end
    end
    GlobalState.Silver.Points = {}
    GlobalState.Silver.LastPos = nil
end

local function RewindSilver()
    local S = GlobalState.Silver
    if S.IsRewinding or #S.Points == 0 then return end
    S.IsRewinding = true
    S.IsRecording = false

    local char = LocalPlayer.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    if root then
        root.Anchored = true
        for i = #S.Points, 1, -1 do
            local pointPart = S.Points[i]
            if pointPart and pointPart.Parent then
                root.CFrame = CFrame.new(pointPart.Position + Vector3.new(0, 3, 0), pointPart.Position + Vector3.new(0, 3, 0) + root.CFrame.LookVector)
                local bb = pointPart:FindFirstChildOfClass("BillboardGui")
                if bb then
                    local im = bb:FindFirstChildOfClass("ImageLabel")
                    if im then
                        TweenService:Create(im, TweenInfo.new(0.1), { ImageTransparency = 1, Size = UDim2.fromScale(0, 0) }):Play()
                    end
                end
                Debris:AddItem(pointPart, 0.2)
            end
            task.wait(0.05)
        end
        root.Anchored = false
    end

    ClearSilver()
    S.IsRewinding = false
    if Options.SilverTog then Options.SilverTog:SetValue(false) end
end

TabTeleport:AddSection("Standard Teleport")

local PlayerDropdown = TabTeleport:AddDropdown("TP_TargetSelect", {
    Title    = "Select Player",
    Values   = GetPlayerList(),
    Multi    = false,
    Default  = nil,
    Callback = function(v) GlobalState.SelectedPlayer = v end
})

TabTeleport:AddButton({
    Title    = "Refresh List",
    Callback = function()
        PlayerDropdown:SetValues(GetPlayerList())
        PlayerDropdown:SetValue(nil)
        GlobalState.SelectedPlayer = nil
    end
})

TabTeleport:AddButton({
    Title       = "Teleport",
    Description = "Teleports to selected target or Lobby",
    Callback    = SmartTeleport
})

TabTeleport:AddKeybind("TP_Bind_Change", {
    Title    = "Teleport Keybind",
    Default  = "V",
    Mode     = "Toggle",
    Callback = function() SmartTeleport() end,
    ChangedCallback = function(New) GlobalState.TeleportBind = New end
})

TabTeleport:AddButton({ Title = "Force Lobby Spawn", Callback = TeleportToLobby })

TabTeleport:AddSection("Silver Ability Settings")

TabTeleport:AddToggle("SilverTog", {
    Title       = "Time Control (Toggle)",
    Description = "ON: Record | OFF: Rewind",
    Default     = false,
    Callback    = function(v)
        local S = GlobalState.Silver
        if v then
            if S.IsRewinding then return end
            ClearSilver()
            S.IsRecording = true
            S.LastPos = nil
            Fluent:Notify({ Title = "Silver", Content = "Recording...", Duration = 2 })
        else
            if S.IsRecording then RewindSilver() end
        end
        if GlobalState.UpdateMobileBtn then GlobalState.UpdateMobileBtn("Silver", v) end
    end
})

TabTeleport:AddKeybind("SilverBind", {
    Title = "Time Control Bind", Default = "L", Mode = "Toggle",
    Callback = function()
        if Options.SilverTog then Options.SilverTog:SetValue(not Options.SilverTog.Value) end
    end
})

TabTeleport:AddSlider("Sil_Max", {
    Title = "Max Portals Limit", Default = 20, Min = 5, Max = 100, Rounding = 0,
    Callback = function(v) GlobalState.Silver.MaxPoints = v end
})

TabTeleport:AddSlider("Sil_Dist", {
    Title = "Distance Between Portals", Default = 10, Min = 10, Max = 50, Rounding = 0,
    Callback = function(v) GlobalState.Silver.MinDist = v end
})

-- UI: Auto Vote Tab
local TabVote = Tabs.AutoVote

TabVote:AddToggle("Vote_Enable", {
    Title   = "Enable Auto Vote",
    Default = false,
    Callback = function(v) GlobalConfig.Vote.Enabled = v end
})

TabVote:AddParagraph({ Title = "Survivor", Content = "Select target if you spawn as Survivor" })
TabVote:AddDropdown("Vote_Surv", {
    Title    = "Survivor Character",
    Values   = VoteLists.Survivor,
    Default  = "Silver",
    Callback = function(v) GlobalConfig.Vote.SurvTarget = v end
})

TabVote:AddParagraph({ Title = "EXE", Content = "Select target if you spawn as EXE" })
TabVote:AddDropdown("Vote_Exe", {
    Title    = "EXE Character",
    Values   = VoteLists.EXE,
    Default  = "2011x",
    Callback = function(v) GlobalConfig.Vote.ExeTarget = v end
})

TabVote:AddToggle("Vote_Random", {
    Title       = "Randomize Selection",
    Description = "Ignores choices above, picks random",
    Default     = false,
    Callback    = function(v) GlobalConfig.Vote.Randomize = v end
})

TabVote:AddSlider("Vote_Delay", {
    Title    = "Vote Delay",
    Default  = 1, Min = 0, Max = 10, Rounding = 1,
    Callback = function(v) GlobalConfig.Vote.Delay = v end
})

-- UI: Auto Hunt Tab
local TabCombat = Tabs.Combat

local TargetIndicatorPresets = {
    ["Target Crosshair"] = "rbxassetid://10131954007",
    ["Shockwave Ring"]   = "rbxassetid://12914395250",
    ["Circle Dashed"]    = "rbxassetid://10382429808",
    ["Shift Lock Cross"] = "rbxassetid://118624373632520",
    ["Cyber Reticle"]    = "rbxassetid://6031265978",
}

local function DoAHCharRefresh(force)
    local list = { "None" }
    local seen = {}
    
    local playersFolder = Workspace:FindFirstChild("Players")
    local candidates = {}
    if playersFolder then
        for _, c in ipairs(playersFolder:GetChildren()) do
            if c:IsA("Model") then table.insert(candidates, c) end
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not table.find(candidates, p.Character) then
            table.insert(candidates, p.Character)
        end
    end

    for _, char in ipairs(candidates) do
        local plr = Players:GetPlayerFromCharacter(char) or Players:FindFirstChild(char.Name)
        if IsTargetValid(char, plr) then
            local n = GetCharacterName(char, plr)
            if n and n ~= "" and not seen[n] then
                table.insert(list, n)
                seen[n] = true
            end
        end
    end

    table.sort(list)
    
    local currentVal = GlobalConfig.AH.TargetChar
    local validDefault = table.find(list, currentVal) and currentVal or "None"
    GlobalConfig.AH.TargetChar = validDefault

    local listSignature = table.concat(list, "|")
    if force or GlobalState.AH.LastListSignature ~= listSignature then
        GlobalState.AH.LastListSignature = listSignature
        SafeSetDropdownValues(AHCharDropdownControl, list, validDefault)
    end
end

local function GetBestTarget()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart") or myChar.PrimaryPart
    if not myRoot then return nil end

    local myPos = myRoot.Position
    local potential = {}

    local currentPingMs = GlobalState.CurrentPing or 50
    local leadTime = math.clamp((currentPingMs / 1000) + 0.05, 0.03, 0.45)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
            if root and IsTargetValid(char, p) then
                local charName = GetCharacterName(char, p)
                table.insert(potential, {
                    Model    = char,
                    Player   = p,
                    Root     = root,
                    LeadTime = leadTime,
                    Dist     = (root.Position - myPos).Magnitude,
                    Prio     = PriorityList[charName] or 5
                })
            end
        end
    end

    if #potential == 0 then
        GlobalState.AH.LockedRandomTarget = nil
        return nil
    end

    local mode = GlobalConfig.AH.Mode

    if mode == "Nearest" then
        GlobalState.AH.LockedRandomTarget = nil
        table.sort(potential, function(a, b) return a.Dist < b.Dist end)
        return potential[1].Model
    elseif mode == "Priority" then
        GlobalState.AH.LockedRandomTarget = nil
        table.sort(potential, function(a, b)
            if a.Prio == b.Prio then return a.Dist < b.Dist end
            return a.Prio > b.Prio
        end)
        return potential[1].Model
    elseif mode == "Random" then
        local currentLocked = GlobalState.AH.LockedRandomTarget
        if currentLocked then
            local lockedPlr = Players:GetPlayerFromCharacter(currentLocked)
            if lockedPlr and IsTargetValid(currentLocked, lockedPlr) then
                return currentLocked
            end
        end
        
        local newTarget = potential[math.random(1, #potential)].Model
        GlobalState.AH.LockedRandomTarget = newTarget
        return newTarget
    end

    return nil
end

local function FastAttackTrigger()
    task.spawn(function()
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
        task.wait(0.005)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)

        local randKey = GlobalState.AH.Keys[math.random(1, #GlobalState.AH.Keys)]
        local kCode   = Enum.KeyCode[randKey]
        VirtualInputManager:SendKeyEvent(true, kCode, false, game)
        task.wait(0.005)
        VirtualInputManager:SendKeyEvent(false, kCode, false, game)
    end)
end

local function UpdateAHVisual(targetRoot)
    local V = GlobalState.AH
    local AH_Cfg = GlobalConfig.AH
    
    if not V.Visual then
        local bg = Instance.new("BillboardGui")
        bg.Name        = "AH_Target_Visual"
        bg.AlwaysOnTop = true
        bg.Parent      = CoreGui
        local img = Instance.new("ImageLabel", bg)
        img.Size = UDim2.fromScale(1, 1)
        img.BackgroundTransparency = 1
        V.Visual = { Gui = bg, Img = img, Rot = 0 }
    end

    if targetRoot then
        V.Visual.Gui.Enabled = true
        V.Visual.Gui.Adornee = targetRoot
        V.Visual.Gui.Size    = UDim2.fromOffset(AH_Cfg.IndicatorSize, AH_Cfg.IndicatorSize)
        
        local finalDecal = TargetIndicatorPresets[AH_Cfg.IndicatorDecal] or "rbxassetid://10131954007"
        if AH_Cfg.IndicatorDecal == "Custom" then
            local numID = string.match(AH_Cfg.IndicatorCustomID, "%d+")
            if numID then finalDecal = "rbxassetid://" .. numID end
        end
        
        V.Visual.Img.Image = finalDecal
        V.Visual.Img.ImageColor3 = AH_Cfg.Color
        V.Visual.Img.ImageTransparency = math.clamp(AH_Cfg.IndicatorTransp / 5, 0, 1)
        
        if AH_Cfg.IndicatorRotate then
            local dirMultiplier = (AH_Cfg.IndicatorDir == "Left") and -AH_Cfg.IndicatorSpeed or AH_Cfg.IndicatorSpeed
            V.Visual.Rot = V.Visual.Rot + dirMultiplier
            V.Visual.Img.Rotation = V.Visual.Rot
        end
    else
        V.Visual.Gui.Enabled = false
    end
end

TabCombat:AddSection("Auto Hunt Settings")

TabCombat:AddToggle("AHTog", {
    Title       = "Enable Auto Hunt",
    Description = "Teleport & Kill Survivors",
    Default     = false,
    Callback    = function(v)
        if v then
            ScanDownedAssets()
            if Options.FlyTog and Options.FlyTog.Value then Options.FlyTog:SetValue(false) end
            if Options.SpeedTog and Options.SpeedTog.Value then Options.SpeedTog:SetValue(false) end
            if GlobalState.UpdateMobileBtn then GlobalState.UpdateMobileBtn("AH", true) end
        else
            GlobalState.AH.LockedRandomTarget = nil
            UpdateAHVisual(nil)
            if LocalPlayer.Character and (LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.PrimaryPart) then
                local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.PrimaryPart
                root.Velocity = Vector3.zero
            end
            if GlobalState.UpdateMobileBtn then GlobalState.UpdateMobileBtn("AH", false) end
        end
        GlobalConfig.AH.Enabled = v
    end
})

TabCombat:AddKeybind("AHBind", {
    Title = "Auto Hunt Bind", Default = "H", Mode = "Toggle",
    Callback = function() if Options.AHTog then Options.AHTog:SetValue(not Options.AHTog.Value) end end
})

TabCombat:AddSlider("AHHeight", {
    Title       = "Hitbox Height (Up/Down)",
    Description = "0 = Center. Pos = Up, Neg = Down",
    Default     = 0, Min = -30, Max = 30, Rounding = 0,
    Callback    = function(v) GlobalConfig.AH.Height = v end
})

TabCombat:AddSlider("AHDistance", {
    Title       = "Hitbox Distance (Fwd/Bwd)",
    Description = "0 = Center. Pos = Behind, Neg = Front",
    Default     = 0, Min = -30, Max = 30, Rounding = 0,
    Callback    = function(v) GlobalConfig.AH.Distance = v end
})

TabCombat:AddSection("Hitbox Angle Offset (Degrees)")

TabCombat:AddSlider("AH_RotX", {
    Title = "Angle X (Pitch)", Default = 0, Min = -180, Max = 180, Rounding = 0,
    Callback = function(v) GlobalConfig.AH.RotX = v end
})

TabCombat:AddSlider("AH_RotY", {
    Title = "Angle Y (Yaw)", Default = 0, Min = -180, Max = 180, Rounding = 0,
    Callback = function(v) GlobalConfig.AH.RotY = v end
})

TabCombat:AddSlider("AH_RotZ", {
    Title = "Angle Z (Roll)", Default = 0, Min = -180, Max = 180, Rounding = 0,
    Callback = function(v) GlobalConfig.AH.RotZ = v end
})

TabCombat:AddToggle("AH_NoclipTog", {
    Title       = "AH Dynamic Obstacle Noclip",
    Description = "Disables collisions for intersected obstacles along attack path",
    Default     = true,
    Callback    = function(v) GlobalConfig.AH.Noclip = v end
})

TabCombat:AddToggle("AH_SmartAttack", {
    Title       = "Smart Timing Attack",
    Description = "Only triggers attack when target is in strike range",
    Default     = true,
    Callback    = function(v) GlobalConfig.AH.SmartAttack = v end
})

TabCombat:AddDropdown("AHMode", {
    Title    = "Logic Mode",
    Values   = { "Nearest", "Priority", "Random" },
    Default  = "Nearest",
    Callback = function(v) GlobalConfig.AH.Mode = v end
})

TabCombat:AddSection("Target Override")

TabCombat:AddToggle("AHManualTog", {
    Title    = "Target Manual Character",
    Default  = false,
    Callback = function(v) GlobalConfig.AH.ManualTarget = v end
})

AHCharDropdownControl = TabCombat:AddDropdown("AHCharSelect", {
    Title    = "Select Character",
    Values   = { "None" },
    Default  = "None",
    Callback = function(v) GlobalConfig.AH.TargetChar = v end
})

TabCombat:AddButton({
    Title       = "Refresh Target List",
    Description = "Updates the list of active players for override",
    Callback    = function()
        DoAHCharRefresh(true)
        Fluent:Notify({ Title = "Auto Hunt", Content = "Target List Refreshed", Duration = 1.5 })
    end
})

TabCombat:AddSection("Target Indicator Visuals")

TabCombat:AddColorpicker("AHColor", {
    Title    = "Indicator Color",
    Default  = Color3.fromRGB(255, 0, 0),
    Callback = function(v) GlobalConfig.AH.Color = v end
})

TabCombat:AddSlider("AH_IndSize", {
    Title    = "Indicator Size (px)",
    Default  = 110, Min = 20, Max = 300, Rounding = 0,
    Callback = function(v) GlobalConfig.AH.IndicatorSize = v end
})

TabCombat:AddSlider("AH_IndTransp", {
    Title    = "Indicator Transparency",
    Default  = 0, Min = 0, Max = 5, Rounding = 1,
    Callback = function(v) GlobalConfig.AH.IndicatorTransp = v end
})

TabCombat:AddDropdown("AH_IndDecal", {
    Title    = "Preset Decal",
    Values   = { "Target Crosshair", "Shockwave Ring", "Circle Dashed", "Shift Lock Cross", "Cyber Reticle", "Custom" },
    Default  = "Target Crosshair",
    Callback = function(v) GlobalConfig.AH.IndicatorDecal = v end
})

TabCombat:AddInput("AH_IndCustomID", {
    Title    = "Custom Decal ID (Numbers only)",
    Default  = "",
    Callback = function(v) GlobalConfig.AH.IndicatorCustomID = v end
})

TabCombat:AddToggle("AH_IndRotate", {
    Title    = "Rotate Decal",
    Default  = true,
    Callback = function(v) GlobalConfig.AH.IndicatorRotate = v end
})

TabCombat:AddSlider("AH_IndSpeed", {
    Title    = "Rotation Speed",
    Default  = 5, Min = 1, Max = 30, Rounding = 1,
    Callback = function(v) GlobalConfig.AH.IndicatorSpeed = v end
})

TabCombat:AddDropdown("AH_IndDir", {
    Title    = "Rotation Direction",
    Values   = { "Right", "Left" },
    Default  = "Right",
    Callback = function(v) GlobalConfig.AH.IndicatorDir = v end
})

-- UI: Animations Tab
local TabAnim = Tabs.Animations

local AnimDB = {
    ["R6"] = {
        { Name = "Dance 1", Id = "182435998",  SoundId = "0" },
        { Name = "Dance 2", Id = "182436842",  SoundId = "0" },
        { Name = "Dance 3", Id = "182436935",  SoundId = "0" }
    },
    ["Sonic"] = {
        { Name = "Baby Dance",   Id = "79203936383675",  SoundId = "90901236525070" },
        { Name = "Relaxing",     Id = "104062552147146", SoundId = "96306683591059" },
        { Name = "Waiting",      Id = "132709141019647", SoundId = "129956345965154" },
        { Name = "Shonic",       Id = "124702409687881", SoundId = "119556420416832" },
        { Name = "Medicine",     Id = "86397585701161",  SoundId = "81957643358938" },
        { Name = "Paced",        Id = "117900173410005", SoundId = "78655470001151" },
        { Name = "Do It",        Id = "115044322367992", SoundId = "138820000124792" },
        { Name = "Impatience",   Id = "87992356942409",  SoundId = "2111554497" },
        { Name = "TickTock 1",   Id = "93800356049298",  SoundId = "117144052716723" },
        { Name = "PBJ",          Id = "113910526539334", SoundId = "119249777974685" },
        { Name = "Ring Walk",    Id = "123377580352862", SoundId = "83964029063021" },
        { Name = "Pipebomb 2",   Id = "130034868708651", SoundId = "119640578709774" },
        { Name = "TickTock 2",   Id = "95107785706455",  SoundId = "73526950119661" },
        { Name = "Diaries",      Id = "92897830029002",  SoundId = "76173803344707" },
    },
    ["Tails"] = {
        { Name = "Rat Dance",    Id = "73313302543888",  SoundId = "105826132589844" },
        { Name = "Sit",          Id = "132926716277265", SoundId = "139085759707240" },
        { Name = "Cory",         Id = "118810363050448", SoundId = "128210514182301" },
        { Name = "Pipebomb",     Id = "137946742808216", SoundId = "119640578709774" },
        { Name = "Helicopter",   Id = "89515158858178",  SoundId = "137931208091292" },
        { Name = "Who",          Id = "84541229170186",  SoundId = "83086967155682" },
        { Name = "Horse",        Id = "93036777474390",  SoundId = "1842306536" },
        { Name = "Goodbye",      Id = "96963375850749",  SoundId = "83964029063021" },
    },
    ["Knuckles"] = {
        { Name = "Stephanie",    Id = "140682945610579", SoundId = "91940041220689" },
        { Name = "ChillOut",     Id = "96036373262427",  SoundId = "89185337796161" },
        { Name = "Aura",         Id = "97453636614232",  SoundId = "89185337796161" },
        { Name = "Sitting",      Id = "79209172925447",  SoundId = "0" },
        { Name = "Do That Thing",Id = "78791270212133",  SoundId = "112624207180199" },
        { Name = "Hit Every Beat",Id= "80597715589852",  SoundId = "120207366318005" },
        { Name = "Fallen Kingdom",Id= "108656705089262", SoundId = "111893253196198" },
    },
    ["Amy"] = {
        { Name = "Surprised",       Id = "95622465731556",  SoundId = "128251124090446" },
        { Name = "Headbang",        Id = "113537674050921", SoundId = "135336648388670" },
        { Name = "Dance of Justice",Id = "97841662978305", SoundId = "71722262464105" },
        { Name = "Smiley",          Id = "83086430858295",  SoundId = "114050562679490" },
        { Name = "Doodle",          Id = "107060462123341", SoundId = "99088950437194" },
        { Name = "Static",          Id = "91094123750588",  SoundId = "130488583055563" },
        { Name = "Love N Cavity",   Id = "76749834700097",  SoundId = "95398124962437" },
        { Name = "Noodle",          Id = "111017557755415", SoundId = "127331265842362" },
        { Name = "Eek!",            Id = "83310660894486",  SoundId = "118187270515767" },
        { Name = "Caramel",         Id = "135111770950723", SoundId = "110835760370936" },
    },
    ["Cream"] = {
        { Name = "Overdrive",    Id = "126157584199051", SoundId = "78649217959001" },
        { Name = "Cat Swing",    Id = "119996423025347", SoundId = "97335273261339" },
        { Name = "Jevil Hop",    Id = "137069582420732", SoundId = "110723101893449" },
        { Name = "Penguin",      Id = "136126837988845", SoundId = "76378854930188" },
        { Name = "Waving",       Id = "101475077691415", SoundId = "88033678198864" },
        { Name = "Griddy",       Id = "88275250559180",  SoundId = "77501488098123" },
    },
    ["Eggman"] = {
        { Name = "Egg Rolled",   Id = "109633747241470", SoundId = "77202079956843" },
        { Name = "Sturdy",       Id = "123633884307468", SoundId = "78459140178909" },
        { Name = "Boohoo",       Id = "118361359360130", SoundId = "0" },
        { Name = "Master Plan",  Id = "135726076356843", SoundId = "81715060320729" },
        { Name = "Why Post",     Id = "75695304745148",  SoundId = "81715060320729" },
        { Name = "Eggly",        Id = "125599236186100", SoundId = "104056772578784" },
        { Name = "Bird Word",    Id = "126886074967700", SoundId = "75327454531443" },
        { Name = "Forklift",     Id = "127435576488001", SoundId = "0" },
    },
    ["Silver"] = {
        { Name = "Baby Dance",     Id = "79203936383675",  SoundId = "90901236525070" },
        { Name = "Release Ghouls", Id = "76998542362740",  SoundId = "125819790931802" },
        { Name = "Levitate Rest",  Id = "127010236869854", SoundId = "0" },
    },
    ["Blaze"] = {
        { Name = "Release Ghouls", Id = "104705063785739", SoundId = "125819790931802" },
        { Name = "Chinese Cat",    Id = "129541820196808", SoundId = "86638249245610" },
        { Name = "Skachacha",      Id = "128435480269503", SoundId = "81579040406533" },
    },
    ["Metal Sonic"] = {
        { Name = "Egg Rolled 2", Id = "128123227077719", SoundId = "103896803231829" },
        { Name = "Fancy Style",  Id = "124654816579604", SoundId = "103189160690380" },
        { Name = "Lonely",       Id = "116357078780443", SoundId = "77269072383403" },
        { Name = "Thinking",     Id = "116585917682409", SoundId = "9043366464" },
        { Name = "Come Closer",  Id = "76249045959187",  SoundId = "131169447699141" },
    },
    ["2011X"] = {
        { Name = "Maria Carey", Id = "92888638699962",  SoundId = "112568013507036" },
        { Name = "Hype",        Id = "78545771079470",  SoundId = "126067106312692" },
        { Name = "Jersey Hog",  Id = "127191399093079", SoundId = "112812055823784" },
    },
    ["Kolossos"] = {
        { Name = "Miss Me",  Id = "81730809348394",  SoundId = "135366495265781" },
        { Name = "Point",    Id = "140180851930686", SoundId = "0" },
        { Name = "Metroman", Id = "107195453398060", SoundId = "99258536244671" },
        { Name = "Laugh",    Id = "102779996718354", SoundId = "84405830596541" },
    },
    ["Fleetway"] = {
        { Name = "Every Beat 2", Id = "99056305997710",  SoundId = "120207366318005" },
        { Name = "Jevil Hop 2",  Id = "92404765326260",  SoundId = "127548237541414" },
        { Name = "You A Jerk",   Id = "106340447585086", SoundId = "106119520633962" },
    },
    ["TailsDoll"] = {
        { Name = "Tripwire Time", Id = "112656139256072", SoundId = "116253727062662" },
        { Name = "Tripwire Sit",  Id = "92259033776440",  SoundId = "0" },
        { Name = "Imposter",      Id = "100732265533480", SoundId = "104146703087176" },
        { Name = "Caramell",      Id = "81240310070946",  SoundId = "110835760370936" },
    },
}

local NameToKey = {
    ["Tripwire"]     = "TailsDoll",
    ["Tails Doll"]   = "TailsDoll",
    ["MetalSonic"]   = "Metal Sonic",
    ["2011x"]        = "2011X",
    ["Super Sonic"]  = "Fleetway",
}

local CharList = {}
for k, _ in pairs(AnimDB) do table.insert(CharList, k) end
table.sort(CharList)

local function StopAnim()
    local A = GlobalState.Anim
    if A.Track then A.Track:Stop(); A.Track:Destroy(); A.Track = nil end
    if A.Sound then A.Sound:Stop(); A.Sound:Destroy(); A.Sound = nil end
end

local function PlayAnim()
    local A = GlobalState.Anim
    if A.Track then StopAnim() end

    local isR6 = (GlobalConfig.Anim.CurrentChar == "R6")
    local charKey = isR6 and "R6" or (NameToKey[GlobalConfig.Anim.CurrentChar] or GlobalConfig.Anim.CurrentChar)
    local db = AnimDB[charKey]
    if not db then return end

    local animData = nil
    for _, a in pairs(db) do
        if a.Name == GlobalConfig.Anim.CurrentName then animData = a; break end
    end

    if animData and LocalPlayer.Character then
        local hum  = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or LocalPlayer.Character.PrimaryPart
        if hum and root then
            local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)

            local aObj = Instance.new("Animation")
            aObj.AnimationId = "rbxassetid://" .. animData.Id

            local s, track = pcall(function() return animator:LoadAnimation(aObj) end)
            if s and track then
                A.Track = track
                A.Track.Priority = Enum.AnimationPriority.Action4
                A.Track.Looped = true
                A.Track:Play()

                if animData.SoundId and animData.SoundId ~= "0" then
                    A.Sound = Instance.new("Sound")
                    A.Sound.Name    = "DoomAnimSound"
                    A.Sound.SoundId = "rbxassetid://" .. animData.SoundId
                    A.Sound.Volume  = GlobalConfig.Anim.MuteSound and 0 or GlobalConfig.Anim.Volume
                    A.Sound.Looped  = true
                    A.Sound.Parent  = root
                    A.Sound:Play()
                end

                A.Track.Stopped:Connect(function()
                    if Options.Anim_PlayTog then Options.Anim_PlayTog:SetValue(false) end
                    StopAnim()
                end)
            else
                Fluent:Notify({ Title = "Error", Content = "Invalid Animation ID", Duration = 2 })
                if Options.Anim_PlayTog then Options.Anim_PlayTog:SetValue(false) end
            end
        end
    end
end

TabAnim:AddSection("Animation Controls")

AnimCharDropdownControl = TabAnim:AddDropdown("Anim_Char", {
    Title    = "Character",
    Values   = CharList,
    Default  = "R6",
    Callback = function(v)
        GlobalConfig.Anim.CurrentChar = v
        local key  = NameToKey[v] or v
        local list = {}
        if AnimDB[key] then
            for _, a in pairs(AnimDB[key]) do table.insert(list, a.Name) end
        end
        SafeSetDropdownValues(AnimNameDropdownControl, list, list[1])
    end
})

AnimNameDropdownControl = TabAnim:AddDropdown("Anim_Name", {
    Title    = "Animation",
    Values   = { "Select Char" },
    Default  = "...",
    Callback = function(v)
        GlobalConfig.Anim.CurrentName = v
        if GlobalState.Anim.Track then
            StopAnim()
            PlayAnim()
        end
    end
})

TabAnim:AddToggle("Anim_Auto", {
    Title       = "Auto Detect Character",
    Description = "Updates list on character spawn",
    Default     = false,
    Callback    = function(v) GlobalConfig.Anim.AutoDetect = v end
})

TabAnim:AddToggle("Anim_PlayTog", {
    Title    = "Play Animation",
    Default  = false,
    Callback = function(v)
        if v then PlayAnim() else StopAnim() end
    end
})

TabAnim:AddToggle("Anim_Mute", {
    Title       = "Mute Animation Sound",
    Description = "Disables playing sound entirely",
    Default     = false,
    Callback    = function(v)
        GlobalConfig.Anim.MuteSound = v
        local snd = GlobalState.Anim.Sound
        if v and snd then
            snd.Volume = 0
        elseif not v and snd then
            snd.Volume = GlobalConfig.Anim.Volume
        end
    end
})

TabAnim:AddSlider("Anim_Vol", {
    Title    = "Sound Volume",
    Default  = 2, Min = 0, Max = 6, Rounding = 1,
    Callback = function(v)
        GlobalConfig.Anim.Volume = v
        local snd = GlobalState.Anim.Sound
        if snd and not GlobalConfig.Anim.MuteSound then snd.Volume = v end
    end
})

TabAnim:AddKeybind("Anim_Bind", {
    Title    = "Animation Keybind",
    Default  = "R",
    Mode     = "Toggle",
    Callback = function()
        if Options.Anim_PlayTog then Options.Anim_PlayTog:SetValue(not Options.Anim_PlayTog.Value) end
    end
})

-- UI: Visuals Tab
local TabVisuals    = Tabs.Visuals
local Visuals_Folder = Instance.new("Folder", CoreGui)
Visuals_Folder.Name  = "Doomsense_Vis_Logic"

local VisualsGui = Instance.new("ScreenGui")
VisualsGui.Name           = "Doomsense_2D_Overlay"
VisualsGui.ResetOnSpawn   = false
VisualsGui.IgnoreGuiInset = true
VisualsGui.Parent         = CoreGui

local function ValidateConfig(tbl, defaults)
    for key, value in pairs(defaults) do
        if tbl[key] == nil then
            tbl[key] = value
        elseif type(value) == "table" and type(tbl[key]) == "table" then
            ValidateConfig(tbl[key], value)
        end
    end
end

local VisualsDefaults = {
    Chams = {
        Surv_Enabled  = false,
        Surv_Style    = { Outline = true, Fill = true },
        Surv_OutCol   = Color3.fromRGB(255, 255, 255),
        Surv_FillCol  = Color3.fromRGB(0, 255, 0),
        Surv_Limp_Out = 0, Surv_Limp_Fill = 2,
        
        EXE_Enabled  = false,
        EXE_Style    = { Outline = true, Fill = true },
        EXE_OutCol   = Color3.fromRGB(255, 255, 255),
        EXE_FillCol  = Color3.fromRGB(255, 0, 0),
        EXE_Limp_Out = 0, EXE_Limp_Fill = 2,
    },
    Tripwire = {
        Enabled    = false,
        CustomID   = "",
        Speed      = 5,
        Direction  = "Right",
        RandMin    = 2,
        RandMax    = 5,
        Style      = "Shockwave",
        Size       = 5,
        ScaleMode  = "3D",
        FillCol    = Color3.fromRGB(255, 50, 50),
        LimpFill   = 2,
    },
    TwoD = {
        GlobalLimp          = 0,

        -- 2D Box Visual Settings

        Surv_Box_WOffset = 0,
        Surv_Box_HOffset = 0,
        EXE_Box_WOffset  = 0,
        EXE_Box_HOffset  = 0,

        Surv_Box_Tog        = false,
        Surv_Box_Fill       = Color3.fromRGB(0, 255, 120),
        Surv_Box_Out        = Color3.fromRGB(255, 255, 255),
        Surv_Box_Limp_Fill  = 4,
        Surv_Box_Limp_Out   = 0,

        EXE_Box_Tog         = false,
        EXE_Box_Fill        = Color3.fromRGB(255, 0, 0),
        EXE_Box_Out         = Color3.fromRGB(255, 255, 255),
        EXE_Box_Limp_Fill   = 4,
        EXE_Box_Limp_Out    = 0,

        -- SURV Tags (10 Separate Controls)
        Surv_Role_Tog       = false,
        Surv_Role_Dir       = "Top",
        Surv_Role_Order     = 1,
        Surv_Role_Fill      = Color3.fromRGB(0, 255, 120),
        Surv_Role_Out       = Color3.fromRGB(0, 0, 0),
        Surv_Role_Limp      = 0,

        Surv_Down_Tog       = false,
        Surv_Down_Dir       = "Top",
        Surv_Down_Order     = 3,
        Surv_Down_Fill      = Color3.fromRGB(255, 140, 0),
        Surv_Down_Out       = Color3.fromRGB(255, 255, 255),
        Surv_Down_Limp      = 0,

        Surv_LastLife_Tog   = false,
        Surv_LastLife_Dir   = "Top",
        Surv_LastLife_Order = 4,
        Surv_LastLife_Fill  = Color3.fromRGB(255, 220, 0),
        Surv_LastLife_Out   = Color3.fromRGB(0, 0, 0),
        Surv_LastLife_Limp  = 0,

        Surv_Dead_Tog       = false,
        Surv_Dead_Dir       = "Top",
        Surv_Dead_Order     = 6,
        Surv_Dead_Fill      = Color3.fromRGB(120, 120, 120),
        Surv_Dead_Out       = Color3.fromRGB(0, 0, 0),
        Surv_Dead_Limp      = 0,

        Surv_CharName_Tog   = false,
        Surv_CharName_Dir   = "Top",
        Surv_CharName_Order = 7,
        Surv_CharName_Fill  = Color3.fromRGB(0, 255, 255),
        Surv_CharName_Out   = Color3.fromRGB(0, 0, 0),
        Surv_CharName_Limp = 0,

        Surv_UserName_Tog   = false,
        Surv_UserName_Dir   = "Top",
        Surv_UserName_Order = 8,
        Surv_UserName_Fill  = Color3.fromRGB(255, 255, 255),
        Surv_UserName_Out   = Color3.fromRGB(0, 0, 0),
        Surv_UserName_Limp = 0,

        Surv_Dist_Tog       = false,
        Surv_Dist_Dir       = "Bottom",
        Surv_Dist_Order     = 1,
        Surv_Dist_Fill      = Color3.fromRGB(255, 255, 255),
        Surv_Dist_Out       = Color3.fromRGB(0, 0, 0),
        Surv_Dist_Limp      = 0,

        -- EXE Tags (10 Separate Controls)
        EXE_Role_Tog        = false,
        EXE_Role_Dir        = "Top",
        EXE_Role_Order      = 1,
        EXE_Role_Fill       = Color3.fromRGB(255, 0, 0),
        EXE_Role_Out        = Color3.fromRGB(0, 0, 0),
        EXE_Role_Limp       = 0,

        EXE_Rage_Tog        = false,
        EXE_Rage_Dir        = "Top",
        EXE_Rage_Order      = 2,
        EXE_Rage_Fill       = Color3.fromRGB(255, 140, 0),
        EXE_Rage_Out        = Color3.fromRGB(255, 255, 0),
        EXE_Rage_Limp       = 0,

        EXE_Stun_Tog        = false,
        EXE_Stun_Dir        = "Top",
        EXE_Stun_Order      = 3,
        EXE_Stun_Fill       = Color3.fromRGB(170, 0, 255),
        EXE_Stun_Out        = Color3.fromRGB(255, 255, 255),
        EXE_Stun_Limp       = 0,

        EXE_Dead_Tog        = false,
        EXE_Dead_Dir        = "Top",
        EXE_Dead_Order      = 4,
        EXE_Dead_Fill       = Color3.fromRGB(120, 120, 120),
        EXE_Dead_Out        = Color3.fromRGB(0, 0, 0),
        EXE_Dead_Limp       = 0,

        EXE_CharName_Tog    = false,
        EXE_CharName_Dir    = "Top",
        EXE_CharName_Order  = 5,
        EXE_CharName_Fill   = Color3.fromRGB(255, 100, 100),
        EXE_CharName_Out    = Color3.fromRGB(0, 0, 0),
        EXE_CharName_Limp  = 0,

        EXE_UserName_Tog    = false,
        EXE_UserName_Dir    = "Top",
        EXE_UserName_Order  = 6,
        EXE_UserName_Fill   = Color3.fromRGB(255, 200, 200),
        EXE_UserName_Out    = Color3.fromRGB(0, 0, 0),
        EXE_UserName_Limp  = 0,

        EXE_Dist_Tog        = false,
        EXE_Dist_Dir        = "Bottom",
        EXE_Dist_Order      = 1,
        EXE_Dist_Fill       = Color3.fromRGB(255, 0, 0),
        EXE_Dist_Out        = Color3.fromRGB(0, 0, 0),
        EXE_Dist_Limp       = 0,
    },
    Distance = {},
    Pad = {
        Enabled  = false,
        Style    = { Outline = true, Fill = true },
        OutCol   = Color3.fromRGB(255, 255, 0),
        FillCol  = Color3.fromRGB(255, 255, 0),
        Limp_Out = 0, Limp_Fill = 2,
    },
    Night = {
        Enabled      = false,
        AmbCol       = Color3.fromRGB(50, 50, 80),
        lightCol     = Color3.fromRGB(0, 0, 0),
        
        -- Lights
        ModifyLights = false,
        LightBright  = 2,
        LightColor   = Color3.fromRGB(255, 255, 255),
        
        -- Fog
        FogEnabled   = false,
        FogColor     = Color3.fromRGB(50, 50, 80),
        FogDensity   = 2.5,
    },
    Local = {
        Enabled  = false,
        Style    = { Outline = true, Fill = true },
        OutCol   = Color3.fromRGB(255, 255, 255),
        FillCol  = Color3.fromRGB(100, 100, 255),
        Limp_Out = 0, Limp_Fill = 2,
    },
}

ValidateConfig(GlobalConfig.Visuals, VisualsDefaults)
local Cfg = GlobalConfig.Visuals

-- ═══════════════════════════════════════════════════════════════════════════
-- WORLD ATMOSPHERE & FOG CONTROLLER
-- ═══════════════════════════════════════════════════════════════════════════
local function UpdateWorldLights()
    local nCfg = (GlobalConfig and GlobalConfig.Visuals and GlobalConfig.Visuals.Night) or (Cfg and Cfg.Night)
    if not nCfg then return end
    local cache = GlobalState.Vis.LightCache

    for light, _ in pairs(cache) do
        if not light or not light.Parent then
            cache[light] = nil
        end
    end

    if nCfg.ModifyLights then
        Lighting.Brightness = tonumber(nCfg.LightBright) or 2
        for _, light in ipairs(Workspace:GetDescendants()) do
            if light:IsA("PointLight") or light:IsA("SpotLight") or light:IsA("SurfaceLight") then
                if not cache[light] then
                    cache[light] = {
                        Color      = light.Color,
                        Brightness = light.Brightness,
                    }
                end
                light.Color      = nCfg.LightColor or Color3.fromRGB(255, 255, 255)
                light.Brightness = tonumber(nCfg.LightBright) or 2
            end
        end
    else
        Lighting.Brightness = 1
        for light, orig in pairs(cache) do
            if light and light.Parent then
                pcall(function()
                    light.Color      = orig.Color
                    light.Brightness = orig.Brightness
                end)
            end
        end
        table.clear(cache)
    end
end

local function ApplyAtmosphereAndFog()
    local nCfg = (GlobalConfig and GlobalConfig.Visuals and GlobalConfig.Visuals.Night) or (Cfg and Cfg.Night)
    if not nCfg then return end

    if nCfg.Enabled then
        Lighting.TimeOfDay      = "00:00:00"
        Lighting.Ambient        = nCfg.AmbCol or Color3.fromRGB(50, 50, 80)
        Lighting.OutdoorAmbient = nCfg.lightCol or Color3.fromRGB(0, 0, 0)
    else
        Lighting.TimeOfDay      = "12:00:00"
        Lighting.Ambient        = Color3.fromRGB(128, 128, 128)
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end

    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
    if nCfg.FogEnabled then
        local fogCol = nCfg.FogColor or Color3.fromRGB(50, 50, 80)
        Lighting.FogColor = fogCol
        Lighting.FogStart = 0
        Lighting.FogEnd   = 350

        if not atmosphere then
            atmosphere = Instance.new("Atmosphere")
            atmosphere.Parent = Lighting
        end
        local densityVal = tonumber(nCfg.FogDensity) or 2.5
        atmosphere.Density = math.clamp(densityVal / 5, 0, 1)
        atmosphere.Color   = fogCol
        atmosphere.Decay   = fogCol
        atmosphere.Offset  = 0.25
        atmosphere.Glare   = 0
        atmosphere.Haze    = 1
    else
        Lighting.FogEnd = 9e9
        if atmosphere then
            atmosphere.Density = 0
        end
    end
end

local function GetTrans(sliderVal, isEnabled)
    if not isEnabled then return 1 end
    return math.clamp(sliderVal / 5, 0, 1)
end

local function GetHighlight(model)
    local cache = GlobalState.Vis.HighlightCache
    if not cache[model] or not cache[model].Parent then
        local hl = Instance.new("Highlight")
        hl.Name = "Doom_Highlight"
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = model
        hl.Parent = Visuals_Folder
        cache[model] = hl
    end
    return cache[model]
end

local function GetModelStudSize(charModel)
    local charName = charModel:GetAttribute("Character") or charModel:GetAttribute("CharName") or charModel.Name
    local skinName = charModel:GetAttribute("Skin") or charModel:GetAttribute("SkinName") or "Default"

    for _, category in ipairs({"EXE", "Survivors"}) do
        local catData = MODEL_DATABASE[category]
        if catData and catData[charName] then
            local charData = catData[charName]
            if charData[skinName] and charData[skinName].Studs then
                local s = charData[skinName].Studs
                return Vector3.new(s.X, s.Y, s.Z)
            elseif charData["Default"] and charData["Default"].Studs then
                local s = charData["Default"].Studs
                return Vector3.new(s.X, s.Y, s.Z)
            end
        end
    end

    return charModel:GetExtentsSize()
end

local function GetTags(model)
    local cache = GlobalState.Vis.TagCache
    if not cache[model] or not cache[model].BoxFrame or not cache[model].BoxFrame.Parent then
        local boxFrame = Instance.new("Frame")
        boxFrame.Name                   = "Doom_2D_Box"
        boxFrame.BackgroundTransparency  = 1
        boxFrame.BorderSizePixel        = 0
        boxFrame.Visible                = false
        boxFrame.Position               = UDim2.fromOffset(-5000, -5000)
        boxFrame.Size                   = UDim2.fromOffset(0, 0)
        boxFrame.Parent                 = VisualsGui

        local boxStroke = Instance.new("UIStroke", boxFrame)
        boxStroke.Name         = "BoxStroke"
        boxStroke.Thickness    = 1.5
        boxStroke.Transparency = 1

        local function MakeHolder(name, anchor, pos, hAlign, vAlign)
            local h = Instance.new("Frame", boxFrame)
            h.Name                  = name
            h.BackgroundTransparency = 1
            h.AnchorPoint           = anchor
            h.Position              = pos
            h.Size                  = UDim2.new(0, 200, 0, 0)
            h.AutomaticSize         = Enum.AutomaticSize.Y

            local layout = Instance.new("UIListLayout", h)
            layout.SortOrder            = Enum.SortOrder.LayoutOrder
            layout.HorizontalAlignment  = hAlign
            layout.VerticalAlignment    = vAlign
            layout.Padding              = UDim.new(0, 1)
            return h
        end

        local topHolder   = MakeHolder("TopHolder",   Vector2.new(0.5, 1), UDim2.new(0.5, 0, 0, -4), Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Bottom)
        local botHolder   = MakeHolder("BottomHolder",Vector2.new(0.5, 0), UDim2.new(0.5, 0, 1, 4),  Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)
        local leftHolder  = MakeHolder("LeftHolder",  Vector2.new(1, 0),   UDim2.new(0, -2, 0, 0),    Enum.HorizontalAlignment.Right,  Enum.VerticalAlignment.Top)
        local rightHolder = MakeHolder("RightHolder", Vector2.new(0, 0),   UDim2.new(1, 2, 0, 0),     Enum.HorizontalAlignment.Left,   Enum.VerticalAlignment.Top)

        local function CreateTagLabel(name)
            local lbl = Instance.new("TextLabel")
            lbl.Name                  = name
            lbl.Text                  = ""
            lbl.BackgroundTransparency = 1
            lbl.Font                  = Enum.Font.GothamBold
            lbl.TextSize              = 12
            lbl.TextStrokeTransparency = 0
            lbl.Size                  = UDim2.new(1, 0, 0, 14)
            lbl.Visible               = false
            return lbl
        end

        cache[model] = {
            BoxFrame  = boxFrame,
            BoxStroke = boxStroke,
            Holders   = {
                Top    = topHolder,
                Bottom = botHolder,
                Left   = leftHolder,
                Right  = rightHolder,
            },
            SURV = {
                Role     = CreateTagLabel("SURV_Role"),
                Down     = CreateTagLabel("SURV_Down"),
                LastLife = CreateTagLabel("SURV_LastLife"),
                Dead     = CreateTagLabel("SURV_Dead"),
                CharName = CreateTagLabel("SURV_CharName"),
                UserName = CreateTagLabel("SURV_UserName"),
                Dist     = CreateTagLabel("SURV_Dist"),
            },
            EXE = {
                Role     = CreateTagLabel("EXE_Role"),
                Rage     = CreateTagLabel("EXE_Rage"),
                Stun     = CreateTagLabel("EXE_Stun"),
                Dead     = CreateTagLabel("EXE_Dead"),
                CharName = CreateTagLabel("EXE_CharName"),
                UserName = CreateTagLabel("EXE_UserName"),
                Dist     = CreateTagLabel("EXE_Dist"),
            }
        }
    end
    return cache[model]
end

local SecChams = TabVisuals:AddSection("Chams (Wallhack)")
SecChams:AddParagraph({ Title = "Survivor Chams", Content = "" })
SecChams:AddToggle("Chams_S_Tog", { Title = "Enable Survivor Chams", Default = Cfg.Chams.Surv_Enabled, Callback = function(v) Cfg.Chams.Surv_Enabled = v end })
SecChams:AddDropdown("Chams_S_Style", { Title = "Survivor Style Options", Values = {"Outline","Fill"}, Multi = true, Default = {"Outline","Fill"}, Callback = function(v) Cfg.Chams.Surv_Style = v end })
SecChams:AddColorpicker("Chams_S_Out",  { Title = "Surv Outline Color", Default = Cfg.Chams.Surv_OutCol, Callback = function(v) Cfg.Chams.Surv_OutCol = v end })
SecChams:AddColorpicker("Chams_S_Fill", { Title = "Surv Fill Color",    Default = Cfg.Chams.Surv_FillCol, Callback = function(v) Cfg.Chams.Surv_FillCol = v end })
SecChams:AddSlider("Chams_S_LO", { Title = "Surv Outline Transparency", Min = 0, Max = 5, Default = Cfg.Chams.Surv_Limp_Out, Rounding = 1, Callback = function(v) Cfg.Chams.Surv_Limp_Out = v end })
SecChams:AddSlider("Chams_S_LF", { Title = "Surv Fill Transparency",    Min = 0, Max = 5, Default = Cfg.Chams.Surv_Limp_Fill, Rounding = 1, Callback = function(v) Cfg.Chams.Surv_Limp_Fill = v end })

SecChams:AddParagraph({ Title = "EXE Chams", Content = "" })
SecChams:AddToggle("Chams_E_Tog", { Title = "Enable EXE Chams", Default = Cfg.Chams.EXE_Enabled, Callback = function(v) Cfg.Chams.EXE_Enabled = v end })
SecChams:AddDropdown("Chams_E_Style", { Title = "EXE Style Options", Values = {"Outline","Fill"}, Multi = true, Default = {"Outline","Fill"}, Callback = function(v) Cfg.Chams.EXE_Style = v end })
SecChams:AddColorpicker("Chams_E_Out",  { Title = "EXE Outline Color", Default = Cfg.Chams.EXE_OutCol, Callback = function(v) Cfg.Chams.EXE_OutCol = v end })
SecChams:AddColorpicker("Chams_E_Fill", { Title = "EXE Fill Color",    Default = Cfg.Chams.EXE_FillCol, Callback = function(v) Cfg.Chams.EXE_FillCol = v end })
SecChams:AddSlider("Chams_E_LO", { Title = "EXE Outline Transparency", Min = 0, Max = 5, Default = Cfg.Chams.EXE_Limp_Out, Rounding = 1, Callback = function(v) Cfg.Chams.EXE_Limp_Out = v end })
SecChams:AddSlider("Chams_E_LF", { Title = "EXE Fill Transparency",    Min = 0, Max = 5, Default = Cfg.Chams.EXE_Limp_Fill, Rounding = 1, Callback = function(v) Cfg.Chams.EXE_Limp_Fill = v end })

local Sec2D = TabVisuals:AddSection("2D Box & Tags System")
Sec2D:AddSlider("2D_GlobalLimp", { Title = "Global Text Transparency", Min = 0, Max = 5, Default = Cfg.TwoD.GlobalLimp, Rounding = 1, Callback = function(v) Cfg.TwoD.GlobalLimp = v end })

local DirValues = { "Top", "Bottom", "Left", "Right" }

-- SURVIVOR 2D BOX & TAGS

Sec2D:AddSlider("S_Box_WOffset", { Title = "Survivor Box Width Offset", Min = -15, Max = 15, Default = 0, Rounding = 1, Callback = function(v) Cfg.TwoD.Surv_Box_WOffset = v end })
Sec2D:AddSlider("S_Box_HOffset", { Title = "Survivor Box Height Offset", Min = -15, Max = 15, Default = 0, Rounding = 1, Callback = function(v) Cfg.TwoD.Surv_Box_HOffset = v end })

Sec2D:AddParagraph({ Title = "Survivor 2D Box Visual", Content = "" })
Sec2D:AddToggle("S_Box_Tog", { Title = "Enable Survivor 2D Box", Default = Cfg.TwoD.Surv_Box_Tog, Callback = function(v) Cfg.TwoD.Surv_Box_Tog = v end })
Sec2D:AddColorpicker("S_Box_Fill", { Title = "Box Fill Color", Default = Cfg.TwoD.Surv_Box_Fill, Callback = function(v) Cfg.TwoD.Surv_Box_Fill = v end })
Sec2D:AddColorpicker("S_Box_Out",  { Title = "Box Outline Color", Default = Cfg.TwoD.Surv_Box_Out, Callback = function(v) Cfg.TwoD.Surv_Box_Out = v end })
Sec2D:AddSlider("S_Box_Limp_Fill", { Title = "Fill Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.Surv_Box_Limp_Fill, Rounding = 1, Callback = function(v) Cfg.TwoD.Surv_Box_Limp_Fill = v end })
Sec2D:AddSlider("S_Box_Limp_Out",  { Title = "Outline Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.Surv_Box_Limp_Out, Rounding = 1, Callback = function(v) Cfg.TwoD.Surv_Box_Limp_Out = v end })

Sec2D:AddParagraph({ Title = "Survivor Tag: SURV", Content = "" })
Sec2D:AddToggle("S_Role_Tog", { Title = "Show SURV Tag", Default = Cfg.TwoD.Surv_Role_Tog, Callback = function(v) Cfg.TwoD.Surv_Role_Tog = v end })
Sec2D:AddDropdown("S_Role_Dir", { Title = "Placement Direction", Values = DirValues, Default = Cfg.TwoD.Surv_Role_Dir, Callback = function(v) Cfg.TwoD.Surv_Role_Dir = v end })
Sec2D:AddSlider("S_Role_Order", { Title = "Queue Order", Min = 1, Max = 10, Default = Cfg.TwoD.Surv_Role_Order, Rounding = 0, Callback = function(v) Cfg.TwoD.Surv_Role_Order = v end })
Sec2D:AddColorpicker("S_Role_Fill", { Title = "SURV Color", Default = Cfg.TwoD.Surv_Role_Fill, Callback = function(v) Cfg.TwoD.Surv_Role_Fill = v end })
Sec2D:AddColorpicker("S_Role_Out",  { Title = "SURV Outline", Default = Cfg.TwoD.Surv_Role_Out, Callback = function(v) Cfg.TwoD.Surv_Role_Out = v end })
Sec2D:AddSlider("S_Role_Limp", { Title = "SURV Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.Surv_Role_Limp, Rounding = 1, Callback = function(v) Cfg.TwoD.Surv_Role_Limp = v end })

Sec2D:AddParagraph({ Title = "Survivor Tag: DOWN", Content = "" })
Sec2D:AddToggle("S_Down_Tog", { Title = "Show DOWN Tag", Default = Cfg.TwoD.Surv_Down_Tog, Callback = function(v) Cfg.TwoD.Surv_Down_Tog = v end })
Sec2D:AddDropdown("S_Down_Dir", { Title = "Placement Direction", Values = DirValues, Default = Cfg.TwoD.Surv_Down_Dir, Callback = function(v) Cfg.TwoD.Surv_Down_Dir = v end })
Sec2D:AddSlider("S_Down_Order", { Title = "Queue Order", Min = 1, Max = 10, Default = Cfg.TwoD.Surv_Down_Order, Rounding = 0, Callback = function(v) Cfg.TwoD.Surv_Down_Order = v end })
Sec2D:AddColorpicker("S_Down_Fill", { Title = "DOWN Color", Default = Cfg.TwoD.Surv_Down_Fill, Callback = function(v) Cfg.TwoD.Surv_Down_Fill = v end })
Sec2D:AddColorpicker("S_Down_Out",  { Title = "DOWN Outline", Default = Cfg.TwoD.Surv_Down_Out, Callback = function(v) Cfg.TwoD.Surv_Down_Out = v end })
Sec2D:AddSlider("S_Down_Limp", { Title = "DOWN Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.Surv_Down_Limp, Rounding = 1, Callback = function(v) Cfg.TwoD.Surv_Down_Limp = v end })

Sec2D:AddParagraph({ Title = "Survivor Tag: LAST LIFE", Content = "" })
Sec2D:AddToggle("S_LastLife_Tog", { Title = "Show LAST LIFE Tag", Default = Cfg.TwoD.Surv_LastLife_Tog, Callback = function(v) Cfg.TwoD.Surv_LastLife_Tog = v end })
Sec2D:AddDropdown("S_LastLife_Dir", { Title = "Placement Direction", Values = DirValues, Default = Cfg.TwoD.Surv_LastLife_Dir, Callback = function(v) Cfg.TwoD.Surv_LastLife_Dir = v end })
Sec2D:AddSlider("S_LastLife_Order", { Title = "Queue Order", Min = 1, Max = 10, Default = Cfg.TwoD.Surv_LastLife_Order, Rounding = 0, Callback = function(v) Cfg.TwoD.Surv_LastLife_Order = v end })
Sec2D:AddColorpicker("S_LastLife_Fill", { Title = "LAST LIFE Color", Default = Cfg.TwoD.Surv_LastLife_Fill, Callback = function(v) Cfg.TwoD.Surv_LastLife_Fill = v end })
Sec2D:AddColorpicker("S_LastLife_Out",  { Title = "LAST LIFE Outline", Default = Cfg.TwoD.Surv_LastLife_Out, Callback = function(v) Cfg.TwoD.Surv_LastLife_Out = v end })
Sec2D:AddSlider("S_LastLife_Limp", { Title = "LAST LIFE Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.Surv_LastLife_Limp, Rounding = 1, Callback = function(v) Cfg.TwoD.Surv_LastLife_Limp = v end })

Sec2D:AddParagraph({ Title = "Survivor Tag: DEAD", Content = "" })
Sec2D:AddToggle("S_Dead_Tog", { Title = "Show DEAD Tag", Default = Cfg.TwoD.Surv_Dead_Tog, Callback = function(v) Cfg.TwoD.Surv_Dead_Tog = v end })
Sec2D:AddDropdown("S_Dead_Dir", { Title = "Placement Direction", Values = DirValues, Default = Cfg.TwoD.Surv_Dead_Dir, Callback = function(v) Cfg.TwoD.Surv_Dead_Dir = v end })
Sec2D:AddSlider("S_Dead_Order", { Title = "Queue Order", Min = 1, Max = 10, Default = Cfg.TwoD.Surv_Dead_Order, Rounding = 0, Callback = function(v) Cfg.TwoD.Surv_Dead_Order = v end })
Sec2D:AddColorpicker("S_Dead_Fill", { Title = "DEAD Color", Default = Cfg.TwoD.Surv_Dead_Fill, Callback = function(v) Cfg.TwoD.Surv_Dead_Fill = v end })
Sec2D:AddColorpicker("S_Dead_Out",  { Title = "DEAD Outline", Default = Cfg.TwoD.Surv_Dead_Out, Callback = function(v) Cfg.TwoD.Surv_Dead_Out = v end })
Sec2D:AddSlider("S_Dead_Limp", { Title = "DEAD Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.Surv_Dead_Limp, Rounding = 1, Callback = function(v) Cfg.TwoD.Surv_Dead_Limp = v end })

Sec2D:AddParagraph({ Title = "Survivor Tag: Character Name", Content = "" })
Sec2D:AddToggle("S_CharName_Tog", { Title = "Show Character Name", Default = Cfg.TwoD.Surv_CharName_Tog, Callback = function(v) Cfg.TwoD.Surv_CharName_Tog = v end })
Sec2D:AddDropdown("S_CharName_Dir", { Title = "Placement Direction", Values = DirValues, Default = Cfg.TwoD.Surv_CharName_Dir, Callback = function(v) Cfg.TwoD.Surv_CharName_Dir = v end })
Sec2D:AddSlider("S_CharName_Order", { Title = "Queue Order", Min = 1, Max = 10, Default = Cfg.TwoD.Surv_CharName_Order, Rounding = 0, Callback = function(v) Cfg.TwoD.Surv_CharName_Order = v end })
Sec2D:AddColorpicker("S_CharName_Fill", { Title = "Name Color", Default = Cfg.TwoD.Surv_CharName_Fill, Callback = function(v) Cfg.TwoD.Surv_CharName_Fill = v end })
Sec2D:AddColorpicker("S_CharName_Out",  { Title = "Name Outline", Default = Cfg.TwoD.Surv_CharName_Out, Callback = function(v) Cfg.TwoD.Surv_CharName_Out = v end })
Sec2D:AddSlider("S_CharName_Limp", { Title = "Name Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.Surv_CharName_Limp, Rounding = 1, Callback = function(v) Cfg.TwoD.Surv_CharName_Limp = v end })

Sec2D:AddParagraph({ Title = "Survivor Tag: Player Nickname", Content = "" })
Sec2D:AddToggle("S_UserName_Tog", { Title = "Show @Username", Default = Cfg.TwoD.Surv_UserName_Tog, Callback = function(v) Cfg.TwoD.Surv_UserName_Tog = v end })
Sec2D:AddDropdown("S_UserName_Dir", { Title = "Placement Direction", Values = DirValues, Default = Cfg.TwoD.Surv_UserName_Dir, Callback = function(v) Cfg.TwoD.Surv_UserName_Dir = v end })
Sec2D:AddSlider("S_UserName_Order", { Title = "Queue Order", Min = 1, Max = 10, Default = Cfg.TwoD.Surv_UserName_Order, Rounding = 0, Callback = function(v) Cfg.TwoD.Surv_UserName_Order = v end })
Sec2D:AddColorpicker("S_UserName_Fill", { Title = "@User Color", Default = Cfg.TwoD.Surv_UserName_Fill, Callback = function(v) Cfg.TwoD.Surv_UserName_Fill = v end })
Sec2D:AddColorpicker("S_UserName_Out",  { Title = "@User Outline", Default = Cfg.TwoD.Surv_UserName_Out, Callback = function(v) Cfg.TwoD.Surv_UserName_Out = v end })
Sec2D:AddSlider("S_UserName_Limp", { Title = "@User Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.Surv_UserName_Limp, Rounding = 1, Callback = function(v) Cfg.TwoD.Surv_UserName_Limp = v end })

Sec2D:AddParagraph({ Title = "Survivor Tag: Distance", Content = "" })
Sec2D:AddToggle("Dist_S_Tog", { Title = "Show Distance Tag", Default = Cfg.TwoD.Surv_Dist_Tog, Callback = function(v) Cfg.TwoD.Surv_Dist_Tog = v end })
Sec2D:AddDropdown("Dist_S_Dir", { Title = "Placement Direction", Values = DirValues, Default = Cfg.TwoD.Surv_Dist_Dir, Callback = function(v) Cfg.TwoD.Surv_Dist_Dir = v end })
Sec2D:AddSlider("Dist_S_Order", { Title = "Queue Order", Min = 1, Max = 10, Default = Cfg.TwoD.Surv_Dist_Order, Rounding = 0, Callback = function(v) Cfg.TwoD.Surv_Dist_Order = v end })
Sec2D:AddColorpicker("Dist_S_Fill", { Title = "Distance Color", Default = Cfg.TwoD.Surv_Dist_Fill, Callback = function(v) Cfg.TwoD.Surv_Dist_Fill = v end })
Sec2D:AddColorpicker("Dist_S_Out",  { Title = "Distance Outline", Default = Cfg.TwoD.Surv_Dist_Out, Callback = function(v) Cfg.TwoD.Surv_Dist_Out = v end })
Sec2D:AddSlider("Dist_S_Limp", { Title = "Distance Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.Surv_Dist_Limp, Rounding = 1, Callback = function(v) Cfg.TwoD.Surv_Dist_Limp = v end })

-- EXE 2D BOX & TAGS

Sec2D:AddSlider("E_Box_WOffset", { Title = "EXE Box Width Offset", Min = -15, Max = 15, Default = 0, Rounding = 1, Callback = function(v) Cfg.TwoD.EXE_Box_WOffset = v end })
Sec2D:AddSlider("E_Box_HOffset", { Title = "EXE Box Height Offset", Min = -15, Max = 15, Default = 0, Rounding = 1, Callback = function(v) Cfg.TwoD.EXE_Box_HOffset = v end })

Sec2D:AddParagraph({ Title = "EXE 2D Box Visual", Content = "" })
Sec2D:AddToggle("E_Box_Tog", { Title = "Enable EXE 2D Box", Default = Cfg.TwoD.EXE_Box_Tog, Callback = function(v) Cfg.TwoD.EXE_Box_Tog = v end })
Sec2D:AddColorpicker("E_Box_Fill", { Title = "Box Fill Color", Default = Cfg.TwoD.EXE_Box_Fill, Callback = function(v) Cfg.TwoD.EXE_Box_Fill = v end })
Sec2D:AddColorpicker("E_Box_Out",  { Title = "Box Outline Color", Default = Cfg.TwoD.EXE_Box_Out, Callback = function(v) Cfg.TwoD.EXE_Box_Out = v end })
Sec2D:AddSlider("E_Box_Limp_Fill", { Title = "Fill Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.EXE_Box_Limp_Fill, Rounding = 1, Callback = function(v) Cfg.TwoD.EXE_Box_Limp_Fill = v end })
Sec2D:AddSlider("E_Box_Limp_Out",  { Title = "Outline Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.EXE_Box_Limp_Out, Rounding = 1, Callback = function(v) Cfg.TwoD.EXE_Box_Limp_Out = v end })

Sec2D:AddParagraph({ Title = "EXE Tag: EXE", Content = "" })
Sec2D:AddToggle("E_Role_Tog", { Title = "Show EXE Tag", Default = Cfg.TwoD.EXE_Role_Tog, Callback = function(v) Cfg.TwoD.EXE_Role_Tog = v end })
Sec2D:AddDropdown("E_Role_Dir", { Title = "Placement Direction", Values = DirValues, Default = Cfg.TwoD.EXE_Role_Dir, Callback = function(v) Cfg.TwoD.EXE_Role_Dir = v end })
Sec2D:AddSlider("E_Role_Order", { Title = "Queue Order", Min = 1, Max = 10, Default = Cfg.TwoD.EXE_Role_Order, Rounding = 0, Callback = function(v) Cfg.TwoD.EXE_Role_Order = v end })
Sec2D:AddColorpicker("E_Role_Fill", { Title = "EXE Color", Default = Cfg.TwoD.EXE_Role_Fill, Callback = function(v) Cfg.TwoD.EXE_Role_Fill = v end })
Sec2D:AddColorpicker("E_Role_Out",  { Title = "EXE Outline", Default = Cfg.TwoD.EXE_Role_Out, Callback = function(v) Cfg.TwoD.EXE_Role_Out = v end })
Sec2D:AddSlider("E_Role_Limp", { Title = "EXE Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.EXE_Role_Limp, Rounding = 1, Callback = function(v) Cfg.TwoD.EXE_Role_Limp = v end })

Sec2D:AddParagraph({ Title = "EXE Tag: RAGE", Content = "" })
Sec2D:AddToggle("E_Rage_Tog", { Title = "Show RAGE Tag", Default = Cfg.TwoD.EXE_Rage_Tog, Callback = function(v) Cfg.TwoD.EXE_Rage_Tog = v end })
Sec2D:AddDropdown("E_Rage_Dir", { Title = "Placement Direction", Values = DirValues, Default = Cfg.TwoD.EXE_Rage_Dir, Callback = function(v) Cfg.TwoD.EXE_Rage_Dir = v end })
Sec2D:AddSlider("E_Rage_Order", { Title = "Queue Order", Min = 1, Max = 10, Default = Cfg.TwoD.EXE_Rage_Order, Rounding = 0, Callback = function(v) Cfg.TwoD.EXE_Rage_Order = v end })
Sec2D:AddColorpicker("E_Rage_Fill", { Title = "RAGE Color", Default = Cfg.TwoD.EXE_Rage_Fill, Callback = function(v) Cfg.TwoD.EXE_Rage_Fill = v end })
Sec2D:AddColorpicker("E_Rage_Out",  { Title = "RAGE Outline", Default = Cfg.TwoD.EXE_Rage_Out, Callback = function(v) Cfg.TwoD.EXE_Rage_Out = v end })
Sec2D:AddSlider("E_Rage_Limp", { Title = "RAGE Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.EXE_Rage_Limp, Rounding = 1, Callback = function(v) Cfg.TwoD.EXE_Rage_Limp = v end })

Sec2D:AddParagraph({ Title = "EXE Tag: STUN", Content = "" })
Sec2D:AddToggle("E_Stun_Tog", { Title = "Show STUN Tag", Default = Cfg.TwoD.EXE_Stun_Tog, Callback = function(v) Cfg.TwoD.EXE_Stun_Tog = v end })
Sec2D:AddDropdown("E_Stun_Dir", { Title = "Placement Direction", Values = DirValues, Default = Cfg.TwoD.EXE_Stun_Dir, Callback = function(v) Cfg.TwoD.EXE_Stun_Dir = v end })
Sec2D:AddSlider("E_Stun_Order", { Title = "Queue Order", Min = 1, Max = 10, Default = Cfg.TwoD.EXE_Stun_Order, Rounding = 0, Callback = function(v) Cfg.TwoD.EXE_Stun_Order = v end })
Sec2D:AddColorpicker("E_Stun_Fill", { Title = "STUN Color", Default = Cfg.TwoD.EXE_Stun_Fill, Callback = function(v) Cfg.TwoD.EXE_Stun_Fill = v end })
Sec2D:AddColorpicker("E_Stun_Out",  { Title = "STUN Outline", Default = Cfg.TwoD.EXE_Stun_Out, Callback = function(v) Cfg.TwoD.EXE_Stun_Out = v end })
Sec2D:AddSlider("E_Stun_Limp", { Title = "STUN Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.EXE_Stun_Limp, Rounding = 1, Callback = function(v) Cfg.TwoD.EXE_Stun_Limp = v end })

Sec2D:AddParagraph({ Title = "EXE Tag: DEAD", Content = "" })
Sec2D:AddToggle("E_Dead_Tog", { Title = "Show DEAD Tag", Default = Cfg.TwoD.EXE_Dead_Tog, Callback = function(v) Cfg.TwoD.EXE_Dead_Tog = v end })
Sec2D:AddDropdown("E_Dead_Dir", { Title = "Placement Direction", Values = DirValues, Default = Cfg.TwoD.EXE_Dead_Dir, Callback = function(v) Cfg.TwoD.EXE_Dead_Dir = v end })
Sec2D:AddSlider("E_Dead_Order", { Title = "Queue Order", Min = 1, Max = 10, Default = Cfg.TwoD.EXE_Dead_Order, Rounding = 0, Callback = function(v) Cfg.TwoD.EXE_Dead_Order = v end })
Sec2D:AddColorpicker("E_Dead_Fill", { Title = "DEAD Color", Default = Cfg.TwoD.EXE_Dead_Fill, Callback = function(v) Cfg.TwoD.EXE_Dead_Fill = v end })
Sec2D:AddColorpicker("E_Dead_Out",  { Title = "DEAD Outline", Default = Cfg.TwoD.EXE_Dead_Out, Callback = function(v) Cfg.TwoD.EXE_Dead_Out = v end })
Sec2D:AddSlider("E_Dead_Limp", { Title = "DEAD Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.EXE_Dead_Limp, Rounding = 1, Callback = function(v) Cfg.TwoD.EXE_Dead_Limp = v end })

Sec2D:AddParagraph({ Title = "EXE Tag: Character Name", Content = "" })
Sec2D:AddToggle("E_CharName_Tog", { Title = "Show Character Name", Default = Cfg.TwoD.EXE_CharName_Tog, Callback = function(v) Cfg.TwoD.EXE_CharName_Tog = v end })
Sec2D:AddDropdown("E_CharName_Dir", { Title = "Placement Direction", Values = DirValues, Default = Cfg.TwoD.EXE_CharName_Dir, Callback = function(v) Cfg.TwoD.EXE_CharName_Dir = v end })
Sec2D:AddSlider("E_CharName_Order", { Title = "Queue Order", Min = 1, Max = 10, Default = Cfg.TwoD.EXE_CharName_Order, Rounding = 0, Callback = function(v) Cfg.TwoD.EXE_CharName_Order = v end })
Sec2D:AddColorpicker("E_CharName_Fill", { Title = "Name Color", Default = Cfg.TwoD.EXE_CharName_Fill, Callback = function(v) Cfg.TwoD.EXE_CharName_Fill = v end })
Sec2D:AddColorpicker("E_CharName_Out",  { Title = "Name Outline", Default = Cfg.TwoD.EXE_CharName_Out, Callback = function(v) Cfg.TwoD.EXE_CharName_Out = v end })
Sec2D:AddSlider("E_CharName_Limp", { Title = "Name Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.EXE_CharName_Limp, Rounding = 1, Callback = function(v) Cfg.TwoD.EXE_CharName_Limp = v end })

Sec2D:AddParagraph({ Title = "EXE Tag: Player Nickname", Content = "" })
Sec2D:AddToggle("E_UserName_Tog", { Title = "Show @Username", Default = Cfg.TwoD.EXE_UserName_Tog, Callback = function(v) Cfg.TwoD.EXE_UserName_Tog = v end })
Sec2D:AddDropdown("E_UserName_Dir", { Title = "Placement Direction", Values = DirValues, Default = Cfg.TwoD.EXE_UserName_Dir, Callback = function(v) Cfg.TwoD.EXE_UserName_Dir = v end })
Sec2D:AddSlider("E_UserName_Order", { Title = "Queue Order", Min = 1, Max = 10, Default = Cfg.TwoD.EXE_UserName_Order, Rounding = 0, Callback = function(v) Cfg.TwoD.EXE_UserName_Order = v end })
Sec2D:AddColorpicker("E_UserName_Fill", { Title = "@User Color", Default = Cfg.TwoD.EXE_UserName_Fill, Callback = function(v) Cfg.TwoD.EXE_UserName_Fill = v end })
Sec2D:AddColorpicker("E_UserName_Out",  { Title = "@User Outline", Default = Cfg.TwoD.EXE_UserName_Out, Callback = function(v) Cfg.TwoD.EXE_UserName_Out = v end })
Sec2D:AddSlider("E_UserName_Limp", { Title = "@User Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.EXE_UserName_Limp, Rounding = 1, Callback = function(v) Cfg.TwoD.EXE_UserName_Limp = v end })

Sec2D:AddParagraph({ Title = "EXE Tag: Distance", Content = "" })
Sec2D:AddToggle("Dist_E_Tog", { Title = "Show Distance Tag", Default = Cfg.TwoD.EXE_Dist_Tog, Callback = function(v) Cfg.TwoD.EXE_Dist_Tog = v end })
Sec2D:AddDropdown("Dist_E_Dir", { Title = "Placement Direction", Values = DirValues, Default = Cfg.TwoD.EXE_Dist_Dir, Callback = function(v) Cfg.TwoD.EXE_Dist_Dir = v end })
Sec2D:AddSlider("Dist_E_Order", { Title = "Queue Order", Min = 1, Max = 10, Default = Cfg.TwoD.EXE_Dist_Order, Rounding = 0, Callback = function(v) Cfg.TwoD.EXE_Dist_Order = v end })
Sec2D:AddColorpicker("Dist_E_Fill", { Title = "Distance Color", Default = Cfg.TwoD.EXE_Dist_Fill, Callback = function(v) Cfg.TwoD.EXE_Dist_Fill = v end })
Sec2D:AddColorpicker("Dist_E_Out",  { Title = "Distance Outline", Default = Cfg.TwoD.EXE_Dist_Out, Callback = function(v) Cfg.TwoD.EXE_Dist_Out = v end })
Sec2D:AddSlider("Dist_E_Limp", { Title = "Distance Transp.", Min = 0, Max = 5, Default = Cfg.TwoD.EXE_Dist_Limp, Rounding = 1, Callback = function(v) Cfg.TwoD.EXE_Dist_Limp = v end })

local SecPad = TabVisuals:AddSection("Pad ESP")
SecPad:AddToggle("Pad_Tog", {
    Title = "Show Pads",
    Default = Cfg.Pad.Enabled,
    Callback = function(v)
        Cfg.Pad.Enabled = v
        if not v then
            for obj, hl in pairs(GlobalState.Vis.PadCache) do
                if hl and hl.Parent then hl:Destroy() end
            end
            table.clear(GlobalState.Vis.PadCache)
            GlobalState.Vis.HasScannedPads = false
        else
            GlobalState.Vis.HasScannedPads = false
        end
    end
})

SecPad:AddDropdown("Pad_Style",    { Title = "Style Options", Values = {"Outline","Fill"}, Multi = true, Default = {"Outline","Fill"}, Callback = function(v) Cfg.Pad.Style = v end })

SecPad:AddColorpicker("Pad_OutCol", { Title = "Pad Outline", Default = Cfg.Pad.OutCol, Callback = function(v)
    Cfg.Pad.OutCol = v
    for _, hl in pairs(GlobalState.Vis.PadCache) do
        if hl and hl.Parent then hl.OutlineColor = v end
    end
end })

SecPad:AddColorpicker("Pad_FillCol",{ Title = "Pad Fill", Default = Cfg.Pad.FillCol, Callback = function(v)
    Cfg.Pad.FillCol = v
    for _, hl in pairs(GlobalState.Vis.PadCache) do
        if hl and hl.Parent then hl.FillColor = v end
    end
end })

SecPad:AddSlider("Pad_LimpOut",     { Title = "Outline Transp.", Min = 0, Max = 5, Default = Cfg.Pad.Limp_Out, Rounding = 1, Callback = function(v) Cfg.Pad.Limp_Out = v end })
SecPad:AddSlider("Pad_LimpFill",    { Title = "Fill Transp.",   Min = 0, Max = 5, Default = Cfg.Pad.Limp_Fill, Rounding = 1, Callback = function(v) Cfg.Pad.Limp_Fill = v end })

local SecTrap = TabVisuals:AddSection("Tripwire Mines ESP")

local function WipeTrapCache()
    for obj, data in pairs(GlobalState.Vis.TrapCache) do
        if data.Proxy then data.Proxy:Destroy() end
    end
    table.clear(GlobalState.Vis.TrapCache)
end

SecTrap:AddToggle("Trap_Tog", { Title = "Show Tripwire Mines", Default = Cfg.Tripwire.Enabled, Callback = function(v) Cfg.Tripwire.Enabled = v; WipeTrapCache() end })

SecTrap:AddDropdown("Trap_Style", {
    Title = "Visual Style (Decal)",
    Values = {"Shockwave", "Circle Dashed 4", "Shift Lock", "Custom"},
    Default = Cfg.Tripwire.Style,
    Callback = function(v) Cfg.Tripwire.Style = v; WipeTrapCache() end
})

SecTrap:AddInput("Trap_CustomID", { Title = "Custom ID (Numbers only)", Default = Cfg.Tripwire.CustomID, Callback = function(v) Cfg.Tripwire.CustomID = v; WipeTrapCache() end })

SecTrap:AddSlider("Trap_Size", { Title = "Size", Min = 0.1, Max = 20, Default = Cfg.Tripwire.Size, Rounding = 1, Callback = function(v) Cfg.Tripwire.Size = v end })

SecTrap:AddDropdown("Trap_ScaleMode", {
    Title = "Scale Mode",
    Description = "2D: Static screen size | 3D: Scales with distance",
    Values = {"2D", "3D"},
    Default = Cfg.Tripwire.ScaleMode,
    Callback = function(v) Cfg.Tripwire.ScaleMode = v end
})

SecTrap:AddParagraph({ Title = "Rotation Settings", Content = "" })
SecTrap:AddSlider("Trap_Speed", { Title = "Rotation Speed", Min = 0.1, Max = 30, Default = Cfg.Tripwire.Speed, Rounding = 1, Callback = function(v) Cfg.Tripwire.Speed = v end })
SecTrap:AddDropdown("Trap_Dir", { Title = "Rotation Direction", Values = {"Left", "Right", "Random"}, Default = Cfg.Tripwire.Direction, Callback = function(v) Cfg.Tripwire.Direction = v end })
SecTrap:AddSlider("Trap_RandMin", { Title = "Random Min Time (s)", Min = 0.1, Max = 10, Default = Cfg.Tripwire.RandMin, Rounding = 1, Callback = function(v) Cfg.Tripwire.RandMin = v end })
SecTrap:AddSlider("Trap_RandMax", { Title = "Random Max Time (s)", Min = 0.1, Max = 10, Default = Cfg.Tripwire.RandMax, Rounding = 1, Callback = function(v) Cfg.Tripwire.RandMax = v end })

SecTrap:AddParagraph({ Title = "Color & Transparency", Content = "" })
SecTrap:AddColorpicker("Trap_FillCol", { Title = "Image Color", Default = Cfg.Tripwire.FillCol, Callback = function(v) Cfg.Tripwire.FillCol = v end })
SecTrap:AddSlider("Trap_LimpFill", { Title = "Image Transp.", Min = 0, Max = 5, Default = Cfg.Tripwire.LimpFill, Rounding = 1, Callback = function(v) Cfg.Tripwire.LimpFill = v end })

local SecLocal = TabVisuals:AddSection("Local Player")
SecLocal:AddToggle("Loc_Tog",        { Title = "Local Chams",    Default = Cfg.Local.Enabled, Callback = function(v) Cfg.Local.Enabled = v end })
SecLocal:AddDropdown("Loc_Style",     { Title = "Style", Values = {"Outline","Fill"}, Multi = true, Default = {"Outline","Fill"}, Callback = function(v) Cfg.Local.Style = v end })
SecLocal:AddColorpicker("Loc_OutCol", { Title = "Outline Color", Default = Cfg.Local.OutCol,  Callback = function(v) Cfg.Local.OutCol = v end })
SecLocal:AddColorpicker("Loc_FillCol",{ Title = "Fill Color",    Default = Cfg.Local.FillCol, Callback = function(v) Cfg.Local.FillCol = v end })
SecLocal:AddSlider("Loc_LimpOut",     { Title = "Outline Transp.", Min = 0, Max = 5, Default = Cfg.Local.Limp_Out, Rounding = 1, Callback = function(v) Cfg.Local.Limp_Out = v end })
SecLocal:AddSlider("Loc_LimpFill",    { Title = "Fill Transp.",   Min = 0, Max = 5, Default = Cfg.Local.Limp_Fill, Rounding = 1, Callback = function(v) Cfg.Local.Limp_Fill = v end })

-- ═════════════════════════════════════════════════════════════════════════
-- UI: NIGHT MODE & WORLD TAB
-- ═════════════════════════════════════════════════════════════════════════
local TabNight = Tabs.NightMode

local SecNightMode = TabNight:AddSection("Night Mode")

SecNightMode:AddToggle("Night_Tog", {
    Title = "Enable Night Mode", 
    Default = Cfg.Night.Enabled,
    Callback = function(v)
        Cfg.Night.Enabled = v
        ApplyAtmosphereAndFog()
    end
})

SecNightMode:AddColorpicker("Night_Amb", { 
    Title = "Ambient Color (Shadows)", 
    Default = Cfg.Night.AmbCol, 
    Callback = function(v) 
        Cfg.Night.AmbCol = v 
        ApplyAtmosphereAndFog()
    end 
})

SecNightMode:AddColorpicker("light_Col", { 
    Title = "Outdoor Light Color", 
    Default = Cfg.Night.lightCol, 
    Callback = function(v) 
        Cfg.Night.lightCol = v 
        ApplyAtmosphereAndFog()
    end 
})

local SecNightLights = TabNight:AddSection("Light Modifiers")

SecNightLights:AddToggle("Light_Mod_Tog", { 
    Title = "Modify Map Lights", 
    Default = Cfg.Night.ModifyLights, 
    Callback = function(v)
        Cfg.Night.ModifyLights = v
        UpdateWorldLights()
    end 
})

local LastLightUpdate = 0
local function RequestLightUpdate()
    local now = tick()
    if now - LastLightUpdate >= 0.2 then
        LastLightUpdate = now
        task.spawn(UpdateWorldLights)
    end
end

SecNightLights:AddSlider("Light_Bright", { 
    Title = "Brightness Level", 
    Min = 0, 
    Max = 10, 
    Default = Cfg.Night.LightBright, 
    Rounding = 1, 
    Callback = function(v)
        Cfg.Night.LightBright = v
        if Cfg.Night.ModifyLights then RequestLightUpdate() end
    end 
})

SecNightLights:AddColorpicker("Light_Color", { 
    Title = "Light Source Color", 
    Default = Cfg.Night.LightColor, 
    Callback = function(v)
        Cfg.Night.LightColor = v
        if Cfg.Night.ModifyLights then RequestLightUpdate() end
    end 
})

local SecNightFog = TabNight:AddSection("Atmosphere & Fog")

SecNightFog:AddToggle("Fog_Tog", { 
    Title = "Enable Custom Fog", 
    Default = Cfg.Night.FogEnabled, 
    Callback = function(v)
        Cfg.Night.FogEnabled = v
        ApplyAtmosphereAndFog()
    end 
})

SecNightFog:AddColorpicker("Fog_Color", { 
    Title = "Fog Color", 
    Default = Cfg.Night.FogColor, 
    Callback = function(v) 
        Cfg.Night.FogColor = v 
        ApplyAtmosphereAndFog()
    end 
})

SecNightFog:AddSlider("Fog_Density", { 
    Title = "Fog Density", 
    Min = 0, 
    Max = 5, 
    Default = Cfg.Night.FogDensity, 
    Rounding = 1, 
    Callback = function(v) 
        Cfg.Night.FogDensity = v 
        ApplyAtmosphereAndFog()
    end 
})

local SecWorldRem = TabNight:AddSection("World Removals")

SecWorldRem:AddButton({
    Title = "Delete Fog & Atmosphere",
    Callback = function()
        Lighting.FogEnd = 9e9
        if Lighting:FindFirstChild("Atmosphere") then Lighting.Atmosphere:Destroy() end
        if Lighting:FindFirstChild("Sky")        then Lighting.Sky:Destroy() end
        local cam = Workspace.CurrentCamera
        if cam:FindFirstChild("WaterBlur")       then cam.WaterBlur:Destroy() end
        if cam:FindFirstChild("WaterCorrection") then cam.WaterCorrection:Destroy() end
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BlurEffect") then v:Destroy() end
        end
        Fluent:Notify({ Title = "World", Content = "Fog & Atmosphere Deleted", Duration = 2 })
    end
})

-- UI: Custom LMS & Music Tab
local TabLMS = Tabs.LMS

local CHARACTER_LIST_LMS = {
    { Key = "Sonic",      Label = "Sonic" },
    { Key = "Tails",      Label = "Tails" },
    { Key = "Knuckles",   Label = "Knuckles" },
    { Key = "Amy",        Label = "Amy" },
    { Key = "Cream",      Label = "Cream" },
    { Key = "Eggman",     Label = "Eggman" },
    { Key = "Silver",     Label = "Silver" },
    { Key = "Blaze",      Label = "Blaze" },
    { Key = "MetalSonic", Label = "Metal Sonic" },
    { Key = "Shadow",     Label = "Shadow" },
    { Key = "Fang",       Label = "Fang" },
}

local LMS_Originals_Lookup = {
    ["AmySolo"] = true, ["BlazeSolo"] = true, ["CreamSolo"] = true,
    ["EggmanSolo"] = true, ["KnucklesSolo"] = true, ["MetalSonicSolo"] = true,
    ["ShadowSolo"] = true, ["SilverSolo"] = true, ["SonicSolo"] = true,
    ["SuperSonicSolo"] = true, ["TailsSolo"] = true, ["FangSolo"] = true,
}

local DOD_Assets = {
    Survivor = {
        ["Cream"]       = "rbxassetid://110574647259027",
        ["Sonic"]       = "rbxassetid://116105674203386",
        ["Blaze"]       = "rbxassetid://132823832100556",
        ["Silver"]      = "rbxassetid://127572902749122",
        ["Tails"]       = "rbxassetid://127820761709025",
        ["Knuckles"]    = "rbxassetid://83319953418213",
        ["MetalSonic"]  = "rbxassetid://139874742917760",
        ["Metal Sonic"] = "rbxassetid://139874742917760",
        ["Eggman"]      = "rbxassetid://85769780673032",
        ["Amy"]         = "rbxassetid://111226713397041",
        ["Shadow"]      = "rbxassetid://113857022513506",
        ["SuperSonic"]  = "rbxassetid://112771236848699",
        ["Super Sonic"] = "rbxassetid://112771236848699",
    },
    EXE = {
        ["TailsDoll"]     = "rbxassetid://88717022359465",
        ["Tripwire"]      = "rbxassetid://88717022359465",
        ["Kolossos"]      = "rbxassetid://119601323636555",
        ["2011x"]         = "rbxassetid://121016358955184",
        ["Fleetway"]      = "rbxassetid://126606461926165",
        ["Furnace"]       = "rbxassetid://117495151098938",
        ["LegacyFurnace"] = "rbxassetid://102159711895519",
        ["OldFurnace"]    = "rbxassetid://102159711895519",
        ["Lord X"]        = "rbxassetid://93696635906407",
        ["2017x"]         = "rbxassetid://120562962195804",
        ["Executor"]      = "rbxassetid://120562962195804",
    },
}

local function GetAssetSafe(path)
    if not isfile(path) then return nil end
    local func = getcustomasset or getsynasset
    if func then
        local s, res = pcall(func, path)
        if s then return res end
    end
    return nil
end

local LMS_PreloadCache = {}

local function ResolveAssetPath(trackName)
    if not trackName or trackName == "None" then return nil end
    if LMS_PreloadCache[trackName] then return LMS_PreloadCache[trackName] end

    local p1 = LMS_DIR .. "/" .. trackName .. ".ogg"
    local p2 = LMS_DIR .. "/" .. trackName .. ".mp3"
    local finalPath = isfile(p1) and p1 or (isfile(p2) and p2 or nil)
    local asset = finalPath and GetAssetSafe(finalPath) or nil
    if asset then LMS_PreloadCache[trackName] = asset end
    return asset
end

local function PreloadAllLMSTracks()
    task.spawn(function()
        for _, name in pairs(GlobalConfig.LMS.ClassTracks) do ResolveAssetPath(name) end
        if GlobalConfig.LMS.Track then ResolveAssetPath(GlobalConfig.LMS.Track) end
    end)
end

local function GetFilesList()
    local list = { "None" }
    if LMS_DIR and type(LMS_DIR) == "string" and isfolder and isfolder(LMS_DIR) then
        local success, files = pcall(listfiles, LMS_DIR)
        if success and files then
            for _, path in pairs(files) do
                if string.match(path, "%.ogg$") or string.match(path, "%.mp3$") then
                    local name = string.match(path, "[^/\\]+$")
                    name = string.gsub(name, "%.ogg$", ""):gsub("%.mp3$", "")
                    table.insert(list, name)
                end
            end
        end
    end
    table.sort(list)
    return list
end

local function PlayFXSound(id, baseVolume)
    local masterVol = GlobalConfig.LMS.EffectVolume or 1
    local s     = Instance.new("Sound")
    s.SoundId   = "rbxassetid://" .. id
    s.Volume    = baseVolume * masterVol
    s.Parent    = SoundService
    s.Name      = "LMS_FX_Audio"
    s:Play()
    Debris:AddItem(s, 10)
    return s
end

local function GetActiveSoloSound()
    local assets = Workspace:FindFirstChild("Assets")
    local songs = assets and assets:FindFirstChild("Songs")
    if songs then
        for _, s in ipairs(songs:GetChildren()) do
            if s:IsA("Sound") and (LMS_Originals_Lookup[s.Name] or string.find(s.Name, "Solo")) and (s.IsPlaying or s.Playing or s.TimePosition > 0) then
                return s
            end
        end
    end

    local reMus = ReplicatedStorage:FindFirstChild("ClientAssets")
    local soloFolder = reMus and reMus:FindFirstChild("Sounds") and reMus.Sounds:FindFirstChild("mus") and reMus.Sounds.mus:FindFirstChild("Game") and reMus.Sounds.mus.Game:FindFirstChild("Round") and reMus.Sounds.mus.Game.Round:FindFirstChild("SoloTheme")
    if soloFolder then
        for _, s in ipairs(soloFolder:GetChildren()) do
            if s:IsA("Sound") and LMS_Originals_Lookup[s.Name] and (s.IsPlaying or s.Playing or s.TimePosition > 0) then
                return s
            end
        end
    end

    for _, s in ipairs(SoundService:GetChildren()) do
        if s:IsA("Sound") and (LMS_Originals_Lookup[s.Name] or string.find(s.Name, "Solo")) and (s.IsPlaying or s.Playing or s.TimePosition > 0) then
            return s
        end
    end

    return nil
end

local LMS_Visuals = {}

LMS_Visuals["Pizza Tower"] = function()
    local fxContainer = GetFXGui()
    local img = Instance.new("ImageLabel", fxContainer)
    img.BackgroundTransparency = 1; img.Size = UDim2.fromScale(0.55, 0.4)
    img.SizeConstraint = Enum.SizeConstraint.RelativeYY; img.AnchorPoint = Vector2.new(0.5, 0.5)
    img.Position = UDim2.fromScale(0.5, 1.5); img.Image = "rbxassetid://77264911614141"

    PlayFXSound("96050676918804", 1)
    TweenService:Create(img, TweenInfo.new(5, Enum.EasingStyle.Linear), { Position = UDim2.fromScale(0.5, -0.5) }):Play()

    task.spawn(function()
        local toggle = false
        while img and img.Parent and img.Position.Y.Scale > -0.5 do
            img.Image = toggle and "rbxassetid://77264911614141" or "rbxassetid://92555127882199"
            toggle = not toggle; task.wait(0.05)
        end
        if img then img:Destroy() end
    end)
end

LMS_Visuals["FNF"] = function()
    local fxContainer = GetFXGui()
    PlayFXSound("6555005549", 0.3)
    task.wait(0.85)
    local function CreateText(id)
        local im = Instance.new("ImageLabel", fxContainer)
        im.Size = UDim2.fromScale(0.4, 0.2); im.SizeConstraint = Enum.SizeConstraint.RelativeYY
        im.AnchorPoint = Vector2.new(0.5, 0.5); im.Position = UDim2.fromScale(0.5, 0.5)
        im.BackgroundTransparency = 1; im.Image = "rbxassetid://" .. id; im.ImageTransparency = 1
        return im
    end
    task.spawn(function()
        local r = CreateText("6443228613")
        TweenService:Create(r, TweenInfo.new(0.1), { ImageTransparency = 0 }):Play(); task.wait(0.6)
        TweenService:Create(r, TweenInfo.new(0.1), { ImageTransparency = 1, Position = UDim2.fromScale(0.5, 0.4) }):Play(); r:Destroy()
        local s = CreateText("6443225217")
        TweenService:Create(s, TweenInfo.new(0.1), { ImageTransparency = 0 }):Play(); task.wait(0.6)
        TweenService:Create(s, TweenInfo.new(0.1), { ImageTransparency = 1, Position = UDim2.fromScale(0.5, 0.4) }):Play(); s:Destroy()
        local g = CreateText("6443224742")
        TweenService:Create(g, TweenInfo.new(0.1), { ImageTransparency = 0 }):Play(); task.wait(0.8)
        TweenService:Create(g, TweenInfo.new(0.5), { ImageTransparency = 1, Size = UDim2.fromScale(0.6, 0.3) }):Play(); g:Destroy()
    end)
end

LMS_Visuals["DOD"] = function(isTest)
    local fxContainer = GetFXGui()
    local activeSurvs, downedSurvs, _, activeExes = AnalyzeLMSState()

    local survChar, exeChar = "", ""

    if isTest then
        survChar = "Tails"
        exeChar  = "2011x"
    else
        local targetSurv = activeSurvs[1]
        if not targetSurv then
            targetSurv = downedSurvs[1]
        end

        if not targetSurv then
            local soloSnd = GetActiveSoloSound()
            if soloSnd then
                local rawSoloName = soloSnd.Name:gsub("Solo", ""):gsub("Theme", "")
                for key, canon in pairs(SURVIVOR_CANON_NAMES) do
                    if string.lower(rawSoloName):find(key, 1, true) then
                        survChar = canon
                        break
                    end
                end
            end
        end

        if survChar == "" and targetSurv then
            survChar = tostring(targetSurv.CharName or "Tails")
        end
        if survChar == "" then
            survChar = "Tails"
        end

        local targetEXE = activeExes[1]
        if targetEXE then
            exeChar = tostring(targetEXE.CharName or "2011x")
        else
            exeChar = "2011x"
        end
    end

    local survNameStr = survChar
    local exeNameStr  = exeChar

    local survImg = DOD_Assets.Survivor[survChar] or DOD_Assets.Survivor["Tails"] or "rbxassetid://127820761709025"
    local exeImg  = DOD_Assets.EXE[exeChar]       or DOD_Assets.EXE["2011x"]     or "rbxassetid://121016358955184"

    local Container = Instance.new("Frame", fxContainer)
    Container.Name = "DOD_Container"
    Container.Size = UDim2.fromScale(1, 1)
    Container.BackgroundTransparency = 1

    local flash = Instance.new("Frame", Container)
    flash.Size = UDim2.fromScale(1, 1)
    flash.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    flash.BackgroundTransparency = 0.3
    TweenService:Create(flash, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()

    PlayFXSound("132670234831172", 0.7)

    -- (Survivor)
    local leftGroup = Instance.new("Frame", Container)
    leftGroup.Size = UDim2.new(0, 650, 0, 180)
    leftGroup.Position = UDim2.new(-0.55, 0, 0.015, 0)
    leftGroup.BackgroundTransparency = 1

    local diesHeader = Instance.new("TextLabel", leftGroup)
    diesHeader.Size = UDim2.new(0, 350, 0, 35)
    diesHeader.Position = UDim2.new(1, -350, 0, 0)
    diesHeader.BackgroundTransparency = 1
    diesHeader.Text = "Here dies..."
    diesHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    diesHeader.TextTransparency = 0.4
    diesHeader.TextStrokeTransparency = 0.6
    diesHeader.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    diesHeader.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Italic)
    diesHeader.TextSize = 34
    diesHeader.TextXAlignment = Enum.TextXAlignment.Right

    local survBox = Instance.new("Frame", leftGroup)
    survBox.Size = UDim2.new(1, 0, 0, 60)
    survBox.Position = UDim2.new(0, 0, 0, 35)
    survBox.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    survBox.BackgroundTransparency = 0.2
    survBox.ZIndex = 2
    local survStroke = Instance.new("UIStroke", survBox)
    survStroke.Color = Color3.fromRGB(255, 255, 255)
    survStroke.Transparency = 0.45
    survStroke.Thickness = 2

    local survLbl = Instance.new("TextLabel", survBox)
    survLbl.Size = UDim2.fromScale(1, 1)
    survLbl.BackgroundTransparency = 1
    survLbl.Text = survNameStr
    survLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    survLbl.Font = Enum.Font.GothamBold
    survLbl.TextSize = 40
    survLbl.ZIndex = 3

    local leftExcl = Instance.new("TextLabel", leftGroup)
    leftExcl.Size = UDim2.new(0, 180, 0, 180)
    leftExcl.Position = UDim2.new(1, -140, 0, 45)
    leftExcl.BackgroundTransparency = 1
    leftExcl.Text = "!"
    leftExcl.TextColor3 = Color3.fromRGB(255, 255, 255)
    leftExcl.TextTransparency = 0.4
    leftExcl.TextStrokeTransparency = 0.6
    leftExcl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    leftExcl.Font = Enum.Font.GothamBold
    leftExcl.TextSize = 210
    leftExcl.Rotation = 90
    leftExcl.ZIndex = 1

    TweenService:Create(leftGroup, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Position = UDim2.new(0.015, 0, 0.015, 0) }):Play()

    -- (EXE)
    local rightGroup = Instance.new("Frame", Container)
    rightGroup.Size = UDim2.new(0, 650, 0, 180)
    rightGroup.Position = UDim2.new(1.55, -650, 0.015, 0)
    rightGroup.BackgroundTransparency = 1

    local deathsHeader = Instance.new("TextLabel", rightGroup)
    deathsHeader.Size = UDim2.new(0, 350, 0, 35)
    deathsHeader.Position = UDim2.new(0, 0, 0, 0)
    deathsHeader.BackgroundTransparency = 1
    deathsHeader.Text = "Here deaths..."
    deathsHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
    deathsHeader.TextTransparency = 0.4
    deathsHeader.TextStrokeTransparency = 0.6
    deathsHeader.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    deathsHeader.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Italic)
    deathsHeader.TextSize = 34
    deathsHeader.TextXAlignment = Enum.TextXAlignment.Left

    local exeBox = Instance.new("Frame", rightGroup)
    exeBox.Size = UDim2.new(1, 0, 0, 60)
    exeBox.Position = UDim2.new(0, 0, 0, 35)
    exeBox.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    exeBox.BackgroundTransparency = 0.2
    exeBox.ZIndex = 2
    local exeStroke = Instance.new("UIStroke", exeBox)
    exeStroke.Color = Color3.fromRGB(255, 255, 255)
    exeStroke.Transparency = 0.45
    exeStroke.Thickness = 2

    local exeLbl = Instance.new("TextLabel", exeBox)
    exeLbl.Size = UDim2.fromScale(1, 1)
    exeLbl.BackgroundTransparency = 1
    exeLbl.Text = exeNameStr
    exeLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    exeLbl.Font = Enum.Font.GothamBold
    exeLbl.TextSize = 40
    exeLbl.ZIndex = 3

    local rightExcl = Instance.new("TextLabel", rightGroup)
    rightExcl.Size = UDim2.new(0, 180, 0, 180)
    rightExcl.Position = UDim2.new(0, -40, 0, 45)
    rightExcl.BackgroundTransparency = 1
    rightExcl.Text = "!"
    rightExcl.TextColor3 = Color3.fromRGB(255, 255, 255)
    rightExcl.TextTransparency = 0.4
    rightExcl.TextStrokeTransparency = 0.6
    rightExcl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    rightExcl.Font = Enum.Font.GothamBold
    rightExcl.TextSize = 210
    rightExcl.Rotation = -90
    rightExcl.ZIndex = 1

    TweenService:Create(rightGroup, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Position = UDim2.new(0.985, -650, 0.015, 0) }):Play()

    -- VS
    local vsGroup = Instance.new("Frame", Container)
    vsGroup.Size = UDim2.new(0, 380, 0, 160)
    vsGroup.AnchorPoint = Vector2.new(0.5, 0)
    vsGroup.Position = UDim2.new(0.5, 0, -0.4, 0)
    vsGroup.BackgroundTransparency = 1

    local rope1 = Instance.new("Frame", vsGroup)
    rope1.Name = "RopeLeft"
    rope1.Size = UDim2.new(0, 3, 0, 60)
    rope1.Position = UDim2.new(0.5, -80, 0, 0)
    rope1.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    rope1.BackgroundTransparency = 0.2
    rope1.BorderSizePixel = 0
    rope1.ZIndex = 3
    local r1Stroke = Instance.new("UIStroke", rope1)
    r1Stroke.Color = Color3.fromRGB(255, 255, 255)
    r1Stroke.Transparency = 0.45
    r1Stroke.Thickness = 1.5

    local rope2 = Instance.new("Frame", vsGroup)
    rope2.Name = "RopeRight"
    rope2.Size = UDim2.new(0, 3, 0, 60)
    rope2.Position = UDim2.new(0.5, 80, 0, 0)
    rope2.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    rope2.BackgroundTransparency = 0.2
    rope2.BorderSizePixel = 0
    rope2.ZIndex = 3
    local r2Stroke = Instance.new("UIStroke", rope2)
    r2Stroke.Color = Color3.fromRGB(255, 255, 255)
    r2Stroke.Transparency = 0.45
    r2Stroke.Thickness = 1.5

    local vsBox = Instance.new("Frame", vsGroup)
    vsBox.Size = UDim2.new(1, 0, 0, 100)
    vsBox.Position = UDim2.new(0, 0, 0, 60)
    vsBox.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    vsBox.BackgroundTransparency = 0.2
    vsBox.ZIndex = 2
    local vsBoxStroke = Instance.new("UIStroke", vsBox)
    vsBoxStroke.Color = Color3.fromRGB(255, 255, 255)
    vsBoxStroke.Transparency = 0.45
    vsBoxStroke.Thickness = 2

    local vsExcl1 = Instance.new("TextLabel", vsBox)
    vsExcl1.Size = UDim2.new(0.28, 0, 1, 0)
    vsExcl1.Position = UDim2.new(0, 10, 0, 0)
    vsExcl1.BackgroundTransparency = 1
    vsExcl1.Text = "!"
    vsExcl1.TextColor3 = Color3.fromRGB(255, 255, 255)
    vsExcl1.TextTransparency = 0.15
    vsExcl1.Font = Enum.Font.GothamBold
    vsExcl1.TextSize = 52
    vsExcl1.ZIndex = 3

    local vsCenterLbl = Instance.new("TextLabel", vsBox)
    vsCenterLbl.Size = UDim2.new(0.44, 0, 1, 0)
    vsCenterLbl.Position = UDim2.new(0.28, 0, 0, 0)
    vsCenterLbl.BackgroundTransparency = 1
    vsCenterLbl.Text = "VS."
    vsCenterLbl.TextColor3 = Color3.fromRGB(255, 220, 0)
    vsCenterLbl.Font = Enum.Font.FredokaOne
    vsCenterLbl.TextSize = 56
    vsCenterLbl.ZIndex = 3

    local vsGrad = Instance.new("UIGradient", vsCenterLbl)
    vsGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 140, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 245, 100)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 140, 0))
    })

    local gradConn
    local tGrad = 0
    gradConn = RunService.RenderStepped:Connect(function(dt)
        if not vsGrad or not vsGrad.Parent then
            if gradConn then gradConn:Disconnect(); gradConn = nil end
            return
        end
        tGrad = tGrad + dt
        vsGrad.Rotation = (tGrad * 120) % 360
    end)

    local vsExcl2 = Instance.new("TextLabel", vsBox)
    vsExcl2.Size = UDim2.new(0.28, 0, 1, 0)
    vsExcl2.Position = UDim2.new(0.72, -10, 0, 0)
    vsExcl2.BackgroundTransparency = 1
    vsExcl2.Text = "!"
    vsExcl2.TextColor3 = Color3.fromRGB(255, 255, 255)
    vsExcl2.TextTransparency = 0.15
    vsExcl2.Font = Enum.Font.GothamBold
    vsExcl2.TextSize = 52
    vsExcl2.ZIndex = 3

    TweenService:Create(vsGroup, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, 0, 0, 0) }):Play()

    local function SpawnSprite(imgId, isLeft, startPos, endPos)
        local box = Instance.new("Frame", Container)
        box.Size = UDim2.fromScale(0.28, 0.52)
        box.AnchorPoint = isLeft and Vector2.new(0, 1) or Vector2.new(1, 1)
        box.Position = startPos
        box.BackgroundTransparency = 1

        local im = Instance.new("ImageLabel", box)
        im.Size = UDim2.fromScale(1, 1)
        im.BackgroundTransparency = 1
        im.Image = imgId
        im.ScaleType = Enum.ScaleType.Fit

        TweenService:Create(box, TweenInfo.new(0.65, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), { Position = endPos }):Play()
        return box
    end

    local sBox = SpawnSprite(survImg, true,  UDim2.new(-0.35, 0, 1, 0), UDim2.new(0, 0, 1, 0))
    local eBox = SpawnSprite(exeImg,  false, UDim2.new(1.35, 0, 1, 0),  UDim2.new(1, 0, 1, 0))

    task.delay(3.2, function()
        if gradConn then gradConn:Disconnect(); gradConn = nil end
        if sBox and sBox.Parent then TweenService:Create(sBox, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Position = UDim2.new(-0.35, 0, 1, 0) }):Play() end
        if eBox and eBox.Parent then TweenService:Create(eBox, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Position = UDim2.new(1.35, 0, 1, 0) }):Play() end
        if leftGroup and leftGroup.Parent then TweenService:Create(leftGroup, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Position = UDim2.new(-0.55, 0, 0.015, 0) }):Play() end
        if rightGroup and rightGroup.Parent then TweenService:Create(rightGroup, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Position = UDim2.new(1.55, -650, 0.015, 0) }):Play() end
        if vsGroup and vsGroup.Parent then TweenService:Create(vsGroup, TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), { Position = UDim2.new(0.5, 0, -0.4, 0) }):Play() end
        
        task.wait(0.45)
        if Container and Container.Parent then Container:Destroy() end
    end)
end

local EffectList = { "None", "Pizza Tower", "DOD", "FNF" }

local function GetShadowSound()
    local s = SoundService:FindFirstChild("Doomsense_LMS_Shadow")
    if not s then
        s = Instance.new("Sound")
        s.Name    = "Doomsense_LMS_Shadow"
        s.SoundId = ""
        s.Volume  = 0
        s.Looped  = GlobalConfig.LMS.LoopTrack
        s.Parent  = SoundService
        s.Ended:Connect(function()
            if not GlobalConfig.LMS.LoopTrack then
                GlobalState.LMS.TrackFinished = true
            end
        end)
    end
    return s
end

local function TriggerSteppedStop(shadow)
    local L = GlobalState.LMS
    if not L.IsCapturing then return end
    L.IsCapturing = false

    local fadeTween = TweenService:Create(shadow, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Volume = 0 })
    fadeTween:Play()
    fadeTween.Completed:Once(function()
        if not L.IsCapturing then
            shadow:Stop()
            shadow.SoundId = ""
        end
    end)
end

-- UI Construction for Custom LMS
TabLMS:AddSection("Custom LMS Control")

TabLMS:AddToggle("LMS_MainToggle", {
    Title       = "Enable Custom LMS",
    Description = "Replace boss music with local file",
    Default     = GlobalConfig.LMS.Enabled,
    Callback    = function(v) GlobalConfig.LMS.Enabled = v end
})

TabLMS:AddSlider("LMS_VolumeSlider", {
    Title   = "Music Volume",
    Default = 1.2, Min = 0, Max = 5, Rounding = 1,
    Callback = function(v) GlobalConfig.LMS.Volume = v end
})

TabLMS:AddSlider("LMS_FXVolumeSlider", {
    Title   = "Start Effect Volume",
    Default = 1, Min = 0, Max = 5, Rounding = 1,
    Callback = function(v) GlobalConfig.LMS.EffectVolume = v end
})

TabLMS:AddSlider("LMS_StartDelay", {
    Title       = "LMS Start Delay (s)",
    Description = "Delay before custom music and visual effect starts",
    Default     = 2.3,
    Min         = 0.0,
    Max         = 10.0,
    Rounding    = 1,
    Callback    = function(v) GlobalConfig.LMS.StartDelay = v end
})

TabLMS:AddToggle("LMS_LoopTrack", {
    Title       = "Loop Custom Track",
    Description = "Repeat when finished.",
    Default     = true,
    Callback    = function(v) 
        GlobalConfig.LMS.LoopTrack = v 
        local shadow = SoundService:FindFirstChild("Doomsense_LMS_Shadow")
        if shadow then shadow.Looped = v end
    end
})

TabLMS:AddDropdown("LMS_StartEffect", {
    Title    = "Start Effect",
    Values   = EffectList,
    Default  = "None",
    Callback = function(v) GlobalConfig.LMS.StartEffect = v end
})


TabLMS:AddButton({
    Title       = "Test Effect",
    Description = "Preview selected start effect",
    Callback    = function()
        local fxName = GlobalConfig.LMS.StartEffect
        local fxFunc = LMS_Visuals[fxName]
        if typeof(fxFunc) == "function" then
            Fluent:Notify({ Title = "LMS Test", Content = "Playing: " .. fxName, Duration = 2 })
            task.spawn(fxFunc, true)
        else
            Fluent:Notify({ Title = "LMS Test", Content = "No valid effect selected", Duration = 2 })
        end
    end
})

TabLMS:AddSection("Class Tracks Selection")

local availableTracks = GetFilesList()

local ctrlSurvClass = TabLMS:AddDropdown("LMS_Track_SurvClass", {
    Title    = "Survivor Track",
    Values   = availableTracks,
    Default  = "None",
    Callback = function(v) GlobalConfig.LMS.ClassTracks.Survivor = v end
})

local ctrlEXEClass = TabLMS:AddDropdown("LMS_Track_EXEClass", {
    Title    = "EXE Track",
    Values   = availableTracks,
    Default  = "None",
    Callback = function(v) GlobalConfig.LMS.ClassTracks.EXE = v end
})

TabLMS:AddButton({
    Title    = "Refresh Music Files",
    Callback = function()
        task.spawn(function()
            local list = GetFilesList()
            if ctrlSurvClass then SafeSetDropdownValues(ctrlSurvClass, list) end
            if ctrlEXEClass then SafeSetDropdownValues(ctrlEXEClass, list) end
            Fluent:Notify({ Title = "LMS", Content = "Refreshed Track List", Duration = 1.5 })
        end)
    end
})

-- Mobile Tab
local TabMobile = Tabs.Mobile

local MobileControl = {
    Buttons   = {},
    IsVisible = true,
    EditMode  = false,
}

local ButtonSettings = {
    Menu     = { Size = 50, Transp = 0, Enabled = true },
    HideUI   = { Size = 50, Transp = 0, Enabled = true },
    Fly      = { Size = 50, Transp = 0, Enabled = true },
    Speed    = { Size = 50, Transp = 0, Enabled = true },
    ART      = { Size = 50, Transp = 0, Enabled = true },
    Teleport = { Size = 50, Transp = 0, Enabled = true },
    AH       = { Size = 50, Transp = 0, Enabled = true },
    Anim     = { Size = 50, Transp = 0, Enabled = true },
    Silver   = { Size = 50, Transp = 0, Enabled = true },
}

local MOB_ICONS = {
    Menu     = "rbxassetid://7539983773",
    Fly      = "rbxassetid://13288142767",
    Speed    = "rbxassetid://6684648436",
    Anim     = "rbxassetid://12099513379",
    ART      = "rbxassetid://13145097542",
    EditOff  = "rbxassetid://4772171909",
    EditOn   = "rbxassetid://9735358798",
    TP       = "rbxassetid://12941020168",
    EyeOpen  = "rbxassetid://6473251976",
    EyeClose = "rbxassetid://6473252651",
    AH       = "rbxassetid://10723395457",
    Lock     = "rbxassetid://15117261700",
    Silver   = "rbxassetid://99162408431074",
}

local MobileScreenGui = Instance.new("ScreenGui")
MobileScreenGui.Name             = "Doomsense_Mobile_Overlay"
MobileScreenGui.Parent           = CoreGui
MobileScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling
MobileScreenGui.ResetOnSpawn     = false
MobileScreenGui.IgnoreGuiInset   = true
MobileScreenGui.Enabled          = GlobalConfig.ShowMobileBtn

local HttpService = game:GetService("HttpService")
local PosFilePath = "Doomsense/cfg/MobilePositions.json"

function MobileControl:SavePositions()
    local data = {}
    for id, btn in pairs(self.Buttons) do
        if btn.Canvas then
            local pos = btn.Canvas.Position
            data[id] = { XScale = pos.X.Scale, XOffset = pos.X.Offset, YScale = pos.Y.Scale, YOffset = pos.Y.Offset }
        end
    end
    pcall(function() writefile(PosFilePath, HttpService:JSONEncode(data)) end)
end

local function GetSavedPos(id, defaultPos)
    local s, res = pcall(function()
        if isfile(PosFilePath) then return HttpService:JSONDecode(readfile(PosFilePath)) end
    end)
    if s and type(res) == "table" and res[id] then
        return UDim2.new(res[id].XScale, res[id].XOffset, res[id].YScale, res[id].YOffset)
    end
    return defaultPos
end

function MobileControl:GetCurrentColors()
    local themeName = Fluent.Theme or "Dark"
    local colors = {
        Main   = Color3.fromRGB(60, 60, 60),
        Accent = Color3.fromRGB(96, 205, 255),
        Text   = Color3.fromRGB(240, 240, 240),
        Stroke = Color3.fromRGB(90, 90, 90),
    }
    if themeName == "Darker" then
        colors.Accent = Color3.fromRGB(72, 138, 182); colors.Main = Color3.fromRGB(30, 30, 30); colors.Stroke = Color3.fromRGB(60, 60, 60)
    elseif themeName == "Light" then
        colors.Accent = Color3.fromRGB(0, 103, 192); colors.Main = Color3.fromRGB(200, 200, 200); colors.Text = Color3.fromRGB(0, 0, 0); colors.Stroke = Color3.fromRGB(120, 120, 120)
    elseif themeName == "Aqua" then
        colors.Accent = Color3.fromRGB(60, 165, 165); colors.Main = Color3.fromRGB(30, 60, 60)
    elseif themeName == "Amethyst" then
        colors.Accent = Color3.fromRGB(97, 62, 167); colors.Main = Color3.fromRGB(45, 30, 65)
    elseif themeName == "Rose" then
        colors.Accent = Color3.fromRGB(180, 55, 90); colors.Main = Color3.fromRGB(40, 40, 40)
    end
    return colors
end

function MobileControl:GetSafePosition(currentUDim2, currentSizeX, currentSizeY)
    local vp = Camera.ViewportSize
    if vp.X == 0 or vp.Y == 0 then return currentUDim2 end
    local pixelX = (currentUDim2.X.Scale * vp.X) + currentUDim2.X.Offset
    local pixelY = (currentUDim2.Y.Scale * vp.Y) + currentUDim2.Y.Offset
    local TargetX = math.clamp(pixelX, 0, vp.X - currentSizeX)
    local TargetY = math.clamp(pixelY, 0, vp.Y - currentSizeY)
    return UDim2.new(TargetX / vp.X, 0, TargetY / vp.Y, 0)
end

function MobileControl:CreateButton(id, icon, defaultScalePos, callback)
    if self.Buttons[id] and self.Buttons[id].Canvas then self.Buttons[id].Canvas:Destroy() end

    local settings = ButtonSettings[id]
    local sizePx   = settings.Size

    local Canvas = Instance.new("CanvasGroup")
    Canvas.Name     = id
    Canvas.Size     = UDim2.fromOffset(sizePx, sizePx)
    Canvas.Position = self:GetSafePosition(defaultScalePos, sizePx, sizePx)
    Canvas.BackgroundTransparency = 1
    Canvas.GroupTransparency = settings.Transp / 100
    Canvas.Visible  = settings.Enabled
    Canvas.Parent   = MobileScreenGui

    local Rotator = Instance.new("Frame")
    Rotator.Size            = UDim2.new(1, -6, 1, -6)
    Rotator.AnchorPoint     = Vector2.new(0.5, 0.5)
    Rotator.Position        = UDim2.new(0.5, 0, 0.5, 0)
    Rotator.BorderSizePixel = 0
    Rotator.BackgroundTransparency = 0.5
    Rotator.Parent          = Canvas

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 2; Stroke.Parent = Rotator
    Instance.new("UICorner", Rotator).CornerRadius = UDim.new(1, 0)

    local IconImg = Instance.new("ImageLabel")
    IconImg.Size       = UDim2.new(0.6, 0, 0.6, 0)
    IconImg.AnchorPoint = Vector2.new(0.5, 0.5)
    IconImg.Position   = UDim2.new(0.5, 0, 0.5, 0)
    IconImg.BackgroundTransparency = 1
    IconImg.Image      = icon
    IconImg.ZIndex     = 5
    IconImg.Parent     = Canvas

    local LockOverlay = Instance.new("Frame")
    LockOverlay.Size            = UDim2.new(1, -6, 1, -6)
    LockOverlay.AnchorPoint     = Vector2.new(0.5, 0.5)
    LockOverlay.Position        = UDim2.new(0.5, 0, 0.5, 0)
    LockOverlay.BackgroundTransparency = 0.5
    LockOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    LockOverlay.Visible         = false
    LockOverlay.ZIndex          = 10
    LockOverlay.Parent          = Canvas
    local LockIcon = Instance.new("ImageLabel")
    LockIcon.Size       = UDim2.new(0.5, 0, 0.5, 0)
    LockIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    LockIcon.Position   = UDim2.new(0.5, 0, 0.5, 0)
    LockIcon.BackgroundTransparency = 1
    LockIcon.Image      = MOB_ICONS.Lock
    LockIcon.ImageColor3 = Color3.new(1, 1, 1)
    LockIcon.Parent     = LockOverlay
    Instance.new("UICorner", LockOverlay).CornerRadius = UDim.new(1, 0)

    local ClickHitbox = Instance.new("TextButton")
    ClickHitbox.Size = UDim2.new(1, 0, 1, 0); ClickHitbox.BackgroundTransparency = 1
    ClickHitbox.Text = ""; ClickHitbox.ZIndex = 20; ClickHitbox.Parent = Canvas

    local DragHitbox = Instance.new("TextButton")
    DragHitbox.Size     = UDim2.new(1.2, 0, 1.2, 0)
    DragHitbox.Position = UDim2.new(-0.1, 0, -0.1, 0)
    DragHitbox.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    DragHitbox.BackgroundTransparency = 0.7
    DragHitbox.Text    = "DRAG"
    DragHitbox.Visible = self.EditMode
    DragHitbox.ZIndex  = 30
    DragHitbox.Parent  = Canvas
    Instance.new("UICorner", DragHitbox).CornerRadius = UDim.new(1, 0)

    local isActive = false
    local isLocked = false

    local function UpdateVisuals()
        local Theme       = MobileControl:GetCurrentColors()
        local targetColor  = isActive and Theme.Accent or Theme.Main
        local targetStroke = isActive and Theme.Text or Theme.Stroke
        local targetTransp = isActive and 0.2 or 0.5
        local targetRot    = isActive and 45 or 0
        local targetIconCol = Theme.Text
        if id == "ART" or id == "Silver" then targetIconCol = Color3.new(1, 1, 1) end

        TweenService:Create(Rotator, TweenInfo.new(0.3), {
            BackgroundColor3       = targetColor,
            BackgroundTransparency = targetTransp,
            Rotation               = targetRot,
        }):Play()
        Stroke.Color      = targetStroke
        IconImg.ImageColor3 = targetIconCol
        LockOverlay.Visible = isLocked
    end

    ClickHitbox.MouseButton1Click:Connect(function()
        if not self.EditMode and not isLocked and callback then callback() end
    end)

    local dragConn, endConn

    DragHitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragConn then dragConn:Disconnect(); dragConn = nil end
            if endConn  then endConn:Disconnect();  endConn  = nil end

            local dragStart = input.Position
            local startPos  = Canvas.Position

            dragConn = UserInputService.InputChanged:Connect(function(changeInput)
                if changeInput.UserInputType == Enum.UserInputType.MouseMovement or changeInput.UserInputType == Enum.UserInputType.Touch then
                    local delta  = changeInput.Position - dragStart
                    local newPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    Canvas.Position = MobileControl:GetSafePosition(newPos, Canvas.AbsoluteSize.X, Canvas.AbsoluteSize.Y)
                end
            end)

            endConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    if dragConn then dragConn:Disconnect(); dragConn = nil end
                    if endConn  then endConn:Disconnect();  endConn  = nil end
                    local s = Canvas.AbsoluteSize
                    Canvas.Position = MobileControl:GetSafePosition(Canvas.Position, s.X, s.Y)
                    MobileControl:SavePositions()
                end
            end)
        end
    end)

    UpdateVisuals()

    self.Buttons[id] = {
        Canvas     = Canvas,
        IconImg    = IconImg,
        DragHitbox = DragHitbox,
        Update     = UpdateVisuals,
        SetState   = function(val) isActive = val; UpdateVisuals() end,
        SetLocked  = function(val) isLocked = val; UpdateVisuals() end,
        ApplySettings = function()
            local s = ButtonSettings[id]
            Canvas.Size = UDim2.fromOffset(s.Size, s.Size)
            Canvas.GroupTransparency = s.Transp / 100
            if id ~= "Menu" and id ~= "HideUI" then
                Canvas.Visible = MobileControl.IsVisible and s.Enabled
            else
                Canvas.Visible = s.Enabled
            end
        end,
    }
end

function MobileControl:UpdateAllThemes()
    for _, btn in pairs(self.Buttons) do if btn.Update then btn.Update() end end
end

function MobileControl:SetEditMode(state)
    self.EditMode = state
    for _, btn in pairs(self.Buttons) do
        if btn.DragHitbox then btn.DragHitbox.Visible = state end
    end
end

function MobileControl:ToggleVisibility()
    self.IsVisible = not self.IsVisible
    for id, btn in pairs(self.Buttons) do
        if id ~= "Menu" and id ~= "HideUI" then
            btn.Canvas.Visible = self.IsVisible and ButtonSettings[id].Enabled
        end
    end
    local eyeBtn = self.Buttons["HideUI"]
    if eyeBtn then
        eyeBtn.IconImg.Image = self.IsVisible and MOB_ICONS.EyeOpen or MOB_ICONS.EyeClose
    end
end

function MobileControl:Lock(id, state)
    if self.Buttons[id] then self.Buttons[id].SetLocked(state) end
end

local function UpdateBtnConfig(id)
    if MobileControl.Buttons[id] then MobileControl.Buttons[id].ApplySettings() end
end

MobileControl:CreateButton("Menu",    MOB_ICONS.Menu,    GetSavedPos("Menu",     UDim2.new(0.9, 0, 0.4, 0)), function()
    if Window then Window:Minimize() end
end)
MobileControl:CreateButton("HideUI",  MOB_ICONS.EyeOpen, GetSavedPos("HideUI",   UDim2.new(0.82, 0, 0.4, 0)), function() MobileControl:ToggleVisibility() end)
MobileControl:CreateButton("Fly",     MOB_ICONS.Fly,     GetSavedPos("Fly",      UDim2.new(0.9, 0, 0.55, 0)), function() if Options.FlyTog   then Options.FlyTog:SetValue(not Options.FlyTog.Value) end end)
MobileControl:CreateButton("Speed",   MOB_ICONS.Speed,   GetSavedPos("Speed",    UDim2.new(0.9, 0, 0.7, 0)),  function() if Options.SpeedTog then Options.SpeedTog:SetValue(not Options.SpeedTog.Value) end end)
MobileControl:CreateButton("ART",     MOB_ICONS.ART,     GetSavedPos("ART",      UDim2.new(0.9, 0, 0.85, 0)), function() if Options.ARTTog   then Options.ARTTog:SetValue(not Options.ARTTog.Value) end end)
MobileControl:CreateButton("Teleport",MOB_ICONS.TP,      GetSavedPos("Teleport", UDim2.new(0.82, 0, 0.85, 0)), function()
    VirtualInputManager:SendKeyEvent(true,  GlobalState.TeleportBind or Enum.KeyCode.V, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, GlobalState.TeleportBind or Enum.KeyCode.V, false, game)
end)
MobileControl:CreateButton("AH",      MOB_ICONS.AH,      GetSavedPos("AH",       UDim2.new(0.82, 0, 0.55, 0)), function() if Options.AHTog       then Options.AHTog:SetValue(not Options.AHTog.Value) end end)
MobileControl:CreateButton("Anim",    MOB_ICONS.Anim,    GetSavedPos("Anim",     UDim2.new(0.82, 0, 0.7, 0)),  function() if Options.Anim_PlayTog then Options.Anim_PlayTog:SetValue(not Options.Anim_PlayTog.Value) end end)
MobileControl:CreateButton("Silver",  MOB_ICONS.Silver,  GetSavedPos("Silver",   UDim2.new(0.74, 0, 0.85, 0)), function() if Options.SilverTog   then Options.SilverTog:SetValue(not Options.SilverTog.Value) end end)

GlobalState.UpdateMobileBtn = function(id, state)
    if MobileControl.Buttons[id] then MobileControl.Buttons[id].SetState(state) end
end

TabMobile:AddToggle("Mob_Enable", {
    Title   = "Show Mobile Overlay",
    Default = true,
    Callback = function(v)
        MobileScreenGui.Enabled = v
        GlobalConfig.ShowMobileBtn = v
    end
})

TabMobile:AddToggle("Mob_Edit", {
    Title    = "Edit Mode (Drag Buttons)",
    Default  = false,
    Callback = function(v) MobileControl:SetEditMode(v) end
})

local EdSection = TabMobile:AddSection("Button Editor")

local function AddEditorControls(id, hasToggle)
    EdSection:AddParagraph({ Title = id, Content = "" })
    EdSection:AddSlider("Size_" .. id, {
        Title = "Size (px)", Default = 50, Min = 1, Max = 100, Rounding = 0,
        Callback = function(v) ButtonSettings[id].Size = v; UpdateBtnConfig(id) end
    })
    EdSection:AddSlider("Transp_" .. id, {
        Title = "Transparency %", Default = 0, Min = 0, Max = 100, Rounding = 0,
        Callback = function(v) ButtonSettings[id].Transp = v; UpdateBtnConfig(id) end
    })
    if hasToggle then
        EdSection:AddToggle("Enable_" .. id, {
            Title = "Button Present?", Default = true,
            Callback = function(v) ButtonSettings[id].Enabled = v; UpdateBtnConfig(id) end
        })
    end
end

AddEditorControls("Menu",     false)
AddEditorControls("HideUI",   true)
AddEditorControls("Fly",      true)
AddEditorControls("Speed",    true)
AddEditorControls("ART",      true)
AddEditorControls("Teleport", true)
AddEditorControls("AH",       true)
AddEditorControls("Anim",     true)
AddEditorControls("Silver",   true)

-- UI: Settings Tab
local TabSettings = Tabs.Settings
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("Doomsense/cfg")
SaveManager:SetFolder("Doomsense/cfg")
InterfaceManager:BuildInterfaceSection(TabSettings)
SaveManager:BuildConfigSection(TabSettings)
TabSettings:AddButton({
    Title = "REJOIN SERVER",
    Description = "Rejoins the current server",
    Callback = function()
        if #Players:GetPlayers() <= 1 then
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        else
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end
})

-- ═══════════════════════════════════════════════════════════════════════════
-- REWORKED SMART NOCLIP
-- ═══════════════════════════════════════════════════════════════════════════
local CachedNoclipRayParams = RaycastParams.new()
CachedNoclipRayParams.FilterType = Enum.RaycastFilterType.Exclude
CachedNoclipRayParams.IgnoreWater = true

local CachedNoclipOverlap = OverlapParams.new()
CachedNoclipOverlap.FilterType = Enum.RaycastFilterType.Exclude

local function HandleSmartNoclip(targetPos)
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    if not root then return end

    local isFlyNoclip = (GlobalConfig.IsFlying and GlobalConfig.Main.NoclipMode == "On")
    local isAHNoclip  = (GlobalConfig.AH.Enabled and GlobalConfig.AH.Noclip)
    local isNoclipActive = isFlyNoclip or isAHNoclip

    local NState = GlobalState.Noclip

    if not isNoclipActive then
        for part, _ in pairs(NState.ActiveObstacles) do
            if part and part.Parent then pcall(function() part.CanCollide = true end) end
        end
        table.clear(NState.ActiveObstacles)
        return
    end

    local currentObstacles = {}
    local playersFolder = Workspace:FindFirstChild("Players")
    local filterList = { char, Camera, playersFolder }

    CachedNoclipRayParams.FilterDescendantsInstances = filterList
    CachedNoclipOverlap.FilterDescendantsInstances = filterList

    if targetPos then
        local dir = (targetPos - root.Position)
        if dir.Magnitude > 0.5 then
            local rayResult = Workspace:Raycast(root.Position, dir, CachedNoclipRayParams)
            if rayResult and rayResult.Instance and rayResult.Instance:IsA("BasePart") then
                local hitPart = rayResult.Instance
                if math.abs(rayResult.Normal.Y) < 0.7 then
                    currentObstacles[hitPart] = true
                end
            end
        end
    end

    local nearParts = Workspace:GetPartBoundsInBox(root.CFrame, Vector3.new(2.5, 4.0, 2.5), CachedNoclipOverlap)
    local feetY = root.Position.Y - 2.0

    for _, part in ipairs(nearParts) do
        if part:IsA("BasePart") then
            local partTopY = part.Position.Y + (part.Size.Y * 0.5)
            if partTopY > feetY + 0.3 then
                currentObstacles[part] = true
            end
        end
    end

    for part, _ in pairs(currentObstacles) do
        if part.CanCollide then
            NState.ActiveObstacles[part] = true
            part.CanCollide = false
        end
    end

    for part, _ in pairs(NState.ActiveObstacles) do
        if part and part.Parent then
            if not currentObstacles[part] then
                part.CanCollide = true
                NState.ActiveObstacles[part] = nil
            end
        else
            NState.ActiveObstacles[part] = nil
        end
    end
end

-- Core Loop Functions
local function DoPhysics()
    if GlobalConfig.AH.Enabled then return end

    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    
    HandleSmartNoclip()

    if GlobalConfig.IsFlying and BodyVel and BodyGyro then
        if not root:FindFirstChild("DoomVel") then
            SetFeatureState("FlyTog", true)
            return
        end

        local camCF = Camera.CFrame
        local move  = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camCF.RightVector end
        
        pcall(function()
            local upKey = GlobalConfig.Main.FlyUpKey or "Space"
            local downKey = GlobalConfig.Main.FlyDownKey or "LeftShift"
            if UserInputService:IsKeyDown(Enum.KeyCode[upKey]) then move = move + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode[downKey]) then move = move - Vector3.new(0, 1, 0) end
        end)

        if move.Magnitude > 0 then
            BodyVel.Velocity = move.Unit * GlobalConfig.FlySpeed
        else
            BodyVel.Velocity = Vector3.zero
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.Velocity = Vector3.zero
        end

        BodyGyro.CFrame = camCF

    elseif GlobalConfig.IsSpeeding and not GlobalConfig.IsFlying then
        if hum.MoveDirection.Magnitude > 0 then
            root.Velocity = Vector3.new(
                hum.MoveDirection.X * GlobalConfig.WalkSpeed,
                root.Velocity.Y,
                hum.MoveDirection.Z * GlobalConfig.WalkSpeed
            )
        end
    end
end

local function DoSilverRecord()
    local S = GlobalState.Silver
    if not S.IsRecording or S.IsRewinding then return end

    local char = LocalPlayer.Character
    local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
    if not root then return end

    if not S.LastPos then
        S.LastPos = root.Position
        local p = CreateSilverPoint(root.CFrame, true)
        table.insert(S.Points, p)
        return
    end

    if (root.Position - S.LastPos).Magnitude >= S.MinDist then
        S.LastPos = root.Position
        local p = CreateSilverPoint(root.CFrame, false)
        table.insert(S.Points, p)

        if #S.Points > S.MaxPoints then
            local startPoint  = S.Points[1]
            local secondPoint = S.Points[2]
            if startPoint and secondPoint then
                startPoint.CFrame = secondPoint.CFrame
                secondPoint:Destroy()
                table.remove(S.Points, 2)
            end
        end
    end
end

local function UpdateTargetHistory(char, root)
    local H = GlobalState.AH.History
    if not H[char] then H[char] = {} end
    local buffer = H[char]
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local state = hum and hum:GetState() or Enum.HumanoidStateType.Running
    local currentVel = root.AssemblyLinearVelocity or root.Velocity or Vector3.zero

    table.insert(buffer, {
        Pos   = root.Position,
        Vel   = currentVel,
        State = state,
        Time  = tick()
    })

    if #buffer > 5 then
        table.remove(buffer, 1)
    end
end

local function Calculate3DPrediction(char, root, leadTime)
    local buffer = GlobalState.AH.History[char]
    if not buffer or #buffer < 2 then
        local vel = root.AssemblyLinearVelocity or root.Velocity or Vector3.zero
        return root.Position + (vel * leadTime)
    end

    local first = buffer[1]
    local last  = buffer[#buffer]
    local dt    = math.max(last.Time - first.Time, 0.001)
    
    local avgVel = (last.Pos - first.Pos) / dt
    local accel  = (last.Vel - first.Vel) / dt

    local verticalFactor = 1.0
    if last.State == Enum.HumanoidStateType.Freefall then
        verticalFactor = 1.25
    elseif last.State == Enum.HumanoidStateType.Jumping then
        verticalFactor = 0.85
    end

    local predicted3D = root.Position + (avgVel * leadTime) + (0.5 * accel * (leadTime ^ 2) * Vector3.new(1, verticalFactor, 1))
    return predicted3D
end

local function DoAutoHunt()
    local myChar = LocalPlayer.Character
    local myHum  = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local myRoot = myChar and (myChar:FindFirstChild("HumanoidRootPart") or myChar.PrimaryPart)

    if not GlobalConfig.AH.Enabled then
        GlobalState.AH.LockedRandomTarget = nil
        UpdateAHVisual(nil)
        if myHum and myHum.PlatformStand then
            myHum.PlatformStand = false
        end
        return
    end

    local gs = GetGameState()
    local isLocalEXE = myChar and IsGameEXE(myChar)

    if (gs ~= "ING" and gs ~= "80s") or not isLocalEXE then
        GlobalState.AH.LockedRandomTarget = nil
        UpdateAHVisual(nil)
        if myHum and myHum.PlatformStand then
            myHum.PlatformStand = false
        end
        return
    end

    if myChar then
        local isHardGrabbing = myChar:FindFirstChild("grab") 
            or CollectionService:HasTag(myChar, "Kill") 
            or CollectionService:HasTag(myChar, "Carried")
            or CollectionService:HasTag(myChar, "Grabbed")
        
        if isHardGrabbing then
            if myRoot then
                myRoot.AssemblyLinearVelocity  = Vector3.zero
                myRoot.AssemblyAngularVelocity = Vector3.zero
                myRoot.Velocity                = Vector3.zero
            end
            return
        end
    end

    local target = GetBestTarget()
    if target and myChar and myRoot and myHum then
        local tRoot = target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart

        if tRoot then
            if not myHum.PlatformStand then
                myHum.PlatformStand = true
            end

            local tVel = tRoot.AssemblyLinearVelocity or tRoot.Velocity or Vector3.zero
            local planarVel = Vector3.new(tVel.X, 0, tVel.Z)
            local isTargetMoving = (planarVel.Magnitude > 1.2) or (math.abs(tVel.Y) > 2.0)

            local distToTarget = (myRoot.Position - tRoot.Position).Magnitude
            local maxHitRange  = math.abs(GlobalConfig.AH.Distance) + 6.0
            local isWithinHitRange = (distToTarget <= maxHitRange)

            local shouldHoldPosition = (not isTargetMoving) and isWithinHitRange

            local predictPos = tRoot.Position + (planarVel * 0.08)
            local lookDir = tRoot.CFrame.LookVector
            local baseCFrame = CFrame.lookAt(predictPos, predictPos + lookDir)

            -- Auto-Adaptive Height System
            local targetSize = GetModelStudSize(target)
            local targetHum = target:FindFirstChildOfClass("Humanoid")
            local tState = targetHum and targetHum:GetState()
            
            local autoHeightOffset = (targetSize.Y * 0.15)

            if tState == Enum.HumanoidStateType.Freefall then
                autoHeightOffset = autoHeightOffset - 0.5
            elseif tState == Enum.HumanoidStateType.Jumping then
                autoHeightOffset = autoHeightOffset + 0.8
            elseif IsDowned(target) then
                autoHeightOffset = -1.8
            end

            -- Floor Clamping
            local floorRay = Workspace:Raycast(predictPos, Vector3.new(0, -6, 0), CachedNoclipRayParams)
            if floorRay then
                local floorY = floorRay.Position.Y + 2.3
                if (predictPos.Y + autoHeightOffset + GlobalConfig.AH.Height) < floorY then
                    autoHeightOffset = floorY - predictPos.Y - GlobalConfig.AH.Height
                end
            end

            local finalHeight = GlobalConfig.AH.Height + autoHeightOffset

            local angleRotation = CFrame.Angles(
                math.rad(GlobalConfig.AH.RotX or 0),
                math.rad(GlobalConfig.AH.RotY or 0),
                math.rad(GlobalConfig.AH.RotZ or 0)
            )

            local targetCFrame = baseCFrame * CFrame.new(0, finalHeight, GlobalConfig.AH.Distance) * angleRotation

            HandleSmartNoclip(predictPos)

            if not shouldHoldPosition then
                myRoot.CFrame = targetCFrame
            end

            myRoot.AssemblyLinearVelocity  = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
            myRoot.Velocity                = Vector3.zero

            local attackDelay = math.clamp(tonumber(GlobalConfig.AH.Delay) or 0.05, 0.05, 5)
            local canHit = true
            if GlobalConfig.AH.SmartAttack then
                canHit = isWithinHitRange
            end

            if canHit and (tick() - GlobalState.AH.LastAttack >= attackDelay) then
                GlobalState.AH.LastAttack = tick()
                FastAttackTrigger()
            end

            UpdateAHVisual(tRoot)
        else
            GlobalState.AH.LockedRandomTarget = nil
            UpdateAHVisual(nil)
        end
    else
        GlobalState.AH.LockedRandomTarget = nil
        UpdateAHVisual(nil)
        if myRoot then 
            myRoot.AssemblyLinearVelocity  = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero
            myRoot.Velocity                = Vector3.zero 
        end
        if myHum and myHum.PlatformStand then
            myHum.PlatformStand = false
        end
    end
end

local function DoNoCDJump()
    if not GlobalConfig.NoCDJump or not LocalPlayer.Character then return end
    local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
        if not hum.Jump and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            hum.Jump = true
        end
    end
end

local LocalTagGui, LocalTagLabel = nil, nil
local LocAnimTimer = 0
local LocAnimStep  = 1

local function DoLocalTagRender(dt)
    local lCfg = Cfg.Local
    if not lCfg or not lCfg.Tag_Enabled or not LocalPlayer.Character then
        if LocalTagGui then LocalTagGui.Enabled = false end
        return
    end

    local head = LocalPlayer.Character:FindFirstChild("Head") or LocalPlayer.Character.PrimaryPart
    if not head then
        if LocalTagGui then LocalTagGui.Enabled = false end
        return
    end

    if not LocalTagGui or not LocalTagGui.Parent then
        LocalTagGui = Instance.new("BillboardGui")
        LocalTagGui.Name = "Doom_Local_Tag"
        LocalTagGui.Size = UDim2.new(0, 200, 0, 40)
        LocalTagGui.StudsOffset = Vector3.new(0, 3.2, 0)
        LocalTagGui.AlwaysOnTop = true
        LocalTagGui.Parent = Visuals_Folder

        LocalTagLabel = Instance.new("TextLabel", LocalTagGui)
        LocalTagLabel.Size = UDim2.fromScale(1, 1)
        LocalTagLabel.BackgroundTransparency = 1
        LocalTagLabel.Font = Enum.Font.GothamBold
        LocalTagLabel.TextSize = 14
    end

    LocalTagGui.Enabled = true
    LocalTagGui.Adornee = head

    local fullText = (lCfg.Tag_Mode == "DOOMSENSE") and "DOOMSENSE" or (lCfg.Tag_Custom or "DOOMSENSE")
    local displayText = fullText

    if lCfg.Tag_Type == "Anim" then
        LocAnimTimer = LocAnimTimer + dt
        local totalChars = #fullText
        local totalSteps = (totalChars * 2) + 4
        if LocAnimTimer >= 0.333 then
            LocAnimTimer = 0
            LocAnimStep = LocAnimStep + 1
            if LocAnimStep > totalSteps then LocAnimStep = 1 end
        end

        if LocAnimStep <= totalChars then
            displayText = string.sub(fullText, 1, LocAnimStep)
        elseif LocAnimStep <= totalChars + 3 then
            displayText = fullText
        elseif LocAnimStep <= (totalChars * 2) + 3 then
            local rem = totalChars - (LocAnimStep - (totalChars + 3))
            displayText = string.sub(fullText, 1, math.max(0, rem))
        else
            displayText = " "
        end
    end

    LocalTagLabel.Text = displayText
    LocalTagLabel.TextColor3 = lCfg.Tag_FillCol
    LocalTagLabel.TextStrokeColor3 = lCfg.Tag_OutCol
    local t = GetTrans(lCfg.Tag_Limp, true)
    LocalTagLabel.TextTransparency = t
    LocalTagLabel.TextStrokeTransparency = t
end

local function DoVisualsRender()

    local gs = GetGameState()
    local isRoundActive = (gs == "ING" or gs == "80s")

    if not isRoundActive then
        for m, hl in pairs(GlobalState.Vis.HighlightCache) do
            if hl and hl.Parent then hl:Destroy() end
        end
        for m, tags in pairs(GlobalState.Vis.TagCache) do
            if tags and tags.BoxFrame and tags.BoxFrame.Parent then
                tags.BoxFrame:Destroy()
            end
        end
        table.clear(GlobalState.Vis.HighlightCache)
        table.clear(GlobalState.Vis.TagCache)
        return
    end

    -- Cleanup Orphaned Player Visuals
    for m, hl in pairs(GlobalState.Vis.HighlightCache) do
        if not m or not m.Parent or not m:IsDescendantOf(Workspace) then
            if hl and hl.Parent then hl:Destroy() end
            GlobalState.Vis.HighlightCache[m] = nil
        end
    end

    for m, tags in pairs(GlobalState.Vis.TagCache) do
        if not m or not m.Parent or not m:IsDescendantOf(Workspace) then
            if tags and tags.BoxFrame and tags.BoxFrame.Parent then
                tags.BoxFrame:Destroy()
            end
            GlobalState.Vis.TagCache[m] = nil
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        local char = p.Character
        if char and char:IsDescendantOf(Workspace) then
            local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Head")
            if not root then continue end

            local charAttr = GetCharacterName(char, p)
            local isLocal  = (p == LocalPlayer)

            -- STRICT LOBBY ELIMINATION: Never draw WH or Tags in Lobby!
            if IsInLobbyArea(root.Position) or IsPlayerEscaped(p, char) then
                if GlobalState.Vis.HighlightCache[char] then
                    GlobalState.Vis.HighlightCache[char].Enabled = false
                end
                if GlobalState.Vis.TagCache[char] and GlobalState.Vis.TagCache[char].BoxFrame then
                    GlobalState.Vis.TagCache[char].BoxFrame.Visible = false
                end
                continue
            end

            if isLocal then
                local hl = GetHighlight(char)
                if Cfg.Local and Cfg.Local.Enabled then
                    hl.Enabled = true; hl.Adornee = char
                    hl.FillColor    = Cfg.Local.FillCol
                    hl.OutlineColor = Cfg.Local.OutCol
                    hl.FillTransparency    = GetTrans(Cfg.Local.Limp_Fill, Cfg.Local.Style and Cfg.Local.Style["Fill"])
                    hl.OutlineTransparency = GetTrans(Cfg.Local.Limp_Out, Cfg.Local.Style and Cfg.Local.Style["Outline"])
                else
                    hl.Enabled = false
                end
            else
                local isExe = IsGameEXE(char)
                local hl    = GetHighlight(char)
                local tData = GetTags(char)

                -- 1. Chams
                local isEnabled = false
                if isExe then
                    isEnabled = Cfg.Chams and Cfg.Chams.EXE_Enabled
                else
                    isEnabled = Cfg.Chams and Cfg.Chams.Surv_Enabled
                end

                if isEnabled then
                    hl.Enabled = true; hl.Adornee = char
                    local showFill = false
                    local showOut  = false
                    if isExe then
                        showFill = Cfg.Chams.EXE_Style and Cfg.Chams.EXE_Style["Fill"]
                        showOut  = Cfg.Chams.EXE_Style and Cfg.Chams.EXE_Style["Outline"]
                        hl.FillColor = Cfg.Chams.EXE_FillCol; hl.OutlineColor = Cfg.Chams.EXE_OutCol
                        hl.FillTransparency    = GetTrans(Cfg.Chams.EXE_Limp_Fill, showFill)
                        hl.OutlineTransparency = GetTrans(Cfg.Chams.EXE_Limp_Out, showOut)
                    else
                        showFill = Cfg.Chams.Surv_Style and Cfg.Chams.Surv_Style["Fill"]
                        showOut  = Cfg.Chams.Surv_Style and Cfg.Chams.Surv_Style["Outline"]
                        hl.FillColor = Cfg.Chams.Surv_FillCol; hl.OutlineColor = Cfg.Chams.Surv_OutCol
                        hl.FillTransparency    = GetTrans(Cfg.Chams.Surv_Limp_Fill, showFill)
                        hl.OutlineTransparency = GetTrans(Cfg.Chams.Surv_Limp_Out, showOut)
                    end
                else
                    hl.Enabled = false
                end

                -- 2. 2D Box Calculation via Model Dimensions
                local boxSize3D = GetModelStudSize(char)
                local rootCF    = root.CFrame
                local halfX, halfY, halfZ = boxSize3D.X / 2, boxSize3D.Y / 2, boxSize3D.Z / 2

                local minX, minY = math.huge, math.huge
                local maxX, maxY = -math.huge, -math.huge
                local anyVisible = false

                for sx = -1, 1, 2 do
                    for sy = -1, 1, 2 do
                        for sz = -1, 1, 2 do
                            local cornerPos = rootCF:PointToWorldSpace(Vector3.new(halfX * sx, halfY * sy, halfZ * sz))
                            local screenPos, onScreen = Camera:WorldToViewportPoint(cornerPos)
                            if onScreen then anyVisible = true end
                            if screenPos.X < minX then minX = screenPos.X end
                            if screenPos.Y < minY then minY = screenPos.Y end
                            if screenPos.X > maxX then maxX = screenPos.X end
                            if screenPos.Y > maxY then maxY = screenPos.Y end
                        end
                    end
                end

                local distStuds = (Camera.CFrame.Position - root.Position).Magnitude
                local isDistanceValid = distStuds > 3.57
                
                local wOffset = isExe and (Cfg.TwoD.EXE_Box_WOffset or 0) or (Cfg.TwoD.Surv_Box_WOffset or 0)
                local hOffset = isExe and (Cfg.TwoD.EXE_Box_HOffset or 0) or (Cfg.TwoD.Surv_Box_HOffset or 0)

                minX = minX - wOffset
                maxX = maxX + wOffset
                minY = minY - hOffset
                maxY = maxY + hOffset

                if anyVisible and isDistanceValid and minX < maxX and minY < maxY then
                    tData.BoxFrame.Visible  = true
                    tData.BoxFrame.Position = UDim2.fromOffset(minX, minY)
                    tData.BoxFrame.Size     = UDim2.fromOffset(maxX - minX, maxY - minY)

                    local isBoxOn, boxFillCol, boxOutCol, fillTransp, outTransp
                    if isExe then
                        isBoxOn    = Cfg.TwoD.EXE_Box_Tog
                        boxFillCol = Cfg.TwoD.EXE_Box_Fill
                        boxOutCol  = Cfg.TwoD.EXE_Box_Out
                        fillTransp = GetTrans(Cfg.TwoD.EXE_Box_Limp_Fill, isBoxOn)
                        outTransp  = GetTrans(Cfg.TwoD.EXE_Box_Limp_Out, isBoxOn)
                    else
                        isBoxOn    = Cfg.TwoD.Surv_Box_Tog
                        boxFillCol = Cfg.TwoD.Surv_Box_Fill
                        boxOutCol  = Cfg.TwoD.Surv_Box_Out
                        fillTransp = GetTrans(Cfg.TwoD.Surv_Box_Limp_Fill, isBoxOn)
                        outTransp  = GetTrans(Cfg.TwoD.Surv_Box_Limp_Out, isBoxOn)
                    end

                    tData.BoxFrame.BackgroundColor3       = boxFillCol
                    tData.BoxFrame.BackgroundTransparency = fillTransp
                    tData.BoxStroke.Color                 = boxOutCol
                    tData.BoxStroke.Transparency          = outTransp
                    tData.BoxStroke.Enabled               = isBoxOn

-- 3. Dynamic Isolated Tag Routing
                    local globalTrans = GetTrans(Cfg.TwoD.GlobalLimp, true)

                    local function ProcessTagLabel(lbl, isTog, dir, order, fillCol, outCol, limpVal, textStr)
                        if isTog and textStr and textStr ~= "" then
                            local holderFrame = tData.Holders[dir] or tData.Holders.Top
                            if lbl.Parent ~= holderFrame then
                                lbl.Parent = holderFrame
                            end
                            if lbl.Text ~= textStr then
                                lbl.Text = textStr
                            end
                            
                            if dir == "Left" then
                                lbl.TextXAlignment = Enum.TextXAlignment.Right
                            elseif dir == "Right" then
                                lbl.TextXAlignment = Enum.TextXAlignment.Left
                            else
                                lbl.TextXAlignment = Enum.TextXAlignment.Center
                            end
                    
                            lbl.TextColor3            = fillCol
                            lbl.TextStrokeColor3      = outCol
                            local dT                  = math.max(globalTrans, GetTrans(limpVal, true))
                            lbl.TextTransparency      = dT
                            lbl.TextStrokeTransparency = dT
                            lbl.LayoutOrder           = order
                            lbl.Visible               = true
                        else
                            lbl.Visible = false
                        end
                    end

                    local entInfo       = ResolveEntityInfo(char)
                    local isDeadState   = IsDead(char, p)
                    local isDownedState = IsDowned(char, p)
                    local isLastLife    = IsLastLife(char, p)
                    local distMeters    = math.floor(distStuds / 3.57)

                    if isExe then
                        for _, l in pairs(tData.SURV) do l.Visible = false end

                        local isRage = IsRageCheck(char)
                        local isStunState = IsStunned(char, p)
                        ProcessTagLabel(tData.EXE.Role,     Cfg.TwoD.EXE_Role_Tog,     Cfg.TwoD.EXE_Role_Dir,     Cfg.TwoD.EXE_Role_Order,     Cfg.TwoD.EXE_Role_Fill,     Cfg.TwoD.EXE_Role_Out,     Cfg.TwoD.EXE_Role_Limp,     "EXE")
                        ProcessTagLabel(tData.EXE.Rage,     Cfg.TwoD.EXE_Rage_Tog and isRage, Cfg.TwoD.EXE_Rage_Dir, Cfg.TwoD.EXE_Rage_Order, Cfg.TwoD.EXE_Rage_Fill, Cfg.TwoD.EXE_Rage_Out, Cfg.TwoD.EXE_Rage_Limp, "RAGE")
                        ProcessTagLabel(tData.EXE.Stun,     Cfg.TwoD.EXE_Stun_Tog and isStunState, Cfg.TwoD.EXE_Stun_Dir, Cfg.TwoD.EXE_Stun_Order, Cfg.TwoD.EXE_Stun_Fill, Cfg.TwoD.EXE_Stun_Out, Cfg.TwoD.EXE_Stun_Limp, "STUN")
                        ProcessTagLabel(tData.EXE.Dead,     Cfg.TwoD.EXE_Dead_Tog and isDeadState, Cfg.TwoD.EXE_Dead_Dir, Cfg.TwoD.EXE_Dead_Order, Cfg.TwoD.EXE_Dead_Fill, Cfg.TwoD.EXE_Dead_Out, Cfg.TwoD.EXE_Dead_Limp, "DEAD")
                        ProcessTagLabel(tData.EXE.CharName, Cfg.TwoD.EXE_CharName_Tog, Cfg.TwoD.EXE_CharName_Dir, Cfg.TwoD.EXE_CharName_Order, Cfg.TwoD.EXE_CharName_Fill, Cfg.TwoD.EXE_CharName_Out, Cfg.TwoD.EXE_CharName_Limp, entInfo.CharName)
                        ProcessTagLabel(tData.EXE.UserName, Cfg.TwoD.EXE_UserName_Tog, Cfg.TwoD.EXE_UserName_Dir, Cfg.TwoD.EXE_UserName_Order, Cfg.TwoD.EXE_UserName_Fill, Cfg.TwoD.EXE_UserName_Out, Cfg.TwoD.EXE_UserName_Limp, entInfo.UserName)
                        ProcessTagLabel(tData.EXE.Dist,     Cfg.TwoD.EXE_Dist_Tog,     Cfg.TwoD.EXE_Dist_Dir,     Cfg.TwoD.EXE_Dist_Order,     Cfg.TwoD.EXE_Dist_Fill,     Cfg.TwoD.EXE_Dist_Out,     Cfg.TwoD.EXE_Dist_Limp,     tostring(distMeters) .. "m")
                    else
                        for _, l in pairs(tData.EXE) do l.Visible = false end

                        ProcessTagLabel(tData.SURV.Role,     Cfg.TwoD.Surv_Role_Tog,     Cfg.TwoD.Surv_Role_Dir,     Cfg.TwoD.Surv_Role_Order,     Cfg.TwoD.Surv_Role_Fill,     Cfg.TwoD.Surv_Role_Out,     Cfg.TwoD.Surv_Role_Limp,     "SURV")
                        ProcessTagLabel(tData.SURV.Down,     Cfg.TwoD.Surv_Down_Tog and isDownedState, Cfg.TwoD.Surv_Down_Dir, Cfg.TwoD.Surv_Down_Order, Cfg.TwoD.Surv_Down_Fill, Cfg.TwoD.Surv_Down_Out, Cfg.TwoD.Surv_Down_Limp, "DOWN")
                        ProcessTagLabel(tData.SURV.LastLife, Cfg.TwoD.Surv_LastLife_Tog and isLastLife and not isDownedState and not isDeadState, Cfg.TwoD.Surv_LastLife_Dir, Cfg.TwoD.Surv_LastLife_Order, Cfg.TwoD.Surv_LastLife_Fill, Cfg.TwoD.Surv_LastLife_Out, Cfg.TwoD.Surv_LastLife_Limp, "LAST LIFE")
                        ProcessTagLabel(tData.SURV.Dead,     Cfg.TwoD.Surv_Dead_Tog and isDeadState, Cfg.TwoD.Surv_Dead_Dir, Cfg.TwoD.Surv_Dead_Order, Cfg.TwoD.Surv_Dead_Fill, Cfg.TwoD.Surv_Dead_Out, Cfg.TwoD.Surv_Dead_Limp, "DEAD")
                        ProcessTagLabel(tData.SURV.CharName, Cfg.TwoD.Surv_CharName_Tog, Cfg.TwoD.Surv_CharName_Dir, Cfg.TwoD.Surv_CharName_Order, Cfg.TwoD.Surv_CharName_Fill, Cfg.TwoD.Surv_CharName_Out, Cfg.TwoD.Surv_CharName_Limp, entInfo.CharName)
                        ProcessTagLabel(tData.SURV.UserName, Cfg.TwoD.Surv_UserName_Tog, Cfg.TwoD.Surv_UserName_Dir, Cfg.TwoD.Surv_UserName_Order, Cfg.TwoD.Surv_UserName_Fill, Cfg.TwoD.Surv_UserName_Out, Cfg.TwoD.Surv_UserName_Limp, entInfo.UserName)
                        ProcessTagLabel(tData.SURV.Dist,     Cfg.TwoD.Surv_Dist_Tog,     Cfg.TwoD.Surv_Dist_Dir,     Cfg.TwoD.Surv_Dist_Order,     Cfg.TwoD.Surv_Dist_Fill,     Cfg.TwoD.Surv_Dist_Out,     Cfg.TwoD.Surv_Dist_Limp,     tostring(distMeters) .. "m")
                    end
                else
                    tData.BoxFrame.Visible = false
                end
            end
        end
    end

    if Cfg.Pad and Cfg.Pad.Enabled then
        for obj, hl in pairs(GlobalState.Vis.PadCache) do
            if obj and obj.Parent then
                hl.Enabled          = true
                hl.FillColor        = Cfg.Pad.FillCol
                hl.OutlineColor     = Cfg.Pad.OutCol
                hl.FillTransparency    = GetTrans(Cfg.Pad.Limp_Fill, Cfg.Pad.Style and Cfg.Pad.Style["Fill"])
                hl.OutlineTransparency = GetTrans(Cfg.Pad.Limp_Out, Cfg.Pad.Style and Cfg.Pad.Style["Outline"])
            else
                if hl then hl:Destroy() end
                GlobalState.Vis.PadCache[obj] = nil
            end
        end
    else
        for obj, hl in pairs(GlobalState.Vis.PadCache) do
            if hl then hl.Enabled = false end
        end
    end
end

local function DoTrapRender(dt)
    if not Cfg.Tripwire.Enabled then return end
    
    local now = tick()
    local spd = Cfg.Tripwire.Speed
    
    for obj, data in pairs(GlobalState.Vis.TrapCache) do
        if obj and obj.Parent and data.Proxy and data.Proxy.Parent then
            if Cfg.Tripwire.Direction == "Random" then
                if now >= data.NextSwitch then
                    data.TargetDir = (math.random(1, 2) == 1) and 1 or -1
                    local rMin = math.clamp(Cfg.Tripwire.RandMin, 0.1, 10)
                    local rMax = math.max(rMin, Cfg.Tripwire.RandMax)
                    data.NextSwitch = now + (math.random(rMin * 10, rMax * 10) / 10)
                end
            else
                data.TargetDir = (Cfg.Tripwire.Direction == "Left") and -1 or 1
            end
            
            data.CurrentDir = data.CurrentDir + (data.TargetDir - data.CurrentDir) * (dt * 2)
            data.Angle = data.Angle + (spd * 20 * data.CurrentDir * dt)
            data.Proxy.CFrame = CFrame.new(obj.Position)

            if data.ImgObj and data.BgObj then
                data.ImgObj.Rotation = data.Angle
                data.ImgObj.ImageColor3 = Cfg.Tripwire.FillCol
                data.ImgObj.ImageTransparency = GetTrans(Cfg.Tripwire.LimpFill, true)
                
                local s = Cfg.Tripwire.Size
                if Cfg.Tripwire.ScaleMode == "3D" then
                    data.BgObj.Size = UDim2.new(s, 0, s, 0)
                else
                    local px = s * 20
                    data.BgObj.Size = UDim2.new(0, px, 0, px)
                end
            end
        end
    end
end

local function DoLMSAudio()
    local L = GlobalState.LMS
    local currentState = GetGameState()

    if currentState == "SEC" or currentState == "MS" then
        PreloadAllLMSTracks()
    end

    local shadow = GetShadowSound()

    if currentState == "ING" or currentState == "80s" then
        if not L.RoundActive then
            L.RoundActive     = true
            L.TrackFinished   = false
            L.VisualPlayed    = false
            L.LmsCounter      = 0
            L.StartDelayTimer = nil
            L.Survivor        = nil
            L.Killer          = nil
        end

        if L.StopRoutineRunning then L.StopRoutineRunning = false end

        local activeSurvs, downedSurvs, escapedSurvs, exes = AnalyzeLMSState()
        local original = GetActiveSoloSound()

        local rawLmsCondition = (original ~= nil and (original.IsPlaying or original.Playing or original.TimePosition > 0)) or (
            #escapedSurvs == 0 and 
            #downedSurvs == 0 and 
            #activeSurvs == 1 and 
            #exes >= 1
        )

        if rawLmsCondition then
            L.LmsCounter = (L.LmsCounter or 0) + 1
        else
            L.LmsCounter = 0
        end

        local isTrueLMSVerified = (original ~= nil and (original.IsPlaying or original.Playing or original.TimePosition > 0)) or (L.LmsCounter >= 5)

        if isTrueLMSVerified and GlobalConfig.LMS.Enabled then
            if not L.StartDelayTimer then
                L.StartDelayTimer = tick()
            end

            local delayTime = tonumber(GlobalConfig.LMS.StartDelay) or 0

            if tick() - L.StartDelayTimer >= delayTime then
                L.IsCapturing = true

                if #activeSurvs == 1 then L.Survivor = activeSurvs[1] end
                if #exes >= 1 then L.Killer = exes[1] end

                if not L.VisualPlayed and GlobalConfig.LMS.StartEffect ~= "None" then
                    local fxName = GlobalConfig.LMS.StartEffect
                    local fxFunc = LMS_Visuals[fxName]
                    if typeof(fxFunc) == "function" then
                        L.VisualPlayed = true
                        task.spawn(fxFunc, false)
                        Fluent:Notify({ Title = "Music System", Content = "True LMS Verified - Custom Track Played", Duration = 2 })
                    end
                end

                if original and original.Volume > 0 then 
                    original.Volume = 0 
                end

                local activeTrackName = GetActiveCustomTrack()
                local resolvedAssetID = ResolveAssetPath(activeTrackName)

                if resolvedAssetID and resolvedAssetID ~= "" then
                    if not L.TrackFinished then
                        if shadow.SoundId ~= resolvedAssetID then
                            shadow.SoundId      = resolvedAssetID
                            shadow.TimePosition = original and original.TimePosition or 0
                            shadow:Play()
                        end
                        
                        if not shadow.IsPlaying then shadow:Play() end
                        if original and shadow.PlaybackSpeed ~= original.PlaybackSpeed then 
                            shadow.PlaybackSpeed = original.PlaybackSpeed 
                        end
                        shadow.Volume = GlobalConfig.LMS.Volume
                    else
                        if shadow.IsPlaying then shadow:Stop() end
                        shadow.Volume = 0
                    end
                end
            end
        else
            L.StartDelayTimer = nil
            L.IsCapturing     = false
            L.VisualPlayed    = false
            if shadow.IsPlaying and shadow.Volume > 0 then
                TriggerSteppedStop(shadow)
            end
        end
    else
        L.LmsCounter      = 0
        L.RoundActive     = false
        L.VisualPlayed    = false
        L.TrackFinished   = false
        L.StartDelayTimer = nil
        L.Survivor        = nil
        L.Killer          = nil
        if L.IsCapturing then TriggerSteppedStop(shadow) end
    end
end

local function DoART()
    local A = GlobalState.ART
    local currentState = GetGameState()

    if currentState == "INT" or currentState == "SEC" or currentState == "MS" or currentState == "RE" then
        A.HandledThisRound = false
        A.SavedRingCF = nil
        A.LastTeleportTime = 0
    end

    if not GlobalConfig.AutoRing or A.HandledThisRound then return end

    if currentState == "ING" or currentState == "80s" then
        local timeVal = Workspace:FindFirstChild("GameProperties") and Workspace.GameProperties:FindFirstChild("Time")
        local isTimeCondition = (timeVal and timeVal.Value <= 80 and timeVal.Value > 0)
        local isStateCondition = (currentState == "80s")

        if isStateCondition or isTimeCondition then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and IsRageCheck(p.Character) then
                    return
                end
            end

            local char = LocalPlayer.Character
            local root = char and (char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart)
            local hum  = char and char:FindFirstChildOfClass("Humanoid")

            if root and hum and hum.Health > 0 and not IsGameEXE(char) then
                if not A.SavedRingCF then
                    local myPos = root.Position
                    local closestCF = nil
                    local closestDist = 800

                    for _, zonePos in ipairs(CachedEscapeZones) do
                        local d = (zonePos - myPos).Magnitude
                        if d < closestDist and not IsInLobbyArea(zonePos) then
                            closestDist = d
                            closestCF = CFrame.new(zonePos + Vector3.new(0, 3, 0))
                        end
                    end

                    if not closestCF then
                        for _, v in ipairs(Workspace:GetDescendants()) do
                            local isRing = (v:IsA("MeshPart") and v.MeshId == "rbxassetid://106058960373684") 
                                or (v:IsA("BasePart") and (v.Name:find("EscapePart") or v.Name == "Ring"))
                            if isRing then
                                local d = (v.Position - myPos).Magnitude
                                if d < closestDist and not IsInLobbyArea(v.Position) then
                                    closestDist = d
                                    closestCF = v.CFrame + Vector3.new(0, 3, 0)
                                end
                            end
                        end
                    end

                    A.SavedRingCF = closestCF
                end

                if A.SavedRingCF then
                    local now = tick()
                    if not A.HandledThisRound or (now - A.LastTeleportTime >= 1.0) then
                        A.LastTeleportTime = now
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.Velocity = Vector3.zero
                        char:PivotTo(A.SavedRingCF)
                        root.CFrame = A.SavedRingCF

                        if not A.HandledThisRound then
                            A.HandledThisRound = true
                            Fluent:Notify({ Title = "ART Triggered", Content = "Locked to Exit Zone", Duration = 3 })
                        end
                    end
                end
            end
        end
    end
end

local function DoAutoVote()
    local V = GlobalState.Vote
    local gs = GetGameState()

    if gs == "INT" or gs == "RE" then
        V.VotedInRound = false
        V.Timer = 0
        return
    end

    if not GlobalConfig.Vote.Enabled or V.VotedInRound or gs ~= "SEC" then 
        return 
    end

    V.Timer = V.Timer + 0.5
    local targetDelay = tonumber(GlobalConfig.Vote.Delay) or 1
    
    if V.Timer >= targetDelay then
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local voteRemote = remotes and remotes:FindFirstChild("Voted")
        
        if voteRemote then
            local survChar = GlobalConfig.Vote.Randomize and VoteLists.Survivor[math.random(1, #VoteLists.Survivor)] or GlobalConfig.Vote.SurvTarget
            local exeChar = GlobalConfig.Vote.Randomize and VoteLists.EXE[math.random(1, #VoteLists.EXE)] or GlobalConfig.Vote.ExeTarget
            
            voteRemote:FireServer(survChar)
            voteRemote:FireServer(exeChar)
            
            Fluent:Notify({ Title = "Auto Vote", Content = "Voted: " .. survChar .. " & " .. exeChar, Duration = 3 })
        end
        V.VotedInRound = true
    end
end

local TRAP_ASSETS = {
    ["Shockwave"]       = "rbxassetid://12914395250",
    ["Circle Dashed 4"] = "rbxassetid://10382429808",
    ["Shift Lock"]      = "rbxassetid://118624373632520",
}

local function DoTrapScan()
    local Cache = GlobalState.Vis.TrapCache
    if not Cfg.Tripwire.Enabled then return end
    
    local projFolder = Workspace:FindFirstChild("Projectile")
    local trapsFolder = projFolder and projFolder:FindFirstChild("Traps")
    if not trapsFolder then return end

    for _, obj in pairs(trapsFolder:GetChildren()) do
        if obj.Name == "Union" and obj:GetAttribute("Owner") and not Cache[obj] then
            local proxy = Instance.new("Part")
            proxy.Name = "Doom_TrapProxy"
            proxy.Anchored = true
            proxy.CanCollide = false
            proxy.CanQuery = false
            proxy.Transparency = 1
            proxy.Size = Vector3.new(0.1, 0.1, 0.1)
            proxy.CFrame = obj.CFrame
            proxy.Parent = Visuals_Folder
            
            local bg = Instance.new("BillboardGui")
            bg.AlwaysOnTop = true
            bg.Parent = proxy
            
            local img = Instance.new("ImageLabel")
            img.BackgroundTransparency = 1
            img.Size = UDim2.fromScale(1, 1)
            
            local targetID = TRAP_ASSETS[Cfg.Tripwire.Style]
            if Cfg.Tripwire.Style == "Custom" then
                local numID = string.match(Cfg.Tripwire.CustomID, "%d+")
                if numID then targetID = "rbxassetid://" .. numID end
            end
            
            img.Image = targetID or ""
            img.Parent = bg

            Cache[obj] = {
                Proxy = proxy,
                BgObj = bg,
                ImgObj = img,
                Angle = 0,
                CurrentDir = (Cfg.Tripwire.Direction == "Left") and -1 or 1,
                TargetDir = (Cfg.Tripwire.Direction == "Left") and -1 or 1,
                NextSwitch = tick() + math.random(Cfg.Tripwire.RandMin * 10, Cfg.Tripwire.RandMax * 10)/10
            }
        end
    end
    
    for obj, data in pairs(Cache) do
        if not obj.Parent then
            if data.Proxy then data.Proxy:Destroy() end
            Cache[obj] = nil
        end
    end
end

local function DoPadScan()
    local SV = GlobalState.Vis
    local currentState = GetGameState()

    if currentState ~= LastMapScanState then
        LastMapScanState = currentState
        UpdateMapCaches()
    end

    if currentState == "RE" or currentState == "INT" or currentState == "MS" or currentState == "SEC" then
        if SV.HasScannedPads then
            SV.HasScannedPads = false
            for obj, hl in pairs(SV.PadCache) do 
                if hl and hl.Parent then hl:Destroy() end 
            end
            table.clear(SV.PadCache)
        end
    elseif currentState == "ING" or currentState == "80s" then
        if not Cfg.Pad.Enabled then return end
        if not SV.HasScannedPads then
            SV.HasScannedPads = true
            task.spawn(function()
                local maps = Workspace:FindFirstChild("Maps") or Workspace:FindFirstChild("Map")
                local scanFolder = maps or Workspace
                for _, obj in pairs(scanFolder:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name == "Pad" or obj.Name == "PadPart") then
                        if not SV.PadCache[obj] then
                            local hl = Instance.new("Highlight")
                            hl.Name = "Doom_Pad_Highlight"
                            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            hl.Parent    = Visuals_Folder
                            hl.Adornee   = obj
                            hl.FillColor = Cfg.Pad.FillCol
                            hl.OutlineColor = Cfg.Pad.OutCol
                            SV.PadCache[obj] = hl
                        end
                    end
                end
            end)
        end
    end
end

local function DoPingCheck()
    local success, ping = pcall(function()
        return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
    end)
    if success then GlobalState.CurrentPing = math.floor(ping) end
end

local function DoAnimDetect()
    if not GlobalConfig.Anim.AutoDetect or not LocalPlayer.Character then return end
    local charName  = LocalPlayer.Character:GetAttribute("Character") or LocalPlayer.Character.Name
    local searchKey = NameToKey[charName] or charName
    local dbKey     = nil
    if AnimDB[searchKey] then dbKey = searchKey end

    if dbKey and dbKey ~= NameToKey[GlobalConfig.Anim.CurrentChar] and dbKey ~= GlobalConfig.Anim.CurrentChar then
        if Options and Options.Anim_Char and typeof(Options.Anim_Char.SetValue) == "function" then
            pcall(function()
                for _, k in pairs(CharList) do
                    if NameToKey[k] == dbKey or k == dbKey then
                        Options.Anim_Char:SetValue(k)
                        GlobalConfig.Anim.CurrentChar = k
                        
                        local list = {}
                        if AnimDB[dbKey] then
                            for _, a in pairs(AnimDB[dbKey]) do table.insert(list, a.Name) end
                        end
                        
                        if AnimNameDropdownControl and typeof(AnimNameDropdownControl.SetValues) == "function" and #list > 0 then
                            AnimNameDropdownControl:SetValues(list)
                            AnimNameDropdownControl:SetValue(list[1])
                            GlobalConfig.Anim.CurrentName = list[1]
                        end
                        break
                    end
                end
            end)
        end
    end
end

local LastViewportCache = Camera.ViewportSize
local function DoViewportCheck()
    local currentVP = Camera.ViewportSize
    if currentVP ~= LastViewportCache and currentVP.X > 0 and currentVP.Y > 0 then
        LastViewportCache = currentVP
        for _, btn in pairs(MobileControl.Buttons) do
            if btn.Canvas and btn.Canvas.Parent then
                local size = btn.Canvas.AbsoluteSize
                if size.X > 0 and size.Y > 0 then
                    btn.Canvas.Position = MobileControl:GetSafePosition(btn.Canvas.Position, size.X, size.Y)
                end
            end
        end
    end
end

-- ═══════════════════════════════════════════════════════════════════════════
-- TIME-SLICED DISPATCHER (25ms Frame Pacing & Command Throttling)
-- ═══════════════════════════════════════════════════════════════════════════
local BudgetPacer = {
    PacingTimer = 0,
    VisualTimer = 0,
    LmsTimer    = 0,
    JumpTimer   = 0,
    SliceStep   = 0
}

RunService.Heartbeat:Connect(function(dt)
    if not GlobalState.ScriptActive then return end

    DoPhysics()
    DoSilverRecord()

    -- AutoHunt - (0.025s)
    BudgetPacer.PacingTimer = BudgetPacer.PacingTimer + dt
    if BudgetPacer.PacingTimer >= 0.025 then
        BudgetPacer.PacingTimer = 0
        DoAutoHunt()
    end

    -- 2D - 30 FPS (0.033s)
    BudgetPacer.VisualTimer = BudgetPacer.VisualTimer + dt
    if BudgetPacer.VisualTimer >= 0.033 then
        BudgetPacer.VisualTimer = 0
        DoTrapRender(0.033)
        DoVisualsRender()
    end

    BudgetPacer.JumpTimer = BudgetPacer.JumpTimer + dt
    if BudgetPacer.JumpTimer >= 0.1 then
        BudgetPacer.JumpTimer = 0
        DoNoCDJump()
    end

    BudgetPacer.LmsTimer = BudgetPacer.LmsTimer + dt
    if BudgetPacer.LmsTimer >= 0.25 then
        BudgetPacer.LmsTimer = 0
        DoLMSAudio()
    end
end)

-- Slow Tick Loop (0.5s)
task.spawn(function()
    local counters = { Ping = 0, AHRefresh = 0, AnimDetect = 0 }

    while GlobalState.ScriptActive do
        task.wait(0.5)
        counters.Ping       = counters.Ping + 1
        counters.AHRefresh  = counters.AHRefresh + 1
        counters.AnimDetect = counters.AnimDetect + 1

        DoART()
        DoAutoVote()
        DoPadScan()
        DoTrapScan()
        DoViewportCheck()

        if counters.Ping >= 2 then
            counters.Ping = 0
            DoPingCheck()
        end

        if counters.AHRefresh >= 4 then
            counters.AHRefresh = 0
            DoAHCharRefresh()
        end

        if counters.AnimDetect >= 2 then
            counters.AnimDetect = 0
            DoAnimDetect()
        end
    end
end)

-- Final Initialization
task.spawn(function()
    task.wait(0.5)
    MobileControl:UpdateAllThemes()
    local vp = Camera.ViewportSize
    if vp.X > 0 and vp.Y > 0 then
        for _, btn in pairs(MobileControl.Buttons) do
            if btn.Canvas then
                local s = btn.Canvas.AbsoluteSize
                btn.Canvas.Position = MobileControl:GetSafePosition(btn.Canvas.Position, s.X, s.Y)
            end
        end
    end
end)

task.delay(1, function()
    if Options and Options.Anim_Char and Options.Anim_Name then
        local list   = {}
        local defKey = "R6"
        if AnimDB[defKey] then
            for _, a in pairs(AnimDB[defKey]) do table.insert(list, a.Name) end
        end
        pcall(function()
            if AnimNameDropdownControl and typeof(AnimNameDropdownControl.SetValues) == "function" then
                AnimNameDropdownControl:SetValues(list)
                if #list > 0 then AnimNameDropdownControl:SetValue(list[1]) end
            end
        end)
    end
end)

Window:SelectTab(1)

-- ═══════════════════════════════════════════════════════════════════════════
-- ANTI-CONSOLE SPAM & ANIMATE FIX
-- ═══════════════════════════════════════════════════════════════════════════
local EmptySignal = { Connect = function() return { Disconnect = function() end } end }
local DummyTrack = setmetatable({
    IsPlaying = false,
    Looped = false,
    Priority = Enum.AnimationPriority.Core,
    Length = 1,
    TimePosition = 0,
    Speed = 1,
    WeightCurrent = 1,
    WeightTarget = 1,
    Stopped = EmptySignal,
    KeyframeReached = EmptySignal,
}, {
    __index = function(self, key)
        if key == "GetMarkerReachedSignal" then
            return function() return EmptySignal end
        end
        return function() end
    end
})

local function PatchCharacterAnimator(char)
    if not char then return end
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end
    local animator = hum:WaitForChild("Animator", 5)
    if not animator then return end

    if not getgenv().AnimatePatched then
        getgenv().AnimatePatched = true
        local oldLoadAnimation
        oldLoadAnimation = hookfunction(animator.LoadAnimation, function(self, anim)
            if not anim then
                return DummyTrack
            end
            local success, track = pcall(oldLoadAnimation, self, anim)
            if success and track then
                return track
            end
            return DummyTrack
        end)
    end
end

if LocalPlayer.Character then
    task.spawn(PatchCharacterAnimator, LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(function(char)
    task.spawn(PatchCharacterAnimator, char)
end)

Fluent:Notify({
    Title    = "DOOMSENSE v2.4",
    Content  = "Stable Release Loaded.",
    Duration = 5
})

task.delay(1.2, function()
    if SaveManager and SaveManager.LoadAutoloadConfig then
        pcall(function()
            SaveManager:LoadAutoloadConfig()
        end)
        
        task.wait(0.3)
        if MobileControl and MobileControl.Buttons then
            for id, _ in pairs(MobileControl.Buttons) do
                UpdateBtnConfig(id)
            end
            MobileControl:UpdateAllThemes()
        end
    end
end)

CoreGui.ChildRemoved:Connect(function(child)
    if child == VisualsGui or child == FX_Gui or child == MobileScreenGui then
        if Visuals_Folder and Visuals_Folder.Parent then Visuals_Folder:Destroy() end
        if VisualsGui and VisualsGui.Parent then VisualsGui:Destroy() end
        if FX_Gui and FX_Gui.Parent then FX_Gui:Destroy() end
    end
end)

print("DOOMSENSE v2.4: patch 2")