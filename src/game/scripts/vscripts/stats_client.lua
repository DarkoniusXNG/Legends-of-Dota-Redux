if not Pregame then
    require('pregame')
end

StatsClient = StatsClient or class({})
JSON = JSON or require("lib/json")
inspect = require("lib/inspect")
StatsClient.AbilityData = StatsClient.AbilityData or {}
StatsClient.PlayerBans = StatsClient.PlayerBans or {}

StatsClient.AuthKey = LoadKeyValues('scripts/kv/stats_client.kv').AuthKey
-- Change to true if you have local server running, so contributors without local server can see some things
StatsClient.Debug = IsInToolsMode()
StatsClient.ServerAddress = StatsClient.Debug and "http://localhost:8080/" or "https://darkoniusxngserver.onrender.com/"

StatsClient.GameVersion = "3.1.2"
StatsClient.SortedAbilityDataEntries = StatsClient.SortedAbilityDataEntries or {}

function StatsClient:SubscribeToClientEvents()
    CustomGameEventManager:RegisterListener("stats_client_create_skill_build", Dynamic_Wrap(StatsClient, "CreateSkillBuild"))
    CustomGameEventManager:RegisterListener("stats_client_remove_skill_build", Dynamic_Wrap(StatsClient, "RemoveSkillBuild"))
    --CustomGameEventManager:RegisterListener("stats_client_vote_skill_build", Dynamic_Wrap(StatsClient, "VoteSkillBuild"))
    --CustomGameEventManager:RegisterListener("stats_client_fav_skill_build", Dynamic_Wrap(StatsClient, "SetFavoriteSkillBuild"))
    --CustomGameEventManager:RegisterListener("stats_client_save_fav_builds", Dynamic_Wrap(StatsClient, "SaveFavoriteBuilds"))
    CustomGameEventManager:RegisterListener("stats_client_options_save", Dynamic_Wrap(StatsClient, "SaveOptions"))
    CustomGameEventManager:RegisterListener("stats_client_options_load", Dynamic_Wrap(StatsClient, "LoadOptions"))
	--CustomGameEventManager:RegisterListener("stats_client_get_skill_builds", Dynamic_Wrap(StatsClient, "GetSkillBuilds"))
	--CustomGameEventManager:RegisterListener("stats_client_get_favorite_skill_builds", Dynamic_Wrap(StatsClient, "GetFavoriteSkillBuilds"))

    --[[
	CustomGameEventManager:RegisterListener("lodConnectAbilityUsageData", function(_, args)
        Timers:CreateTimer(function()
            local playerID = args.PlayerID
            if not StatsClient.AbilityData or not StatsClient.SortedAbilityDataEntries or not StatsClient.GlobalAbilityUsageData or not StatsClient.totalGameAbilitiesCount then
                return 0.1
            end
            CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerID), "lodConnectAbilityUsageData", {
                data = StatsClient.AbilityData[playerID] or {},
                entries = StatsClient.SortedAbilityDataEntries[playerID] or {},
                global = StatsClient.GlobalAbilityUsageData,
                totalGameAbilitiesCount = StatsClient.totalGameAbilitiesCount
            })
        end)
    end)
	]]

    --ListenToGameEvent('dota_match_done', Dynamic_Wrap(StatsClient, "SendAbilityUsageData"), self)
end

--function StatsClient:Fetch()
    --StatsClient:FetchAbilityUsageData()
    --StatsClient:FetchBans()
--end

function StatsClient:GetSkillBuilds(args)
	StatsClient:Send("getSkillBuilds?skip=" .. args.Skip, nil, function(response)
		local playerID = args.PlayerID
        local player = PlayerResource:GetPlayer(playerID)
		CustomGameEventManager:Send_ServerToPlayer(player, "lodReceiveBuilds", response)
    end, math.huge, "GET")
end

function StatsClient:GetFavoriteSkillBuilds(args)
	-- Not the most ideal, but it will do for now. Should use the data parameter correctly in the future
	-- but data doesn't show up server side for some reason
	StatsClient:Send("getFavoriteSkillBuilds?playerId=" .. args.PlayerID .. "&steamId=" .. args.SteamID, nil, function(response)
		local playerId = args.PlayerID
		local player = PlayerResource:GetPlayer(playerId)
		CustomGameEventManager:Send_ServerToPlayer(player, "lodReceiveFavoriteBuilds", response)
	end, math.huge, "GET")
