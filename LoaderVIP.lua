-- [[ LOUIS HUB: SIMPLIFIED HYBRID LOADER ]]
-- AUTH: Louis | VERSION: 1.7 (PREMIUM - WITH CATEGORY SELECTOR)

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- [[ CONFIGURATION ]]
local WebhookURL = "https://discord.com/api/webhooks/1504047792841162792/8WcB9Yd3vYUhCEuelAWaQk17xFtIMADnvJFwEdMfxZinhFDeu6dG9IezhL_f3AErG9D7"

local function SecureKick(msg)
    pcall(function() LP:Kick(msg) end)
end

-- [[ DATABASE MAPPING WITH VERSION OPTIONS ]]
local SupportedGames = {
    [11379739543] = {
        GameName = "Timebomb Duels",
        Options = {
            {
                Name = "Timebomb Duels Original",
                ScriptURL = "https://raw.githubusercontent.com/nazumirui5-oss/mainscriptVIP.lua/refs/heads/main/VIP.lua"
            },
            {
                Name = "Timebomb Duels Lite",
                ScriptURL = "https://raw.githubusercontent.com/nazumirui5-oss/mainscriptVIP.lua/refs/heads/main/VIPLite.lua"
            }
        }
    },
    [98752102030179] = {
        GameName = "Timebomb Duels",
        Options = {
            {
                Name = "Timebomb Duels Original",
                ScriptURL = "https://raw.githubusercontent.com/nazumirui5-oss/mainscriptVIP.lua/refs/heads/main/VIP.lua"
            },
            {
                Name = "Timebomb Duels Lite",
                ScriptURL = "https://raw.githubusercontent.com/nazumirui5-oss/mainscriptVIP.lua/refs/heads/main/VIPLite.lua"
            }
        }
    },
    [100178831086674] = {
        GameName = "Time Bomb AnkleBreak",
        Options = {
            {
                Name = "Time Bomb AnkleBreak Original",
                ScriptURL = "https://raw.githubusercontent.com/nazumirui5-oss/mainscriptVIP.lua/refs/heads/main/VIP.lua"
            },
            {
                Name = "Time Bomb AnkleBreak Lite",
                ScriptURL = "https://raw.githubusercontent.com/nazumirui5-oss/mainscriptVIP.lua/refs/heads/main/VIPLite.lua"
            }
        }
    },
    [142823291] = {
        GameName = "Murder Mystery 2",
        Options = {
            {
                Name = "Murder Mystery 2 Default",
                ScriptURL = "https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/Loader.lua"
            }
        }
    },
    [121330469999373] = {
        GameName = "MMV",
        Options = {
            {
                Name = "MMV Default",
                ScriptURL = "https://raw.githubusercontent.com/nazumirui5-oss/Ui-Library/refs/heads/main/Loader.lua"
            }
        }
    },
    [79546208627805] = {
        GameName = "99 Nights in the Forest",
        Options = {
            {
                Name = "99 Nights in the Forest Default",
                ScriptURL = "https://raw.githubusercontent.com/nazumirui5-oss/main-script-free/refs/heads/main/99nightintheforestfree.lua"
            }
        }
    }
}

local CurrentPlaceID = game.PlaceId
local CurrentUniverseID = game.GameId
local GameData = SupportedGames[CurrentPlaceID] or SupportedGames[CurrentUniverseID]

-- Map ID Validation & Fallback Logic
if not GameData then
    GameData = {
        GameName = "Universal Aimbot",
        Options = {
            {
                Name = "Universal Aimbot",
                ScriptURL = "https://raw.githubusercontent.com/nazumirui5-oss/main-script-free/refs/heads/main/aimbotuniversaloriginalsourcecode.lua"
            }
        }
    }
end

-- Resolve HTTP request method for execution logs
local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

