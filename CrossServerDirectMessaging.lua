-- Messaging Logic for a Direct Messaging System from Roverse


function Messaging.SendMessage(fromPlayer, toUserId, messageContent)
	toUserId = tonumber(toUserId)
	assert(toUserId ~= nil, "toUserId must be a number")
	
	local fromUserId = fromPlayer.UserId
	local topicKey = getDMTopicKey(fromUserId, toUserId)
	local toPlayer = game.Players:GetPlayerByUserId(toUserId)
	local msgPayload = {
		UID = HttpService:GenerateGUID(false);
		AuthorId = fromUserId;
		Content = messageContent;
		Timestamp = os.time();
	}
	
	if toPlayer ~= nil then
		-- Receiving player is in the same server, life is easy --
		local toPlayerData = ServerDataCacher.Get(toPlayer)
		
		ServerDataCacher.Set(toPlayer, "DirectMessages", function(dms)
			local dmsWithFriend = dms[tostring(toPlayer.UserId)] or {}
			dmsWithFriend[msgPayload.UID] = msgPayload
			return dms
		end)
		
		DMReceivedRE:FireClient(toPlayer, msgPayload)
	else
		-- If the receiving player is not in this server, do dumb stuff --
		spawn(function()
			local success, err = pcall(function()
				print("broadcasting...")
				MessagingService:PublishAsync(topicKey, msgPayload)
				print("broadcasted!")
			end)
			
			if not success then
				warn("Error while sending DM from " .. fromPlayer.Name .. " to " .. toUserId .. ": " .. err)
			end
		end)
		
		print("Caching message " .. msgPayload.UID)
		DMCache[tostring(toUserId)] = DMCache[tostring(toUserId)] or {}
		DMCache[tostring(toUserId)][msgPayload.UID] = msgPayload
	end
end