end

function StatsClient:CreateSkillBuild(args)
    local playerID = args.PlayerID
    local steamID = PlayerResource:GetRealSteamID(playerID)
    local title = args.title or ""
    local description = args.description or ""
    local abilities = util:DeepCopy(Pregame.selectedSkills[playerID]) or {}
    local heroName = Pregame.selectedHeroes[playerID]
    local attribute = Pregame.selectedPlayerAttr[playerID]
    for k,_ in pairs(abilities) do
        if tonumber(k) == nil then abilities[k] = nil end
    end
    if util:getTableLength(abilities) < 6 or not heroName or (attribute ~= "str" and attribute ~= "agi" and attribute ~= "int") then
        network:sendNotification(PlayerResource:GetPlayer(playerID), {
            sort = 'lodDanger',
            text = 'lodServerFailedCreateSkillBuildUnfinished'
        })
        Pregame:PlayAlert(playerID)
        return
    end
    if #title < 4 or #title > 64 or #description < 10 or #description > 256 then
        network:sendNotification(PlayerResource:GetPlayer(playerID), {
            sort = 'lodDanger',
            text = 'lodServerFailedCreateSkillBuildText'
        })
        Pregame:PlayAlert(playerID)
        return
    end
    StatsClient:Send("createSkillBuild", {
        steamID = steamID,
        title = title,
        description = description,
        abilities = abilities,
        heroName = heroName,
        attribute = attribute,
        tags = {},
    }, function(response)
        local player = PlayerResource:GetPlayer(playerID)
        if response.success then
            network:sendNotification(player, {
                sort = 'lodSuccess',
                text = 'lodServerSuccessCreateSkillBuild'
            })
            CustomGameEventManager:Send_ServerToPlayer(player, "lodReloadBuilds", {})
        else
            network:sendNotification(player, {
                sort = 'lodDanger',
                text = response.error or ''
            })
            Pregame:PlayAlert(playerID)
        end
    end)
end

function StatsClient:RemoveSkillBuild(args)
	local playerId = args.PlayerID
    local _steamId = PlayerResource:GetRealSteamID(args.PlayerID)
	local _buildId = args.id
	
	StatsClient:Send("removeSkillBuild", {
		steamId = _steamId,
		buildId = _buildId
	}, function(response)
		local player = PlayerResource:GetPlayer(playerId)
		network:sendNotification(player, {
			sort = 'lodSuccess',
			text = 'lodServerSuccessRemoveSkillBuild'
		})
		CustomGameEventManager:Send_ServerToPlayer(player, "lodReloadBuilds", {})
	end)
end

function StatsClient:VoteSkillBuild(args)
    StatsClient:Send("voteSkillBuild", {
        steamID = PlayerResource:GetRealSteamID(args.PlayerID),
        id = args.id or "",
        vote = type(args.vote) == "number" and args.vote or 0
    })
end

function StatsClient:SetFavoriteSkillBuild(args)
    StatsClient:Send("setFavoriteSkillBuild", {
        steamID = PlayerResource:GetRealSteamID(args.PlayerID),
        id = args.id or "",
        fav = type(args.fav) == "number" and args.fav or 0
    })
end

function StatsClient:SaveOptions(args)
	StatsClient:Send(
		"saveOptions",
		{
			steamID = PlayerResource:GetRealSteamID(args.PlayerID),
			content = args.content
		},
		function()
			local player = PlayerResource:GetPlayer(args.PlayerID)
			CustomGameEventManager:Send_ServerToPlayer(player, "lodNotification", { text = 'importAndExport_success_save' })
		end,
		0
	)
end

function StatsClient:LoadOptions(args)
	StatsClient:Send(
		"loadOptions",
		{
			steamID = PlayerResource:GetRealSteamID(args.PlayerID)
		},
		function(response)
			local player = PlayerResource:GetPlayer(args.PlayerID)
			CustomGameEventManager:Send_ServerToPlayer(player, "lodLoadOptions", { content = response.content })
		end,
		0
	)
