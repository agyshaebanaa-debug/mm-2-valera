-- =================================================================
--   👑 VALERA DAYN V5 ULTRA NEON PURPLE [MM2 GODMODE HUB]
--   • Dark Purple Neon Theme
--   • 100% Sheriff Silent Aim & Auto-Shoot
--   • Smooth Mobile Fly + Anti-Void Recovery
--   • Target & All Fling Exploits
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

if TargetGui:FindFirstChild("ValeraDayn_V5") then
    TargetGui.ValeraDayn_V5:Destroy()
end

-- // Хранилище настроек
local Config = {
    -- Combat
    SheriffAutoShoot = false,
    MurderKillAll = false,
    KnifeAura = false,
    KnifeAuraDist = 20,
    AutoGrabGun = false,
    AntiStab = false,
    
    -- Visuals
    RoleESP = true,
    GunESP = true,
    NameESP = true,
    Tracers = false,
    Fullbright = false,
    Xray = false,
    
    -- Movement
    SpeedValue = 16,
    SpeedEnabled = false,
    Fly = false,
    FlySpeed = 35,
    InfiniteJump = false,
    Noclip = false,
    AntiVoid = true,
    
    -- Misc / Fling
    FlingAll = false,
    TargetFling = false,
    FpsBoost = false
}

local ConfigFolder = "ValeraDayn_Configs"
local ConfigPath = ConfigFolder .. "/MM2_V5_Neon.json"

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

-- // Поиск ролей и предметов
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

local LastSafeCFrame = CFrame.new(0, 10, 0)

-- // Интерфейс Dark Purple Neon
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ValeraDayn_V5"
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

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 470, 0, 300)
MainFrame.Position = UDim2.new(0.5, -235, 0.5, -150)
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
Title.Text = "⚡ VALERA DAYN V5 [NEON]"
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
TabLayout.Padding = UDim.new(0, 6)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.Parent = TabBar

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -20, 1, -90)
PagesContainer.Position = UDim2.new(0, 10, 0, 85)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

local TabPages = {}
local TabNames = {"Combat", "Visuals", "Movement", "Fling & Misc"}

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
    Grid.CellSize = UDim2.new(0.48, 0, 0, 38)
    Grid.CellPadding = UDim2.new(0.03, 0, 0, 8)
    Grid.Parent = Page

    TabPages[tab] = Page

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 100, 1, 0)
    TabBtn.BackgroundColor3 = (i == 1) and Color3.fromRGB(157, 78, 221) or Color3.fromRGB(24, 15, 46)
    TabBtn.Text = tab:upper()
    TabBtn.TextColor3 = (i == 1) and Color3.fromRGB(15, 8, 28) or Color3.fromRGB(200, 180, 230)
    TabBtn.TextSize = 10
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

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

-- Конструкторы элементов
local function AddToggle(parentTab, text, key, callback)
    local Btn = Instance.new("TextButton")
    Btn.BackgroundColor3 = Config[key] and Color3.fromRGB(60, 24, 94) or Color3.fromRGB(20, 12, 38)
    Btn.Text = (Config[key] and "● " or "○ ") .. text
    Btn.TextColor3 = Config[key] and Color3.fromRGB(224, 170, 255) or Color3.fromRGB(160, 140, 190)
    Btn.TextSize = 10
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = TabPages[parentTab]
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

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
    Btn.TextSize = 10
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = TabPages[parentTab]
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Btn.MouseButton1Click:Connect(callback)
end

local function AddSlider(parentTab, titleText, minVal, maxVal, currentVal, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.98, 0, 0, 38)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 12, 38)
    SliderFrame.Parent = TabPages[parentTab]
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

    local SLabel = Instance.new("TextLabel")
    SLabel.Size = UDim2.new(1, -12, 0, 18)
    SLabel.Position = UDim2.new(0, 8, 0, 2)
    SLabel.BackgroundTransparency = 1
    SLabel.Text = titleText .. ": " .. tostring(currentVal)
    SLabel.TextColor3 = Color3.fromRGB(224, 170, 255)
    SLabel.TextSize = 9
    SLabel.Font = Enum.Font.GothamBold
    SLabel.TextXAlignment = Enum.TextXAlignment.Left
    SLabel.Parent = SliderFrame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -16, 0, 7)
    Bar.Position = UDim2.new(0, 8, 0, 22)
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

