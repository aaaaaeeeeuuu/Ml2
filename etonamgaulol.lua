local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/IVRzHxZ/Kyo-UI-Library/refs/heads/main/Kyo-UI-LibraryxPrivate", true))()

-- Make sure the Players service is available
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Dynamically generate the window title with a welcome message
local windowTitle = "TANG INA MO!| Welcome " .. LocalPlayer.DisplayName

local window = library:AddWindow(windowTitle, {
    main_color = Color3.fromRGB(41, 74, 122),
    min_size = Vector2.new(600, 500),
    can_resize = false
})

task.spawn(function()
    local imgui = game:GetService("CoreGui"):WaitForChild("imgui", 10)
    if not imgui then return end

    -- 🔥 FIXED THEME COLORS
    local WINDOW_COLOR = Color3.fromRGB(20, 20, 25)
    local FIRE_ORANGE = Color3.fromRGB(80, 80, 80)
    local DARK_EMBER = Color3.fromRGB(80, 80, 80)
    local BLACK = Color3.fromRGB(10, 10, 12)
    
    -- 🎨 DROPDOWN BOX COLOR
    local DROPDOWN_BOX_COLOR = Color3.fromRGB(20, 20, 25)

    local function forceFireTheme(element)
        if not element or not element:IsA("GuiObject") then return end
        if element:GetAttribute("UI_ForcedFire") then return end

        local nameLower = element.Name:lower()
        local parent = element.Parent
        local parentName = parent and parent.Name:lower() or ""

        if nameLower:match("indicator") or nameLower:match("checkmark") or nameLower:match("toggle") then
            return 
        end

        local isDropdownBox = (nameLower == "box") and (parentName:match("dropdown") or parentName == "d" or parentName:match("adddropdown"))

        -- 1. IMAGE ASSETS
        if element:IsA("ImageLabel") or element:IsA("ImageButton") then
            if isDropdownBox then
                element.ImageColor3 = DROPDOWN_BOX_COLOR
                element:SetAttribute("UI_ForcedFire", true)
                return
            elseif nameLower:match("window") or nameLower:match("main") then
                element.ImageColor3 = WINDOW_COLOR
            elseif nameLower:match("folder") then
                element.ImageColor3 = BLACK
            elseif nameLower:match("tab") then
                element.ImageColor3 = DARK_EMBER
            else
                element.ImageColor3 = FIRE_ORANGE
            end
        end

        -- 2. BACKGROUNDS & FRAMES
        if element:IsA("Frame") or element:IsA("TextButton") or element:IsA("TextBox") then
            if isDropdownBox then
                element.BackgroundColor3 = DROPDOWN_BOX_COLOR
                element:SetAttribute("UI_ForcedFire", true)
                return
            elseif nameLower:match("window") or nameLower:match("main") then
                element.BackgroundColor3 = WINDOW_COLOR
            elseif nameLower:match("folder") then
                element.BackgroundColor3 = BLACK
            elseif nameLower:match("tab") then
                element.BackgroundColor3 = DARK_EMBER
            elseif nameLower:match("addswitch") 
                or nameLower:match("addbutton") 
                or nameLower:match("addslider") 
                or nameLower:match("addtextbox")
                or nameLower:match("bar") then
                
                element.BackgroundColor3 = FIRE_ORANGE
            end
        end

        element:SetAttribute("UI_ForcedFire", true)
    end

    for _, element in ipairs(imgui:GetDescendants()) do
        task.defer(forceFireTheme, element)
    end

    imgui.DescendantAdded:Connect(function(element)
        task.defer(forceFireTheme, element)
    end)
end)

-- Create the Tab Layout
local mainTab = window:AddTab("Farm")

local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")

local AntiAFKConnection = nil
local AFKTimerThread = nil
local RainbowThread = nil

-- 1. Create Standalone ScreenGui Overlay
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Elerium_AFKOverlay"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Protect GUI from detection if supported by executor
pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    elseif gethui then
        ScreenGui.Parent = gethui()
    end
end)

if not ScreenGui.Parent then
    ScreenGui.Parent = CoreGui
end

-- 2. Build the Timer Frame Layout
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 500, 0, 80)
MainFrame.Position = UDim2.new(0.5, -250, 0.00, 0)
MainFrame.BackgroundTransparency = 1
MainFrame.BorderSizePixel = 0
MainFrame.Active = false 
MainFrame.Draggable = false 
MainFrame.Visible = false 
MainFrame.Parent = ScreenGui

