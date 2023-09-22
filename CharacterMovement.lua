-- Double Jump w/ Directional Momentum Maintained alongside a CombatRoll while Weapon is Active

inputService.JumpRequest:connect(function()
	-- Vars

	local char = localPlayer.Character
	local human = char:FindFirstChild("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	if human and root then
		-- Combat State Checks
		if localPlayer:GetAttribute("IsStunned") == true then return end
		if localPlayer:GetAttribute("IsDowned") == true then return end

		if not localPlayer:GetAttribute("WeaponEquipped") then
			task.spawn(function()
				local lookVector
				if (tick() - ticks["jump_request"]) < .2 then return end
				-- Verify that the Player is not on the ground like a plebian
				if human.FloorMaterial == Enum.Material.Air or human.FloorMaterial == nil then
					if (tick() - ticks["doublejump_request"]) < 1 then return end
					if not canDoubleJump then return end

					-- Handle State Changing and Debounce
					localPlayer:SetAttribute("DoubleJumping", true)
					canDoubleJump = false
					ticks["doublejump_request"] = tick()
					ticks["jump_request"] = tick()
					lookVector = CFrame.new(root.CFrame.p,(root.CFrame*CFrame.new(0,20,-8)).p).LookVector
					root.Velocity = lookVector*70

					-- Play Animation and VFX
					animations["ForwardJump"]:Play()
					effects["Jump_Effect"](
						root.CFrame*CFrame.new(0,0,-4),
						{-50,0,0},
						CFrame.new(0,0,0),
						Color3.fromRGB(300, 500, 500),
						2
					)
					network:fireServer("drawEffects",
						root.CFrame,
						"Jump_Effect",
						root.CFrame*CFrame.new(0,-0,0),
						{0,0,0},
						CFrame.new(0,0,0),
						Color3.fromRGB(300, 500, 500),
						2
					)

					-- Update Jump Request Tick
				elseif human.FloorMaterial ~= Enum.Material.Air and human.FloorMaterial ~= nil then
					ticks["jump_request"] = tick()
				end

				coroutine.wrap(function()
					wait(3)

					-- Reset the state so other actions can occur
					localPlayer:SetAttribute("DoubleJumping", false)
				end)
			end)
		else -- The player has weapon equipped, and this should be interpretted as a Combat Roll
			task.spawn(function()
				local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
				if root and animations["CombatRoll"] then
					local human = localPlayer.Character:FindFirstChild("Humanoid")

					-- Double check player is grounded 
					if human.FloorMaterial ~= Enum.Material.Air and human.FloorMaterial ~= nil then
						if (os.clock() - frontdashtick) < dashcooldown then return end
						frontdashtick = os.clock()

						-- Apply Physics Changes and Play Animation
						animations["CombatRoll"]:Play()
						local root = localPlayer.Character:FindFirstChild("HumanoidRootPart")
						local lookVector = root.CFrame.LookVector * 275
						task.wait(.2)

						-- Tween FOV for Asthetic
						spawn(function()
							TweenService:Create(camera, TweenInfo.new(0.1), {FieldOfView = 65}):Play()
							task.wait(.2)
							TweenService:Create(camera, TweenInfo.new(1), {FieldOfView = 55}):Play()
						end)

						-- Reset Velocity
						root.Velocity = Vector3.new(lookVector.X,0,lookVector.Z)
						human.JumpPower = 0
					end
				end
			end)
		end
	end
end)
