DONOTREMOVE = {
	ability_capture = true,
	ability_lamp_use = true,
	ability_pluck_famango = true,
	twin_gate_portal_warp = true,
	--special_bonus_attributes = true,
}

ALREADYPRECACHING = {}
for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
	ALREADYPRECACHING[i] = {}
end

if not util then
    util = class({})
end

-- A store of player names
local storedNames = {}

-- Grab steamid data
util.contributors = util.contributors or LoadKeyValues('scripts/kv/contributors.kv')
util.patrons = util.patrons or LoadKeyValues('scripts/kv/patrons.kv')
util.patreon_features = util.patreon_features or LoadKeyValues('scripts/kv/patreon_features.kv')

-- This function RELIABLY gets a player's name
-- Note: PlayerResource needs to be loaded (aka, after Activated has been called)
--       This method is safe for all of our internal uses
function util:GetPlayerNameReliable(playerID)
    -- Ensure player resource is ready
    if not PlayerResource then
        print("PlayerResource not loaded!")
        return 'Unknown'
    end

    -- Grab their steamID
    local steamID = tostring(PlayerResource:GetSteamAccountID(playerID) or -1)

    -- Return the name we have set, or call the normal function (GetPlayerName doesn't work)
    return storedNames[steamID] or PlayerResource:GetPlayerName(playerID)
end

-- Store player names
ListenToGameEvent('player_connect', function(keys)
    -- Grab their steamID
    local steamID64 = tostring(keys.xuid)
    local steamIDPart = tonumber(steamID64:sub(4))
    if not steamIDPart then return end
    local steamID = tostring(steamIDPart - 61197960265728)

    -- Store their name
    storedNames[steamID] = keys.name
end, nil)

-- Encodes a byte to send over the network
-- This function expects a number from 0 - 254
-- This function returns a character, values 1 - 255
function util:EncodeByte(v)
    -- Check for negative
    if v < 0 then
        print("Warning: Tried to encode a number less than 0! Clamping to 255")
        return string.char(255)
    end

    -- Add one to the value
    v = math.floor(v) + 1

    -- Ensure a valid value
    if v > 255 then
        print("Warning: Tried to encode a number larger than 254! Clamped to 255")
        return string.char(255)
    end
    -- Return the correct character

    return string.char(v)
end

-- Merges the contents of t2 into t1
function util:MergeTables(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                util:MergeTables(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

function util:DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[self:DeepCopy(orig_key)] = self:DeepCopy(orig_value)
        end
        setmetatable(copy, self:DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Tells you if a given spell is channelled or not
function util:isChannelled(name)
    local ability_data = GetAbilityKeyValuesByName(name)
    if not ability_data then
        print("util:isChannelled: Ability "..name.." does not exist!")
        return
    end
    local behavior = ability_data.AbilityBehavior
    if not behavior then
        print("util:isChannelled: Ability "..name.." does not have a behavior!")
        return
    end
    return string.find(behavior, "DOTA_ABILITY_BEHAVIOR_CHANNELLED")
end

-- Tells you if a given spell is target based one or not
function util:isTargetSpell(name)
    local ability_data = GetAbilityKeyValuesByName(name)
    if not ability_data then
        print("util:isTargetSpell: Ability "..name.." does not exist!")
        return
    end
    local behavior = ability_data.AbilityBehavior
    if not behavior then
        print("util:isTargetSpell: Ability "..name.." does not have a behavior!")
        return
    end
    return string.find(behavior, "DOTA_ABILITY_BEHAVIOR_UNIT_TARGET")
end

-- Tells you if given spell is a talent
function util:IsTalent(ability)
    local ability_name
    if type(ability) == "string" then
        ability_name = ability
        if ability_name == "" then
            return false
        end
        local ability_data = GetAbilityKeyValuesByName(ability_name)
        if not ability_data then
            print("util:IsTalent: Ability "..ability_name.." does not exist!")
            return false
        end
    else
        if not ability or ability:IsNull() then
            print("util:IsTalent: Passed parameter does not exist!")
            return false
        end
        if not ability.GetAbilityName then
            print("util:IsTalent: Passed parameter is not an ability!")
            return false
        end
        ability_name = ability:GetAbilityName()
    end

    return string.find(ability_name, "special_bonus_") and ability_name ~= "special_bonus_attributes"
end

-- Tells you if given spell is an innate
function util:IsVanillaInnate(ability)
	local ability_name
	if type(ability) == "string" then
		ability_name = ability
		if ability_name == "" then
			return false
		end
	else
		if not ability or ability:IsNull() then
			print("util:IsVanillaInnate: Passed parameter does not exist!")
			return false
		end
		if not ability.GetAbilityName then
			print("util:IsVanillaInnate: Passed parameter is not an ability!")
			return false
		end
		ability_name = ability:GetAbilityName()
	end

	local ability_data = GetAbilityKeyValuesByName(ability_name)
	if not ability_data then
		print("util:IsVanillaInnate: Ability "..ability_name.." does not exist!")
		return false
	end

	if ability_data.Innate ~= nil then
		if tonumber(ability_data.Innate) == 1 then
			return true
		end
	end
	return false
end

function util:sortTable(input)
    local array = {}
    for heroName in pairs(input) do
        array[heroName] = {}
        while #array[heroName] ~= self:getTableLength(input[heroName]) do
            for abilityName, position in pairs(input[heroName]) do
                if self:getTableLength(array[heroName])+1 == tonumber(position) then
                    table.insert(array[heroName], abilityName)
                end
            end
        end
    end
    return array
end

function util:swapTable(input)
    local array = {}
    for k,v in pairs(input) do
        if type(v) == 'table' then
            array[k] = self:swapTable(v)
        else
            table.insert(array, k)
        end
    end
    return array
end


-- Returns true if a player is premium
function util:playerIsPremium(playerID)
    -- Check our premium rank
    return self:getPremiumRank(playerID) > 0
end

-- Returns true if a player is bot
function util:isPlayerBot(playerID)
    return PlayerResource:GetSteamAccountID(playerID) == 0 or PlayerResource:IsFakeClient(playerID)
end

-- Returns a player's premium rank
function util:getPremiumRank(playerID)
    local steamID = tostring(PlayerResource:GetSteamAccountID(playerID))
    local conData

    for k,v in pairs(util.contributors) do
        if tostring(v.steamID3) == steamID then
            conData = v
            break
        end
    end

    -- Default is no premium
    local totalPremium = 0

    -- Check their contributor status
    if conData then
        -- Do they have premium?
        if conData.premium then
            -- Add this to their total premium
            totalPremium = totalPremium + conData.premium
        end
    end

    -- They are not
    return totalPremium
end

function isPlayerHost(player)
    if type(player) == 'number' then
        player = PlayerResource:GetPlayer(player)
    end
    return player.isHost
end

function setPlayerHost(oldHost, newHost)
    if isPlayerHost(oldHost) then
        oldHost.isHost = nil
        newHost.isHost = true
    end
end

function getPlayerHost()
    for i = 0, DOTA_MAX_PLAYERS - 1 do
        if PlayerResource:IsValidPlayer(i) then
            local player = PlayerResource:GetPlayer(i)
            if player and player.isHost then
                return player
            end
        end
    end
end

function util:GetActivePlayerCountForTeam(team)
    local number = 0
    for x=0,DOTA_MAX_TEAM do
        local pID = PlayerResource:GetNthPlayerIDOnTeam(team,x)
        if PlayerResource:IsValidPlayerID(pID) and (PlayerResource:GetConnectionState(pID) == 1 or PlayerResource:GetConnectionState(pID) == 2) then
            number = number + 1
        end
    end
    return number
end

function util:GetActiveHumanPlayerCountForTeam(team)
    local number = 0
    for x=0,DOTA_MAX_TEAM do
        local pID = PlayerResource:GetNthPlayerIDOnTeam(team,x)
        if PlayerResource:IsValidPlayerID(pID) and not self:isPlayerBot(pID) and (PlayerResource:GetConnectionState(pID) == 1 or PlayerResource:GetConnectionState(pID) == 2) then
            number = number + 1
        end
    end
    return number
end

function util:secondsToClock(seconds)
  local seconds = math.abs(tonumber(seconds))

  if seconds <= 0 then
    return "00:00";
  else
    local mins = string.format("%02.f", math.floor(seconds/60));
    local secs = string.format("%02.f", math.floor(seconds - mins *60));
    return mins..":"..secs
  end
end

-- Returns a player's voting power
function util:getVotingPower(playerID)
    return self:getPremiumRank(playerID) + 1
end

-- Attempts to fetch gameinfo of players
function util:fetchPlayerData()
    local this = self

    -- Protected call
    local status, err = pcall(function()
        -- Only fetch player data once
        if this.fetchedPlayerData then return end

        local fullPlayerArray = {}

        for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
            local steamID = PlayerResource:GetSteamAccountID(playerID)
            if steamID ~= 0 then
                table.insert(fullPlayerArray, steamID)
            end
        end

        -- Did we fail to find anyone?
        if #fullPlayerArray <= 0 then return end

        local statInfo = LoadKeyValues('scripts/vscripts/statcollection/settings.kv')
        local gameInfoHost = 'https://api.getdotastats.com/player_summary.php'

        local payload = {
            modIdentifier = statInfo.modID,
            schemaVersion = 1,
            players = fullPlayerArray
        }

        -- Make the request
        local req = CreateHTTPRequestScriptVM('POST', gameInfoHost)

        if not req then return end
        this.fetchedPlayerData = true

        -- Add the data
        req:SetHTTPRequestGetOrPostParameter('payload', json.encode(payload))

        -- Send the request
        req:Send(function(res)
            if res.StatusCode ~= 200 or not res.Body then
                print('Failed to query for player info!')
                return
            end

            -- Try to decode the result
            local obj, pos, err = json.decode(res.Body, 1, nil)

            -- Feed the result into our callback
            if err then
                print(err)
                return
            end

            --[[if obj and obj.result then
                local mapData = {}

                for k,data in pairs(obj.result) do
                    local steamID = tostring(data.sid)

                    local totalAbandons = data.na
                    local totalWins = data.nw
                    local totalGames = data.ng
                    local totalFails = data.nf

                    local lastAbandon = data.la
                    local lastFail = data.lf
                    local lastGame = data.lr
                    local lastUpdate = data.lu

                    mapData[steamID] = {
                        totalAbandons = totalAbandons,
                        totalWins = totalWins,
                        totalGames = totalGames,
                        totalFails = totalFails,

                        lastAbandon = lastAbandon,
                        lastFail = lastFail,
                        lastGame = lastGame,
                        lastUpdate = lastUpdate
                    }
                end

                -- Push to pregame
                Pregame:onGetPlayerData(mapData)
            end]]--
        end)
    end)

    -- Failure?
    if not status then
        this.fetchedPlayerData = nil
    end
end

function util:split(pString, pPattern)
    local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = '(.-)' .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= '' then
            table.insert(Table,cap)
        end
        last_end = e+1
        s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
        cap = pString:sub(last_end)
        table.insert(Table, cap)
    end

    return Table
end

-- Works out the time difference between two LoD times
function util:timeDifference(lodCurrentTime, lodPreviousTime)
    return self:countSeconds(lodCurrentTime) - self:countSeconds(lodPreviousTime)
end

-- Calculates how many seconds in the given LoD timestamp
function util:countSeconds(lodTime)
    local seconds = lodTime.second
    local minuteSeconds = lodTime.minute * 60
    local hourSeconds = lodTime.hour * 60 * 60

    local daySeconds = lodTime.day * 60 * 60 * 24
    local monthSeconds = self:getDaysInPreviousMonths(lodTime.month) * 60 * 60 * 24
    local yearSeconds = lodTime.year * 60 * 60 * 24 * 365

    -- Add all the seconds together
    return seconds + minuteSeconds + hourSeconds + daySeconds + monthSeconds + yearSeconds
end

-- Works out how many days have passed in order to get to the given month
function util:getDaysInPreviousMonths(currentMonth)
    local daysInMonth = {
        [1] = 31,
        [2] = 28,
        [3] = 31,
        [4] = 30,
        [5] = 31,
        [6] = 30,
        [7] = 31,
        [8] = 31,
        [9] = 30,
        [10] = 31,
        [11] = 30,
        [12] = 31
    }

    local total = 0

    for i=1,(currentMonth-1) do
        total = total + daysInMonth[i]
    end

    return total
end

-- Parses a time
function util:parseTime(timeString)
    timeString = timeString or ''

    local year = 0
    local month = 0
    local day = 0

    local hour = 0
    local minute = 0
    local second = 0

    local parts = self:split(timeString, '%s')

    if #parts == 2 then
        local dateParts = self:split(parts[1], '-')
        local timeParts = self:split(parts[2], ':')

        year = tonumber(dateParts[1])
        month = tonumber(dateParts[2])
        day = tonumber(dateParts[3])

        hour = tonumber(timeParts[1])
        minute = tonumber(timeParts[2])
        second = tonumber(timeParts[3])
    end

    return {
        year = year,
        month = month,
        day = day,

        hour = hour,
        minute = minute,
        second = second
    }
end

function util:getTableLength(t)
  if not t then return nil end
  local length = 0

  for k,v in pairs(t) do
    length = length + 1
  end

  return length
end

function DebugCalls()
    if not GameRules.DebugCalls then
        print("Starting DebugCalls")
        GameRules.DebugCalls = true

        debug.sethook(function(...)
            local info = debug.getinfo(2)
            local src = tostring(info.short_src)
            local name = tostring(info.name)
            if name ~= "__index" then
                print("Call: ".. src .. " -- " .. name)
            end
        end, "c")
    else
        print("Stopped DebugCalls")
        GameRules.DebugCalls = false
        debug.sethook(nil, "c")
    end
end

function ShuffleArray(input)
  local rand = math.random
    local iterations = #input
    local j

    for i = iterations, 2, -1 do
        j = rand(i)
        input[i], input[j] = input[j], input[i]
    end
end

function util:MoveArray(input, index)
    index = index or 1
    local temp = table.remove(input, index)
    table.insert(input, temp)
end

function util:RandomChoice(input)
    local temp = {}
    for k in pairs(input) do
        table.insert(temp, k)
    end
    return input[temp[math.random(#temp)]]
end

function util:split(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result;
end

function util:anyBots()
    if Pregame.enabledBots == true then return true end
    local count = 0
    local toggle = false
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        print(playerID, self:isPlayerBot(playerID), PlayerResource:IsFakeClient(playerID), PlayerResource:GetPlayer(playerID))
        if PlayerResource:GetPlayer(playerID) and (PlayerResource:IsFakeClient(playerID) or PlayerResource:GetSteamAccountID(playerID) == 0) then
            toggle = true
        end
    end
    return toggle
end

function util:isSinglePlayerMode()
    local count = 0
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if not self:isPlayerBot(playerID) then
            count = count + 1
            if count > 1 then return false end
        end
    end

    return true
end

function util:checkPickedHeroes( builds )
    local players = {}

    for i = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        local ply = PlayerResource:GetPlayer(i)
        if ply then
            if not builds[i] then
                table.insert(players, i)
            end
        end
    end

    if #players == 0 then
        return nil
    else
        return players
    end
end

function util:isCoop()
    local RadiantHumanPlayers = self:GetActivePlayerCountForTeam(DOTA_TEAM_GOODGUYS)
    local DireHumanPlayers = self:GetActiveHumanPlayerCountForTeam(DOTA_TEAM_BADGUYS)
    if RadiantHumanPlayers == 0 or DireHumanPlayers == 0 then
        return true
    else
        return false
    end
end

function IsCustomAbilityByName(name)
    if not name then
        return false
    end
    if name == "" then
        return false
    end
    local ability_kvs = GetAbilityKeyValuesByName(name)
    if not ability_kvs then
        print("IsCustomAbilityByName: Ability "..name.." does not exist.")
        return false
    end
    return ability_kvs.BaseClass ~= nil and not util:IsTalent(name)
end

function GetRandomAbilityFromListForPerk(flag)
    local numberOfValues = 0
    local localTable = {}

    -- Getting the number of abilities and recreating the table
     for k,v in pairs(GameRules.perks[flag]) do
        if not k then
            break
        else

            numberOfValues = numberOfValues + 1
            localTable[numberOfValues] = v
        end
    end

    local random = RandomInt(1,numberOfValues)
    return localTable[random]
end

local voteCooldown = 150
util.votesBlocked = {}
util.votesRejected = {}
function util:CreateVoting(votingName, initiator, duration, percent, onaccept, onvote, ondecline, voteForInitiator)
    percent = percent or 100
    if util.activeVoting then
        if util.activeVoting.name == votingName and Time() >= util.activeVoting.recieveStartTime then
            util.activeVoting.onvote(initiator, true)
        else
            --TODO: Display error message - Can't start a new voting while there is another ongoing voting
        end
        return
    end

    if util.votesRejected[initiator] and util.votesRejected[initiator] >= 2 then
        util:DisplayError(initiator, "#votingPlayerBanned")
        return
    end

    -- If a vote fails, players cannot call another vote for 5 minutes, to prevent abuse.
    if util.votesBlocked[initiator] then
        util:DisplayError(initiator, "#votingCooldown")
        return
    end

    -- If a vote has been called of this type recently, block
    if util.votesBlocked[votingName] then
        util:DisplayError(initiator, "#voteCooldown")
        return
    end

    -- Temporarily block future votes if the vote is not succesful
    util.votesBlocked[votingName] = true
    util.votesBlocked[initiator] = true

    Timers:CreateTimer({
        useGameTime = false,
        endTime = voteCooldown,
        callback = function()
            util.votesBlocked[votingName] = false
            util.votesBlocked[initiator] = false
        end
    })

    local CheckForEnd = function(force)
        local votesAccepted = 0
        local totalPlayers = 0
        local votesDeclined = 0
        for PlayerID = 0, 23 do
            if PlayerResource:IsValidPlayerID(PlayerID) and not util:isPlayerBot(PlayerID) then
                local state = PlayerResource:GetConnectionState(PlayerID)
                if state == 1 or state == 2 then
                    if util.activeVoting.votes[PlayerID] ~= nil then
                        if util.activeVoting.votes[PlayerID] then
                            votesAccepted = votesAccepted + 1
                        else
                            votesDeclined = votesDeclined + 1
                        end
                    end
                    totalPlayers = totalPlayers + 1
                end
            end
        end
        local accept
        --If voting was declined x players, so percent can't be reached
        if votesDeclined > 0 and votesDeclined / totalPlayers >= 1 - (percent * 0.01) then
            accept = false
        end
        --If voting was accepted by % players
        if votesAccepted / totalPlayers >= percent * 0.01 then
            accept = true
        end

        if accept ~= nil or force then
            if accept == nil then accept = false end

            if accept then
                util.votesBlocked[initiator] = false
                if onaccept then
                    onaccept()
                end
            else
                if ondecline then
                    ondecline()
                end
                util.votesRejected[initiator] = (util.votesRejected[initiator] or 0) + 1
            end

            Timers:RemoveTimer(util.activeVoting.pauseChecker)
            Timers:RemoveTimer(util.activeVoting.vote_counter)
            CustomGameEventManager:Send_ServerToAllClients("universalVotingsUpdate", {votingName = votingName, accept = accept})
            util.activeVoting = nil
            PauseGame(false)
        end
    end

    local pauseChecker = Timers:CreateTimer({
        useGameTime = false,
        callback = function()
            if not GameRules:IsGamePaused() then
                PauseGame(true)
            end
            return 1/30
        end
    })
    local vote_counter = Timers:CreateTimer({
        useGameTime = false,
        endTime = duration,
        callback = function()
            CheckForEnd(true)
        end
    })
    local _onvote = function(pid, accepted)
        util.activeVoting.votes[pid] = accepted
        if onvote then
            onvote(pid, accepted)
        end
        CheckForEnd()
    end
    util.activeVoting = {
        name = votingName,
        votes = {},
        recieveStartTime = Time() + 3,
        onvote = _onvote,
        pauseChecker = pauseChecker,
        vote_counter = vote_counter
    }
    CustomGameEventManager:Send_ServerToAllClients("lodCreateUniversalVoting", {
        title = votingName,
        initiator = initiator,
        duration = duration
    })
    if voteForInitiator ~= false then
        _onvote(initiator, true)
    end
end

DisableHelpStates = DisableHelpStates or {}
function CDOTA_PlayerResource:SetDisableHelpForPlayerID(nPlayerID, nOtherPlayerID, disabled)
    if nPlayerID ~= nOtherPlayerID then
        DisableHelpStates[nPlayerID] = DisableHelpStates[nPlayerID] or {}
        DisableHelpStates[nPlayerID][nOtherPlayerID] = disabled
        CustomNetTables:SetTableValue("phase_ingame", "disable_help_data", DisableHelpStates)
    end
end

function CDOTA_PlayerResource:IsDisableHelpSetForPlayerID(nPlayerID, nOtherPlayerID)
    return DisableHelpStates[nPlayerID] ~= nil and DisableHelpStates[nPlayerID][nOtherPlayerID] and PlayerResource:GetTeam(nPlayerID) == PlayerResource:GetTeam(nOtherPlayerID)
end

function util:DisplayError(pid, message)
    local player = PlayerResource:GetPlayer(pid)
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "lodCreateIngameErrorMessage", {message=message})
    end
end

function util:EmitSoundOnClient(pid, sound)
    local player = PlayerResource:GetPlayer(pid)
    if player then
        CustomGameEventManager:Send_ServerToPlayer(player, "lodEmitClientSound", {sound=sound})
    end
end

-- Abilities ignored for custom Essence Aura abilities
function util:IsIgnoredForEssenceAura(ability)
    local essence_aura_ignore_list = {
        winter_wyvern_arctic_burn = true,
        eat_tree_eldri = true,
        storm_spirit_ball_lightning = true,
        ability_wards = true,
        ability_wards_op = true,
    }

	if not ability or ability:IsNull() then
		print("util:IsIgnoredForEssenceAura: Passed parameter does not exist!")
		return true
	end
	if not ability.GetAbilityKeyValues then
		print("util:IsIgnoredForEssenceAura: Passed parameter is not an ability!")
		return true
	end

	local ability_data = ability:GetAbilityKeyValues()
	local ability_mana_cost = ability:GetManaCost(-1)
	--local ability_cooldown = ability:GetCooldown(-1)

	-- Ignore items
	if ability:IsItem() then
		return true
	end

	if not ability_data then
		print("util:IsIgnoredForEssenceAura: Ability "..ability:GetAbilityName().." does not exist!")
		return true
	end

	-- Ignore toggle abilities
	local ability_behavior = ability_data.AbilityBehavior
	if string.find(ability_behavior, "DOTA_ABILITY_BEHAVIOR_TOGGLE") then
		return true
	end

	-- Ignore abilities that cost no mana
	if ability_mana_cost == 0 then
		return true
	end

	-- Ignore abilities that have no cooldown (but not attack-based spells)
	--if ability_cooldown == 0 and not string.find(ability_behavior, "DOTA_ABILITY_BEHAVIOR_ATTACK") then
		--return true
	--end

	-- Ignore abilities on the list
	if essence_aura_ignore_list[ability:GetAbilityName()] then
		return true
	end

	return false
end

-- Abilities ignored for custom Aftershock Redux
function util:IsIgnoredForAftershock(ability)
    local aftershock_ignore_list = {
        winter_wyvern_arctic_burn = true,
        eat_tree_eldri = true,
        ability_wards = true,
        ability_wards_op = true,
    }

	if not ability or ability:IsNull() then
		print("util:IsIgnoredForAftershock: Passed parameter does not exist!")
		return true
	end
	if not ability.GetAbilityKeyValues then
		print("util:IsIgnoredForAftershock: Passed parameter is not an ability!")
		return true
	end

	local ability_data = ability:GetAbilityKeyValues()
	--local ability_mana_cost = ability:GetManaCost(-1)
	local ability_cooldown = ability:GetCooldown(-1)

	-- Ignore items
	if ability:IsItem() then
		return true
	end

	if not ability_data then
		print("util:IsIgnoredForAftershock: Ability "..ability:GetAbilityName().." does not exist!")
		return true
	end

	-- Ignore toggle abilities
	local ability_behavior = ability_data.AbilityBehavior
	if string.find(ability_behavior, "DOTA_ABILITY_BEHAVIOR_TOGGLE") then
		return true
	end

	-- Ignore abilities that cost no mana
	--if ability_mana_cost == 0 then
		--return true
	--end

	-- Ignore abilities that have no cooldown (but not attack-based spells)
	if ability_cooldown == 0 and not string.find(ability_behavior, "DOTA_ABILITY_BEHAVIOR_ATTACK") then
		return true
	end

	-- Ignore abilities on the list
	if aftershock_ignore_list[ability:GetAbilityName()] then
		return true
	end

	return false
end

function util:getAbilityKV(ability, key)
    if key then
        if self.abilityKVs[ability] then
            return self.abilityKVs[ability][key]
        end
    elseif ability then
        return self.abilityKVs[ability]
    else
        return self.abilityKVs
    end
end

function util:contains(table, element)
    if table then
        for _, value in pairs(table) do
            if value == element then
                return true
            end
        end
    end
    return false
end

function util:removeByValue(t, value)
    for i,v in pairs(t) do
        if v == value then
            table.remove(t, i)
            break
        end
    end
end

function util:tableCount(t)
    local counter = 0
    for _ in pairs(t) do
        counter = counter + 1
    end
    return counter
end

function StringToArray(inputString, seperator)
  if not seperator then seperator = " " end
  local array={}
  local i=1

  for str in string.gmatch(inputString, "([^"..seperator.."]+)") do
    array[i] = str
    i = i + 1
  end
  return array
end

(function()
    util.abilityKVs = LoadKeyValues('scripts/npc/npc_abilities.txt')
    local absOverride = LoadKeyValues('scripts/npc/npc_abilities_override.txt')
    local absCustom = LoadKeyValues('scripts/npc/npc_abilities_custom.txt')

    util:MergeTables(util.abilityKVs, absOverride)
    util:MergeTables(util.abilityKVs, absCustom)

    for abilityName,data in pairs(util.abilityKVs) do
        if type(data) ~= 'table' then
            util.abilityKVs[abilityName] = nil
        end
    end
end)()
