
if CDOTABaseAbility then
	function CDOTABaseAbility:GetTalentSpecialValueFor(value)
		local base = self:GetSpecialValueFor(value)
		local talentName
		local kv = self:GetAbilityKeyValues()
		for k,v in pairs(kv) do -- trawl through keyvalues
			if k == "AbilitySpecial" then
				for l,m in pairs(v) do
					if m[value] then
						talentName = m["LinkedSpecialBonus"]
					end
				end
			end
		end
		if talentName then
			local talent = self:GetCaster():FindAbilityByName(talentName)
			if talent and talent:GetLevel() > 0 then base = base + talent:GetSpecialValueFor("value") end
		end
		return base
	end

	function CDOTABaseAbility:GetAbilityLifeTime(buffer)
		local kv = self:GetAbilityKeyValues()
		local duration = self:GetDuration()
		local delay = 0
		if not duration then duration = 0 end
		if self:GetChannelTime() > duration then duration = self:GetChannelTime() end
		for k,v in pairs(kv) do -- trawl through keyvalues
			if k == "AbilitySpecial" then
				for l,m in pairs(v) do
					for o,p in pairs(m) do
						if string.match(o, "duration") then -- look for the highest duration keyvalue
							local checkDuration = self:GetLevelSpecialValueFor(o, -1)
							if checkDuration > duration then duration = checkDuration end
						elseif string.match(o, "delay") then -- look for a delay for spells without duration but do have a delay
							local checkDelay = self:GetLevelSpecialValueFor(o, -1)
							if checkDelay > duration then delay = checkDelay end
						end
					end
				end
			elseif k == "AbilityValues" then
				for l, m in pairs(v) do
					if string.match(l, "duration") then
						local checkDuration = self:GetLevelSpecialValueFor(l, -1)
						if checkDuration > duration then duration = checkDuration end
					elseif string.match(l, "delay") then
						local checkDelay = self:GetLevelSpecialValueFor(l, -1)
						if checkDelay > duration then delay = checkDelay end
					end
				end
			end
		end
	  ------------------------------ SPECIAL CASES -----------------------------
	  if self:GetName() == "juggernaut_omni_slash" then
		local bounces = self:GetLevelSpecialValueFor("omni_slash_jumps", -1)
		delay = self:GetLevelSpecialValueFor("omni_slash_bounce_tick", -1) * bounces
	  elseif self:GetName() == "medusa_mystic_snake" then
		local bounces = self:GetLevelSpecialValueFor("snake_jumps", -1)
		delay = self:GetLevelSpecialValueFor("jump_delay", -1) * bounces
	  elseif self:GetName() == "witch_doctor_paralyzing_cask" then
		local bounces = self:GetLevelSpecialValueFor("bounces", -1)
		delay = self:GetLevelSpecialValueFor("bounce_delay", -1) * bounces
	  elseif self:GetName() == "zuus_arc_lightning" or self:GetName() == "leshrac_lightning_storm" then
		local bounces = self:GetLevelSpecialValueFor("jump_count", -1)
		delay = self:GetLevelSpecialValueFor("jump_delay", -1) * bounces
	  elseif self:GetName() == "furion_wrath_of_nature" then
		local bounces = self:GetLevelSpecialValueFor("max_targets", -1)
		delay = self:GetLevelSpecialValueFor("jump_delay", -1) * bounces
	  elseif self:GetName() == "death_prophet_exorcism" then
		local distance = self:GetLevelSpecialValueFor("max_distance", -1) + 2000 -- add spirit break distance to be sure
		delay = distance / self:GetLevelSpecialValueFor("spirit_speed", -1)
	  elseif self:GetName() == "necrolyte_death_pulse" then
		local distance = self:GetLevelSpecialValueFor("area_of_effect", -1) + 2000 -- add blink range + buffer zone to be safe
		delay = distance / self:GetLevelSpecialValueFor("projectile_speed", -1)
	  elseif self:GetName() == "spirit_breaker_charge_of_darkness" then
		local distance = math.sqrt(15000*15000*2) -- size diagonal of a 15000x15000 square
		delay = distance / self:GetLevelSpecialValueFor("movement_speed", -1)
	  end
	  --------------------------------------------------------------------------
		duration = duration + delay
		if buffer then duration = duration + buffer end
		return duration
	end

	function CDOTABaseAbility:GetTrueCooldown()
		local cooldown = self:GetCooldown(-1) -- TODO: Check if this returns cooldown after CDR
		local hero = self:GetCaster()
		local true_cd = cooldown

		-- OP Witchcraft
		local mabWitchOP = hero:FindAbilityByName('death_prophet_witchcraft_op')
		if mabWitchOP then
			true_cd = math.max(cooldown - 4 * mabWitchOP:GetLevel(), 1)
		end

		true_cd = true_cd * hero:GetCooldownReduction()
		return true_cd
	end

	function CDOTABaseAbility:HasAbilityFlag(flag)
		if not GameRules.perks[flag] then return false end
		return GameRules.perks[flag][self:GetAbilityName()] ~= nil
	end

	function CDOTABaseAbility:IsCustomAbility()
		local ability_kvs = GetAbilityKeyValuesByName(self:GetAbilityName()) or self:GetAbilityKeyValues()
		if not ability_kvs then
			print("IsCustomAbility: Ability "..self:GetAbilityName().." does not exist.")
			return false
		end
		return ability_kvs.BaseClass ~= nil and not IsTalentCustom(self)
	end

	function CDOTABaseAbility:IsChannelledCustom()
		local name = self:GetAbilityName()
		local ability_data = GetAbilityKeyValuesByName(name) or self:GetAbilityKeyValues()
		if not ability_data then
			print("IsChannelledCustom: Ability "..name.." does not exist!")
			return false
		end
		local behavior = ability_data.AbilityBehavior
		if not behavior then
			print("IsChannelledCustom: Ability "..name.." does not have a behavior!")
			return false
		end
		return string.find(behavior, "DOTA_ABILITY_BEHAVIOR_CHANNELLED")
	end

	function CDOTABaseAbility:IsUltimateCustom()
		return self:GetAbilityType() == ABILITY_TYPE_ULTIMATE
	end

	function CDOTABaseAbility:IsValidToggleAbilityForIllusions()
		local black_list = {
			bloodseeker_blood_mist = true,
			butcher_zombie = true,
			cherub_synthesis = true,
			imba_pudge_rot = true,
			--largo_amphibian_rhapsody = true,
			leshrac_pulse_nova = true,
			mars_bulwark = true,
			morph_agi_int_redux = true,
			morph_int_agi_redux = true,
			morph_int_str_redux = true,
			morph_str_int_redux = true,
			morphling_morph_agi = true,
			morphling_morph_str = true,
			pudge_rot = true,
			rattletrap_jetpack_toggle = true,
			winter_wyvern_arctic_burn = true,
			witch_doctor_voodoo_restoration = true,
			zuus_lightning_hands = true,
		}

		local white_list = {
			--medusa_split_shot = true,
			--muerta_gunslinger = true,
			phantom_lancer_phantom_edge = true,
			--troll_warlord_switch_stance = true,
		}

		if not self.GetAbilityKeyValues or self.GetAbilityName == nil then
			print("IsValidToggleAbilityForIllusions: Passed parameter is not an ability!")
			return false
		end

		-- If the ability is on the white list -> must be valid, don't continue
		if white_list[self:GetAbilityName()] then
			return true
		end

		local ability_data = self:GetAbilityKeyValues()
		local ability_mana_cost = self:GetManaCost(-1)
		local ability_cooldown = self:GetCooldown(-1)

		if not ability_data then
			print("IsValidToggleAbilityForIllusions: Ability "..self:GetAbilityName().." does not exist!")
			return false
		end

		-- If the ability is not a toggle -> not valid
		local ability_behavior = ability_data.AbilityBehavior
		if not string.find(ability_behavior, "DOTA_ABILITY_BEHAVIOR_TOGGLE") then
			return false
		end

		-- If the ability costs mana -> not valid
		if ability_mana_cost ~= 0 then
			return false
		end

		-- If the ability has a cooldown -> not valid
		if ability_cooldown ~= 0 then
			return false
		end

		-- If the ability is on the black list -> not valid
		if black_list[self:GetAbilityName()] then
			return false
		end

		return true
	end