-- Rainbow Text Label (ANTI AFK Text)
local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(1, 0, 1, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "ANTI AFK: 00:00:00"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.Font = Enum.Font.GothamBold
TextLabel.TextSize = 25 
TextLabel.TextXAlignment = Enum.TextXAlignment.Center
TextLabel.TextYAlignment = Enum.TextYAlignment.Center
TextLabel.Parent = MainFrame

-- 3. Add to your Elerium Tab
local AntiAFKSwitch = mainTab:AddSwitch("Anti-AFK ☕", function(bool)
    if bool then
        MainFrame.Visible = true
        
        if not AntiAFKConnection then
            AntiAFKConnection = LocalPlayer.Idled:Connect(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end
        
        if not AFKTimerThread then
            AFKTimerThread = task.spawn(function()
                local startTime = os.time()
                while true do
                    local elapsed = os.time() - startTime
                    local hours = math.floor(elapsed / 3600)
                    local minutes = math.floor((elapsed % 3600) / 60)
                    local seconds = elapsed % 60
                    
                    TextLabel.Text = string.format("ANTI AFK: %02d:%02d:%02d", hours, minutes, seconds)
                    task.wait(1)
                end
            end)
        end

        if not RainbowThread then
            RainbowThread = task.spawn(function()
                local hue = 0
                while true do
                    TextLabel.TextColor3 = Color3.fromHSV(hue, 1, 1)
                    hue = hue + 0.01
                    if hue >= 1 then
                        hue = 0
                    end
                    task.wait(0.03)
                end
            end)
        end
    else
        MainFrame.Visible = false
        
        if typeof(AntiAFKConnection) == "RBXScriptConnection" then
            AntiAFKConnection:Disconnect()
            AntiAFKConnection = nil
        end
        
        if AFKTimerThread then
            task.cancel(AFKTimerThread)
            AFKTimerThread = nil
        end

        if RainbowThread then
            task.cancel(RainbowThread)
            RainbowThread = nil
        end
    end
end)

AntiAFKSwitch:Set(true)

-- Global state for Popups
local _G = getgenv and getgenv() or _G
_G.HideGainedPopups = false
local originalStates = {}

local function isFrameUi(element)
    return element:IsA("Frame") or element:IsA("ScrollingFrame") or element:IsA("CanvasGroup")
end

local function hideElement(element)
    if not isFrameUi(element) then return end
    
    if not originalStates[element] then
        originalStates[element] = {
            Visible = element.Visible,
            Position = element.Position
        }
    end
    
    element.Visible = false
    element.Position = UDim2.new(5, 0, 5, 0)
end

local function restoreElements()
    for element, state in pairs(originalStates) do
        if element and element.Parent then
            element.Visible = state.Visible
            element.Position = state.Position
        end
    end
    table.clear(originalStates)
end

local playerGui = LocalPlayer:WaitForChild("PlayerGui")

playerGui.DescendantAdded:Connect(function(descendant)
    if _G.HideGainedPopups then
        task.wait(0.05)
        if _G.HideGainedPopups then
            hideElement(descendant)
        end
    end
end)

mainTab:AddSwitch("Hide All UI Frames", function(state)
    _G.HideGainedPopups = state
    if state then
        for _, desc in ipairs(playerGui:GetDescendants()) do
            hideElement(desc)
        end
    else
        restoreElements()
    end
end)

-- Global State Flags for the Switches
local farmActive = false
local rebirthActive = false
local speedActive = false

local function autoEquipWeight()
    local character = LocalPlayer.Character
    if not character then return end
    
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") and string.find(string.lower(item.Name), "weight") then
            return 
        end
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(string.lower(tool.Name), "weight") then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:EquipTool(tool)
                    break
                end
            end
        end
    end
end

mainTab:AddSwitch("Fast Reps Weight", function(state)
    farmActive = state
    
    if farmActive then
        task.spawn(function()
            while farmActive do
                autoEquipWeight()
                if LocalPlayer and LocalPlayer:FindFirstChild("muscleEvent") then
                    LocalPlayer.muscleEvent:FireServer("rep")
                end
                task.wait(0.1) 
            end
        end)
    end
end)

local function autoEquipPushUps()
    local character = LocalPlayer.Character
    if not character then return end
    
    for _, item in pairs(character:GetChildren()) do
        if item:IsA("Tool") and string.find(string.lower(item.Name), "push") then
            return 
        end
    end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") and string.find(string.lower(tool.Name), "push") then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:EquipTool(tool)
                    break
                end
            end
        end
    end
end

mainTab:AddSwitch("Fast Reps Push Ups", function(state)
    farmActive = state
    
    if farmActive then
        task.spawn(function()
            while farmActive do
                autoEquipPushUps()
                if LocalPlayer and LocalPlayer:FindFirstChild("muscleEvent") then
                    LocalPlayer.muscleEvent:FireServer("rep")
                end
                task.wait(0.1) 
            end
        end)
    end
end)

mainTab:AddSwitch("Fast Rebirth (500)", function(state)
    rebirthActive = state
    if rebirthActive then
        task.spawn(function()
            while rebirthActive do
                local rEvents = replicatedStorage:FindFirstChild("rEvents")
                if rEvents and rEvents:FindFirstChild("rebirthRemote") then
                    rEvents.rebirthRemote:InvokeServer("massRebirthRequest", 500)
                end
                task.wait(0.1) 
            end
        end)
    end
end)

local FastPunchConnection

mainTab:AddSwitch('Fast Punch', function(state)
    if state then
        _G.punchanim = true
        if FastPunchConnection then FastPunchConnection:Disconnect() end
        
        FastPunchConnection = RunService.Heartbeat:Connect(function()
            if _G.punchanim then
                local Character = LocalPlayer.Character
                if Character then
                    local Humanoid = Character:FindFirstChildOfClass('Humanoid')
                    local PunchTool = LocalPlayer.Backpack:FindFirstChild('Punch') or Character:FindFirstChild('Punch')
                    
                    if PunchTool then
                        local attackTime = PunchTool:FindFirstChild('attackTime')
                        if attackTime then attackTime.Value = 0 end
                        if Humanoid and PunchTool.Parent ~= Character then Humanoid:EquipTool(PunchTool) end
                        PunchTool:Activate()
                    end
                end
            else
                if FastPunchConnection then 
                    FastPunchConnection:Disconnect() 
                    FastPunchConnection = nil 
                end
            end
        end)
    else
        _G.punchanim = false
        if FastPunchConnection then 
            FastPunchConnection:Disconnect() 
            FastPunchConnection = nil 
        end
        local PunchInBackpack = LocalPlayer.Backpack:FindFirstChild('Punch')
        local PunchInCharacter = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild('Punch')
        local TargetPunch = PunchInBackpack or PunchInCharacter
        if TargetPunch and TargetPunch:FindFirstChild('attackTime') then 
            TargetPunch.attackTime.Value = 0.35 
        end
    end
end):Set(false)

local isLocked = false
local savedCFrame = nil 

local function applyLock(character)
    if isLocked and savedCFrame then
        local rootPart = character:WaitForChild("HumanoidRootPart", 5)
        if rootPart then
            task.wait(0.2)
            rootPart.CFrame = savedCFrame
            task.wait(0.05)
            rootPart.Anchored = true
        end
    end
end

LocalPlayer.CharacterAdded:Connect(applyLock)

mainTab:AddSwitch("Lock Position", function(state)
    isLocked = state
    if LocalPlayer.Character then
        local rootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            if state then
                savedCFrame = rootPart.CFrame
                rootPart.Anchored = true
            else
                rootPart.Anchored = false
                savedCFrame = nil
            end
        end
    end
end)

mainTab:AddSwitch("LoopSpeed 500", function(state)
    speedActive = state
    if speedActive then
        task.spawn(function()
            while speedActive do
                local character = LocalPlayer.Character
                if character then
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.WalkSpeed ~= 500 then
                        humanoid.WalkSpeed = 500
                    end
                end
                task.wait(0.05)
            end
        end)
    else
        local character = LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16
            end
        end
    end
end)

-- ============================================================================
-- PETS & CRYSTALS TAB (WITH PETSHOP REMOTE & AUTO TRASH ENGINE)
-- ============================================================================
local pets = window:AddTab("Pets & Crystals")

local selectedPet = "Secret Chaos Sorcerer"
_G.AutoHatchPet = false

local petDropdown = pets:AddDropdown("Select Pet / Crystal", function(text)
    selectedPet = text
end)

-- PET / CRYSTAL LIST
petDropdown:Add("Secret Chaos Sorcerer")
petDropdown:Add("Dark Revelations Titan")
petDropdown:Add("Secret Blades Crystal")
petDropdown:Add("Ultra Shockwave Crystal")
petDropdown:Add("Secret Void Crystal")
petDropdown:Add("Jungle Crystal")
petDropdown:Add("Galaxy Oracle Crystal")
petDropdown:Add("Muscle Elite Crystal")
petDropdown:Add("Legends Crystal")
petDropdown:Add("Inferno Crystal")
petDropdown:Add("Mythical Crystal")
petDropdown:Add("Frost Crystal")
petDropdown:Add("Green Crystal")
petDropdown:Add("Blue Crystal")

local function getPetsFolder()
    return LocalPlayer:FindFirstChild("petsFolder") 
        or LocalPlayer:FindFirstChild("pets") 
        or LocalPlayer:FindFirstChild("Pets")
end

-- AUTO HATCH SWITCH
pets:AddSwitch("⚡ Instant Auto Hatch Selected", function(state)
    _G.AutoHatchPet = state
 
    if state then
        task.spawn(function()
            local petShopFolder = replicatedStorage:FindFirstChild("PetShopFolder")
            local petShopRemote = replicatedStorage:FindFirstChild("PetShopRemote")
            local rEvents = replicatedStorage:FindFirstChild("rEvents")
            local openCrystalRemote = rEvents and rEvents:FindFirstChild("openCrystalRemote")
            local sellRemote = rEvents and rEvents:FindFirstChild("sellPetEvent")

            while _G.AutoHatchPet do
                -- 1. Check if the target pet is already in inventory
                local pFolder = getPetsFolder()
                local petFound = false

                if pFolder then
                    for _, pet in ipairs(pFolder:GetChildren()) do
                        if string.find(string.lower(pet.Name), string.lower(selectedPet)) then
                            petFound = true
                            break
                        end
                    end
                end

                if petFound then
                    pcall(function()
                        game:GetService("StarterGui"):SetCore("SendNotification", {
                            Title = "🎉 PET UNLOCKED!",
                            Text = selectedPet .. " obtained successfully!",
                            Duration = 8
                        })
                    end)
                    _G.AutoHatchPet = false
                    break
                end

                -- 2. Auto-trash non-target pets so the bag never fills up
                if sellRemote and pFolder then
                    for _, pet in ipairs(pFolder:GetChildren()) do
                        if not string.find(string.lower(pet.Name), string.lower(selectedPet)) then
                            pcall(function()
                                sellRemote:FireServer("sellPet", pet)
                                sellRemote:FireServer("sellPet", pet.Name)
                            end)
                        end
                    end
                end

                -- 3. Parallel Non-Blocking Burst Invocations
                for _ = 1, 3 do
                    task.spawn(function()
                        pcall(function()
                            if petShopFolder and petShopRemote then
                                local targetInstance = petShopFolder:FindFirstChild(selectedPet)
                                if targetInstance then
                                    petShopRemote:InvokeServer(targetInstance)
                                else
                                    petShopRemote:InvokeServer(selectedPet)
                                end
                            elseif petShopRemote then
                                petShopRemote:InvokeServer(selectedPet)
                            elseif openCrystalRemote then
                                openCrystalRemote:InvokeServer("openCrystal", selectedPet)
                            end
                        end)
                    end)
                end

                task.wait(0.04)
            end
        end)
    end
end)

pets:AddLabel("Auto Sell")

pets:AddSwitch("Auto Sell Corrupted Elements Hydra", function(state)
    getgenv().AutoSellHydra = state
    task.spawn(function()
        local remote = replicatedStorage:WaitForChild("rEvents", 5):WaitForChild("sellPetEvent", 5)
        while getgenv().AutoSellHydra do
            if remote then
                remote:FireServer("sellPet", "Corrupted Elements Hydra")
            end
            task.wait(0.1) 
        end
    end)
end)

pets:AddSwitch("Auto Sell Dual Destiny Shadow Dragon", function(state)
    getgenv().AutoSellDragon = state
    task.spawn(function()
        local remote = replicatedStorage:WaitForChild("rEvents", 5):WaitForChild("sellPetEvent", 5)
        while getgenv().AutoSellDragon do
            if remote then
                remote:FireServer("sellPet", "Dual Destiny Shadow Dragon")
            end
            task.wait(0.1) 
        end
    end)
end)

pets:AddLabel("Auto Evolved")

local autoEvolveEnabled = false
pets:AddSwitch("Auto Evolve All Pets", function(state)
    autoEvolveEnabled = state
    if autoEvolveEnabled then
        task.spawn(function()
            local autoEvolve = replicatedStorage:WaitForChild("rEvents", 5):WaitForChild("autoEvolveRemote", 5)
            while autoEvolveEnabled do
                if autoEvolve then
                    pcall(function()
                        autoEvolve:InvokeServer()
                    end)
                end
                task.wait(0.1)
            end
        end)
    end
end)

local _Teleport = window:AddTab('Teleport')

local selectedLocationCFrame = nil
local locations = {
    ['Spawn']                 = CFrame.new(0, 0, 0),
    ['Tiny Island']           = CFrame.new(-39.0918, 10.0, 1886.1307),
    ['Frost Island']          = CFrame.new(-2623.0222, 10.0, -409.0733),
    ['Mythical Island']       = CFrame.new(2250.7780, 10.0, 1073.2266),
    ['Infernal Island']       = CFrame.new(-6758.9638, 10.0, -1284.9187),
    ['Legend Island']         = CFrame.new(4603.2817, 995.0, -3897.8657),
    ['Muscle King']           = CFrame.new(-8625.9287, 20.0, -5730.4721),
    ['Ancient Jungle Island'] = CFrame.new(-8642.2529, 10.0, 2380.5065)
}

local _SelectTeleport = _Teleport:AddDropdown('Select Teleport', function(choice)
    selectedLocationCFrame = locations[choice]
end)

for locName, _ in pairs(locations) do
    _SelectTeleport:Add(locName)
end

_Teleport:AddButton('Teleport Now', function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") and selectedLocationCFrame then
        character.HumanoidRootPart.Velocity = Vector3.zero
        character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        character:PivotTo(selectedLocationCFrame)
    end
end)

---------------------------------------------------------
-- [SECTION 1: LOCAL PLAYER STATS TAB]
---------------------------------------------------------
if _G.LocalTracker then _G.LocalTracker = nil end
_G.LocalTracker = {
    Config = {
        Stats = {"Strength", "Durability", "Rebirths", "Agility", "Kills", "Brawls", "Good Karma", "Evil Karma", "Gems"},
        Suffixes = {"K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "UDc", "DDc", "TDc", "QaDc", "QiDc", "SxDc", "SpDc", "ODc", "NDc", "Vg"}
    },
    Labels = {},
    StartStats = {},
    CachedObjects = {},
    Connections = {},
    TotalGained = {},
    LastValues = {},
    Rates = {},
    LastUpdates = {},
    StartTime = os.time(),
    Utils = {}
}

_G.LocalTracker.Utils.updateLabelText = function(name, content)
    local label = _G.LocalTracker.Labels[name]
    if not label then return end
    local ok = pcall(function() label.Text = content end)
    if not ok then ok = pcall(function() label:SetText(content) end) end
    if not ok then pcall(function() label:UpdateLabel(content) end) end
end

_G.LocalTracker.Utils.formatNumber = function(value)
    if not value or typeof(value) ~= "number" then return "0" end
    local absVal = math.abs(value)
    if absVal < 1000 then 
        return tostring(value < 0 and -math.floor(absVal) or math.floor(absVal)) 
    end
    local index = math.floor(math.log10(absVal) / 3)
    if index > #_G.LocalTracker.Config.Suffixes then index = #_G.LocalTracker.Config.Suffixes end
    return string.format("%.1f", value / (10 ^ (index * 3))):gsub("%.0$", "") .. (_G.LocalTracker.Config.Suffixes[index] or "")
end

_G.LocalTracker.Utils.scanForStatFast = function(statName)
    if not LocalPlayer then return nil end
    local lowerTarget = string.lower(statName)
    local cleanTarget = lowerTarget:gsub("%s+", ""):gsub("_+", "")
    
    local function matches(name)
        local lName = string.lower(name)
        local cName = lName:gsub("%s+", ""):gsub("_+", "")
        return string.find(lName, lowerTarget) or cName == cleanTarget or string.find(cName, cleanTarget)
    end
    
    local classicHubs = {"leaderstats", "leaderstats2", "Stats", "PlayerData", "Data", "Currency"}
    for i = 1, #classicHubs do
        local folder = LocalPlayer:FindFirstChild(classicHubs[i])
        if folder then
            local children = folder:GetChildren()
            for j = 1, #children do
                local child = children[j]
                if matches(child.Name) and string.find(child.ClassName, "Value") then
                    return child
                end
            end
        end
    end

    local rootChildren = LocalPlayer:GetChildren()
    for i = 1, #rootChildren do
        local child = rootChildren[i]
        if matches(child.Name) and string.find(child.ClassName, "Value") then
            return child
        elseif child:IsA("Folder") or child:IsA("Configuration") then
            local subChildren = child:GetChildren()
            for j = 1, #subChildren do
                local subChild = subChildren[j]
                if matches(subChild.Name) and string.find(subChild.ClassName, "Value") then
                    return subChild
                end
            end
        end
    end
    
    return nil
end

_G.LocalTracker.Utils.computeAndRenderStat = function(name, currentVal)
    local currentTime = os.time()
    local startVal = _G.LocalTracker.StartStats[name]
    
    if not startVal then
        _G.LocalTracker.StartStats[name] = currentVal
        startVal = currentVal
        _G.LocalTracker.TotalGained[name] = 0
        _G.LocalTracker.LastValues[name] = currentVal
        _G.LocalTracker.LastUpdates[name] = currentTime
        _G.LocalTracker.Rates[name] = 0
    end
    
    _G.LocalTracker.TotalGained[name] = _G.LocalTracker.TotalGained[name] or 0
    _G.LocalTracker.LastValues[name] = _G.LocalTracker.LastValues[name] or currentVal
    _G.LocalTracker.LastUpdates[name] = _G.LocalTracker.LastUpdates[name] or currentTime
    _G.LocalTracker.Rates[name] = _G.LocalTracker.Rates[name] or 0

    if currentVal < _G.LocalTracker.LastValues[name] then
        local progressBeforeReset = math.max(_G.LocalTracker.LastValues[name] - startVal, 0)
        _G.LocalTracker.TotalGained[name] = _G.LocalTracker.TotalGained[name] + progressBeforeReset
        _G.LocalTracker.StartStats[name] = currentVal
        startVal = currentVal
    end

    local diff = currentVal - _G.LocalTracker.LastValues[name]
    if diff > 0 then
        local timePassed = math.max(currentTime - _G.LocalTracker.LastUpdates[name], 1)
        _G.LocalTracker.Rates[name] = diff / timePassed
        _G.LocalTracker.LastUpdates[name] = currentTime
    end
    
    _G.LocalTracker.LastValues[name] = currentVal

    local currentGain = math.max(currentVal - startVal, 0)
    local gained = _G.LocalTracker.TotalGained[name] + currentGain
    local formattedCurrent = _G.LocalTracker.Utils.formatNumber(currentVal)
    local activeRate = _G.LocalTracker.Rates[name] or 0
    
    if gained > 0 and activeRate > 0 then
        _G.LocalTracker.Utils.updateLabelText(name, string.format(
            "%s: %s (+%s) | M: %s | H: %s | D: %s | W: %s | MO: %s",
            name, formattedCurrent, _G.LocalTracker.Utils.formatNumber(gained),
            _G.LocalTracker.Utils.formatNumber(activeRate * 60), 
            _G.LocalTracker.Utils.formatNumber(activeRate * 3600), 
            _G.LocalTracker.Utils.formatNumber(activeRate * 86400), 
            _G.LocalTracker.Utils.formatNumber(activeRate * 604800),
            _G.LocalTracker.Utils.formatNumber(activeRate * 2592000)
        ))
    else
        _G.LocalTracker.Utils.updateLabelText(name, string.format("%s: %s (+0) | M: 0 | H: 0 | D: 0 | W: 0 | MO: 0", name, formattedCurrent))
    end
end

_G.LocalTracker.Utils.bindObjectSignals = function(name, obj)
    _G.LocalTracker.CachedObjects[name] = obj
    _G.LocalTracker.StartStats[name] = tonumber(obj.Value) or 0
    _G.LocalTracker.LastValues[name] = tonumber(obj.Value) or 0
    _G.LocalTracker.TotalGained[name] = _G.LocalTracker.TotalGained[name] or 0
    _G.LocalTracker.LastUpdates[name] = os.time()
    _G.LocalTracker.Rates[name] = 0
    
    if _G.LocalTracker.Connections[name] then
        pcall(function() _G.LocalTracker.Connections[name]:Disconnect() end)
    end
    
    _G.LocalTracker.Connections[name] = obj.Changed:Connect(function(newVal)
        _G.LocalTracker.Utils.computeAndRenderStat(name, tonumber(newVal) or 0)
    end)
    
    _G.LocalTracker.Utils.computeAndRenderStat(name, _G.LocalTracker.StartStats[name])
end

_G.LocalTracker.TrackerTab = nil
pcall(function() _G.LocalTracker.TrackerTab = window:AddTab("Stats 📊") end)

_G.LocalTracker.ClockLabel = _G.LocalTracker.TrackerTab and _G.LocalTracker.TrackerTab:AddLabel("Session Time: 00:00:00") or nil

for i = 1, #_G.LocalTracker.Config.Stats do
    local name = _G.LocalTracker.Config.Stats[i]
    _G.LocalTracker.StartStats[name] = 0
    
    local foundObj = _G.LocalTracker.Utils.scanForStatFast(name)
    local currentText = name .. ": 0 (+0) | M: 0 | H: 0 | D: 0 | W: 0 | MO: 0"
    
    if foundObj then
        local initialVal = tonumber(foundObj.Value) or 0
        _G.LocalTracker.StartStats[name] = initialVal
        _G.LocalTracker.LastValues[name] = initialVal
        currentText = string.format("%s: %s (+0) | M: 0 | H: 0 | D: 0 | W: 0 | MO: 0", name, _G.LocalTracker.Utils.formatNumber(initialVal))
    end
    
    if _G.LocalTracker.TrackerTab then
        pcall(function() _G.LocalTracker.Labels[name] = _G.LocalTracker.TrackerTab:AddLabel(currentText) end)
    end
    
    if foundObj then
        _G.LocalTracker.Utils.bindObjectSignals(name, foundObj)
    end
end

task.spawn(function()
    while task.wait(1) do
        local elapsedSeconds = math.max(os.time() - _G.LocalTracker.StartTime, 1)
        local currentTime = os.time()
        
        local hours = math.floor(elapsedSeconds / 3600)
        local minutes = math.floor((elapsedSeconds % 3600) / 60)
        local seconds = elapsedSeconds % 60
        if _G.LocalTracker.ClockLabel then
            pcall(function() _G.LocalTracker.ClockLabel.Text = string.format("Session Time: %02d:%02d:%02d", hours, minutes, seconds) end)
        end
        
        for i = 1, #_G.LocalTracker.Config.Stats do
            local name = _G.LocalTracker.Config.Stats[i]
            local obj = _G.LocalTracker.CachedObjects[name]
            if obj then
                local lastActive = _G.LocalTracker.LastUpdates[name] or currentTime
                if currentTime - lastActive > 60 then
                    _G.LocalTracker.Rates[name] = math.max((_G.LocalTracker.Rates[name] or 0) * 0.99, 0)
                    if _G.LocalTracker.Rates[name] < 0.001 then _G.LocalTracker.Rates[name] = 0 end
                    _G.LocalTracker.Utils.computeAndRenderStat(name, tonumber(obj.Value) or 0)
                end
            end
        end
    end
end)

---------------------------------------------------------
-- [SECTION 2: SPY PLAYER INTERFACE FIELDS]
---------------------------------------------------------
do
    if _G.TrackerCore then _G.TrackerCore = nil end
    _G.TrackerCore = {
        Config = {
            Stats = {"Strength", "Durability", "Rebirths", "Agility", "Kills", "Brawls", "Good Karma", "Evil Karma", "Gems"},
            Suffixes = {"K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc", "UDc", "DDc", "TDc", "QaDc", "QiDc", "SxDc", "SpDc", "ODc", "NDc", "Vg"}
        },
        SpyState = { target = nil, startTime = os.time(), labels = {}, start = {}, total = {}, last = {}, rate = {}, ticks = {} },
        Utils = {}
    }

    _G.TrackerCore.Utils.updateLabelText = function(label, content)
        if not label then return end
        local ok = pcall(function() label.Text = content end)
        if not ok then ok = pcall(function() label:SetText(content) end) end
        if not ok then pcall(function() label:UpdateLabel(content) end) end
    end

    _G.TrackerCore.Utils.formatNumber = function(value)
        if not value or typeof(value) ~= "number" then return "0" end
        local absVal = math.abs(value)
        if absVal < 1000 then 
            return tostring(value < 0 and -math.floor(absVal) or math.floor(absVal)) 
        end
        local index = math.floor(math.log10(absVal) / 3)
        if index > #_G.TrackerCore.Config.Suffixes then index = #_G.TrackerCore.Config.Suffixes end
        return string.format("%.1f", value / (10 ^ (index * 3))):gsub("%.0$", "") .. (_G.TrackerCore.Config.Suffixes[index] or "")
    end

    _G.TrackerCore.Utils.locatePlayerStatObject = function(playerInstance, statName)
        if not playerInstance then return nil end
        local lowerTarget = string.lower(statName)
        local cleanTarget = lowerTarget:gsub("%s+", ""):gsub("_+", "")
        
        local function matches(name)
            local lName = string.lower(name)
            local cName = lName:gsub("%s+", ""):gsub("_+", "")
            return string.find(lName, lowerTarget) or cName == cleanTarget or string.find(cName, cleanTarget)
        end
        
        local classicHubs = {"leaderstats", "leaderstats2", "Stats", "PlayerData", "Data", "Currency"}
        for i = 1, #classicHubs do
            local folder = playerInstance:FindFirstChild(classicHubs[i])
            if folder then
                local children = folder:GetChildren()
                for j = 1, #children do
                    local child = children[j]
                    if matches(child.Name) and string.find(child.ClassName, "Value") then
                        return child
                    end
                end
            end
        end

        local rootChildren = playerInstance:GetChildren()
        for i = 1, #rootChildren do
            local child = rootChildren[i]
            if matches(child.Name) and string.find(child.ClassName, "Value") then
                return child
            elseif child:IsA("Folder") or child:IsA("Configuration") then
                local subChildren = child:GetChildren()
                for j = 1, #subChildren do
                    local subChild = subChildren[j]
                    if matches(subChild.Name) and string.find(subChild.ClassName, "Value") then
                        return subChild
                    end
                end
            end
        end
        return nil
    end

    _G.TrackerCore.SpyTab = nil
    pcall(function() _G.TrackerCore.SpyTab = window:AddTab("Spy Stats Player 👁️") end)

    _G.TrackerCore.PlayerDropdown = _G.TrackerCore.SpyTab and _G.TrackerCore.SpyTab:AddDropdown("Select Player...", function(selectedDisplayName)
        local S = _G.TrackerCore.SpyState
        if selectedDisplayName == "None" or selectedDisplayName == "" then
            S.target, S.start, S.total, S.last, S.rate, S.ticks = nil, {}, {}, {}, {}, {}
            return
        end
        
        local found = nil
        for _, p in ipairs(Players:GetPlayers()) do
            if p.DisplayName == selectedDisplayName then
                found = p
                break
            end
        end

        if found then
            S.target, S.startTime, S.start, S.total, S.last, S.rate, S.ticks = found, os.time(), {}, {}, {}, {}, {}
            local curT = os.time()
            for _, name in ipairs(_G.TrackerCore.Config.Stats) do
                local obj = _G.TrackerCore.Utils.locatePlayerStatObject(found, name)
                local val = obj and tonumber(obj.Value) or 0
                S.start[name], S.last[name], S.total[name], S.ticks[name], S.rate[name] = val, val, 0, curT, 0
            end
        else
            S.target = nil
        end
    end) or nil

    local function refreshDropdownOptions()
        if not _G.TrackerCore.PlayerDropdown then return end
        pcall(function() _G.TrackerCore.PlayerDropdown:Clear() end) 
        pcall(function() _G.TrackerCore.PlayerDropdown:Add("None") end)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then 
                pcall(function() _G.TrackerCore.PlayerDropdown:Add(p.DisplayName) end) 
            end
        end
    end

    refreshDropdownOptions()
    Players.PlayerAdded:Connect(refreshDropdownOptions)
    Players.PlayerRemoving:Connect(function(p)
        if _G.TrackerCore.SpyState.target == p then
            _G.TrackerCore.SpyState.target, _G.TrackerCore.SpyState.start, _G.TrackerCore.SpyState.total, _G.TrackerCore.SpyState.last, _G.TrackerCore.SpyState.rate, _G.TrackerCore.SpyState.ticks = nil, {}, {}, {}, {}, {}
        end
        refreshDropdownOptions()
    end)

    if _G.TrackerCore.SpyTab then
        for _, name in ipairs(_G.TrackerCore.Config.Stats) do
            pcall(function() _G.TrackerCore.SpyState.labels[name] = _G.TrackerCore.SpyTab:AddLabel(name .. ": N/A (+0) | M: 0 | H: 0 | D: 0 | W: 0 | MO: 0") end)
        end
    end

    task.spawn(function()
        while task.wait(0.5) do
            local currentTime = os.time()
            local S = _G.TrackerCore.SpyState
            
            if S.target and S.target.Parent == Players then
                for _, name in ipairs(_G.TrackerCore.Config.Stats) do
                    local statObj = _G.TrackerCore.Utils.locatePlayerStatObject(S.target, name)
                    if statObj and S.labels[name] then
                        local currentVal = tonumber(statObj.Value) or 0
                        if not S.start[name] then
                            S.start[name], S.last[name], S.total[name], S.ticks[name], S.rate[name] = currentVal, currentVal, 0, currentTime, 0
                        end

                        if currentVal < S.last[name] then
                            S.total[name] = S.total[name] + math.max(S.last[name] - S.start[name], 0)
                            S.start[name] = currentVal
                        end

                        local diff = currentVal - S.last[name]
                        if diff > 0 then
                            S.rate[name] = diff / math.max(currentTime - S.ticks[name], 1)
                            S.ticks[name] = currentTime
                        else
                            if currentTime - (S.ticks[name] or currentTime) > 60 then
                                S.rate[name] = math.max((S.rate[name] or 0) * 0.99, 0)
                                if S.rate[name] < 0.001 then S.rate[name] = 0 end
                            end
                        end
                        S.last[name] = currentVal

                        local gained = S.total[name] + math.max(currentVal - S.start[name], 0)
                        local r = S.rate[name] or 0
                        
                        if gained > 0 then
                            if r <= 0 then r = gained / math.max(currentTime - S.startTime, 1) end
                            _G.TrackerCore.Utils.updateLabelText(S.labels[name], string.format(
                                "%s: %s (+%s) | M: %s | H: %s | D: %s | W: %s | MO: %s",
                                name, _G.TrackerCore.Utils.formatNumber(currentVal), _G.TrackerCore.Utils.formatNumber(gained),
                                _G.TrackerCore.Utils.formatNumber(r * 60), 
                                _G.TrackerCore.Utils.formatNumber(r * 3600), 
                                _G.TrackerCore.Utils.formatNumber(r * 86400), 
                                _G.TrackerCore.Utils.formatNumber(r * 604800), 
                                _G.TrackerCore.Utils.formatNumber(r * 2592000)
                            ))
                        else
                            _G.TrackerCore.Utils.updateLabelText(S.labels[name], string.format("%s: %s (+0) | M: 0 | H: 0 | D: 0 | W: 0 | MO: 0", name, _G.TrackerCore.Utils.formatNumber(currentVal)))
                        end
                    end
                end
            else
                for _, name in ipairs(_G.TrackerCore.Config.Stats) do
                    if S.labels[name] then
                        _G.TrackerCore.Utils.updateLabelText(S.labels[name], name .. ": N/A (+0) | M: 0 | H: 0 | D: 0 | W: 0 | MO: 0")
                    end
                end
            end
        end
    end)
end

-- ============================================================================
-- AUTO KILL TAB
-- ============================================================================
local whitelistFriendsActive = false 
local TargetInput = ""         
local WhitelistedPlayers = {}
local MultiInputText = ""

local WhitelistDisplayLabel = nil
local TargetKillListActive = false
local TargetKillPlayers = {}
local SpyTargetKillListActive = false
local KillListDisplayLabel = nil

local LoopKillAllActive = false
local FastLoopKillAllV2Active = false
local LoopKilling = false
local Spectating = false

local function GetPlayerByInput(input)
    if not input or input == "" then return nil end
    local cleanInput = input:lower():match("^%s*(.-)%s*$")
    if cleanInput == "" then return nil end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #cleanInput) == cleanInput or p.DisplayName:lower():sub(1, #cleanInput) == cleanInput then
            return p
        end
    end
    return nil
end

local function UpdateWhitelistLabel()
    if not WhitelistDisplayLabel then return end
    
    local displayNames = {}
    for userId, _ in pairs(WhitelistedPlayers) do
        local p = Players:GetPlayerByUserId(userId)
        if p then
            table.insert(displayNames, p.DisplayName)
        else
            table.insert(displayNames, tostring(userId))
        end
    end
    
    local finalString = "Whitelist: (Empty)"
    if #displayNames > 0 then
        finalString = "Whitelist: " .. table.concat(displayNames, ", ")
    end
    
    pcall(function()
        if type(WhitelistDisplayLabel) == "table" then
            if WhitelistDisplayLabel.Update then
                WhitelistDisplayLabel:Update(finalString)
            elseif WhitelistDisplayLabel.SetText then
                WhitelistDisplayLabel:SetText(finalString)
            elseif WhitelistDisplayLabel.Text then
                WhitelistDisplayLabel.Text = finalString
            end
        elseif typeof(WhitelistDisplayLabel) == "Instance" and WhitelistDisplayLabel:IsA("TextLabel") then
            WhitelistDisplayLabel.Text = finalString
        end
    end)
end

local function UpdateKillListLabel()
    if not KillListDisplayLabel then return end
    
    local displayNames = {}
    for userId, _ in pairs(TargetKillPlayers) do
        local p = Players:GetPlayerByUserId(userId)
        if p then
            table.insert(displayNames, p.DisplayName)
        else
            table.insert(displayNames, tostring(userId))
        end
    end
    
    local finalString = "Kill List: (Empty)"
    if #displayNames > 0 then
        finalString = "Kill List: " .. table.concat(displayNames, ", ")
    end
    
    pcall(function()
        if type(KillListDisplayLabel) == "table" then
            if KillListDisplayLabel.Update then
                KillListDisplayLabel:Update(finalString)
            elseif KillListDisplayLabel.SetText then
                KillListDisplayLabel:SetText(finalString)
            elseif KillListDisplayLabel.Text then
                KillListDisplayLabel.Text = finalString
            end
        elseif typeof(KillListDisplayLabel) == "Instance" and KillListDisplayLabel:IsA("TextLabel") then
            KillListDisplayLabel.Text = finalString
        end
    end)
end

local function isWhitelisted(otherPlayer)
    if not otherPlayer then return false end
    if WhitelistedPlayers[otherPlayer.UserId] then return true end
    if whitelistFriendsActive then
        local success, result = pcall(function()
            return LocalPlayer:IsFriendsWith(otherPlayer.UserId)
        end)
        if success and result then return true end
    end
    return false
end

local Tab = window:AddTab("☠️ Auto Kill")

Tab:AddSwitch("Loop TP Auto Kill All", function(Value)
    LoopKillAllActive = Value
    if Value then
        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            while LoopKillAllActive do
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")

                if myChar and myRoot and myHumanoid then
                    local targetList = Players:GetPlayers()
                    for _, targetPlayer in ipairs(targetList) do
                        if not LoopKillAllActive then break end
                        if targetPlayer ~= LocalPlayer and targetPlayer.Character and not isWhitelisted(targetPlayer) then
                            local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local timeSpent = 0
                            
                            while LoopKillAllActive and tRoot and targetPlayer.Parent == Players and timeSpent < 0.5 do
                                myChar = LocalPlayer.Character
                                myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
                                
                                if not (myChar and myRoot and myHumanoid) then break end
                                myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
                                
                                local tool = myChar:FindFirstChild("Punch")
                                if not tool then
                                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                                    local bpTool = backpack and backpack:FindFirstChild("Punch")
                                    if bpTool then
                                        myHumanoid:EquipTool(bpTool)
                                        tool = bpTool
                                    end
                                end
                                
                                if tool then tool:Activate() end
                                
                                local remotes = ReplicatedStorage:FindFirstChild("RemotesEvent")
                                if remotes and remotes:FindFirstChild("SizeChanged") then
                                    remotes.SizeChanged:FireServer(1)
                                end
                                
                                task.wait(0.05)
                                timeSpent = timeSpent + 0.05 
                            end
                        end
                    end
                end
                task.wait(0.1) 
            end
        end)
    end
end)

Tab:AddSwitch("Loop TP Auto Kill All V2", function(Value)
    FastLoopKillAllV2Active = Value
    if Value then
        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            while FastLoopKillAllV2Active do
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")

                if myChar and myRoot and myHumanoid then
                    local targetList = Players:GetPlayers()
                    for _, targetPlayer in ipairs(targetList) do
                        if not FastLoopKillAllV2Active then break end
                        if targetPlayer ~= LocalPlayer and targetPlayer.Character and not isWhitelisted(targetPlayer) then
                            local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local tHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
                            
                            if tRoot and tHumanoid and tHumanoid.Health > 0 then
                                for _ = 1, 3 do
                                    if not FastLoopKillAllV2Active or tHumanoid.Health <= 0 then break end
                                    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
                                    
                                    local tool = myChar:FindFirstChild("Punch")
                                    if not tool then
                                        local backpack = LocalPlayer:FindFirstChild("Backpack")
                                        local bpTool = backpack and backpack:FindFirstChild("Punch")
                                        if bpTool then
                                            myHumanoid:EquipTool(bpTool)
                                            tool = bpTool
                                        end
                                    end
                                    
                                    if tool then tool:Activate() end
                                    
                                    local remotes = ReplicatedStorage:FindFirstChild("RemotesEvent")
                                    if remotes and remotes:FindFirstChild("SizeChanged") then
                                        pcall(function() remotes.SizeChanged:FireServer(1) end)
                                    end
                                    task.wait(0.1)
                                end
                            end
                        end
                    end
                end
                task.wait()
            end
        end)
    end
end)

local singleTargetDropdown = Tab:AddDropdown("Target Player", function(text)
    TargetInput = text
end)

local function RefreshDropdowns()
    pcall(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                singleTargetDropdown:Add(p.DisplayName)
            end
        end
    end)
end

RefreshDropdowns()
Players.PlayerAdded:Connect(function(p)
    task.wait(1)
    if p ~= LocalPlayer then singleTargetDropdown:Add(p.DisplayName) end
end)

Tab:AddSwitch("TP Kill Target", function(state)
    LoopKilling = state
    if LoopKilling then
        task.spawn(function()
            while LoopKilling do
                local target = GetPlayerByInput(TargetInput)
                if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and 
                    LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    
                    LocalPlayer.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    local tool = LocalPlayer.Character:FindFirstChild("Punch")
                    if not tool then
                        local backpackTool = LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Punch")
                        if backpackTool then
                            LocalPlayer.Character.Humanoid:EquipTool(backpackTool)
                            tool = backpackTool
                        end
                    end
                    if tool then tool:Activate() end
                end
                task.wait(0.01) 
            end
        end)
    end
end)

Tab:AddSwitch("Spy Target", function(state)
    Spectating = state
    local camera = workspace.CurrentCamera
    if state then
        task.spawn(function()
            while Spectating do
                local target = GetPlayerByInput(TargetInput)
                if target and target.Character and target.Character:FindFirstChild("Humanoid") then
                    camera.CameraSubject = target.Character.Humanoid
                else
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        camera.CameraSubject = LocalPlayer.Character.Humanoid
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end)

Tab:AddLabel("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
KillListDisplayLabel = Tab:AddLabel("Kill List: (Empty)")

local targetKillDropdown = Tab:AddDropdown("Add To Target Kill List", function(text)
    local target = GetPlayerByInput(text)
    if target then
        TargetKillPlayers[target.UserId] = true
        UpdateKillListLabel()
    end
end)

task.spawn(function()
    while true do
        task.wait(3)
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    targetKillDropdown:Add(p.DisplayName)
                end
            end
        end)
    end
end)

Tab:AddButton("Clear All Target Kill List", function()
    TargetKillPlayers = {}
    UpdateKillListLabel()
end)

Tab:AddSwitch("TP Kill Target List", function(Value)
    TargetKillListActive = Value
    if Value then
        task.spawn(function()
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            while TargetKillListActive do
                local myChar = LocalPlayer.Character
                local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")

                if myChar and myRoot and myHumanoid then
                    for userId, _ in pairs(TargetKillPlayers) do
                        if not TargetKillListActive then break end
                        local targetPlayer = Players:GetPlayerByUserId(userId)
                        
                        if targetPlayer and targetPlayer ~= LocalPlayer and targetPlayer.Character and not isWhitelisted(targetPlayer) then
                            local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local tHumanoid = targetPlayer.Character:FindFirstChild("Humanoid")
                            local timeSpent = 0
                            
                            while TargetKillListActive and tRoot and tHumanoid and tHumanoid.Health > 0 and targetPlayer.Parent == Players and timeSpent < 0.5 do
                                myChar = LocalPlayer.Character
                                myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
                                myHumanoid = myChar and myChar:FindFirstChildOfClass("Humanoid")
                                
                                if not (myChar and myRoot and myHumanoid) then break end
                                myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 3)
                                
                                local tool = myChar:FindFirstChild("Punch")
                                if not tool then
                                    local backpack = LocalPlayer:FindFirstChild("Backpack")
                                    local bpTool = backpack and backpack:FindFirstChild("Punch")
                                    if bpTool then
                                        myHumanoid:EquipTool(bpTool)
                                        tool = bpTool
                                    end
                                end
                                
                                if tool then tool:Activate() end
                                local remotes = ReplicatedStorage:FindFirstChild("RemotesEvent")
                                if remotes and remotes:FindFirstChild("SizeChanged") then
                                    pcall(function() remotes.SizeChanged:FireServer(1) end)
                                end
                                
                                task.wait(0.05)
                                timeSpent = timeSpent + 0.05
                            end
                        end
                    end
                end
                task.wait(0.1)
            end
        end)
    end
end)

Tab:AddSwitch("Spy Target Kill List", function(state)
    SpyTargetKillListActive = state
    local camera = workspace.CurrentCamera
    
    if state then
        task.spawn(function()
            while SpyTargetKillListActive do
                local foundTarget = false
                for userId, _ in pairs(TargetKillPlayers) do
                    if not SpyTargetKillListActive then break end
                    local targetPlayer = Players:GetPlayerByUserId(userId)
                    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Humanoid") and targetPlayer.Character.Humanoid.Health > 0 then
                        camera.CameraSubject = targetPlayer.Character.Humanoid
                        foundTarget = true
                        task.wait(3) 
                    end
                end
                
                if not foundTarget then
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                        camera.CameraSubject = LocalPlayer.Character.Humanoid
                    end
                    task.wait(1)
                end
            end
        end)
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            camera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end)

local AutoPunchActive = false
Tab:AddSwitch("Auto Punch", function(Value)
    AutoPunchActive = Value
    if Value then
        task.spawn(function()
            while AutoPunchActive do
                local char = LocalPlayer.Character
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local tool = char and char:FindFirstChild("Punch")
                
                if not tool and backpack then
                    local bpTool = backpack:FindFirstChild("Punch")
                    if bpTool then
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then hum:EquipTool(bpTool) end
                    end
                end
                
                if char and char:FindFirstChild("Punch") then
                    char.Punch:Activate()
                end
                task.wait(0.1) 
            end
        end)
    end
end)

_G.HeadSize = 25
_G.HitboxEnabled = false 

Tab:AddSwitch("Kill Aura Range", function(Value)
    _G.HitboxEnabled = Value
    if not Value then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                v.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1) 
                v.Character.HumanoidRootPart.Transparency = 1
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if _G.HitboxEnabled then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    local hrp = v.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
                    hrp.Transparency = 0.7 
                    hrp.BrickColor = BrickColor.new("Really red")
                    hrp.Material = Enum.Material.Neon
                    hrp.CanCollide = false
                end)
            end
        end
    end