-- Функция выстрела шерифа с предиктом
local function ShootMurderer()
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local gun = LocalPlayer.Backpack:FindFirstChild("Gun") or myChar:FindFirstChild("Gun")
    if not gun then return end
    
    gun.Parent = myChar
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and GetPlayerRole(plr) == "Murderer" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = plr.Character.HumanoidRootPart
            local targetVel = targetHRP.AssemblyLinearVelocity or targetHRP.Velocity or Vector3.zero
            local shootPos = targetHRP.Position + (targetVel * 0.12) -- Предикт движения

            -- Поиск remotes стрельбы
            local shootRemote = game:GetService("ReplicatedStorage"):FindFirstChild("ShootGun", true)
            if shootRemote then
                shootRemote:FireServer(1, shootPos, "Gun")
            end
            
            -- Tool activate fallback
            pcall(function()
                if gun:FindFirstChild("KnifeServer") or gun:FindFirstChild("GunServer") then
                    gun:Activate()
                end
            end)
        end
    end
end

-- ==================== НАПОЛНЕНИЕ ВКЛАДОК ====================

-- 1. COMBAT
AddToggle("Combat", "Автовыстрел в Мардера", "SheriffAutoShoot")
AddToggle("Combat", "Kill All Мирных", "MurderKillAll")
AddToggle("Combat", "Knife Aura (Радиус)", "KnifeAura")
AddToggle("Combat", "Anti-Stab (Защита)", "AntiStab")
AddButton("Combat", "Точный Выстрел (Manual)", function()
    ShootMurderer()
end)

-- 2. VISUALS
AddToggle("Visuals", "Роли Подсветка (Chams)", "RoleESP")
AddToggle("Visuals", "ESP Выпавший Пистолет", "GunESP")
AddToggle("Visuals", "Ники и Дистанция", "NameESP")
AddToggle("Visuals", "Fullbright", "Fullbright", function(v)
    Lighting.Brightness = v and 3 or 1
    Lighting.ClockTime = v and 14 or 12
    Lighting.GlobalShadows = not v
end)
AddToggle("Visuals", "X-Ray Стены", "Xray", function(v)
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Parent:FindFirstChild("Humanoid") then
            part.LocalTransparencyModifier = v and 0.55 or 0
        end
    end
end)

-- 3. MOVEMENT
AddToggle("Movement", "Авто-Подбор Пистолета", "AutoGrabGun")
AddToggle("Movement", "Спидхак", "SpeedEnabled")
AddSlider("Movement", "Скорость Бега", 1, 100, Config.SpeedValue, function(val)
    Config.SpeedValue = val
    SaveConfig()
end)
AddToggle("Movement", "Mobile Fly", "Fly")
AddSlider("Movement", "Скорость Fly", 1, 100, Config.FlySpeed, function(val)
    Config.FlySpeed = val
    SaveConfig()
end)
AddToggle("Movement", "Noclip", "Noclip")
AddToggle("Movement", "Anti-Void Спасение", "AntiVoid")
AddToggle("Movement", "Бесконечный Прыжок", "InfiniteJump")

-- 4. FLING & MISC
AddToggle("Fling & Misc", "Fling All (Раскидать всех)", "FlingAll")
AddButton("Fling & Misc", "Fling Мардера", function()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and GetPlayerRole(plr) == "Murderer" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local targetHRP = plr.Character.HumanoidRootPart
            local oldPos = myHRP.CFrame
            for i = 1, 20 do
                myHRP.CFrame = targetHRP.CFrame
                myHRP.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
                myHRP.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
                task.wait()
            end
            myHRP.CFrame = oldPos
            myHRP.AssemblyLinearVelocity = Vector3.zero
            myHRP.AssemblyAngularVelocity = Vector3.zero
        end
    end
end)
AddToggle("Fling & Misc", "FPS Booster", "FpsBoost", function(v)
    if v then
        for _, fx in ipairs(Lighting:GetChildren()) do
            if fx:IsA("PostEffect") then fx.Enabled = false end
        end
    end
end)
AddButton("Fling & Misc", "ТП к Пистолету", function()
    local g = FindDroppedGun()
    if g and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = g.CFrame + Vector3.new(0, 2, 0)
    end
end)

-- ==================== СИСТЕМНЫЕ СЛУЖБЫ ====================

-- Drag Stealth
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

