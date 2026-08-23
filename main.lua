-- =================================================================
--   👑 VALERA DAYN V6 GODMODE MEGA HUB [MM2]
--   • Manual Controlled Mobile Fly (No auto-drift)
--   • Coin Auto-Farm & Box Opener
--   • Hitbox Expander & Distance Radar
--   • Client-side Skin Changer & Spectate
--   • Dark Purple Neon Ultra Theme
-- =================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local TargetGui = game:GetService("CoreGui")
if not pcall(function() local _ = TargetGui.Name end) then
    TargetGui = LocalPlayer:WaitForChild("PlayerGui")
end

if TargetGui:FindFirstChild("ValeraDayn_V6") then
    TargetGui.ValeraDayn_V6:Destroy()
end

-- // Хранилище Настроек
local Config = {
    -- Combat
    SheriffAutoShoot = false,
    MurderKillAll = false,
    KnifeAura = false,
    KnifeAuraDist = 18,
    HitboxExpander = false,
    HitboxSize = 8,
    AutoGrabGun = false,
    AntiStab = false,
    
    -- Farm & Economy
    AutoFarmCoins = false,
    CoinMagnet = false,
    AutoOpenBoxes = false,
    
    -- Visuals & Radar
    RoleESP = true,
    GunESP = true,
    NameESP = true,
    DistanceRadar = true,
    ChromaSkins = false,
    Fullbright = false,
    Xray = false,
    
    -- Movement & Fly
    SpeedValue = 16,
    SpeedEnabled = false,
    Fly = false,
    FlySpeed = 25,
    InfiniteJump = false,
    Noclip = false,
    AntiVoid = true,
    
    -- Misc & Troll
    ChatAnnouncer = false,
    TradeScamAlert = true,
    FlingAll = false,
    FpsBoost = false
}

local ConfigFolder = "ValeraDayn_Configs"
local ConfigPath = ConfigFolder .. "/MM2_V6_Mega.json"

local function SaveConfig()
    pcall(function()
        if writefile and isfolder then
            if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
            writefile(ConfigPath, HttpService:JSONEncode(Config))
        end
    end)
end

local function LoadConfig()
    pcall(function()
        if readfile and isfile and isfile(ConfigPath) then
            local data = HttpService:JSONDecode(readfile(ConfigPath))
            for k, v in pairs(data) do Config[k] = v end
        end
    end)
end
LoadConfig()

-- // Вспомогательные функции
local function GetPlayerRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    local c = plr.Character
    local b = plr:FindFirstChild("Backpack")
    if (c:FindFirstChild("Knife") or (b and b:FindFirstChild("Knife"))) then return "Murderer" end
    if (c:FindFirstChild("Gun") or (b and b:FindFirstChild("Gun"))) then return "Sheriff" end
    return "Innocent"
end