end

function StatsClient:SendAbilityUsageData()
    local data = {}
    for playerID, build in pairs(Pregame.selectedSkills) do
        local steamID = PlayerResource:GetRealSteamID(playerID)
        if steamID ~= "0" then
            local abilities = {}
            for i,v in ipairs(build) do
                abilities[i] = v
            end
            data[steamID] = abilities
        end
    end
    StatsClient:Send("saveAbilityUsageData", data, nil, math.huge)
end

function StatsClient:FetchAbilityUsageData()
    local required = {}

    for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayerID(i) then
            required[i] = PlayerResource:GetRealSteamID(i)
        end
    end

    StatsClient:Send("fetchAbilityUsageData", required, function(response)
        for playerID, value in pairs(response) do
            playerID = tonumber(playerID)
            StatsClient.AbilityData[playerID] = value

            local entries = {}
            for ability in pairs(value) do
                table.insert(entries, ability)
            end
            table.sort(entries, function(a, b) return value[a] > value[b] end)

            local values = {}
            for i, ability in ipairs(entries) do
                values[ability] = i / #entries
            end

            StatsClient.SortedAbilityDataEntries[playerID] = values
        end
    end, math.huge)

    StatsClient:Send("fetchGlobalAbilityUsageData", nil, function(response)
        StatsClient.totalGameAbilitiesCount = #response
        StatsClient.GlobalAbilityUsageData = {}
        for i,v in ipairs(response) do
            StatsClient.GlobalAbilityUsageData[v._id] = i / #response
        end
    end, math.huge, "GET")
end

function StatsClient:GetAbilityUsageData(playerID)
    return StatsClient.AbilityData[playerID]
end

