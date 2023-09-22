-- Player Controller which handled movement abilities for an MMORPG

uis.InputBegan:connect(function(input, gameEvent)
	
	-- Make sure Player is able to perform any ability
	if plr.Character:GetAttribute("IsDowned") == true then return end
	if plr.Character:GetAttribute("IsStunned") == true then return end
	if plr:GetAttribute("Dialogue") == true then return end
	if _G.Blocking == true then return end
	
	if not gameEvent then
		
		-- Gamepad Controls 
		if input.UserInputType == Enum.UserInputType.Gamepad1 and plr:GetAttribute("InMenu") ~= true then
			if input.KeyCode == Enum.KeyCode.ButtonB then
				if dashCombo == true then
					local root = plr.Character:FindFirstChild("HumanoidRootPart")
					if root and _G.AnimSet["dash"] then
						local human = plr.Character:FindFirstChild("Humanoid")
						if humanoid.FloorMaterial ~= Enum.Material.Air and humanoid.FloorMaterial ~= nil then
							if (os.clock() - maneuverTick) < 1 then return end
							if (os.clock() - frontdashtick) < dashcooldown then return end
							maneuverTick = os.clock()
							frontdashtick = os.clock()
							canDash = false
							local root = plr.Character:FindFirstChild("HumanoidRootPart")
							local lookVector = root.CFrame.LookVector * magnitude
							root.Anchored = true
							_G.AnimSet["dash"]:Play()
							task.wait(.2)
							spawn(function()
								TweenService:Create(camera, TweenInfo.new(0.1), {FieldOfView = 65}):Play()
								task.wait(.2)
								TweenService:Create(camera, TweenInfo.new(1), {FieldOfView = 55}):Play()
							end)
							root.Anchored = false
							root.Velocity = Vector3.new(lookVector.X,0,lookVector.Z)
							human.JumpPower = 0
							task.delay(.34, function() human.JumpPower = 50 end)
						end
					end
				end
			elseif input.KeyCode == Enum.KeyCode.ButtonX then
				local char = plr.Character
				local weapon = char:FindFirstChild("WeaponHandler")
				if weapon then
					if humanoid.FloorMaterial ~= Enum.Material.Air and humanoid.FloorMaterial ~= nil then
						weapon:Activate()
					end
				end
			end
			
		-- Keyboard Inputs
		elseif input.UserInputType == Enum.UserInputType.Keyboard and plr:GetAttribute("InMenu") ~= true then
			-- Sidestep Dash
			if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.D then
				dashCombo = true
				coroutine.resume(coroutine.create(function()
					side = true
					dashtick = os.clock()
					task.delay(.25,function() 
						if os.clock() - dashtick >= .25 then
							side = false
							initKey = nil
						end
					end)
					if side == true and focusing and initKey then
						if humanoid.FloorMaterial ~= Enum.Material.Air and humanoid.FloorMaterial ~= nil then
							if (os.clock() - sidedashtick) < 1 then return end
							
							sidedashtick = os.clock()
							local root = plr.Character:FindFirstChild("HumanoidRootPart")
							local lookVector
							local force
							local dashanim
							if input.KeyCode == Enum.KeyCode.A and initKey == Enum.KeyCode.A then
								lookVector = CFrame.new(root.CFrame.p,(root.CFrame*CFrame.new(-1,0,-.35)).p).LookVector
								force = 175
								dashanim = _G.AnimSet["leftdash"]
							elseif input.KeyCode == Enum.KeyCode.D and initKey == Enum.KeyCode.D then
								lookVector = CFrame.new(root.CFrame.p,(root.CFrame*CFrame.new(1,0,-.35)).p).LookVector
								force = 175
								dashanim = _G.AnimSet["rightdash"]
							end
							dashanim:Play()
							
							initKey = nil
							if lookVector ~= nil then
								root.Velocity = lookVector*force
							end
						end
					else
						initKey = input.KeyCode
					end
				end))
				
			-- Long Range Dash
			elseif input.KeyCode == Enum.KeyCode.LeftControl then
				if dashCombo == true then
					local root = plr.Character:FindFirstChild("HumanoidRootPart")
					if root and _G.AnimSet["dash"] then
						local human = plr.Character:FindFirstChild("Humanoid")
						if humanoid.FloorMaterial ~= Enum.Material.Air and humanoid.FloorMaterial ~= nil and plr:GetAttribute("IsDowned") == false then
							if (os.clock() - maneuverTick) < 1 then return end
							if (os.clock() - frontdashtick) < dashcooldown then return end
							maneuverTick = os.clock()
							frontdashtick = os.clock()
							canDash = false
							local root = plr.Character:FindFirstChild("HumanoidRootPart")
							local lookVector = root.CFrame.LookVector * 350
							local human : Humanoid = plr.Character:FindFirstChild("Humanoid")
							root.Anchored = true
							_G.AnimSet["dash"]:Play()
							task.wait(.2)
							spawn(function()
								TweenService:Create(camera, TweenInfo.new(0.1), {FieldOfView = 65}):Play()
								task.wait(.2)
								TweenService:Create(camera, TweenInfo.new(1), {FieldOfView = 55}):Play()
							end)
							root.Anchored = false
							root.Velocity = Vector3.new(lookVector.X,0,lookVector.Z)
							spawn(function()
								wait(.1)
								root.Velocity = Vector3.new((lookVector/3).X,0,(lookVector/3).Z)

							end)
							human.JumpPower = 0
							task.delay(.34, function() human.JumpPower = 50 end)
						end
					end
				end
			end
		end	
	end
end)