end)

local whitelistSwitch = Tab:AddSwitch("Whitelist Friends", function(bool)
    whitelistFriendsActive = bool
end)
if whitelistSwitch and whitelistSwitch.Set then whitelistSwitch:Set(false) end

Tab:AddLabel("~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
WhitelistDisplayLabel = Tab:AddLabel("Whitelist: (Empty)")

Tab:AddTextBox("Type Name Player To Whitelist", function(text)
    MultiInputText = text
end, {
    ["placeholder"] = "e.g. builderman, roblox, player3",
    ["clear"] = false
})

Tab:AddButton("Add Whitelist Players", function()
    if MultiInputText == "" then return end
    for nameSegment in string.gmatch(MultiInputText, "([^,]+)") do
        local target = GetPlayerByInput(nameSegment)
        if target then
            WhitelistedPlayers[target.UserId] = true
        end
    end
    UpdateWhitelistLabel()
end)

Tab:AddButton("Clear All Whitelist", function()
    WhitelistedPlayers = {}
    UpdateWhitelistLabel()
end)

-- ============================================================================
-- MISC TAB
-- ============================================================================
local Tab = window:AddTab("⚙️ Misc")
local misc = Tab:AddFolder("Misc")

local function serverHop()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local placeId = game.PlaceId
    local serversUrl = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(serversUrl))
    end)
    
    if success and result and result.data then
        for _, server in ipairs(result.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                end)
                return
            end
        end
    else
        pcall(function()
            TeleportService:Teleport(placeId, LocalPlayer)
        end)
    end