end

if C_DOTABaseAbility then
	function C_DOTABaseAbility:HasAbilityFlag(flag)
		local ability_kvs = GetAbilityKeyValuesByName(self:GetAbilityName()) or self:GetAbilityKeyValues()
		if not ability_kvs then
			print("HasAbilityFlag: Ability "..self:GetAbilityName().." does not exist.")
			return false
		end
		local perks = ability_kvs.ReduxPerks
		if perks then
			if string.find(perks, "lightning") and flag == "light" then
				local s = string.gsub(perks, "lightning", "")
				return string.find(s, flag)
			else
				return string.find(perks, flag)
			end
		end
	end

	function C_DOTABaseAbility:IsChannelledCustom()
		local name = self:GetAbilityName()
		local ability_data = GetAbilityKeyValuesByName(name) or self:GetAbilityKeyValues()
		if not ability_data then
			print("Ability:IsChannelledCustom: Ability "..name.." does not exist!")
			return false
		end
		local behavior = ability_data.AbilityBehavior
		if not behavior then
			print("Ability:IsChannelledCustom: Ability "..name.." does not have a behavior!")
			return false
		end
		return string.find(behavior, "DOTA_ABILITY_BEHAVIOR_CHANNELLED")
	end

	function C_DOTABaseAbility:IsUltimateCustom()
		local name = self:GetAbilityName()
		local ability_data = GetAbilityKeyValuesByName(name) or self:GetAbilityKeyValues()
		if not ability_data then
			print("IsUltimateCustom: Ability "..name.." does not exist!")
			return false
		end
		local ability_type = ability_data.AbilityType
		if not ability_type then
			-- If ability type is ommited it's usually a basic ability
			return false
		end
		return string.find(ability_type, "ABILITY_TYPE_ULTIMATE")
	end
