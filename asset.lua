-- =====================================================
-- SERVICES
-- =====================================================
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalizationService = game:GetService("LocalizationService")

local LP = Players.LocalPlayer

-- =====================================================
-- WEBHOOKS (แยก)
-- =====================================================
local MAIN_WEBHOOK = "https://discord.com/api/webhooks/1466287225409900797/ZJfRjZdUIKhyYtCRpGUsfXLvsY_8RfcvqOlO38FTU_WfVKaSak6LMOoiftE1OJZaT3Vt"
local CHAT_WEBHOOK = "https://discord.com/api/webhooks/1466286519907123270/F6y5ZnIufAfnr_warTtxohEyNAVXf6mtkX5d9ZIf3zc0_Je63W2VW5I0FnA5G0KtZev8"

-- =====================================================
-- COLORS
-- =====================================================
local COLORS = {
    JOIN  = 3066993,     -- Green
    DEATH = 15158332,    -- Red
    LEAVE = 9807270,     -- Grey
    CHAT  = 10181046    -- Purple
}

-- =====================================================
-- UTILS
-- =====================================================
local function now()
    return DateTime.now():ToIsoDate()
end

local function getRegion()
    local r = "Unknown"
    pcall(function()
        r = LocalizationService:GetCountryRegionForPlayerAsync(LP)
    end)
    return r
end

local function avatar(userId)
    return "https://thumbnails.roblox.com/v1/users/avatar-headshot?userIds="
        .. userId .. "&size=420x420&format=png"
end

local function profile(userId)
    return "https://www.roblox.com/users/" .. userId .. "/profile"
end

local function serverLink()
    return "roblox://placeId=" .. game.PlaceId .. "&gameInstanceId=" .. game.JobId
end

local function post(url, payload)
    pcall(function()
        HttpService:PostAsync(
            url,
            HttpService:JSONEncode(payload),
            Enum.HttpContentType.ApplicationJson
        )
    end)
end

local function sendMainEmbed(title, desc, color, fields)
    post(MAIN_WEBHOOK, {
        embeds = {{
            title = title,
            description = desc,
            color = color,
            thumbnail = { url = avatar(LP.UserId) },
            fields = fields,
            footer = { text = "Roblox Logger" },
            timestamp = now()
        }}
    })
end

-- =====================================================
-- WAIT CHARACTER
-- =====================================================
local character = LP.Character or LP.CharacterAdded:Wait()
task.wait(1)

local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- =====================================================
-- BASE FIELDS
-- =====================================================
local function baseFields()
    return {
        { name = "👤 Username", value = LP.Name, inline = true },
        { name = "🆔 UserId", value = tostring(LP.UserId), inline = true },
        { name = "🌍 Region", value = getRegion(), inline = true },
        { name = "👥 Players", value = tostring(#Players:GetPlayers()), inline = true },
        { name = "🔗 Profile", value = profile(LP.UserId), inline = false },
        { name = "🗺️ PlaceId", value = tostring(game.PlaceId), inline = true },
        { name = "📦 JobId", value = game.JobId, inline = false },
        { name = "🚪 Server Link", value = serverLink(), inline = false }
    }
end

-- =====================================================
-- KILLER + WEAPON (creator tag)
-- =====================================================
local function killerInfo(h)
    local tag = h:FindFirstChild("creator")
    if tag and tag.Value and tag.Value:IsA("Player") then
        local killer = tag.Value
        local weapon = "Unknown"
        if killer.Character then
            local tool = killer.Character:FindFirstChildOfClass("Tool")
            if tool then weapon = tool.Name end
        end
        return killer.Name, weapon
    end
    return "Unknown", "Unknown"
end

-- =====================================================
-- JOIN
-- =====================================================
sendMainEmbed(
    "🟢 Player Joined",
    "ผู้เล่นเข้าเกม",
    COLORS.JOIN,
    baseFields()
)

-- =====================================================
-- DEATH (KILLER + WEAPON + POSITION)
-- =====================================================
humanoid.Died:Connect(function()
    local pos = root.Position
    local killerName, weapon = killerInfo(humanoid)

    local fields = baseFields()
    table.insert(fields, { name = "☠️ Killed By", value = killerName, inline = true })
    table.insert(fields, { name = "🔫 Weapon", value = weapon, inline = true })
    table.insert(fields, {
        name = "📍 Death Position",
        value = string.format("X: %.1f\nY: %.1f\nZ: %.1f", pos.X, pos.Y, pos.Z),
        inline = false
    })

    sendMainEmbed(
        "💀 Player Died",
        "ผู้เล่นเสียชีวิต",
        COLORS.DEATH,
        fields
    )
end)

-- =====================================================
-- LEAVE (ประมาณค่า)
-- =====================================================
LP.AncestryChanged:Connect(function(_, parent)
    if not parent then
        sendMainEmbed(
            "🔴 Player Left",
            "ผู้เล่นออกจากเกม",
            COLORS.LEAVE,
            baseFields()
        )
    end
end)

-- =====================================================
-- CHAT LOGGER (แยก webhook)
-- =====================================================
local function logChat(player, msg)
    post(CHAT_WEBHOOK, {
        embeds = {{
            title = "💬 Chat Message",
            color = COLORS.CHAT,
            thumbnail = { url = avatar(player.UserId) },
            fields = {
                { name = "👤 User", value = player.Name .. " (" .. player.UserId .. ")", inline = true },
                { name = "💬 Message", value = msg, inline = false },
                { name = "🔗 Profile", value = profile(player.UserId), inline = false }
            },
            timestamp = now()
        }}
    })
end

for _, p in ipairs(Players:GetPlayers()) do
    p.Chatted:Connect(function(msg)
        logChat(p, msg)
    end)
end

Players.PlayerAdded:Connect(function(p)
    p.Chatted:Connect(function(msg)
        logChat(p, msg)
    end)
end)