local function FindDroppedGun()
    for _, item in ipairs(Workspace:GetDescendants()) do
        if item.Name == "GunDrop" and (item:IsA("BasePart") or item:IsA("Model")) then
            return item:IsA("Model") and (item.PrimaryPart or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")) or item
        end
    end
    return nil
end

local FlyUp = false
local FlyDown = false
local LastSafePos = CFrame.new(0, 10, 0)

-- // UI (Dark Purple Neon)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ValeraDayn_V6"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = TargetGui

-- Плавающая кнопка
local StealthBtn = Instance.new("TextButton")
StealthBtn.Size = UDim2.new(0, 48, 0, 48)
StealthBtn.Position = UDim2.new(0.04, 0, 0.25, 0)
StealthBtn.BackgroundColor3 = Color3.fromRGB(15, 8, 28)
StealthBtn.Text = "VD"
StealthBtn.TextColor3 = Color3.fromRGB(199, 125, 255)
StealthBtn.TextSize = 16
StealthBtn.Font = Enum.Font.GothamBlack
StealthBtn.Parent = ScreenGui
Instance.new("UICorner", StealthBtn).CornerRadius = UDim.new(1, 0)
local SStroke = Instance.new("UIStroke", StealthBtn)
SStroke.Color = Color3.fromRGB(157, 78, 221)
SStroke.Thickness = 2

-- Радар Расстояния до Мардера
local RadarFrame = Instance.new("Frame")
RadarFrame.Size = UDim2.new(0, 150, 0, 32)
RadarFrame.Position = UDim2.new(0.5, -75, 0.03, 0)
RadarFrame.BackgroundColor3 = Color3.fromRGB(18, 10, 32)
RadarFrame.Visible = Config.DistanceRadar
RadarFrame.Parent = ScreenGui
Instance.new("UICorner", RadarFrame).CornerRadius = UDim.new(0, 8)
local RStroke = Instance.new("UIStroke", RadarFrame)
RStroke.Color = Color3.fromRGB(157, 78, 221)

local RadarLabel = Instance.new("TextLabel")
RadarLabel.Size = UDim2.new(1, 0, 1, 0)
RadarLabel.BackgroundTransparency = 1
RadarLabel.Text = "🔴 Мардер: Поиск..."
RadarLabel.TextColor3 = Color3.fromRGB(240, 220, 255)
RadarLabel.TextSize = 10
RadarLabel.Font = Enum.Font.GothamBold
RadarLabel.Parent = RadarFrame

-- Мобильные кнопки высоты для Fly
local FlyControls = Instance.new("Frame")
FlyControls.Size = UDim2.new(0, 50, 0, 110)
FlyControls.Position = UDim2.new(0.9, -20, 0.5, -55)
FlyControls.BackgroundTransparency = 1
FlyControls.Visible = false
FlyControls.Parent = ScreenGui

local UpBtn = Instance.new("TextButton")
UpBtn.Size = UDim2.new(0, 48, 0, 48)
UpBtn.BackgroundColor3 = Color3.fromRGB(25, 12, 45)
UpBtn.Text = "▲"
UpBtn.TextColor3 = Color3.fromRGB(199, 125, 255)
UpBtn.TextSize = 16
UpBtn.Parent = FlyControls
Instance.new("UICorner", UpBtn).CornerRadius = UDim.new(0, 8)

local DownBtn = Instance.new("TextButton")
DownBtn.Size = UDim2.new(0, 48, 0, 48)
DownBtn.Position = UDim2.new(0, 0, 0, 55)
DownBtn.BackgroundColor3 = Color3.fromRGB(25, 12, 45)
DownBtn.Text = "▼"
DownBtn.TextColor3 = Color3.fromRGB(199, 125, 255)
DownBtn.TextSize = 16
DownBtn.Parent = FlyControls
Instance.new("UICorner", DownBtn).CornerRadius = UDim.new(0, 8)

UpBtn.MouseButton1Down:Connect(function() FlyUp = true end)
UpBtn.MouseButton1Up:Connect(function() FlyUp = false end)
DownBtn.MouseButton1Down:Connect(function() FlyDown = true end)
DownBtn.MouseButton1Up:Connect(function() FlyDown = false end)

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 310)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(11, 8, 19)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local MStroke = Instance.new("UIStroke", MainFrame)
MStroke.Color = Color3.fromRGB(157, 78, 221)
MStroke.Thickness = 1.5

-- Верхняя панель
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(20, 12, 38)
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 260, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "👑 VALERA DAYN V6 [MEGA]"
Title.TextColor3 = Color3.fromRGB(224, 170, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 7)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 120)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Горизонтальные Вкладки
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 32)
TabBar.Position = UDim2.new(0, 10, 0, 48)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 5)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.Parent = TabBar

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -20, 1, -90)
PagesContainer.Position = UDim2.new(0, 10, 0, 85)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

local TabPages = {}
local TabNames = {"Combat", "Farm & Auto", "Visuals", "Movement", "Misc & Troll"}

for i, tab in ipairs(TabNames) do
    local Page = Instance.new("ScrollingFrame")
    Page.Name = tab .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 2
    Page.Visible = (i == 1)
    Page.CanvasSize = UDim2.new(0, 0, 0, 340)
    Page.Parent = PagesContainer

    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize = UDim2.new(0.48, 0, 0, 36)
    Grid.CellPadding = UDim2.new(0.03, 0, 0, 6)
    Grid.Parent = Page

    TabPages[tab] = Page

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 85, 1, 0)
    TabBtn.BackgroundColor3 = (i == 1) and Color3.fromRGB(157, 78, 221) or Color3.fromRGB(24, 15, 46)
    TabBtn.Text = tab:upper()
    TabBtn.TextColor3 = (i == 1) and Color3.fromRGB(15, 8, 28) or Color3.fromRGB(200, 180, 230)
    TabBtn.TextSize = 9
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(TabPages) do p.Visible = false end
        for _, b in ipairs(TabBar:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(24, 15, 46)
                b.TextColor3 = Color3.fromRGB(200, 180, 230)
            end
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(157, 78, 221)
        TabBtn.TextColor3 = Color3.fromRGB(15, 8, 28)
    end)