end

misc:AddButton("Server Hop", function() serverHop() end)

local function rejoinServer()
    local TeleportService = game:GetService("TeleportService")
    local placeId = game.PlaceId
    local jobId = game.JobId

    if #Players:GetPlayers() <= 1 then
        pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end)
    else
        pcall(function() TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer) end)
    end
end

misc:AddButton("Rejoin Server", function() rejoinServer() end)
misc:AddButton("Emotes", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))() end)
misc:AddButton("Jerk Tool (R15)", function() loadstring(game:HttpGet("https://pastefy.app/YZoglOyJ/raw"))() end)
misc:AddButton("Fly GUI V3", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))() end)

local ClickTPEnabled = false
local Mouse = LocalPlayer:GetMouse()

misc:AddSwitch("Click Teleport", function(Value) ClickTPEnabled = Value end)
Mouse.Button1Down:Connect(function()
    if ClickTPEnabled then
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0, 3, 0)) end
    end
end)

misc:AddLabel("~~~~~~~~~~~~~")

local JumpModEnabled = false
local TargetPower = 50
local TargetHeight = 7.2

misc:AddSwitch("Jump~Power", function(State)
    JumpModEnabled = State
    if not State then
        pcall(function()
            local Character = LocalPlayer.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    Humanoid.UseJumpPower = true
                    Humanoid.JumpPower = 50
                    Humanoid.JumpHeight = 7.2
                end
            end
        end)
    end
end)

