-- =================================================================
--   👑 VALERA DAYN V4 ULTRA MAX [MM2 GODMODE HUB]
--   • Рабочий Kill All & Sheriff Aimbot
--   • Сенсорный Слайдер Скорости (1-100)
--   • Cyberpunk UI с горизонтальными табами и автозагрузкой
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

-- Защита от родительских ошибок (CoreGui / PlayerGui)
local TargetGui = game:GetService("CoreGui")
if not pcall(function() local _ = TargetGui.Name end) then
    TargetGui = LocalPlayer:WaitForChild("PlayerGui")
end

if TargetGui:FindFirstChild("ValeraDayn_V4") then
    TargetGui.ValeraDayn_V4:Destroy()
end

-- // Хранилище настроек
local Config = {
    -- Combat
    SheriffAutoShoot = false,
    MurderKillAll = false,
    KnifeAura = false,
    KnifeAuraDist = 18,
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
    InfiniteJump = false,
    Noclip = false,
    Fly = false,
    FlySpeed = 30,
    
    -- Misc
    FpsBoost = false,
    AntiFling = false
}

local ConfigFolder = "ValeraDayn_Configs"
local ConfigPath = ConfigFolder .. "/MM2_V4.json"

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

-- // Вспомогательные функции ролей и оружия
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

-- // Создание Интерфейса (Cyberpunk Dark Neon)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ValeraDayn_V4"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = TargetGui

-- Кнопка открытия/скрытия (Drag & Stealth)
local StealthBtn = Instance.new("TextButton")
StealthBtn.Size = UDim2.new(0, 48, 0, 48)
StealthBtn.Position = UDim2.new(0.04, 0, 0.25, 0)
StealthBtn.BackgroundColor3 = Color3.fromRGB(13, 16, 26)
StealthBtn.Text = "VD"
StealthBtn.TextColor3 = Color3.fromRGB(0, 255, 178)
StealthBtn.TextSize = 16
StealthBtn.Font = Enum.Font.GothamBlack
StealthBtn.Parent = ScreenGui
Instance.new("UICorner", StealthBtn).CornerRadius = UDim.new(1, 0)
local SStroke = Instance.new("UIStroke", StealthBtn)
SStroke.Color = Color3.fromRGB(0, 255, 178)
SStroke.Thickness = 2

-- Главный фрейм (Горизонтальное адаптивное меню)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 460, 0, 290)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -145)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MStroke = Instance.new("UIStroke", MainFrame)
MStroke.Color = Color3.fromRGB(0, 255, 178)
MStroke.Transparency = 0.5

-- Верхняя панель
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
Header.BorderSizePixel = 0
Header.Parent = MainFrame
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 250, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "👑 VALERA DAYN V4 MAX"
Title.TextColor3 = Color3.fromRGB(0, 255, 178)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBlack
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -34, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 70)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 12
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Горизонтальные Вкладки (Tabs)
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 32)
TabBar.Position = UDim2.new(0, 10, 0, 46)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 6)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.Parent = TabBar

local PagesContainer = Instance.new("Frame")
PagesContainer.Size = UDim2.new(1, -20, 1, -88)
PagesContainer.Position = UDim2.new(0, 10, 0, 82)
PagesContainer.BackgroundTransparency = 1
PagesContainer.Parent = MainFrame

local TabPages = {}
local TabNames = {"Combat", "Visuals", "Movement", "Misc"}

for i, tab in ipairs(TabNames) do
    local Page = Instance.new("ScrollingFrame")
    Page.Name = tab .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 2
    Page.Visible = (i == 1)
    Page.CanvasSize = UDim2.new(0, 0, 0, 320)
    Page.Parent = PagesContainer

    local Grid = Instance.new("UIGridLayout")
    Grid.CellSize = UDim2.new(0.48, 0, 0, 38)
    Grid.CellPadding = UDim2.new(0.03, 0, 0, 8)
    Grid.Parent = Page

    TabPages[tab] = Page

    local TabBtn = Instance.new("TextButton")
    TabBtn.Size = UDim2.new(0, 100, 1, 0)
    TabBtn.BackgroundColor3 = (i == 1) and Color3.fromRGB(0, 255, 178) or Color3.fromRGB(22, 26, 42)
    TabBtn.Text = tab:upper()
    TabBtn.TextColor3 = (i == 1) and Color3.fromRGB(15, 18, 28) or Color3.fromRGB(190, 195, 210)
    TabBtn.TextSize = 11
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.Parent = TabBar
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 8)

    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(TabPages) do p.Visible = false end
        for _, b in ipairs(TabBar:GetChildren()) do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = Color3.fromRGB(22, 26, 42)
                b.TextColor3 = Color3.fromRGB(190, 195, 210)
            end
        end
        Page.Visible = true
        TabBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 178)
        TabBtn.TextColor3 = Color3.fromRGB(15, 18, 28)
    end)
