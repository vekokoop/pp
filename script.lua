-- Tribes 3v3 VIP Script Hub v3 (Mobile Optimized & Team Check Fixed)

-- 1. المزامنة عند الانتقال
local queue_on_teleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
if queue_on_teleport then
    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/vekokoop/op/refs/heads/main/script.lua", true))()')
end

-- 2. تحميل مكتبة الواجهة
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/jensonhirst/Orion/main/source"))()
local Window = OrionLib:MakeWindow({
    Name = "Tribes 3v3 - VIP Hub 👑",
    HidePremium = false,
    SaveConfig = false,
    ConfigFolder = "TribesVIP"
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

---------------------------------------------------------
-- إنشاء زر عائم متحرك يدعم السحب
---------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "VIP_FloatingToggle"
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

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
    if OrionLib then
        -- تبديل حالة ظهور القائمة
        local OrionGui = game:GetService("CoreGui"):FindFirstChild("Orion") or (gethui and gethui():FindFirstChild("Orion"))
        if OrionGui then
            OrionGui.Enabled = not OrionGui.Enabled
        end
    end
end)

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
-- TAB 2: كشف الأعداء والفريق (ESP)
---------------------------------------------------------
local VisualTab = Window:MakeTab({
    Name = "كشف الأماكن",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ESP_Enabled = false

local function applyESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ESP_Highlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.Parent = player.Character
            end

            -- تمييز الأعداء باللون الأحمر والفريق باللون الأخضر
            if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                highlight.FillColor = Color3.fromRGB(0, 255, 0) -- أخضر للفريق
            else
                highlight.FillColor = Color3.fromRGB(255, 0, 0) -- أحمر للأعداء
            end
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.Enabled = ESP_Enabled
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

-- إعادة تطبيق الـ ESP تلقائياً عند تجدد اللاعبين أو بدء جول جديدة
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if ESP_Enabled then applyESP() end
    end)
end)

RunService.Stepped:Connect(function()
    if ESP_Enabled then
        applyESP()
    end
end)

---------------------------------------------------------
-- TAB 3: مساعد التصويب والـ FOV
---------------------------------------------------------
local AimbotTab = Window:MakeTab({
    Name = "مساعد التصويب",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local AimbotEnabled = false
local FOV_Radius = 150

local Drawing = Drawing or import("drawing_lib")
local fovCircle = nil

if Drawing then
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible = false
    fovCircle.Radius = FOV_Radius
    fovCircle.Color = Color3.fromRGB(255, 215, 0)
    fovCircle.Thickness = 1.5
    fovCircle.Filled = false
    fovCircle.Transparency = 0.8
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

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

-- خيارات حجم الدائرة بأزرار مخصصة لتسهيل التحكم على الموبايل
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

-- البحث عن أقرب هدف (استثناء أعضاء الفريق)
local function getClosestTarget()
    local closestTarget = nil
    local maxDistance = FOV_Radius

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            -- تحقق من عدم وجود الهدف في نفس الفريق
            local isEnemy = true
            if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
                isEnemy = false
            end

            if isEnemy then
                local targetPart = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
                local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

                if targetPart and humanoid and humanoid.Health > 0 then
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen then
                        local centerScreen = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - centerScreen).Magnitude

                        if dist < maxDistance then
                            maxDistance = dist
                            closestTarget = targetPart
                        end
                    end
                end
            end
        end
    end
    return closestTarget
end

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local target = getClosestTarget()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

OrionLib:Init()