misc:AddSlider("Jump Power Value", function(Value)
    TargetPower = Value
    TargetHeight = (Value * 0.144)
end, { min = 50, max = 1000 })

RunService.RenderStepped:Connect(function()
    if JumpModEnabled then
        pcall(function()
            local Character = LocalPlayer.Character
            if Character then
                local Humanoid = Character:FindFirstChildOfClass("Humanoid")
                if Humanoid then
                    Humanoid.UseJumpPower = true
                    Humanoid.JumpPower = TargetPower
                    Humanoid.JumpHeight = TargetHeight
                end
            end
        end)
    end
end)

local noclipEnabled = false
RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

misc:AddSwitch("Noclip", function(state)
    noclipEnabled = state
    if not noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end)

local InfiniteJumpEnabled = false
misc:AddSwitch("Infinite Jump", function(Value) InfiniteJumpEnabled = Value end)

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJumpEnabled then
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

getgenv().LoopSpeedEnabled = false
getgenv().WalkSpeedValue = 16

misc:AddSwitch("Loop WalkSpeed", function(bool) getgenv().LoopSpeedEnabled = bool end)
misc:AddTextBox("Speed Amount", function(text)
    local num = tonumber(text)
    if num then getgenv().WalkSpeedValue = num end
end)

task.spawn(function()
    while task.wait() do
        if getgenv().LoopSpeedEnabled then
            pcall(function()
                local char = LocalPlayer.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = getgenv().WalkSpeedValue
                end
            end)
        end
    end
end)