end

-- // Компоненты UI (Чекбоксы, Кнопки, Слайдер)
local function AddToggle(parentTab, text, key, callback)
    local Btn = Instance.new("TextButton")
    Btn.BackgroundColor3 = Config[key] and Color3.fromRGB(25, 52, 45) or Color3.fromRGB(20, 24, 38)
    Btn.Text = (Config[key] and "● " or "○ ") .. text
    Btn.TextColor3 = Config[key] and Color3.fromRGB(0, 255, 178) or Color3.fromRGB(160, 165, 180)
    Btn.TextSize = 10
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = TabPages[parentTab]
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)

    Btn.MouseButton1Click:Connect(function()
        Config[key] = not Config[key]
        Btn.BackgroundColor3 = Config[key] and Color3.fromRGB(25, 52, 45) or Color3.fromRGB(20, 24, 38)
        Btn.TextColor3 = Config[key] and Color3.fromRGB(0, 255, 178) or Color3.fromRGB(160, 165, 180)
        Btn.Text = (Config[key] and "● " or "○ ") .. text
        SaveConfig()
        if callback then callback(Config[key]) end
    end)
end

local function AddButton(parentTab, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.BackgroundColor3 = Color3.fromRGB(28, 33, 52)
    Btn.Text = "⚡ " .. text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 10
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = TabPages[parentTab]
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Btn.MouseButton1Click:Connect(callback)
end

-- Сенсорный Ползунок Скорости (1-100)
local function AddSlider(parentTab, titleText, minVal, maxVal, currentVal, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(0.98, 0, 0, 38)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 38)
    SliderFrame.Parent = TabPages[parentTab]
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

    local SLabel = Instance.new("TextLabel")
    SLabel.Size = UDim2.new(1, -12, 0, 18)
    SLabel.Position = UDim2.new(0, 8, 0, 2)
    SLabel.BackgroundTransparency = 1
    SLabel.Text = titleText .. ": " .. tostring(currentVal)
    SLabel.TextColor3 = Color3.fromRGB(200, 205, 220)
    SLabel.TextSize = 9
    SLabel.Font = Enum.Font.GothamBold
    SLabel.TextXAlignment = Enum.TextXAlignment.Left
    SLabel.Parent = SliderFrame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -16, 0, 8)
    Bar.Position = UDim2.new(0, 8, 0, 22)
    Bar.BackgroundColor3 = Color3.fromRGB(30, 36, 56)
    Bar.BorderSizePixel = 0
    Bar.Parent = SliderFrame
    Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((currentVal - minVal) / (maxVal - minVal), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 178)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local function UpdateSlider(input)
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
            UpdateSlider(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
            UpdateSlider(input)
        end
    end)
end

-- ==================== НАПОЛНЕНИЕ ВКЛАДОК ====================

-- 1. COMBAT
AddToggle("Combat", "Автовыстрел в Мардера", "SheriffAutoShoot")
AddToggle("Combat", "Kill All Мирных (Мардер)", "MurderKillAll")
AddToggle("Combat", "Knife Aura (Радиус)", "KnifeAura")
AddToggle("Combat", "Anti-Stab (Защита)", "AntiStab")
AddButton("Combat", "Мгновенный Килл Мардера", function()
    local myChar = LocalPlayer.Character
    local gun = LocalPlayer.Backpack:FindFirstChild("Gun") or (myChar and myChar:FindFirstChild("Gun"))
    if gun and myChar then
        gun.Parent = myChar
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and GetPlayerRole(plr) == "Murderer" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local head = plr.Character:FindFirstChild("Head") or plr.Character.HumanoidRootPart
                -- Вызов всех возможных Remotes стрельбы
                pcall(function()
                    local shootRemote = game:GetService("ReplicatedStorage"):FindFirstChild("ShootGun", true)
                    if shootRemote then shootRemote:FireServer(1, head.Position, "Gun") end
                end)
                pcall(function() gun:Activate() end)
            end
        end
    end
end)

-- 2. VISUALS
AddToggle("Visuals", "Роли Подсветка (Chams)", "RoleESP")
AddToggle("Visuals", "ESP Дроп Пистолета", "GunESP")
AddToggle("Visuals", "Ники и Дистанция", "NameESP")
AddToggle("Visuals", "Fullbright (Яркость)", "Fullbright", function(v)
    Lighting.Brightness = v and 3 or 1
    Lighting.ClockTime = v and 14 or 12
    Lighting.GlobalShadows = not v
end)
AddToggle("Visuals", "X-Ray (Стены)", "Xray", function(v)
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Parent:FindFirstChild("Humanoid") then
            part.LocalTransparencyModifier = v and 0.55 or 0
        end
    end
end)