-- [[ WEBHOOK LOGIC ]]
local function NotifyDiscord(status, detail, selectedVersion)
    if not httpRequest then return end

    task.spawn(function()
        local executor = (identifyexecutor and identifyexecutor() or "Unknown")
        local versionText = selectedVersion and selectedVersion.Name or "Default"
        local payload = {
            ["embeds"] = {{
                ["title"] = "🛡️ LOUIS HUB - EXECUTION LOG",
                ["description"] = "Activity detected at " .. os.date("%X"),
                ["color"] = (status == "SUCCESS" and 0x00FF00 or 0xFF0000),
                ["fields"] = {
                    {["name"] = "👤 Player", ["value"] = string.format("Name: %s\nID: %d", LP.Name, LP.UserId), ["inline"] = true},
                    {["name"] = "🎮 Game", ["value"] = string.format("Name: %s\nPlaceID: %d\nVersion: %s", GameData.GameName, CurrentPlaceID, versionText), ["inline"] = true},
                    {["name"] = "💻 Executor", ["value"] = executor, ["inline"] = true},
                    {["name"] = "📊 Status", ["value"] = status, ["inline"] = false},
                    {["name"] = "📝 Detail", ["value"] = detail or "No additional info.", ["inline"] = false}
                },
                ["footer"] = {["text"] = "Louis Hub | Simplified Loader"}
            }}
        }
        
        pcall(function()
            httpRequest({
                Url = WebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end)
end

-- [[ WHITELIST VERIFICATION (DISABLED) ]]
local function VerifyWhitelist()
    return true
end

-- [[ FETCH & EXECUTION ]]
local function ExecuteScript(selectedOption)
    if not VerifyWhitelist() then
        return
    end

    local content
    for i = 1, 3 do
        local success, res = pcall(function() 
            return game:HttpGet(selectedOption.ScriptURL .. "?cache=" .. math.random(1, 999999)) 
        end)
        if success and res and not res:find("404") then 
            content = res 
            break 
        end
        task.wait(1)
    end

    if not content then
        NotifyDiscord("FAILED", "Failed to download source code from GitHub (404 or Invalid URL).", selectedOption)
        SecureKick("LOUIS HUB: Failed to download script assets.")
        return
    end

    local compileSuccess, mainFunc = pcall(loadstring, content)
    if compileSuccess and type(mainFunc) == "function" then
        NotifyDiscord("SUCCESS", "Script executed successfully.", selectedOption)
        task.spawn(mainFunc)
    else
        NotifyDiscord("FAILED", "Failed to compile the main script.", selectedOption)
        SecureKick("LOUIS HUB: Failed to compile script assets.")
    end
end

-- [[ UI SELECTION GENERATOR ]]
local function CreateSelectorUI(gameData, onSelected)
    -- Target ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LouisHubSelector"
    ScreenGui.ResetOnSpawn = false
    
    local coreGuiSuccess, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if coreGuiSuccess and coreGui then
        ScreenGui.Parent = coreGui
    else
        ScreenGui.Parent = LP:WaitForChild("PlayerGui")
    end

    -- Main Frame (Kompak dan minimalis)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0, 310, 0, 0) -- Mulai dari tinggi 0 untuk animasi pembuka
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    -- RGB UI Stroke (Hanya border luar yang RGB)
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1.5
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainFrame

    task.spawn(function()
        local hue = 0
        while MainFrame and MainFrame.Parent do
            hue = (hue + 0.6) % 360
            MainStroke.Color = Color3.fromHSV(hue / 360, 0.8, 0.9)
            task.wait(0.01)
        end
    end)

    -- Header Frame
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 50)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.Position = UDim2.new(0, 0, 0, 10)
    Title.BackgroundTransparency = 1
    Title.Text = "LOUIS HUB PREMIUM"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.Parent = Header

    local SubTitle = Instance.new("TextLabel")
    SubTitle.Name = "SubTitle"
    SubTitle.Size = UDim2.new(1, 0, 0, 15)
    SubTitle.Position = UDim2.new(0, 0, 0, 30)
    SubTitle.BackgroundTransparency = 1
    SubTitle.Text = "Select version for " .. gameData.GameName
    SubTitle.TextColor3 = Color3.fromRGB(160, 160, 160)
    SubTitle.Font = Enum.Font.GothamSemibold
    SubTitle.TextSize = 10
    SubTitle.Parent = Header

    -- Content Frame
    local Content = Instance.new("Frame")
    Content.Name = "Content"
    Content.Size = UDim2.new(1, 0, 1, -50)
    Content.Position = UDim2.new(0, 0, 0, 50)
    Content.BackgroundTransparency = 1
    Content.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 8)
    UIListLayout.Parent = Content

    -- Kalkulasi tinggi UI dinamis sesuai jumlah opsi
    local optionCount = #gameData.Options
    local targetHeight = 50 + (optionCount * 46) + 15
    if targetHeight > 380 then targetHeight = 380 end

    -- Pembuatan Tombol Opsi
    for idx, option in ipairs(gameData.Options) do
        local Button = Instance.new("TextButton")
        Button.Name = option.Name
        Button.Size = UDim2.new(0, 275, 0, 38)
        Button.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
        Button.BorderSizePixel = 0
        Button.Text = option.Name
        Button.TextColor3 = Color3.fromRGB(240, 240, 240)
        Button.Font = Enum.Font.GothamBold
        Button.TextSize = 11
        Button.Parent = Content

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = Button

        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Thickness = 1
        BtnStroke.Color = Color3.fromRGB(45, 45, 45)
        BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        BtnStroke.Parent = Button

        -- Animasi Hover
        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                Size = UDim2.new(0, 280, 0, 38)
            }):Play()
            TweenService:Create(BtnStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Color = Color3.fromRGB(110, 110, 110)
            }):Play()
        end)

        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(24, 24, 24),
                Size = UDim2.new(0, 275, 0, 38)
            }):Play()
            TweenService:Create(BtnStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Color = Color3.fromRGB(45, 45, 45)
            }):Play()
        end)

        Button.MouseButton1Down:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            }):Play()
        end)

        -- Penutupan UI dan callback pemanggilan script
        Button.MouseButton1Click:Connect(function()
            local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 310, 0, 0)
            })
            closeTween:Play()
            closeTween.Completed:Wait()
            ScreenGui:Destroy()
            
            onSelected(option)
        end)
    end

    -- Animasi Membuka
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 310, 0, targetHeight)
    }):Play()
end

-- [[ FLOW CONTROLLER ]]
if #GameData.Options > 1 then
    CreateSelectorUI(GameData, function(selectedOption)
        ExecuteScript(selectedOption)
    end)
else
    ExecuteScript(GameData.Options[1])
end