-- Рендер и Физика
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

    -- Сохранение безопасной позиции и Anti-Void
    if myHRP then
        if myHRP.Position.Y > -50 then
            LastSafeCFrame = myHRP.CFrame
        elseif Config.AntiVoid and myHRP.Position.Y <= -50 then
            myHRP.CFrame = LastSafeCFrame + Vector3.new(0, 5, 0)
            myHRP.AssemblyLinearVelocity = Vector3.zero
        end
    end

    -- Mobile Fly
    if Config.Fly and myHRP then
        myHRP.AssemblyLinearVelocity = Camera.CFrame.LookVector * Config.FlySpeed
    end

    -- ESP Игроков
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local char = plr.Character
            local role = GetPlayerRole(plr)
            
            if Config.RoleESP then
                local hl = char:FindFirstChild("VD_NeonHL") or Instance.new("Highlight")
                hl.Name = "VD_NeonHL"
                hl.Parent = char
                hl.FillTransparency = 0.4
                hl.OutlineTransparency = 0
                if role == "Murderer" then hl.FillColor = Color3.fromRGB(255, 30, 80)
                elseif role == "Sheriff" then hl.FillColor = Color3.fromRGB(60, 140, 255)
                else hl.FillColor = Color3.fromRGB(157, 78, 221) end
            else
                if char:FindFirstChild("VD_NeonHL") then char.VD_NeonHL:Destroy() end
            end

            if Config.NameESP then
                local head = char:FindFirstChild("Head")
                if head and not head:FindFirstChild("VD_Tag") then
                    local bb = Instance.new("BillboardGui", head)
                    bb.Name = "VD_Tag"
                    bb.Size = UDim2.new(0, 110, 0, 40)
                    bb.StudsOffset = Vector3.new(0, 2.5, 0)
                    bb.AlwaysOnTop = true
                    
                    local txt = Instance.new("TextLabel", bb)
                    txt.Size = UDim2.new(1, 0, 1, 0)
                    txt.BackgroundTransparency = 1
                    txt.TextSize = 10
                    txt.Font = Enum.Font.GothamBold
                    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
                elseif head and head:FindFirstChild("VD_Tag") then
                    local dist = myHRP and math.floor((myHRP.Position - head.Position).Magnitude) or 0
                    head.VD_Tag.TextLabel.Text = plr.Name .. " (" .. dist .. "m)\n[" .. role .. "]"
                end
            end
        end
    end

    -- ESP & Подбор гана
    local gun = FindDroppedGun()
    if gun then
        if Config.GunESP then
            local ghl = gun:FindFirstChild("VD_GunHL") or Instance.new("Highlight")
            ghl.Name = "VD_GunHL"
            ghl.Parent = gun
            ghl.FillColor = Color3.fromRGB(255, 215, 0)
        end
        if Config.AutoGrabGun and myHRP then
            if firetouchinterest then
                firetouchinterest(myHRP, gun, 0)
                firetouchinterest(myHRP, gun, 1)
            else
                myHRP.CFrame = gun.CFrame
            end
        end
    end
end)

-- Heartbeat Loops
RunService.Heartbeat:Connect(function()
    pcall(function()
        local myChar = LocalPlayer.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
        local myHRP = myChar.HumanoidRootPart

        -- 1. Постоянный автовыстрел шерифа
        if Config.SheriffAutoShoot then
            ShootMurderer()
        end

        -- 2. Kill All за Мардера
        if (Config.MurderKillAll or Config.KnifeAura) and GetPlayerRole(LocalPlayer) == "Murderer" then
            local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or myChar:FindFirstChild("Knife")
            if knife then
                knife.Parent = myChar
                local handle = knife:FindFirstChild("Handle")
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local victimHRP = plr.Character.HumanoidRootPart
                        local dist = (myHRP.Position - victimHRP.Position).Magnitude
                        if Config.MurderKillAll or (Config.KnifeAura and dist <= Config.KnifeAuraDist) then
                            if Config.MurderKillAll then
                                myHRP.CFrame = victimHRP.CFrame * CFrame.new(0, 0, 1.2)
                            end
                            if handle and firetouchinterest then
                                firetouchinterest(victimHRP, handle, 0)
                                firetouchinterest(victimHRP, handle, 1)
                            end
                            knife:Activate()
                        end
                    end
                end
            end
        end

        -- 3. Fling All Loop
        if Config.FlingAll then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    myHRP.CFrame = plr.Character.HumanoidRootPart.CFrame
                    myHRP.AssemblyLinearVelocity = Vector3.new(9999, 9999, 9999)
                    myHRP.AssemblyAngularVelocity = Vector3.new(9999, 9999, 9999)
                end
            end
        end
    end)
end)

print("[ValeraDayn V5] Скрипт успешно активирован!")
