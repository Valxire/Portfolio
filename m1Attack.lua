-- M1 Attack with Combos

function attack()
	if blocking == false then
		--	print("1")
		local period = os.clock() - attack_tick
		if period > tick_class["Shortsword"] then
			--	print("2")
			local anims = Animations
			if period > tick_class["Shortsword"] and period < (tick_class["Shortsword"] + 1) then
				--	print("3")
				if attack_chain < #anims then
					--	print("4")
					attack_chain += 1
				elseif attack_chain == #anims then
					--	print("5")
					attack_chain = 1
				end
			elseif period > (tick_class["Shortsword"] + 1) then
				--print("6")
				attack_chain = 1
			end
			attack_tick = os.clock()
			if attack_chain == #anims then
				task.spawn(function()
					for i = 1, 38 do
						task.wait()
						attack_tick = os.clock()
					end
				end)
			end
			local hooman = player.Character:WaitForChild("Humanoid")
			local anim_Load = hooman:LoadAnimation(anims[attack_chain])
			anim_Load:Play()
			player.Character.Sword.Handle:FindFirstChild("Swing".. attack_chain):Play()
			local wroot = player.Character:WaitForChild("HumanoidRootPart", true)

			coroutine.resume(coroutine.create(function()
				player:SetAttribute("CombatMove",true)
				local con = require(player.PlayerScripts.PlayerModule):GetControls()
				if true then
					task.spawn(function()
						print("Automoving")
						task.wait(walkwaittime["Shortsword"])
						con:Disable()
						local count = 1
						local to = (wroot.CFrame*CFrame.new(0,0,-5+.25)).p
						local part = Instance.new("Part")
						part.Transparency = 1
						part.Anchored = true
						part.CanCollide = false
						part.Position = to
						part.Parent = workspace.IgnoredParts
						game.Debris:AddItem(part,3)
						local increments = {
							Shortsword = 14;
							Greatsword = 20;
							Rapier = 13;
						}
						for i = 1, increments["Shortsword"] do
							hooman.WalkSpeed = 35-(35*(i/increments["Shortsword"]))
							hooman:MoveTo(to,part)
							game:GetService("RunService").RenderStepped:Wait()
							hooman:MoveTo(to,part)
							hooman.WalkSpeed = 35-(35*(i/increments["Shortsword"]))
						end

						hooman:MoveTo(wroot.CFrame.p)
						task.wait(0.15)
						player:SetAttribute("CombatMove",false)
						hooman.WalkSpeed = 14
						con:Enable(true)
					end)
				end
				anim_Load:GetMarkerReachedSignal("Hit"):Wait()
				
				task.delay(.023,function()
					network:fireServer("drawEffects",
						wroot.CFrame*CFrame.new(0,0,-1),
						eff["Shortsword"][attack_chain],
						wroot.CFrame*CFrame.new(0,0,-1),
						(cframes["Shortsword"] and cframes["Shortsword"][attack_chain]) or {0,0,0},
						(offsets["Shortsword"] and offsets["Shortsword"][attack_chain]) or CFrame.new(0,0,0),
						Color3.fromRGB(800, 1000, 3000),
						eff_scales["Shortsword"][attack_chain]--2.25
					)
					print(attack_chain)
					effects[eff["Shortsword"][attack_chain]](
						wroot.CFrame*CFrame.new(0,0,-1),
						(cframes["Shortsword"] and cframes["Shortsword"][attack_chain]) or {0,0,0},
						(offsets["Shortsword"] and offsets["Shortsword"][attack_chain]) or CFrame.new(0,0,0),
						Color3.fromRGB(800, 1000, 3000),
						eff_scales["Shortsword"][attack_chain]--2.25
					)
				end)

				network:fireServer("signalBasicAttacking",attack_chain)
				if trail ~= nil then
					local duration = anim_Load.Length - .43
					local clone_trail = trail:Clone()
					clone_trail.Name = "CloneTrail"
					clone_trail.Enabled = true
					clone_trail.Parent = trail.Parent
					delay(duration,function()
						game.Debris:AddItem(clone_trail,.01)
					end)
				end
				local onStop 
				onStop = anim_Load.Stopped:connect(function()
					anim_Load:Destroy()
					onStop:Disconnect()
				end)
			end))
		end
	end
end