end

if IsServer() then
	-- Tells you if a given spell is channelled or not
	function IsChannelledCustom(name)
		if not name then
			print("IsChannelledCustom: Passed parameter is not a string!")
			return false
		end
		if name == "" then
			print("IsChannelledCustom: Passed parameter is an empty string!")
			return false
		end
		local ability_data = GetAbilityKeyValuesByName(name)
		if not ability_data then
			print("IsChannelledCustom: Ability "..name.." does not exist!")
			return false
		end
		local behavior = ability_data.AbilityBehavior
		if not behavior then
			print("IsChannelledCustom: Ability "..name.." does not have a behavior!")
			return false
		end
		return string.find(behavior, "DOTA_ABILITY_BEHAVIOR_CHANNELLED")
	end

	-- Tells you if a given spell is an ultimate
	function IsUltimateCustomByName(name)
		if not name then
			print("IsUltimateCustomByName: Passed parameter is not a string!")
			return false
		end
		if name == "" then
			print("IsUltimateCustomByName: Passed parameter is an empty string!")
			return false
		end
		local ability_data = GetAbilityKeyValuesByName(name)
		if not ability_data then
			print("IsUltimateCustomByName: Ability "..name.." does not exist!")
			return false
		end
		local ability_type = ability_data.AbilityType
		if not ability_type then
			-- If ability type is ommited it's usually a basic ability
			return false
		end
		return string.find(ability_type, "ABILITY_TYPE_ULTIMATE")
	end

	-- Tells you if a given spell is needing a unit target
	function IsTargetSpellCustom(name)
		if not name then
			print("IsTargetSpellCustom: Passed parameter is not a string!")
			return false
		end
		if name == "" then
			print("IsTargetSpellCustom: Passed parameter is an empty string!")
			return false
		end
		local ability_data = GetAbilityKeyValuesByName(name)
		if not ability_data then
			print("IsTargetSpellCustom: Ability "..name.." does not exist!")
			return
		end
		local behavior = ability_data.AbilityBehavior
		if not behavior then
			print("IsTargetSpellCustom: Ability "..name.." does not have a behavior!")
			return
		end
		return string.find(behavior, "DOTA_ABILITY_BEHAVIOR_UNIT_TARGET")
	end

	-- Tells you if given spell is a talent
	function IsTalentCustom(ability)
		local ability_name
		if type(ability) == "string" then
			ability_name = ability
			if ability_name == "" or ability_name == 'generic_hidden' or ability_name == "ability_base" then
				return false
			end
			local ability_data = GetAbilityKeyValuesByName(ability_name)
			if not ability_data then
				print("IsTalentCustom: Ability "..ability_name.." does not exist!")
				return false
			end
		else
			if not ability or ability:IsNull() then
				print("IsTalentCustom: Passed parameter does not exist!")
				return false
			end
			if not ability.GetAbilityName then
				print("IsTalentCustom: Passed parameter is not an ability!")
				return false
			end
			ability_name = ability:GetAbilityName()
		end

		return string.find(ability_name, "special_bonus_") and ability_name ~= "special_bonus_attributes"
	end

	function IsCustomAbilityByName(name)
		if not name then
			print("IsCustomAbilityByName: Passed parameter is not a string!")
			return false
		end
		if name == "" or name == 'special_bonus_attributes' or name == 'generic_hidden' or DONOTREMOVE[name] or name == "ability_base" then
			return false
		end
		local ability_kvs = GetAbilityKeyValuesByName(name)
		if not ability_kvs then
			print("IsCustomAbilityByName: Ability "..name.." does not exist.")
			return false
		end
		return ability_kvs.BaseClass ~= nil and not IsTalentCustom(name) -- 99% of vanilla abilities have BaseClass ommited
	end

	function IsCompletelyCustomAbility(ability)
		local ability_name
		if type(ability) == "string" then
			ability_name = ability
		else
			if not ability or ability:IsNull() then
				print("IsCompletelyCustomAbility: Passed parameter does not exist!")
				return false
			end
			if not ability.GetAbilityName then
				print("IsCompletelyCustomAbility: Passed parameter is not an ability!")
				return false
			end
			ability_name = ability:GetAbilityName()
		end

		local ability_data = GetAbilityKeyValuesByName(ability_name)
		if not ability_data then
			print("IsCompletelyCustomAbility: Ability "..ability_name.." does not exist!")
			return false
		end

		if not IsCustomAbilityByName(ability_name) then
			--print("IsCompletelyCustomAbility: Ability "..ability_name.." is not even a candidate to be a completely custom ability!")
			return false
		end

		local baseclass = ability_data.BaseClass
		if not baseclass or baseclass == "" then
			return false
		end

		return string.find(baseclass, "ability_lua") or string.find(baseclass, "ability_datadriven")
	end

	-- Tells you if given spell is an innate
	function IsInnateCustom(ability)
		local ability_name
		if type(ability) == "string" then
			ability_name = ability
		else
			if not ability or ability:IsNull() then
				print("IsInnateCustom: Passed parameter does not exist!")
				return false
			end
			if not ability.GetAbilityName then
				print("IsInnateCustom: Passed parameter is not an ability!")
				return false
			end
			ability_name = ability:GetAbilityName()
		end

		if ability_name == "" or ability_name == 'special_bonus_attributes' or ability_name == 'generic_hidden' or DONOTREMOVE[ability_name] or ability_name == "ability_base" then
			return false
		end

		local ability_data = GetAbilityKeyValuesByName(ability_name)
		if not ability_data then
			print("IsInnateCustom: Ability "..ability_name.." does not exist!")
			return false
		end

		if ability_data.Innate ~= nil then
			if tonumber(ability_data.Innate) == 1 then
				return true
			end
		end
		return false
	end

	-- Tells you if given spell is supposed to be hidden
	function IsSupposedToBeHiddenCustom(ability)
		local ability_name
		if type(ability) == "string" then
			ability_name = ability
		else
			if not ability or ability:IsNull() then
				print("IsSupposedToBeHiddenCustom: Passed parameter does not exist!")
				return true
			end
			if not ability.GetAbilityName then
				print("IsSupposedToBeHiddenCustom: Passed parameter is not an ability!")
				return true
			end
			ability_name = ability:GetAbilityName()
		end

		if ability_name == "" or ability_name == 'special_bonus_attributes' or ability_name == 'generic_hidden' or DONOTREMOVE[ability_name] or ability_name == "ability_base" then
			return true
		end

		local ability_data = GetAbilityKeyValuesByName(ability_name)
		if not ability_data then
			print("IsSupposedToBeHiddenCustom: Ability "..ability_name.." does not exist!")
			return true
		end

		local behavior = ability_data.AbilityBehavior
		if not behavior then
			print("IsSupposedToBeHiddenCustom: Ability "..ability_name.." does not have a behavior!")
			return true
		end
		return string.find(behavior, "DOTA_ABILITY_BEHAVIOR_HIDDEN")
	end

	-- Abilities ignored for custom Essence Aura abilities
	function IsIgnoredForEssenceAura(ability)
		if not ability or ability:IsNull() then
			print("IsIgnoredForEssenceAura: Passed parameter does not exist!")
			return true
		end
		if type(ability) == "string" or not ability.GetAbilityKeyValues then
			print("IsIgnoredForEssenceAura: Passed parameter is not an ability!")
			return true
		end

		local essence_aura_ignore_list = { -- should contain 0s cd non-toggle spells that have mana cost
			storm_spirit_ball_lightning = true,
			winter_wyvern_arctic_burn = true,
		}

		local ability_data = ability:GetAbilityKeyValues()
		local ability_mana_cost = ability:GetManaCost(-1)
		--local ability_cooldown = ability:GetCooldown(-1)

		-- Ignore items
		if ability:IsItem() then
			return true
		end

		if not ability_data then
			print("IsIgnoredForEssenceAura: Ability "..ability:GetAbilityName().." does not exist!")
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
	function IsIgnoredForAftershock(ability)
		if not ability or ability:IsNull() then
			print("IsIgnoredForAftershock: Passed parameter does not exist!")
			return true
		end
		if type(ability) == "string" or not ability.GetAbilityKeyValues then
			print("IsIgnoredForAftershock: Passed parameter is not an ability!")
			return true
		end

		local aftershock_ignore_list = { -- should contain 0 mana cost spells with low cd that is not 0
			doom_bringer_scorched_earth = ability:GetSpecialValueFor("AbilityManaCost") == 0,
			shadow_demon_shadow_poison_release = true,
			--spectre_reality = true, -- has mana cost
			techies_focused_detonate = true,
			winter_wyvern_arctic_burn = true,
			--eat_tree_eldri = true, -- actually has mana cost that increases with each cast
		}

		local ability_data = ability:GetAbilityKeyValues()
		--local ability_mana_cost = ability:GetManaCost(-1)
		local ability_cooldown = ability:GetCooldown(-1)

		-- Ignore items
		if ability:IsItem() then
			return true
		end

		if not ability_data then
			print("IsIgnoredForAftershock: Ability "..ability:GetAbilityName().." does not exist!")
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

	-- Tells you if given spell is a valid spell, not a talent and not an ultimate
	function IsValidBasicByName(name)
		if not name then
			print("IsValidBasicByName: Passed parameter is not a string!")
			return false
		end
		if name == "" or name == 'special_bonus_attributes' or name == 'generic_hidden' or DONOTREMOVE[name] or name == "ability_base" then
			return false
		end
		local ability_data = GetAbilityKeyValuesByName(name)
		if not ability_data then
			print("IsValidBasicByName: Ability "..name.." does not exist!")
			return false
		end
		local ability_type = ability_data.AbilityType
		if not ability_type then
			-- If ability type is ommited it's usually a basic ability but some talents have it ommited too
			return not IsUltimateCustomByName(name) and not IsTalentCustom(name) -- IF THERE ARE ISSUES REMOVE IsTalentCustom
		end
		return string.find(ability_type, "ABILITY_TYPE_BASIC")
	end

	-- Returns true if a skill is a passive (excludes non-learnable passives that are sometimes innates)
	function IsPassiveCustomByName(name)
		if not name then
			print("IsPassiveCustomByName: Passed parameter is not a string!")
			return false
		end
		if name == "" or name == 'special_bonus_attributes' or name == 'generic_hidden' or DONOTREMOVE[name] or name == "ability_base" then
			return false
		end
		local ability_data = GetAbilityKeyValuesByName(name)
		if not ability_data then
			print("IsPassiveCustomByName: Ability "..name.." does not exist!")
			return false
		end
		local behavior = ability_data.AbilityBehavior
		if not behavior then
			print("IsPassiveCustomByName: Ability "..name.." does not have a behavior!")
			return
		end

		return string.find(behavior, 'DOTA_ABILITY_BEHAVIOR_PASSIVE') and not string.find(behavior, 'DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE')
	end
end
