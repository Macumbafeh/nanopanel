	--[[

		nanopanel
			Minimal datatext panel for 2.4.3 TBC

			https://github.com/nullfoxh

			My humble datatext panel, nothing fancy or modular

	]]--

	-- config

	local time = { 
		enable = true, 
		twentyfour = true, 
		anchor = "TOP", 
		position = 0
	}

	local fps = {
		enable = true, 
		anchor = "TOP", 
		position = 65
	}

	local ping = {
		enable = true, 
		anchor = "TOP", 
		position = -60
	}

	local friends = {
		enable = true, 
		anchor = "TOPLEFT", 
		position = 13
	}

	local guild = {
		enable = true,
		motd = true,
		listMax = 30,
		anchor = "TOPLEFT", 
		position = 80
	}

	local bags = {
		enable = true, 
		anchor = "TOPRIGHT", 
		position = 3
	}

	local durability = {
		enable = true, 
		anchor = "TOPRIGHT", 
		position = -60
	}

	local combatcolor = true
	local color = "|cff".."7dd174"
	local font = "Interface\\AddOns\\nanopanel\\homespun.ttf"

	---------------------------------------------------------------------------------------------

	local pairs = pairs
	local select = select
	local min = math.min
	local floor = math.floor
	local upper = string.upper
	local format = string.format
	local table_sort = table.sort
	local table_insert = table.insert
	local date = date
	local IsInGuild = IsInGuild
	local GetNetStats = GetNetStats
	local GetFramerate = GetFramerate
	local GetNumAddOns = GetNumAddOns
	local GetAddOnInfo = GetAddOnInfo
	local GetGuildInfo = GetGuildInfo
	local GetFriendInfo = GetFriendInfo
	local GetNumFriends = GetNumFriends
	local IsAddOnLoaded = IsAddOnLoaded
	local GetDifficultyColor = GetDifficultyColor
	local GetGuildRosterInfo = GetGuildRosterInfo
	local GetNumGuildMembers = GetNumGuildMembers
	local GetAddOnMemoryUsage = GetAddOnMemoryUsage
	local GetContainerNumSlots = GetContainerNumSlots
	local GetInventorySlotInfo = GetInventorySlotInfo
	local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage
	local GetContainerNumFreeSlots = GetContainerNumFreeSlots
	local GetInventoryItemDurability = GetInventoryItemDurability
	local RAID_CLASS_COLORS = RAID_CLASS_COLORS

	---------------------------------------------------------------------------------------------

	local createstring = function(parent)
		local frame = parent:CreateFontString(nil, "OVERLAY")
		frame:SetFont(font, 10, "OUTLINE")
		frame:SetShadowColor(0, 0, 0)
		frame:SetShadowOffset(1, -1)
		return frame
	end

	---------------------------------------------------------------------------------------------

	local GetGradient = function(perc, ...) -- http://wowwiki.wikia.com/wiki/ColorGradient
		if perc >= 1 then
			local r, g, b = select(select('#', ...) - 2, ...)
			return r, g, b
		elseif perc <= 0 then
			local r, g, b = ...
			return r, g, b
		end

		local num = select('#', ...) / 3

		local segment, relperc = math.modf(perc*(num-1))
		local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

		return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
	end

	local gradient = function(perc)
		return GetGradient(perc * 0.01, 1, 0, 0, 1, 1, 0, 0, 1, 0)
	end

	---------------------------------------------------------------------------------------------

	local hex = function(r, g, b)
		if type(r) == 'table' then
			if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
		end
		return format('|cff%02x%02x%02x', r*255, g*255, b*255)
	end

	---------------------------------------------------------------------------------------------

	local panel = CreateFrame("frame", "nanopanel", UIParent)
	panel:SetHeight(14)
	panel:SetPoint("BOTTOMLEFT", -1, -1)
	panel:SetPoint("BOTTOMRIGHT", 1, -1)
	panel:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeSize =1,
	})
	panel:SetBackdropColor(.06, .06, .06, .7)
	panel:SetBackdropBorderColor(0, 0, 0)

	if combatcolor then
		panel:SetScript("OnEvent", function(self, event)
			if event == "PLAYER_REGEN_ENABLED" then
				panel:SetBackdropBorderColor(0, 0, 0)
			else
				panel:SetBackdropBorderColor(255, 0, 0)
			end
		end)
		panel:RegisterEvent("PLAYER_REGEN_ENABLED")
		panel:RegisterEvent("PLAYER_REGEN_DISABLED")
	end

	---------------------------------------------------------------------------------------------

	if ping.enable then

		local f = CreateFrame("frame", "nanopanelping", panel)
		f:SetPoint(ping.anchor, panel, ping.anchor, ping.position, 0)
		f:SetHeight(20)
		f:SetWidth(75)
		f:EnableMouse(true)

		local text = createstring(f)
		text:SetPoint("TOP", 0, 0)

		local throttle = 5
		local function OnUpdate(self, elapsed)
			throttle = throttle + elapsed
			if throttle > 5 then
				throttle = 0
				local _, _, latencyHome = GetNetStats()
				text:SetText(format("%d%sms|r", latencyHome or 0, color))
			end
		end

		local function OnEnter(this)
			local bwIn, bwOut, latencyHome = GetNetStats()
			GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
			GameTooltip:ClearLines()
			GameTooltip:AddLine(color.."Network|r")
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine("Latency", format("%i ms", latencyHome), 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine("Bandwidth In", format("%.2f kb", bwIn), 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine("Bandwidth Out", format("%.2f kb", bwOut), 1, 1, 1, 1, 1, 1)
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine("Left-Click", "Toggle Game Menu", 1, 1, 1, 1, 1, 1)
			GameTooltip:Show()
		end

		f:SetScript("OnUpdate", OnUpdate)
		f:SetScript("OnEnter", OnEnter)
		f:SetScript("OnLeave", function() GameTooltip:Hide() end)
		f:SetScript("OnMouseUp", function() 
			if GameMenuFrame:IsShown() then
				PlaySound("igMainMenuQuit")
				HideUIPanel(GameMenuFrame)
			else
				PlaySound("igMainMenuOpen")
				ShowUIPanel(GameMenuFrame)
			end 
		end)
	end

	---------------------------------------------------------------------------------------------

	if fps.enable then

		local f = CreateFrame("frame", "nanopanelfps", panel)
		f:SetPoint(fps.anchor, panel, fps.position, 0)
		f:SetHeight(20)
		f:SetWidth(75)
		f:EnableMouse(true)

		local text = createstring(f)
		text:SetPoint("TOP")

		local function formatMem(num)
			if num > 1024 then 
				return format("%.2f |cffff0000mb|r", (num/1024))
			else
				return format("%d |cff00ff00kb|r", num)
			end
		end

		local throttle = 1	
		local function OnUpdate(self, elapsed)
			throttle = throttle + elapsed
			if throttle > 1 then
				throttle = 0
				text:SetText(format("%d%sfps|r", floor(GetFramerate()), color))
			end
		end

		local function order(a, b) 
			return a[2] > b[2] 
		end		

		local function OnEnter()
			local addons = {}
			local totalMemory = 0

			UpdateAddOnMemoryUsage()

			for i = 1, GetNumAddOns() do
				if IsAddOnLoaded(i) then
					local memory = GetAddOnMemoryUsage(i)
					table_insert(addons, { GetAddOnInfo(i), memory })
					totalMemory = totalMemory + memory
				end
			end
			table_sort(addons, order)

			GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
			GameTooltip:ClearLines()
			GameTooltip:AddLine(color.."Addons|r")
			GameTooltip:AddLine(" ")

			for i = 1, #addons do
				local v = addons[i]
				GameTooltip:AddDoubleLine(v[1], formatMem(v[2]), 1, 1, 1)
			end

			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(color.."Total usage: |r", formatMem(totalMemory))
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine("Left-Click", "Toggle FPS display", 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine("Right-Click", "Collect Garbage", 1, 1, 1, 1, 1, 1)
			GameTooltip:Show()
		end

		f:SetScript("OnEnter", OnEnter)
		f:SetScript("OnUpdate", OnUpdate)
		f:SetScript("OnLeave", function() GameTooltip:Hide() end)
		f:SetScript("OnMouseUp", function(self, button) 
			if button == "LeftButton" then
				ToggleFramerate()
			elseif button == "RightButton" then
				collectgarbage()
			end
		end)

	end

	---------------------------------------------------------------------------------------------

	if durability.enable then

		local f = CreateFrame("frame", "nanopaneldurability", panel)
		f:SetPoint(durability.anchor, panel, durability.position, 0)
		f:SetHeight(20)
		f:SetWidth(75)
		f:EnableMouse(true)

		local text = createstring(f)
		text:SetPoint("TOP")

		local slots = { "Head", "Shoulder", "Chest", "Wrist", "Hands", "Waist",
				"Legs", "Feet", "MainHand", "SecondaryHand", "Ranged" , "Ammo" }

		local function OnEvent(self, event)
			local min = 100
			for i = 1, 18 do
				local dur, max = GetInventoryItemDurability(i)
				if dur ~= max then
					local cur = dur/max*100
					if cur < min then min = cur end
				end
			end

			text:SetText(format("%sdur:|r %s%d%%|r", color, hex(gradient(min)), min))
		end

		local function OnEnter(this)
			GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
			GameTooltip:ClearLines()
			GameTooltip:AddLine(color.."Durability|r")
			GameTooltip:AddLine(" ")

			local count = 0
			for i, v in pairs(slots) do
				local id = GetInventorySlotInfo(v.. "Slot")
				local dur, max = GetInventoryItemDurability(id)
				if dur ~= max then
					local perc = dur/max*100
					GameTooltip:AddDoubleLine(v, format("%d / %d (%d%%)", dur, max, perc), 1, 1, 1, gradient(perc))
					count = count + 1
				end
			end

			if count == 0 then
				GameTooltip:AddDoubleLine("All Items", "100%", 1, 1, 1, 1, 1, 1)
			end

			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine("Left-Click", "Toggle Character Frame", 1, 1, 1, 1, 1, 1)
			GameTooltip:Show()
		end

		f:SetScript("OnEvent", OnEvent)
		f:SetScript("OnEnter", OnEnter)
		f:SetScript("OnLeave", function() GameTooltip:Hide() end)
		f:SetScript("OnMouseUp", function() ToggleCharacter("PaperDollFrame") end)
		f:RegisterEvent("UPDATE_INVENTORY_DURABILITY")

	end

	---------------------------------------------------------------------------------------------

	if friends.enable then

		local f = CreateFrame("frame", "nanopanelfriends", panel)
		f:SetPoint(friends.anchor, panel, friends.position, 0)
		f:SetHeight(20)
		f:SetWidth(75)
		f:EnableMouse(true)

		local text = createstring(f)
		text:SetPoint("TOPLEFT")

		local function OnEvent(self, event)
			local num = GetNumFriends()
			if num > 0 then
				local online = 0
				for i = 1, num do
					local _, _, _, _, connected = GetFriendInfo(i)
					if connected then
						online = online + 1
					end
				end
				text:SetText(format("%sFriends:|r %d", color, online))
			else
				text:SetText(format("%sNo friends|r", color, online))
			end
		end

		local function OnEnter(this)
			GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
			GameTooltip:ClearLines()
			GameTooltip:AddLine(color.."Friends|r")
			GameTooltip:AddLine(" ")

			local num = GetNumFriends()
			if num > 0 then
				local count = 0
				for i = 1, num do
					local name, level, class, area, connected = GetFriendInfo(i)
					if connected then
						count = count + 1
						local cc = RAID_CLASS_COLORS[upper(class)]
						local dc = GetDifficultyColor(level)
						GameTooltip:AddDoubleLine(format("%s%s|r (%s%s|r)", hex(cc), name, hex(dc), level), area, 1, 1, 1, 1, 1, 1)
					end
				end
				if count == 0 then
					GameTooltip:AddLine("No friends online", 1, 1, 1, 1, 1, 1)
				end
			else
				GameTooltip:AddLine("You have no friends :(", 1, 1, 1, 1, 1, 1)
			end

			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine("Left-Click", "Toggle Friends Frame", 1, 1, 1, 1, 1, 1)
			GameTooltip:Show()
		end

		f:SetScript("OnEvent", OnEvent)
		f:SetScript("OnEnter", OnEnter)
		f:SetScript("OnLeave", function() GameTooltip:Hide() end)
		f:SetScript("OnMouseUp", function() ToggleFriendsFrame(1) end)
		f:RegisterEvent("FRIENDLIST_UPDATE")
		f:RegisterEvent("PLAYER_ENTERING_WORLD")

	end

	---------------------------------------------------------------------------------------------

	if guild.enable then

		local f = CreateFrame("frame", "nanopanelguild", panel)
		f:SetPoint(guild.anchor, panel, guild.position, 0)
		f:SetHeight(20)
		f:SetWidth(75)
		f:EnableMouse(true)

		local text = createstring(f)
		text:SetPoint("TOP")

		local nextUpdate = 0
		local numOnline = 0
		local guildMax = 0
		local motd = ""

		local function GetNumOnline()
			local num = 0
			guildMax = GetNumGuildMembers()
			for i = 1, guildMax do
				local _, _, _, _, _, _, _, _, connected = GetGuildRosterInfo(i)
				if connected then
					num = num + 1
				end
			end
			numOnline = num
		end

		local time
		local function OnUpdate()
			time = GetTime()
			if time > nextUpdate then
				if IsInGuild() then
					GuildRoster()
				end
				nextUpdate = time + 60
			end
		end

		local function OnEvent(self, event, msg)
			if event == "GUILD_MOTD" then
				motd = msg
			elseif IsInGuild() then
				GetNumOnline()
				text:SetText(format("%sGuild:|r %d", color, numOnline))
			else
				text:SetText(format("%sNo Guild|r", color))
			end
		end

		local function OnEnter(this)
			GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
			GameTooltip:ClearLines()

			if IsInGuild() then
				GameTooltip:AddDoubleLine(format("%s%s|r", color, GetGuildInfo("player")), format("%s/%s", numOnline, guildMax), 1, 1, 1, 1, 1, 1)
				GameTooltip:AddLine(" ")
				if guild.motd and motd ~= "" then
					GameTooltip:AddLine(motd)
					GameTooltip:AddLine(" ")
				end
				local numlines = 0
				for i = 1, GetNumGuildMembers() do
					if numlines > guild.listMax then break end
					local name, _, _, level, class, zone, _, _, connected = GetGuildRosterInfo(i)
					if connected then
						numlines = numlines + 1
						local cc = RAID_CLASS_COLORS[upper(class)]
						local dc = GetDifficultyColor(level)
						GameTooltip:AddDoubleLine(format("%s%s|r (%s%s|r)", hex(cc), name, hex(dc), level), zone, 1, 1, 1, 1, 1, 1)
					end
				end
				GameTooltip:AddLine(" ")
				GameTooltip:AddDoubleLine("Left-Click", "Toggle Guild Frame", 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddLine(color.."Guild|r")
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine("Not in a guild :(", 1, 1, 1, 1, 1, 1)
			end

			GameTooltip:Show()
		end

		f:SetScript("OnEvent", OnEvent)
		f:SetScript("OnUpdate", OnUpdate)
		f:SetScript("OnEnter", OnEnter)
		f:SetScript("OnLeave", function() GameTooltip:Hide() end)
		f:SetScript("OnMouseUp", function() ToggleFriendsFrame(3) end)
		f:RegisterEvent("GUILD_ROSTER_UPDATE")
		f:RegisterEvent("PLAYER_GUILD_UPDATE")
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f:RegisterEvent("GUILD_MOTD")
	end

	---------------------------------------------------------------------------------------------

	if bags.enable then

		local f = CreateFrame("frame", "nanopanelbags", panel)
		f:SetPoint(bags.anchor, panel, bags.position, 0)
		f:SetHeight(20)
		f:SetWidth(75)
		f:EnableMouse(true)

		local text = createstring(f)
		text:SetPoint("TOP")

		local update = true
		local total = 0
		local free = 0

		local function UpdateSlots()
			free = 0
			total = 0
			local freeSlots, bagType
			for bag = 0, NUM_BAG_SLOTS do
				freeSlots, bagType = GetContainerNumFreeSlots(bag)
				if bagType == 0 then
					free = free + freeSlots
					total = total + GetContainerNumSlots(bag)
				end
			end
		end
		
		local throttle = 1
		local function OnUpdate(self, elapsed)
			if update then
				throttle = throttle + elapsed
				if throttle > 1 then
					throttle = 0
					update = false
					UpdateSlots()
					--text:SetText(format("%sbags:|r %s%d|r", color, hex(gradient(free/total*100)), free))
					--text:SetText(format("%sbags:|r %d/%d", color, total-free, total))
					text:SetText(format("%sbags:|r %d", color, free))
				end	
			end
		end

		local function OnEnter(this)
			GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
			GameTooltip:ClearLines()
			GameTooltip:AddLine(color.."Bags|r")
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine("Slots free", free, 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine("Slots used", format("%d/%d", total-free, total), 1, 1, 1, 1, 1, 1)
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine("Left-Click", "Toggle Bags", 1, 1, 1, 1, 1, 1)
			GameTooltip:Show()
		end

		f:SetScript("OnEvent", function() update = true end)
		f:SetScript("OnUpdate", OnUpdate)
		f:SetScript("OnEnter", OnEnter)
		f:SetScript("OnLeave", function() GameTooltip:Hide() end)
		f:SetScript("OnMouseUp", function() if IsBagOpen(0) then CloseAllBags() else OpenAllBags() end end)
		f:RegisterEvent("BAG_UPDATE")
	end

	---------------------------------------------------------------------------------------------

	if time.enable then

		local f = CreateFrame("frame", "nanopaneltime", panel)
		f:SetPoint(time.anchor, panel, time.position, 0)
		f:SetHeight(20)
		f:SetWidth(75)
		f:EnableMouse(true)

		local text = createstring(f)
		text:SetPoint("TOP")

		local throttle = 5	
		local function OnUpdate(self, elapsed)
			throttle = throttle + elapsed
			if throttle > 5 then
				throttle = 0

				if time.twentyfour then
					text:SetText(format("%s%s:|r%s", date("%H"), color, date("%M")))
				else
					text:SetText(format("%s%s:|r%s%s%s|r", date("%I"), color, date("%M"), color, date("%p")))
				end
			end	
		end

		local function OnEnter(this)
			GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
			GameTooltip:ClearLines()

			if time.twentyfour then
				GameTooltip:AddDoubleLine(color.."Time|r", format("%s%s:|r%s", date("%H"), color, date("%M")), 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(color.."Time|r", format("%s%s:|r%s%s%s|r", date("%I"), color, date("%M"), color, date("%p")), 1, 1, 1, 1, 1, 1)
			end

			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(date("%A"), date("%B %d."), 1, 1, 1, 1, 1, 1)
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine("Left-Click", "Toggle Time Manager", 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine("Right-Click", "Toggle Stopwatch", 1, 1, 1, 1, 1, 1)
			GameTooltip:Show()
		end

		f:SetScript("OnUpdate", OnUpdate)
		f:SetScript("OnEnter", OnEnter)
		f:SetScript("OnLeave", function() GameTooltip:Hide() end)
		f:SetScript("OnMouseUp", function(self, button) 
			if button == "LeftButton" then
				GameTimeFrame:Click()
			elseif button == "RightButton" then
				if not IsAddOnLoaded("Blizzard_TimeManager") then
					UIParentLoadAddOn("Blizzard_TimeManager")
				end
				Stopwatch_Toggle()
			end
		end)
	end

	---------------------------------------------------------------------------------------------