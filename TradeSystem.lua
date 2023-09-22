-- Some out-of-context code from the Trading System of Roverse (Server Side)

function TradeService.AddItem(player, itemData)
	local sessionData = sessions[player]
	assert("itemData must be a table", type(itemData) == "table")
	assert("itemData must contain Id", type(itemData.Id) == "number")
	assert("itemData must contain StackingId", type(itemData.StackingId) == "string")
	assert("itemData must contain Count", type(itemData.Count) == "number")
	
	if sessionData and itemData.Count > 0 then
		if #sessionData.Items[player] < MAX_ITEMS_PER_PLAYER then
			local playerProfile = ServerDataCacher.Get(player)
			if not playerProfile then return -3 end -- Could not access player data
			
			local savedItemData = playerProfile.Inventory.Furniture[tostring(itemData.Id)]
			if not savedItemData then return -4 end -- Player does not have enough items from requested stack
			
			local itemsInStack = InventoryStackUtils.GetItemsInStack(playerProfile.Inventory.Furniture, itemData)
			local stackItemCount = (type(itemsInStack) == "number" and itemsInStack) or (type(itemsInStack) == "table" and #itemsInStack)
			local enoughInStack = (type(savedItemData) == "number" and savedItemData >= stackItemCount) or (type(savedItemData) == "table" and #savedItemData >= stackItemCount)
			if enoughInStack and stackItemCount >= itemData.Count then
				local existingSlotId
				for slotId, slotData in pairs(sessionData.Items[player]) do
					if slotData.StackingId == itemData.StackingId then
						existingSlotId = slotId
						break
					end
				end
				
				for _, member in pairs(sessionData.Members) do
					setConfirmedState(member, false)
				end
				
				local itemList = sessionData.Items[player]
				
				if existingSlotId then
					return TradeService.ChangeItem(player, existingSlotId, itemData)
				else
					if type(itemsInStack) == "table" then
						local metadataItems = {}
						for i = 1, itemData.Count do
							table.insert(metadataItems, itemsInStack[i])
						end
						itemData.MetadataItems = metadataItems
					end
					
					table.insert(itemList, itemData)
					local newSlotId = #itemList
					broadcastSignal(sessionData, "TradeSlotChanged", player, newSlotId, itemData)
					return 0, #itemList -- Success
				end
			else
				return -4 -- Player does not have enough items from requested stack
			end
		else
			return -2 -- Max items for this player
		end
	else
		return -1 -- Player is not in session or count is not enough
	end
end

function TradeService.ChangeItem(player, slotId, itemData)
	local sessionData = sessions[player]
	assert("itemData must be a table", type(itemData) == "table")
	assert("slotId must be a number", type(slotId) == "number")
	assert("itemData must contain Count", type(itemData.Count) == "number")

	if sessionData then
		if itemData.Count > 0 then
			local itemList = sessionData.Items[player]
			
			if slotId and itemList[slotId] then
				local itemInSlot = itemList[slotId]
				
				local playerProfile = ServerDataCacher.Get(player)
				if not playerProfile then return -3 end -- Could not access player data
				
				local savedItemData = playerProfile.Inventory.Furniture[tostring(itemInSlot.Id)]
				if not savedItemData then return -4 end -- Player does not have enough items from requested stack
				
				local itemsInStack = InventoryStackUtils.GetItemsInStack(playerProfile.Inventory.Furniture, itemInSlot)
				local stackItemCount = (type(itemsInStack) == "number" and itemsInStack) or (type(itemsInStack) == "table" and #itemsInStack)
				local enoughInStack = (type(savedItemData) == "number" and savedItemData >= stackItemCount) or (type(savedItemData) == "table" and #savedItemData >= stackItemCount)
				if enoughInStack and stackItemCount >= itemData.Count then
					for _, member in pairs(sessionData.Members) do
						setConfirmedState(member, false)
					end
					
					if type(itemsInStack) == "table" then
						local metadataItems = {}
						for i = 1, itemData.Count do
							table.insert(metadataItems, itemsInStack[i])
						end
						itemData.MetadataItems = metadataItems
					end
					
					itemInSlot.Count = itemData.Count
					broadcastSignal(sessionData, "TradeSlotChanged", player, slotId, itemInSlot)
				end
			else
				return -2 -- No item matching the request
			end
		else
			return TradeService.RemoveItem(player, slotId)
		end
	else
		return -1 -- Player is not in session or count is not enough
	end
end

function TradeService.RemoveItem(player, slotId)
	local sessionData = sessions[player]
	assert("slotId must be a number", type(slotId) == "number")
	
	if sessionData and slotId > 0 and slotId <= MAX_ITEMS_PER_PLAYER then
		for _, member in pairs(sessionData.Members) do
			setConfirmedState(member, false)
		end
		
		local itemList = sessionData.Items[player]
		
		if itemList[slotId] then
			for i = slotId+1, MAX_ITEMS_PER_PLAYER+1 do
				local newData = itemList[i]
				itemList[i-1] = newData
				broadcastSignal(sessionData, "TradeSlotChanged", player, i-1, newData)
			end
		else
			return -2 -- No item at that slot
		end
	else
		return -1 -- Player is not in session or slotId is invalid
	end
end