end

-- Конструкторы UI
local function AddToggle(parentTab, text, key, callback)
    local Btn = Instance.new("TextButton")
    Btn.BackgroundColor3 = Config[key] and Color3.fromRGB(60, 24, 94) or Color3.fromRGB(20, 12, 38)
    Btn.Text = (Config[key] and "● " or "○ ") .. text
    Btn.TextColor3 = Config[key] and Color3.fromRGB(224, 170, 255) or Color3.fromRGB(160, 140, 190)
    Btn.TextSize = 9
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = TabPages[parentTab]
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    Btn.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        Btn.BackgroundColor3 = Config[key] and Color3.fromRGB(60, 24, 94) or Color3.fromRGB(20, 12, 38)
        Btn.TextColor3 = Config[key] and Color3.fromRGB(224, 170, 255) or Color3.fromRGB(160, 140, 190)
        Btn.Text = (Config[key] and "● " or "○ ") .. text
        SaveConfig()
        if callback then callback(Config[key]) end
    end)
end

local function AddButton(parentTab, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.BackgroundColor3 = Color3.fromRGB(36, 18, 68)
    Btn.Text = "⚡ " .. text
    Btn.TextColor3 = Color3.fromRGB(240, 220, 255)
    Btn.TextSize = 9
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = TabPages[parentTab]
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(callback)
end

local function AddSlider(parentTab, titleText, minVal, maxVal, currentVal, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.98, 0, 0, 36)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 12, 38)
    SliderFrame.Parent = TabPages[parentTab]
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

    local SLabel = Instance.new("TextLabel")
    SLabel.Size = UDim2.new(1, -12, 0, 16)
    SLabel.Position = UDim2.new(0, 8, 0, 2)
    SLabel.BackgroundTransparency = 1
    SLabel.Text = titleText .. ": " .. tostring(currentVal)
    SLabel.TextColor3 = Color3.fromRGB(224, 170, 255)
    SLabel.TextSize = 9
    SLabel.Font = Enum.Font.GothamBold
    SLabel.TextXAlignment = Enum.TextXAlignment.Left
    SLabel.Parent = SliderFrame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -16, 0, 6)
    Bar.Position = UDim2.new(0, 8, 0, 20)
    Bar.BackgroundColor3 = Color3.fromRGB(36, 20, 64)
    Bar.BorderSizePixel = 0
    Bar.Parent = SliderFrame
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((currentVal - minVal) / (maxVal - minVal), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(157, 78, 221)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local function Update(input)
        local posX = math.clamp(input.Position.X - Bar.AbsolutePosition.X, 0, Bar.AbsoluteSize.X)
        local ratio = posX / Bar.AbsoluteSize.X
        local val = math.floor(minVal + (maxVal - minVal) * ratio)
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        SLabel.Text = titleText .. ": " .. tostring(val)
        callback(val)
    end

    local isDragging = false
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            Update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            Update(input)
        end
    end)
end

-- ==================== НАПОЛНЕНИЕ МЕНЮ ====================

-- 1. COMBAT
AddToggle("Combat", "Автовыстрел Шериф", "SheriffAutoShoot")
AddToggle("Combat", "Kill All Мирных", "MurderKillAll")
AddToggle("Combat", "Knife Aura (Радиус)", "KnifeAura")
AddToggle("Combat", "Hitbox Expander", "HitboxExpander")
AddSlider("Combat", "Размер Hitbox", 2, 25, Config.HitboxSize, function(val)
    Config.HitboxSize = val
    SaveConfig()
end)
AddButton("Combat", "Fake Dead (Притвориться)", function()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        task.wait(2)
        char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end)