local miscTab2 = Tab:AddFolder("Misc V2")
local function mk(n, c)
    local g = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
    g.Name, g.ResetOnSpawn, g.DisplayOrder, g.IgnoreGuiInset = n, false, 9999999, true
    local f = Instance.new("Frame", g)
    f.Size, f.BackgroundColor3, f.BorderSizePixel, f.Visible = UDim2.new(1,0,1,0), c, 0, false
    return f
end

local bF, wF = mk("B", Color3.new(0,0,0)), mk("W", Color3.new(1,1,1))
miscTab2:AddSwitch("Black Screen", function(s) bF.Visible = s end)
miscTab2:AddSwitch("White Screen", function(s) wF.Visible = s end)

local fb, orig = false, {game:GetService("Lighting").Ambient, game:GetService("Lighting").OutdoorAmbient, game:GetService("Lighting").Brightness, game:GetService("Lighting").ClockTime, game:GetService("Lighting").GlobalShadows}
task.spawn(function()
    while task.wait(0.5) do
        if fb then game:GetService("Lighting").Ambient, game:GetService("Lighting").OutdoorAmbient, game:GetService("Lighting").Brightness, game:GetService("Lighting").ClockTime, game:GetService("Lighting").GlobalShadows = Color3.new(1,1,1), Color3.new(1,1,1), 2, 14, false end
    end
end)
miscTab2:AddSwitch("Fullbright", function(s)
    fb = s
    if not s then game:GetService("Lighting").Ambient, game:GetService("Lighting").OutdoorAmbient, game:GetService("Lighting").Brightness, game:GetService("Lighting").ClockTime, game:GetService("Lighting").GlobalShadows = unpack(orig) end
end)