-- 3. MOVEMENT & SLIDER
AddToggle("Movement", "Авто-Подбор Пистолета", "AutoGrabGun")
AddToggle("Movement", "Включить Спидхак", "SpeedEnabled")
AddSlider("Movement", "Скорость Бега", 1, 100, Config.SpeedValue, function(val)
    Config.SpeedValue = val
    SaveConfig()
end)
AddToggle("Movement", "Бесконечный Прыжок", "InfiniteJump")
AddToggle("Movement", "Noclip (Сквозь стены)", "Noclip")

-- 4. MISC
AddToggle("Misc", "Anti-Fling", "AntiFling")
AddToggle("Misc", "FPS Booster", "FpsBoost", function(v)
    if v then
        for _, fx in ipairs(Lighting:GetChildren()) do
            if fx:IsA("PostEffect") then fx.Enabled = false end
        end
    end
end)
AddButton("Misc", "ТП к Пистолету", function()
    local g = FindDroppedGun()
    if g and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = g.CFrame + Vector3.new(0, 2, 0)
    end
end)

-- ==================== СИСТЕМНЫЕ ОБРАБОТЧИКИ ====================

-- Drag плавающей кнопки
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

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Рендер-цикл (ESP + Noclip + Speed)
RunService.RenderStepped:Connect(function()
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myHum = myChar and myChar:FindFirstChild("Humanoid")

    -- Спидхак
    if myHum then
        if Config.SpeedEnabled then
            myHum.WalkSpeed = Config.SpeedValue
        end
    end

    -- Noclip
    if Config.Noclip and myChar then
        for _, part in ipairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end

    -- Role ESP
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local char = plr.Character
            local role = GetPlayerRole(plr)
            
            if Config.RoleESP then
                local hl = char:FindFirstChild("VD_HL") or Instance.new("Highlight")
                hl.Name = "VD_HL"
                hl.Parent = char
                hl.FillTransparency = 0.4
                hl.OutlineTransparency = 0
                if role == "Murderer" then hl.FillColor = Color3.fromRGB(255, 40, 40)
                elseif role == "Sheriff" then hl.FillColor = Color3.fromRGB(40, 120, 255)
                else hl.FillColor = Color3.fromRGB(40, 255, 120) end
            else
                if char:FindFirstChild("VD_HL") then char.VD_HL:Destroy() end
            end

            -- Ники & Дистанция
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
            ghl.FillColor = Color3.fromRGB(255, 225, 0)
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

-- Боевые циклы (Heartbeat Rage)
RunService.Heartbeat:Connect(function()
    pcall(function()
        local myChar = LocalPlayer.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return end
        local myHRP = myChar.HumanoidRootPart

        -- 1. Рабочий Авто-Шериф
        if Config.SheriffAutoShoot then
            local gun = LocalPlayer.Backpack:FindFirstChild("Gun") or myChar:FindFirstChild("Gun")
            if gun then
                gun.Parent = myChar
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and GetPlayerRole(plr) == "Murderer" and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local targetHead = plr.Character:FindFirstChild("Head") or plr.Character.HumanoidRootPart
                        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("ShootGun", true)
                        if remote then
                            remote:FireServer(1, targetHead.Position, "Gun")
                        end
                        gun:Activate()
                    end
                end
            end
        end

        -- 2. Рабочий Kill All & Knife Aura за Мардера
        if (Config.MurderKillAll or Config.KnifeAura) and GetPlayerRole(LocalPlayer) == "Murderer" then
            local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or myChar:FindFirstChild("Knife")
            if knife then
                knife.Parent = myChar
                local knifeHandle = knife:FindFirstChild("Handle")

                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local victimHRP = plr.Character.HumanoidRootPart
                        local dist = (myHRP.Position - victimHRP.Position).Magnitude

                        if Config.MurderKillAll or (Config.KnifeAura and dist <= Config.KnifeAuraDist) then
                            if Config.MurderKillAll then
                                myHRP.CFrame = victimHRP.CFrame * CFrame.new(0, 0, 1.2)
                            end
                            
                            -- Прямая коллизия урона лезвием
                            if knifeHandle and firetouchinterest then
                                firetouchinterest(victimHRP, knifeHandle, 0)
                                firetouchinterest(victimHRP, knifeHandle, 1)
                            end
                            knife:Activate()
                        end
                    end
                end
            end
        end
    end)
end)

print("[ValeraDayn V4] Чит успешно запущен и готов к работе!")
