local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")

local camlockOn = false
local speedOn = false
local speedEnabled = false
local target = nil
local espOn = true

local gui = Instance.new("ScreenGui", player.PlayerGui)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 300)
frame.Position = UDim2.new(0.5, -150, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(5,5,5)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0,16)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(80,80,80)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.Text = "usergod"
title.TextColor3 = Color3.fromRGB(255,255,255)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.TextSize = 22

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,0,0,30)
status.Position = UDim2.new(0,0,1,-40)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(200,200,200)
status.Font = Enum.Font.GothamBold
status.TextSize = 18

local function createButton(text, y)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1,-20,0,50)
	btn.Position = UDim2.new(0,10,0,y)
	btn.BackgroundColor3 = Color3.fromRGB(15,15,15)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

	btn.MouseEnter:Connect(function()
		tweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(30,30,30)
		}):Play()
	end)
	btn.MouseLeave:Connect(function()
		tweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(15,15,15)
		}):Play()
	end)

	return btn
end

local function getClosest()
	local mouse = player:GetMouse()
	local closest = nil
	local shortest = math.huge

	for _,v in pairs(game.Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			local pos, visible = workspace.CurrentCamera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
			if visible then
				local dist = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
				if dist < shortest then
					shortest = dist
					closest = v
				end
			end
		end
	end
	return closest
end

-- BUTTONS
local safetyBtn = createButton("OFF Safety", 60)
local speedBtn = createButton("OFF Speed (X)", 120)
local camBtn = createButton("OFF Camlock (C)", 180)
local espBtn = createButton("ON ESP", 240)

local function updateUI()
	safetyBtn.Text = speedEnabled and "ON Safety" or "OFF Safety"
	speedBtn.Text = speedOn and "ON Speed (X)" or "OFF Speed (X)"
	camBtn.Text = camlockOn and "ON Camlock (C)" or "OFF Camlock (C)"
	espBtn.Text = espOn and "ON ESP" or "OFF ESP"

	status.Text = (speedOn and speedEnabled) and "SPEED ACTIVE" or ""
end

local function toggleSafety()
	speedEnabled = not speedEnabled
	if not speedEnabled then speedOn = false end
	updateUI()
end

local function toggleSpeed()
	if not speedEnabled then return end
	speedOn = not speedOn
	updateUI()
end

local function toggleCam()
	camlockOn = not camlockOn
	target = camlockOn and getClosest() or nil
	updateUI()
end

local function toggleESP()
	espOn = not espOn
	updateUI()
end

safetyBtn.MouseButton1Click:Connect(toggleSafety)
speedBtn.MouseButton1Click:Connect(toggleSpeed)
camBtn.MouseButton1Click:Connect(toggleCam)
espBtn.MouseButton1Click:Connect(toggleESP)

-- KEY (T เปิด UI)
uis.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.X then toggleSpeed() end
	if input.KeyCode == Enum.KeyCode.C then toggleCam() end
	if input.KeyCode == Enum.KeyCode.T then
		gui.Enabled = not gui.Enabled
	end
end)

runService.RenderStepped:Connect(function()
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid.WalkSpeed = (speedOn and speedEnabled) and 500 or 16
	end

	if camlockOn and target then
		local char = target.Character

		local knocked = char 
			and char:FindFirstChild("BodyEffects") 
			and char.BodyEffects:FindFirstChild("K.O") 
			and char.BodyEffects["K.O"].Value == true

		if knocked then
			target = nil
			camlockOn = false
			updateUI()
		else
			if char and char:FindFirstChild("HumanoidRootPart") then
				workspace.CurrentCamera.CFrame = CFrame.new(
					workspace.CurrentCamera.CFrame.Position,
					char.HumanoidRootPart.Position
				)
			end
		end
	end
end)

-- ESP
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera
local ESPs = {}

local function createESP(plr)
    if plr == player then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Filled = false
    box.Visible = false

    local name = Drawing.new("Text")
    name.Size = 14
    name.Center = true
    name.Outline = true
    name.Color = Color3.fromRGB(255,255,255)
    name.Visible = false

    ESPs[plr] = {box = box, name = name}
end

local function removeESP(plr)
    if ESPs[plr] then
        ESPs[plr].box:Remove()
        ESPs[plr].name:Remove()
        ESPs[plr] = nil
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    createESP(plr)
end

Players.PlayerAdded:Connect(createESP)
Players.PlayerRemoving:Connect(removeESP)

runService.RenderStepped:Connect(function()
    for plr, esp in pairs(ESPs) do

        if not espOn then
            esp.box.Visible = false
            esp.name.Visible = false
            continue
        end

        local char = plr.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local hrp = char.HumanoidRootPart
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                local scale = 1 / (hrp.Position - Camera.CFrame.Position).Magnitude * 100
                local size = Vector2.new(40, 60) * scale

                esp.box.Size = size
                esp.box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                esp.box.Visible = true

                esp.name.Text = tostring(plr.DisplayName)
                esp.name.Position = Vector2.new(pos.X, pos.Y - size.Y/2 - 15)
                esp.name.Visible = true
            else
                esp.box.Visible = false
                esp.name.Visible = false
            end
        else
            esp.box.Visible = false
            esp.name.Visible = false
        end
    end
end)

updateUI()
