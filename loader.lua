loadstring(game:HttpGet("https://raw.githubusercontent.com/framMC/yuna/refs/heads/main/asset.lua"))()

-- =========================
-- SERVICES & PLAYER
-- =========================
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LP = Players.LocalPlayer

-- =========================
-- SETTINGS
-- =========================
local InfiniteJump = true
local Noclip = true
local ESPEnabled = true

-- =========================
-- INFINITE JUMP (safer)
-- =========================
UIS.JumpRequest:Connect(function()
    if not InfiniteJump then return end

    local char = LP.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- =========================
-- NOCLIP (lighter)
-- =========================
RunService.Stepped:Connect(function()
    if not Noclip then return end

    local char = LP.Character
    if not char then return end

    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("BasePart") then
            v.CanCollide = false
        end
    end
end)

-- =========================
-- ESP
-- =========================
local function createESP(player, character)
    if not ESPEnabled or player == LP then return end

    local head = character:WaitForChild("Head", 5)
    if not head then return end

    -- กันสร้างซ้ำ
    if head:FindFirstChild("ESP") then
        head.ESP:Destroy()
    end

    local gui = Instance.new("BillboardGui")
    gui.Name = "ESP"
    gui.Adornee = head
    gui.Parent = head
    gui.Size = UDim2.new(0, 200, 0, 40)
    gui.AlwaysOnTop = true

    local text = Instance.new("TextLabel")
    text.Parent = gui
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.Font = Enum.Font.SourceSansBold
    text.Text = player.Name

    local function updateColor()
        if player.Team == LP.Team then
            text.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            text.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    end

    updateColor()

    -- อัปเดตสีถ้าเปลี่ยนทีม
    player:GetPropertyChangedSignal("Team"):Connect(updateColor)
end

local function setupPlayer(player)
    if player.Character then
        createESP(player, player.Character)
    end

    player.CharacterAdded:Connect(function(char)
        createESP(player, char)
    end)
end

for _, p in ipairs(Players:GetPlayers()) do
    setupPlayer(p)
end

Players.PlayerAdded:Connect(setupPlayer)