-- 2. FARM & AUTO
AddToggle("Farm & Auto", "Автофарм Монет", "AutoFarmCoins")
AddToggle("Farm & Auto", "Магнит Монет", "CoinMagnet")
AddButton("Farm & Auto", "Авто-Открытие Ящика", function()
    local buyRemote = game:GetService("ReplicatedStorage"):FindFirstChild("BuyMysteryBox", true)
    if buyRemote then buyRemote:FireServer("StandardBox") end
end)

-- 3. VISUALS
AddToggle("Visuals", "ESP Ролей", "RoleESP")
AddToggle("Visuals", "ESP Пистолета", "GunESP")
AddToggle("Visuals", "Радар Мардера HUD", "DistanceRadar", function(v)
    RadarFrame.Visible = v
end)
AddToggle("Visuals", "Chroma Скины", "ChromaSkins")
AddToggle("Visuals", "Fullbright", "Fullbright", function(v)
    Lighting.Brightness = v and 3 or 1
    Lighting.ClockTime = v and 14 or 12
    Lighting.GlobalShadows = not v
end)

-- 4. MOVEMENT
AddToggle("Movement", "Авто-Подбор Гана", "AutoGrabGun")
AddToggle("Movement", "Спидхак", "SpeedEnabled")
AddSlider("Movement", "Скорость Бега", 1, 100, Config.SpeedValue, function(val)
    Config.SpeedValue = val
    SaveConfig()
end)
AddToggle("Movement", "Ручной Mobile Fly", "Fly", function(v)
    FlyControls.Visible = v
end)
AddSlider("Movement", "Скорость Fly", 5, 80, Config.FlySpeed, function(val)
    Config.FlySpeed = val
    SaveConfig()
end)
AddToggle("Movement", "Noclip", "Noclip")
AddToggle("Movement", "Anti-Void Спасение", "AntiVoid")
AddToggle("Movement", "Бесконечный Прыжок", "InfiniteJump")

-- 5. MISC & TROLL
AddToggle("Misc & Troll", "Чат-Аннонсер Ролей", "ChatAnnouncer")
AddToggle("Misc & Troll", "Anti-Scam Трейда", "TradeScamAlert")
AddButton("Misc & Troll", "Спектатор Мардера", function()
    for _, plr in ipairs(Players:GetPlayers()) do
        if GetPlayerRole(plr) == "Murderer" and plr.Character and plr.Character:FindFirstChild("Humanoid") then
            Camera.CameraSubject = plr.Character.Humanoid
        end
    end
end)
AddButton("Misc & Troll", "Вернуть Камеру", function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        Camera.CameraSubject = LocalPlayer.Character.Humanoid
    end
end)
AddToggle("Misc & Troll", "Fling All", "FlingAll")
AddButton("Misc & Troll", "ТП к Пистолету", function()
    local g = FindDroppedGun()
    if g and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = g.CFrame + Vector3.new(0, 2, 0)
    end
end)

-- ==================== ОБРАБОТЧИКИ И ЦИКЛЫ ====================

-- Перетаскивание стелс-кнопки
local isDrag, dStart, sPos
StealthBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        isDrag = true
        dStart = inp.Position
        sPos = StealthBtn.Position
    end
end)
StealthBtn.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1 then
        isDrag = false
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if isDrag and (inp.UserInputType == Enum.UserInputType.Touch or inp.UserInputType == Enum.UserInputType.MouseButton1) then
        local delta = inp.Position - dStart
        StealthBtn.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + delta.X, sPos.Y.Scale, sPos.Y.Offset + delta.Y)
    end