local be, ne, he, c = false, false, false, {}
local function esp(p)
    if c[p] or p == LocalPlayer then return end
    local hl = Instance.new("Highlight")
    hl.FillColor, hl.FillTransparency, hl.OutlineColor = Color3.new(1,0,0), 0.5, Color3.new(1,1,1)
    
    local nt = Instance.new("BillboardGui")
    nt.Size, nt.AlwaysOnTop, nt.ExtentsOffset = UDim2.new(0,200,0,50), true, Vector3.new(0,3,0)
    local tx = Instance.new("TextLabel", nt)
    tx.Size, tx.BackgroundTransparency, tx.Text, tx.TextColor3, tx.TextSize, tx.Font, tx.TextStrokeTransparency = UDim2.new(1,0,1,0), 1, p.Name, Color3.new(1,1,1), 14, Enum.Font.SourceSansBold, 0

    local hb = Instance.new("BillboardGui")
    hb.Size, hb.AlwaysOnTop, hb.ExtentsOffset = UDim2.new(0,5,0,45), true, Vector3.new(-2.2,0.5,0)
    local bg = Instance.new("Frame", hb)
    bg.Size, bg.BackgroundColor3, bg.BorderSizePixel = UDim2.new(1,0,1,0), Color3.fromRGB(40,40,40), 0
    local hm = Instance.new("Frame", bg)
    hm.Size, hm.Position, hm.AnchorPoint, hm.BackgroundColor3, hm.BorderSizePixel = UDim2.new(1,0,1,0), UDim2.new(0,0,1,0), Vector2.new(0,1), Color3.fromRGB(0,255,0), 0

    c[p] = {H = hl, N = nt, B = hb, M = hm}

    local function up()
        local ch = p.Character
        local hd, hu = ch and ch:WaitForChild("Head", 5), ch and ch:WaitForChild("Humanoid", 5)
        if ch and hd and hu then
            hl.Parent, hl.Enabled = ch, be
            nt.Adornee, nt.Parent, nt.Enabled = hd, hd, ne
            hb.Adornee, hb.Parent, hb.Enabled = hd, hd, he
            if c[p].Cn then c[p].Cn:Disconnect() end
            c[p].Cn = hu:GetPropertyChangedSignal("Health"):Connect(function()
                local pct = math.clamp(hu.Health / hu.MaxHealth, 0, 1)
                hm.Size = UDim2.new(1, 0, pct, 0)
                hm.BackgroundColor3 = Color3.fromHSV(pct * 0.35, 1, 1)
            end)
        end
    end
    p.CharacterAdded:Connect(function() task.wait(0.5) up() end)
    up()