function StatsClient:SendBans(playerID, data)
    StatsClient:Send(
		"saveBans",
		{ 
			steamID = PlayerResource:GetRealSteamID(playerID),
			bans = data
		},
		function()
			local player = PlayerResource:GetPlayer(playerID)
			CustomGameEventManager:Send_ServerToPlayer(player, "lodNotification", { text = 'lodSuccessSavedBans', params = { entries = #data } })
		end,
		0
	)
end

-- Load bans of all players, not just for the player that clicked the button
-- function StatsClient:FetchBans()
    -- local required = {}

    -- for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        -- if PlayerResource:IsValidPlayerID(i) then
            -- required[i] = PlayerResource:GetRealSteamID(i)
        -- end
    -- end

    -- StatsClient:Send("fetchBans", required, function(response)
        -- for playerID, value in pairs(response) do
            -- StatsClient:SetBans(tonumber(playerID), value)
        -- end
    -- end, math.huge)
-- end

function StatsClient:GetBans(playerID)
    StatsClient:Send(
		"loadBans",
		{
			steamID = PlayerResource:GetRealSteamID(playerID)
		},
		function(response)
			local bans = response.bans
			StatsClient:SetBans(playerID, bans)
			Pregame:ActualLoadingBans(playerID)
		end,
		0
	)
end

function StatsClient:SetBans(playerID, value)
    StatsClient.PlayerBans[playerID] = value
end

function StatsClient:Send(path, data, callback, retryCount, protocol, _currentRetry)
	local new_data = {}
	local newpath = path
	if path == 'saveOptions' or path == 'loadOptions' then
		newpath = 'options'
		new_data.id = data.steamID
		new_data.content = data.content
	elseif path == 'saveBans' or path == 'loadBans' then
		newpath = "bans"
		new_data.id = data.steamID
		new_data.bans = data.bans
	end

	if path == 'saveOptions' or path == 'saveBans' then
		local already_there = false
		local request = CreateHTTPRequestScriptVM("GET", self.ServerAddress..newpath)
		request:SetHTTPRequestGetOrPostParameter("id", tostring(new_data.id))
		request:Send(function(response)
			if response.StatusCode == 200 and response.Body then
				if response.Body ~= "[]" then
					already_there = true
					print("[StatsClient] "..newpath.." for this player exist on the server already.")
				end
			else
				print("status code == "..response.StatusCode)
				print("body == "..tostring(response.Body))
			end
		end)
		Timers:CreateTimer(2, function()
			if already_there then
				local request = CreateHTTPRequestScriptVM("DELETE", StatsClient.ServerAddress..newpath.."/"..new_data.id)
				request:SetHTTPRequestHeaderValue("Auth-Key", StatsClient.AuthKey)
				request:Send(function(response)
					if response.StatusCode == 200 and response.Body then
						print("[StatsClient] Deleted Old "..newpath)
						local request2 = CreateHTTPRequestScriptVM("POST", StatsClient.ServerAddress..newpath)
						request2:SetHTTPRequestHeaderValue("Auth-Key", StatsClient.AuthKey)
						request2:SetHTTPRequestRawPostBody("application/json", json.encode(new_data))
						request2:Send(function(response2)
							if response2.StatusCode == 201 and response2.Body then
								print("[StatsClient] New "..newpath.." Saved")
								if callback then
									callback()
								end
							else
								print("status code == "..response2.StatusCode)
								print("body == "..tostring(response2.Body))
								GameRules:SendCustomMessage("Saving "..newpath.." failed!", 0, 0)
							end
						end)
					else
						print("status code == "..response.StatusCode)
						print("body == "..tostring(response.Body))
						GameRules:SendCustomMessage("Saving "..newpath.." failed!", 0, 0)
					end
				end)
			else
				local request = CreateHTTPRequestScriptVM("POST", StatsClient.ServerAddress..newpath)
				request:SetHTTPRequestHeaderValue("Auth-Key", StatsClient.AuthKey)
				request:SetHTTPRequestRawPostBody("application/json", json.encode(new_data))
				request:Send(function(response)
					if response.StatusCode == 201 and response.Body then
						print("[StatsClient] New "..newpath.." Saved!")
						if callback then
							callback()
						end
					else
						print("status code == "..response.StatusCode)
						print("body == "..tostring(response.Body))
						GameRules:SendCustomMessage("Saving "..newpath.." failed!", 0, 0)
					end
				end)
			end
		end)
	elseif path == 'loadOptions' or path == 'loadBans' then
		local request = CreateHTTPRequestScriptVM("GET", self.ServerAddress..newpath)
		request:SetHTTPRequestGetOrPostParameter("id", tostring(new_data.id))
		request:Send(function(response)
			if response.StatusCode == 200 and response.Body then
				if response.Body ~= "[]" then
					if callback then
						local obj = json.decode(response.Body)
						print("[StatsClient] "..newpath.." Loaded!")
						if obj then
							local new_obj = {}
							new_obj.steamID = obj[1].id
							if path == 'loadOptions' then
								new_obj.content = obj[1].content
							elseif path == 'loadBans' then
								new_obj.bans = obj[1].bans
							end
							callback(new_obj)
						end
					end
				end
			else
				print("status code == "..response.StatusCode)
				print("body == "..tostring(response.Body))
				GameRules:SendCustomMessage("Loading "..newpath.." failed!", 0, 0)
			end
		end)
	end
	
	--local request = CreateHTTPRequestScriptVM(protocol or "POST", self.ServerAddress .. path)
	--request:SetHTTPRequestHeaderValue("Auth-Key", StatsClient.AuthKey)
	--local encoded = JSON:encode(data)
	--request:SetHTTPRequestGetOrPostParameter("data", encoded)
	--request:Send(function(response)
		-- if response.StatusCode ~= 200 or not response.Body then
			-- print("[StatsClient] error, status == " .. response.StatusCode)
			-- local currentRetry = (_currentRetry or 0) + 1
			-- if currentRetry < (retryCount or 0) then
				-- Timers:CreateTimer(30, function()
					-- print("[StatsClient] Retry (" .. currentRetry .. ")")
					-- StatsClient:Send(path, data, callback, retryCount, protocol, currentRetry)
				-- end)
			-- end
		-- else
			-- local obj, pos, err = JSON:decode(response.Body, 1, nil)
			-- if callback then
				-- callback(obj)
			-- end
		-- end
	-- end)
end

function CDOTA_PlayerResource:GetRealSteamID(PlayerID)
    return tostring(PlayerResource:GetSteamID(PlayerID))
end