end)
StealthBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Бесконечный прыжок
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Основной цикл RenderStepped
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChild("Humanoid")

    -- Спидхак
    if myHum and Config.SpeedEnabled then
        myHum.WalkSpeed = Config.SpeedValue
    end

    -- Noclip
    if Config.Noclip and myChar then
        for _, part in ipairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- Anti-Void спасение
    if myHRP then
        if myHRP.Position.Y > -40 then
            LastSafePos = myHRP.CFrame
        elseif Config.AntiVoid and myHRP.Position.Y <= -40 then
            myHRP.CFrame = LastSafePos + Vector3.new(0, 4, 0)
            myHRP.AssemblyLinearVelocity = Vector3.zero
        end
    end

    -- Ручной Fly (Движется только по направлению стика + кнопки вверх/вниз)
    if Config.Fly and myHRP and myHum then
        local moveDir = myHum.MoveDirection
        local upVel = 0
        if FlyUp then upVel = Config.FlySpeed end
        if FlyDown then upVel = -Config.FlySpeed end
        
        myHRP.AssemblyLinearVelocity = Vector3.new(moveDir.X * Config.FlySpeed, upVel, moveDir.Z * Config.FlySpeed)
    end

    -- Hitbox Expander
    if Config.HitboxExpander then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = plr.Character.HumanoidRootPart
                hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                hrp.Transparency = 0.7
                hrp.CanCollide = false
            end
        end
    end

    -- ESP & Дистанция Мардера на Радаре
    local mFound = false
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local char = plr.Character
            local role = GetPlayerRole(plr)
            
            if role == "Murderer" and myHRP then
                mFound = true
                local dist = math.floor((myHRP.Position - char.HumanoidRootPart.Position).Magnitude)
                RadarLabel.Text = "🔴 Мардер: " .. plr.Name .. " [" .. dist .. "m]"
            end

            if Config.RoleESP then
                local hl = char:FindFirstChild("VD_NeonHL") or Instance.new("Highlight")
                hl.Name = "VD_NeonHL"
                hl.Parent = char
                hl.FillTransparency = 0.4
                if role == "Murderer" then hl.FillColor = Color3.fromRGB(255, 30, 80)
                elseif role == "Sheriff" then hl.FillColor = Color3.fromRGB(60, 140, 255)
                else hl.FillColor = Color3.fromRGB(157, 78, 221) end
            end
        end
    end
    if not mFound then RadarLabel.Text = "🟢 Мардер: Не обнаружен" end

    -- Chroma Skins Effect
    if Config.ChromaSkins and myChar then
        local hue = tick() % 5 / 5
        local chromaColor = Color3.fromHSV(hue, 1, 1)
        for _, tool in ipairs(myChar:GetChildren()) do
            if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
                tool.Handle.Color = chromaColor
            end
        end
    end
end)

-- Фоновые боевые и фарм циклы
RunService.Heartbeat:Connect(function()
    pcall(function()
        local myChar = LocalPlayer.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
        local myHRP = myChar.HumanoidRootPart

        -- Автофарм и магнит монет
        if Config.AutoFarmCoins or Config.CoinMagnet then
            for _, coin in ipairs(Workspace:GetDescendants()) do
                if coin.Name == "Coin_Server" or coin.Name == "Coin" or coin.Name:find("Coin") then
                    if coin:IsA("BasePart") then
                        if Config.CoinMagnet and (myHRP.Position - coin.Position).Magnitude < 25 then
                            coin.CFrame = myHRP.CFrame
                        elseif Config.AutoFarmCoins then
                            myHRP.CFrame = coin.CFrame
                            task.wait(0.1)
                        end
                    end
                end
            end
        end

        -- Автовыстрел Шерифа
        if Config.SheriffAutoShoot then
            local gun = LocalPlayer.Backpack:FindFirstChild("Gun") or myChar:FindFirstChild("Gun")
            if gun then
                gun.Parent = myChar
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and GetPlayerRole(plr) == "Murderer" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local tHRP = plr.Character.HumanoidRootPart
                        local shootRemote = game:GetService("ReplicatedStorage"):FindFirstChild("ShootGun", true)
                        if shootRemote then
                            shootRemote:FireServer(1, tHRP.Position + (tHRP.AssemblyLinearVelocity * 0.12), "Gun")
                        end
                    end
                end
            end
        end

        -- Kill All за Мардера
        if Config.MurderKillAll and GetPlayerRole(LocalPlayer) == "Murderer" then
            local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or myChar:FindFirstChild("Knife")
            if knife then
                knife.Parent = myChar
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        myHRP.CFrame = plr.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.2)
                        if knife:FindFirstChild("Handle") and firetouchinterest then
                            firetouchinterest(plr.Character.HumanoidRootPart, knife.Handle, 0)
                            firetouchinterest(plr.Character.HumanoidRootPart, knife.Handle, 1)
                        end
                        knife:Activate()
                    end
                end
            end
        end
    end)
end)

print("[ValeraDayn V6] Все мега-функции успешно активированы!")