end

for _, p in ipairs(Players:GetPlayers()) do esp(p) end
Players.PlayerAdded:Connect(esp)
Players.PlayerRemoving:Connect(function(p)
    if c[p] then
        for _, v in pairs(c[p]) do if typeof(v) == "Instance" then v:Destroy() elseif typeof(v) == "RBXScriptConnection" then v:Disconnect() end end
        c[p] = nil
    end
end)

miscTab2:AddSwitch("Box ESP", function(s) be = s for _, d in pairs(c) do if d.H then d.H.Enabled = s end end end)
miscTab2:AddSwitch("Player Name ESP", function(s) ne = s for _, d in pairs(c) do if d.N then d.N.Enabled = s end end end)
miscTab2:AddSwitch("Health Bar ESP", function(s) he = s for _, d in pairs(c) do if d.B then d.B.Enabled = s end end end)

local fps1 = Tab:AddFolder("Misc V3")

fps1:AddButton('Remove Textures', function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA('Decal') or v:IsA('Texture') then v.Transparency = 1 end
    end
    game:GetService('StarterGui'):SetCore('SendNotification', { Title = 'Performance', Text = 'Textures removed!', Duration = 5 })
end)

fps1:AddButton('Reduce Graphics', function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    game:GetService('StarterGui'):SetCore('SendNotification', { Title = 'Performance', Text = 'Graphics reduced!', Duration = 5 })
end)

fps1:AddButton('Disable Shadows', function()
    game:GetService('Lighting').GlobalShadows = false
    game:GetService('StarterGui'):SetCore('SendNotification', { Title = 'Performance', Text = 'Shadows disabled!', Duration = 5 })
end)

fps1:AddButton('Disable Effects', function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA('ParticleEmitter') or v:IsA('Smoke') or v:IsA('Fire') or v:IsA('Sparkles') then v.Enabled = false end
    end
    for _, v in pairs(game:GetService('Lighting'):GetChildren()) do
        if v:IsA('BlurEffect') or v:IsA('SunRaysEffect') or v:IsA('ColorCorrectionEffect') or v:IsA('BloomEffect') or v:IsA('DepthOfFieldEffect') then v.Enabled = false end
    end
    game:GetService('StarterGui'):SetCore('SendNotification', { Title = 'Performance', Text = 'Effects disabled!', Duration = 5 })
end)

fps1:AddButton('Simplify Materials', function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA('BasePart') and not v:IsA('MeshPart') then
            v.Material = Enum.Material.SmoothPlastic
            if not (v.Parent and (v.Parent:FindFirstChild('Humanoid') or v.Parent.Parent:FindFirstChild('Humanoid'))) then
                v.Reflectance = 0
            end
        end
    end
    game:GetService('StarterGui'):SetCore('SendNotification', { Title = 'Performance', Text = 'Materials simplified!', Duration = 5 })
end)

fps1:AddButton('Remove Fog', function()
    game:GetService('Lighting').FogEnd = 10000000000
    game:GetService('StarterGui'):SetCore('SendNotification', { Title = 'Performance', Text = 'Fog removed!', Duration = 5 })
end)

fps1:AddButton('Anti Lag (Advanced)', function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA('Decal') or v:IsA('Texture') then
            v:Destroy()
        elseif v:IsA('PointLight') or v:IsA('SurfaceLight') or v:IsA('SpotLight') then
            v.Enabled = false
        end
    end
    local _Terrain = workspace:FindFirstChildOfClass('Terrain')
    if _Terrain then
        _Terrain.WaterWaveSize = 0
        _Terrain.WaterWaveSpeed = 0
        _Terrain.WaterReflectance = 0
        _Terrain.WaterTransparency = 1
        _Terrain.Decorations = false
    end
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA('Explosion') or v:IsA('Debris') or (v:IsA('BasePart') and v.Name:lower():find('debris')) then
            v:Destroy()
        elseif v:IsA('Sound') then
            v:Stop()
        end
    end
end)

fps1:AddButton('Ultra FPS Booster', function()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
    settings().Rendering.EagerBulkExecution = true
    settings().Rendering.ReloadAssets = false
    local _Lighting3 = game:GetService('Lighting')
    _Lighting3.GlobalShadows = false
    _Lighting3.FogEnd = 10000000000
    _Lighting3.Brightness = 0
    _Lighting3.EnvironmentDiffuseScale = 0
    _Lighting3.EnvironmentSpecularScale = 0
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA('ParticleEmitter') or v:IsA('Trail') or v:IsA('Smoke') or v:IsA('Fire') or v:IsA('Sparkles') or v:IsA('Decal') or v:IsA('Texture') then
            v:Destroy()
        elseif v:IsA('PointLight') or v:IsA('SpotLight') or v:IsA('SurfaceLight') then
            v.Enabled = false
        elseif v:IsA('Sound') then
            v:Stop()
            v.Volume = 0
        end
    end
    local _Terrain2 = workspace:FindFirstChildOfClass('Terrain')
    if _Terrain2 then
        _Terrain2.WaterWaveSize = 0
        _Terrain2.WaterWaveSpeed = 0
        _Terrain2.WaterReflectance = 0
        _Terrain2.WaterTransparency = 1
        _Terrain2.Decorations = false
    end
end)

fps1:AddButton('Full Optimization', function()
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA('ParticleEmitter') or v:IsA('Smoke') or v:IsA('Fire') or v:IsA('Sparkles') then
            v.Enabled = false
        elseif v:IsA('Decal') or v:IsA('Texture') then
            v.Transparency = 1
        elseif v:IsA('BasePart') and not v:IsA('MeshPart') then
            v.Material = Enum.Material.SmoothPlastic
        end
    end
    local _Lighting4 = game:GetService('Lighting')
    _Lighting4.GlobalShadows = false
    _Lighting4.FogEnd = 9000000000
    _Lighting4.Brightness = 0
    settings().Rendering.QualityLevel = 1
    for _, v in pairs(_Lighting4:GetChildren()) do
        if v:IsA('BlurEffect') or v:IsA('SunRaysEffect') or v:IsA('ColorCorrectionEffect') or v:IsA('BloomEffect') or v:IsA('DepthOfFieldEffect') then
            v.Enabled = false
        end
    end
    game:GetService('StarterGui'):SetCore('SendNotification', {
        Title = 'Optimization',
        Text = 'Full optimization applied!', on
        Duration = 5,
    })
end)
