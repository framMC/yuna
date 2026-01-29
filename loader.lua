loadstring(game:HttpGet("https://github.com/exxtremestuffs/SimpleSpySource/raw/master/SimpleSpy.lua"))()

local InfiniteJump = true

game:GetService("UserInputService").JumpRequest:Connect(function()
    if InfiniteJump then
        local h = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)


-- =========================
-- NOCLIP
-- =========================
local Noclip = true
game:GetService("RunService").Stepped:Connect(function()
    if Noclip then
        for _,v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)


-- =========================
-- ESP TEAM
-- =========================
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local function ESP(p)
    if p == LP then return end
    p.CharacterAdded:Connect(function(c)
        local h = c:WaitForChild("Head")
        local b = Instance.new("BillboardGui", h)
        b.Size = UDim2.new(0,200,0,40)
        b.AlwaysOnTop = true

        local t = Instance.new("TextLabel", b)
        t.Size = UDim2.new(1,0,1,0)
        t.BackgroundTransparency = 1
        t.Text = p.Name
        t.TextScaled = true

        if p.Team == LP.Team then
            t.TextColor3 = Color3.fromRGB(0,255,0)
        else
            t.TextColor3 = Color3.fromRGB(255,0,0)
        end
    end)
end

for _,p in pairs(Players:GetPlayers()) do
    ESP(p)
end
