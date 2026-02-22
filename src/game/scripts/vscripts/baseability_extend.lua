
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
			return
		end
		return ability_kvs.BaseClass ~= nil and not util:IsTalent(self)
	end

	function CDOTABaseAbility:IsChannelledCustom()
		local name = self:GetAbilityName()
		local ability_data = GetAbilityKeyValuesByName(name) or self:GetAbilityKeyValues()
		if not ability_data then
			print("IsChannelledCustom: Ability "..name.." does not exist!")
			return
		end
		local behavior = ability_data.AbilityBehavior
		if not behavior then
			print("IsChannelledCustom: Ability "..name.." does not have a behavior!")
			return
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
			leshrac_pulse_nova = true,
			mars_bulwark = true,
			morph_agi_int_redux = true,
			morph_int_agi_redux = true,
			morph_int_str_redux = true,
			morph_str_int_redux = true,
			morphling_morph_agi = true,
			morphling_morph_str = true,
			pudge_rot = true,
			winter_wyvern_arctic_burn = true,
			witch_doctor_voodoo_restoration = true,
			zuus_lightning_hands = true,
		}

		local white_list = {
			phantom_lancer_phantom_edge = true,
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
			return
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
			print("IsChannelledCustom: Ability "..name.." does not exist!")
			return
		end
		local behavior = ability_data.AbilityBehavior
		if not behavior then
			print("IsChannelledCustom: Ability "..name.." does not have a behavior!")
			return
		end
		return string.find(behavior, "DOTA_ABILITY_BEHAVIOR_CHANNELLED")
	end

	function C_DOTABaseAbility:IsUltimateCustom()
		local name = self:GetAbilityName()
		local ability_data = GetAbilityKeyValuesByName(name) or self:GetAbilityKeyValues()
		if not ability_data then
			print("IsUltimateCustom: Ability "..name.." does not exist!")
			return
		end
		local ability_type = ability_data.AbilityType
		if not ability_type then
			-- If ability type is ommited it's usually a basic ability
			return false
		end
		return string.find(ability_type, "ABILITY_TYPE_ULTIMATE")
	end
end
