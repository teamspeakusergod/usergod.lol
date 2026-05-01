-- // SERVICES
local player = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")
local runService = game:GetService("RunService")
local tweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Camera = workspace.CurrentCamera

-- // STATES
local camlockOn = false
local speedOn = false
local target = nil
local espOn = true
local lockPart = "Head" -- 🔥 "Head" หรือ "HumanoidRootPart"

-- // GUI
local gui = Instance.new("ScreenGui")
gui.Name = "UserGodUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 320, 0, 300)
frame.Position = UDim2.new(0.5, -160, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(10,10,10)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,18)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "USERGOD"
title.Font = Enum.Font.GothamBlack
title.TextSize = 24
title.TextColor3 = Color3.fromRGB(255,255,255)

local status = Instance.new("TextLabel", frame)
status.Size = UDim2.new(1,0,0,30)
status.Position = UDim2.new(0,0,1,-35)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(180,180,180)
status.Font = Enum.Font.Gotham
status.TextSize = 16

-- // BUTTON
local function createButton(text, y)
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1,-30,0,45)
	btn.Position = UDim2.new(0,15,0,y)
	btn.BackgroundColor3 = Color3.fromRGB(20,20,20)
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 17
	btn.TextColor3 = Color3.fromRGB(255,255,255)

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)

	btn.MouseEnter:Connect(function()
		tweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(35,35,35)
		}):Play()
	end)

	btn.MouseLeave:Connect(function()
		tweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(20,20,20)
		}):Play()
	end)

	return btn
end

-- // BUTTONS
local speedBtn = createButton("Speed : OFF (X)", 60)
local camBtn = createButton("Camlock : OFF (C)", 110)
local partBtn = createButton("Lock : HEAD (V)", 160)
local espBtn = createButton("ESP : ON", 210)

-- // UI
local function updateUI()
	speedBtn.Text = "Speed : "..(speedOn and "ON" or "OFF")
	camBtn.Text = "Camlock : "..(camlockOn and "ON" or "OFF")
	espBtn.Text = "ESP : "..(espOn and "ON" or "OFF")
	partBtn.Text = "Lock : "..(lockPart == "Head" and "HEAD" or "BODY")
	status.Text = speedOn and "Speed Active" or ""
end

-- // TARGET
local function getClosest()
	local mouse = player:GetMouse()
	local closest, shortest = nil, math.huge

	for _,v in pairs(Players:GetPlayers()) do
		if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
			local pos, visible = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
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

-- // TOGGLES
local function toggleSpeed()
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

local function togglePart()
	lockPart = (lockPart == "Head") and "HumanoidRootPart" or "Head"
	updateUI()
end

-- // EVENTS
speedBtn.MouseButton1Click:Connect(toggleSpeed)
camBtn.MouseButton1Click:Connect(toggleCam)
espBtn.MouseButton1Click:Connect(toggleESP)
partBtn.MouseButton1Click:Connect(togglePart)

uis.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.X then toggleSpeed() end
	if input.KeyCode == Enum.KeyCode.C then toggleCam() end
	if input.KeyCode == Enum.KeyCode.V then togglePart() end
	if input.KeyCode == Enum.KeyCode.T then gui.Enabled = not gui.Enabled end
end)

-- // SPEED (ไม่ทับ slow เกม)
runService.RenderStepped:Connect(function()
	if player.Character and player.Character:FindFirstChild("Humanoid") then
		local hum = player.Character.Humanoid
		if speedOn then
			hum.WalkSpeed = 500
		end
	end
end)

-- // CAMLOCK
runService.RenderStepped:Connect(function()
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
			return
		end

		if char and char:FindFirstChild(lockPart) then
			Camera.CFrame = CFrame.new(
				Camera.CFrame.Position,
				char[lockPart].Position
			)
		end
	end
end)

-- // ESP
local ESPs = {}

local function createESP(plr)
	if plr == player then return end

	local box = Drawing.new("Square")
	box.Thickness = 2
	box.Color = Color3.fromRGB(255,0,0)
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

for _,plr in ipairs(Players:GetPlayers()) do
	createESP(plr)
end

Players.PlayerAdded:Connect(function(plr)
	task.wait(0.3)
	createESP(plr)
end)

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
				local size = Vector2.new(40,60) * scale

				esp.box.Size = size
				esp.box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
				esp.box.Visible = true

				esp.name.Text = plr.DisplayName
				esp.name.Position = Vector2.new(pos.X, pos.Y - size.Y/2 - 15)
				esp.name.Visible = true
			else
				esp.box.Visible = false
				esp.name.Visible = false
			end
		end
	end
end)

updateUI()
