-- Tribes 3v3 VIP Script Hub v8 (Fixed Team Detection & Working Aimbot)

---------------------------------------------------------
-- 0. تنظيف أي سكربت أو واجهة سابقة لمنع التداخل
---------------------------------------------------------
if _G.TribesVIP_Loaded then
    if _G.TribesVIP_Cleanup then
        pcall(_G.TribesVIP_Cleanup)
    end
end
_G.TribesVIP_Loaded = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- مسح الهايلايت والواجهات القديمة بأمان
pcall(function()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name == "VIP_FloatingToggle" or v.Name == "Orion" then
            v:Destroy()
        end
    end
end)

---------------------------------------------------------
-- 1. المزامنة عند التنقل بين الماب واللوبي
---------------------------------------------------------
local queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
if queue_on_teleport then
    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/vekokoop/pp/refs/heads/main/script.lua", true))()')
end

---------------------------------------------------------
-- 2. تحميل مكتبة الواجهة
---------------------------------------------------------
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Window = OrionLib:MakeWindow({
    Name = "Tribes 3v3 - VIP Hub 👑",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "TribesVIP"
})

---------------------------------------------------------
-- 3. الأيقونة العائمة القابلة للسحب
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "VIP_FloatingToggle"
local successGui, targetGui = pcall(function()
    return gethui()
end)
ScreenGui.Parent = (successGui and targetGui) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ToggleButton.Position = UDim2.new(0.05, 0, 0.2, 0)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Text = "👑 VIP"
ToggleButton.TextColor3 = Color3.fromRGB(255, 215, 0)
ToggleButton.TextSize = 16
ToggleButton.Active = true
ToggleButton.Draggable = true

UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ToggleButton

ToggleButton.MouseButton1Click:Connect(function()
    pcall(function()
        local OrionGui = game:GetService("CoreGui"):FindFirstChild("Orion") or (gethui and gethui():FindFirstChild("Orion"))
        if OrionGui then
            OrionGui.Enabled = not OrionGui.Enabled
        end
    end)
end)

---------------------------------------------------------
-- دالة التحقق الذكي من الفرق (تم حل مشكلة الـ nil)
---------------------------------------------------------
local function isTeammate(player)
    if player == LocalPlayer then return true end
    if player.Team and LocalPlayer.Team then
        return player.Team == LocalPlayer.Team
    end
    -- إذا لم تكن هناك فرق روبلوكس رسمية، نعتبر البقية أعداء ليعمل الكشف والأيم بوت
    return false
end

---------------------------------------------------------
-- TAB 1: حركة اللاعب
---------------------------------------------------------
local MainTab = Window:MakeTab({
    Name = "اللاعب والحركة",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

MainTab:AddSlider({
    Name = "السرعة (WalkSpeed)",
    Min = 16,
    Max = 150,
    Default = 16,
    Color = Color3.fromRGB(255, 215, 0),
    Increment = 1,
    ValueName = "سرعة",
    Callback = function(s)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = s
        end
    end
})

MainTab:AddSlider({
    Name = "قوة القفز (JumpPower)",
    Min = 50,
    Max = 200,
    Default = 50,
    Color = Color3.fromRGB(255, 215, 0),
    Increment = 1,
    ValueName = "قوة",
    Callback = function(s)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = s
        end
    end
})

---------------------------------------------------------
-- TAB 2: كشف الأماكن (ESP) - (الخصم أحمر والتيم أخضر)
---------------------------------------------------------
local VisualTab = Window:MakeTab({
    Name = "كشف الأماكن",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ESP_Enabled = false

local function removeESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("ESP_Highlight") then
            p.Character.ESP_Highlight:Destroy()
        end
    end
end

local function applyESP()
    if not ESP_Enabled then 
        removeESP()
        return 
    end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ESP_Highlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.Parent = player.Character
            end

            -- تيمك أخضر والخصم أحمر
            if isTeammate(player) then
                highlight.FillColor = Color3.fromRGB(0, 255, 0)   -- أخضر للتيم
            else
                highlight.FillColor = Color3.fromRGB(255, 0, 0)   -- أحمر للخصم
            end
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Enabled = true
        end
    end
end

VisualTab:AddToggle({
    Name = "تفعيل كشف الأماكن التلقائي",
    Default = false,
    Callback = function(state)
        ESP_Enabled = state
        applyESP()
    end
})

local espConnection = RunService.Stepped:Connect(function()
    if ESP_Enabled then
        applyESP()
    end
end)

---------------------------------------------------------
-- TAB 3: مساعد التصويب الفوري (Aimbot)
---------------------------------------------------------
local AimbotTab = Window:MakeTab({
    Name = "مساعد التصويب",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local AimbotEnabled = false
local FOV_Radius = 150

local DrawingLib = (typeof(Drawing) == "table" and Drawing) or nil
local fovCircle = nil

if DrawingLib then
    pcall(function()
        fovCircle = DrawingLib.new("Circle")
        fovCircle.Visible = false
        fovCircle.Radius = FOV_Radius
        fovCircle.Color = Color3.fromRGB(255, 215, 0)
        fovCircle.Thickness = 1.5
        fovCircle.Filled = false
        fovCircle.Transparency = 0.8
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end)

    RunService.RenderStepped:Connect(function()
        if fovCircle then
            fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        end
    end)
end

AimbotTab:AddToggle({
    Name = "إظهار دائرة الـ FOV",
    Default = false,
    Callback = function(state)
        if fovCircle then
            fovCircle.Visible = state
        end
    end
})

AimbotTab:AddToggle({
    Name = "تفعيل التصويب التلقائي",
    Default = false,
    Callback = function(state)
        AimbotEnabled = state
    end
})

AimbotTab:AddButton({
    Name = "تكبير دائرة FOV (+25)",
    Callback = function()
        FOV_Radius = math.min(FOV_Radius + 25, 500)
        if fovCircle then fovCircle.Radius = FOV_Radius end
    end
})

AimbotTab:AddButton({
    Name = "تصغير دائرة FOV (-25)",
    Callback = function()
        FOV_Radius = math.max(FOV_Radius - 25, 30)
        if fovCircle then fovCircle.Radius = FOV_Radius end
    end
})

-- دالة البحث عن أقرب عدو داخل الدائرة واستثناء التيم
local function getClosestEnemyTarget()
    local closestTarget = nil
    local maxDistance = FOV_Radius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not isTeammate(player) and player.Character then
            local targetPart = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

            if targetPart and humanoid and humanoid.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude

                    if dist < maxDistance then
                        maxDistance = dist
                        closestTarget = targetPart.Position
                    end
                end
            end
        end
    end
    return closestTarget
end

local aimConnection = RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local targetPos = getClosestEnemyTarget()
        if targetPos then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end
    end
end)

-- تنظيف العمليات عند الخروج أو إعادة التحميل
_G.TribesVIP_Cleanup = function()
    if espConnection then espConnection:Disconnect() end
    if aimConnection then aimConnection:Disconnect() end
    removeESP()
    if fovCircle then
        pcall(function() fovCircle:Remove() end)
    end
    pcall(function() ScreenGui:Destroy() end)
end

OrionLib:Init()
