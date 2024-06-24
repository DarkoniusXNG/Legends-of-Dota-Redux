
if CDOTA_BaseNPC then
	function CDOTA_BaseNPC:IsSpiritBearCustom()
		return string.find(self:GetUnitName(), "npc_dota_lone_druid_bear")
	end

	function CDOTA_BaseNPC:HasShardCustom()
		return self:HasModifier("modifier_item_aghanims_shard")
	end

	function CDOTA_BaseNPC:IsLeashedCustom()
		local normal_leashes = {
			"modifier_furion_sprout_tether",
			"modifier_grimstroke_soul_chain",
			"modifier_puck_coiled",
			"modifier_rattletrap_cog_leash", -- not sure if this modifier exists
			"modifier_slark_pounce_leash",
			"modifier_tidehunter_anchor_clamp",
			--"modifier_mars_arena_of_blood_leash",
			--"modifier_faceless_void_time_zone_effect",
			-- custom:
		}

		-- Check for Leash immunities first
		-- if self:HasModifier("") then
			-- return false
		-- end

		-- Debuff Immunity interactions
		if self:IsDebuffImmune() then
			-- Grimstroke ult always pierces debuff immunity
			if self:HasModifier("modifier_grimstroke_soul_chain") then
				return true
			end

			-- Puck Dream Coil pierce debuff immunity with the talent
			local dream_coil = self:FindModifierByName("modifier_puck_coiled")
			if dream_coil then
				local caster = dream_coil:GetCaster()
				if caster then
					local talent = caster:FindAbilityByName("special_bonus_unique_puck_5")
					if talent and talent:GetLevel() > 0 then
						return true
					end
				end
			end

			return false
		end

		for _, v in pairs(normal_leashes) do
			if self:HasModifier(v) then
				return true
			end
		end

		local power_cogs = self:FindModifierByName("modifier_rattletrap_cog_marker")
		if power_cogs then
			local caster = power_cogs:GetCaster()
			if caster then
				local talent = caster:FindAbilityByName("special_bonus_unique_clockwerk_2")
				if talent and talent:GetLevel() > 0 then
					return true
				end
			end
		end
		return false
	end

	function CDOTA_BaseNPC:DispelUndispellableDebuffs()
		local undispellable_item_debuffs = {
			"modifier_heavens_halberd_debuff",               -- Heaven's Halberd debuff
			"modifier_item_bloodstone_drained",              -- Bloodstone drained debuff
			"modifier_item_nullifier_mute",                  -- Nullifier debuff
			"modifier_item_skadi_slow",
			"modifier_silver_edge_debuff",                   -- Silver Edge debuff
			-- custom:

		}

		local undispellable_ability_debuffs = {
			"modifier_axe_berserkers_call",
			"modifier_bloodseeker_rupture",
			"modifier_bristleback_quill_spray",       -- Quill Spray stacks
			"modifier_dazzle_bad_juju_armor",         -- Bad Juju stacks
			"modifier_doom_bringer_doom",
			"modifier_earthspirit_petrify",           -- Earth Spirit Enchant Remnant debuff
			"modifier_forged_spirit_melting_strike_debuff",
			"modifier_grimstroke_soul_chain",
			"modifier_huskar_burning_spear_debuff",   -- Burning Spear stacks
			"modifier_ice_blast",
			"modifier_invoker_deafening_blast_disarm",
			"modifier_maledict",
			"modifier_obsidian_destroyer_astral_imprisonment_prison",
			"modifier_queenofpain_sonic_wave_damage",
			"modifier_queenofpain_sonic_wave_knockback",
			"modifier_razor_eye_of_the_storm_armor",  -- Eye of the Storm stacks
			"modifier_razor_static_link_debuff",
			"modifier_sand_king_caustic_finale_orb",  -- Caustic Finale initial debuff
			"modifier_shadow_demon_disruption",
			"modifier_shadow_demon_purge_slow",
			"modifier_shadow_demon_shadow_poison",
			"modifier_silencer_curse_of_the_silent",  -- Arcane Curse becomes undispellable with the talent
			"modifier_slardar_amplify_damage",        -- Corrosive Haze becomes undispellable with the talent
			"modifier_slark_pounce_leash",
			"modifier_treant_overgrowth",             -- Overgrowth becomes undispellable with the talent
			"modifier_tusk_walrus_kick_slow",
			"modifier_tusk_walrus_punch_slow",
			"modifier_ursa_fury_swipes_damage_increase",
			"modifier_venomancer_poison_nova",
			"modifier_viper_viper_strike_slow",
			"modifier_windrunner_windrun_slow",
			"modifier_winter_wyvern_winters_curse",
			"modifier_winter_wyvern_winters_curse_aura",
		}

		local function RemoveTableOfModifiersFromUnit(unit, t)
			for i = 1, #t do
				unit:RemoveModifierByName(t[i])
			end
		end

		RemoveTableOfModifiersFromUnit(self, undispellable_item_debuffs)
		RemoveTableOfModifiersFromUnit(self, undispellable_ability_debuffs)
	end

	function CDOTA_BaseNPC:DispelDeathPreventingBuffs()
		-- It doesnt need to contain all of them, just those that don't crash
		local undispellable_ability_buffs = {
			"modifier_abaddon_borrowed_time",
			"modifier_dazzle_shallow_grave",
			"modifier_oracle_false_promise_timer",
			"modifier_phoenix_supernova_hiding",
			"modifier_skeleton_king_reincarnation_scepter_active", -- Wraith King Wraith Form
			"modifier_templar_assassin_refraction_absorb",
			"modifier_troll_warlord_battle_trance",
			-- custom:
			"modifier_imba_shallow_grave",
			"modifier_imba_spiked_carapace",
			"modifier_oracle_will_to_live",
		}

		local function RemoveTableOfModifiersFromUnit(unit, t)
			for i = 1, #t do
				unit:RemoveModifierByName(t[i])
			end
		end

		RemoveTableOfModifiersFromUnit(self, undispellable_ability_buffs)

		self:Purge(true, false, false, false, true)
	end

	function CDOTA_BaseNPC:GetUnsafeAbilitiesCount()
		local count = 0
		local randomKv = self.randomKv
		for i = 0, DOTA_MAX_ABILITIES - 1 do
			if self:GetAbilityByIndex(i) then
				local ability = self:GetAbilityByIndex(i)
				local name = ability:GetName()
				if not randomKv["Safe"][name] and not self.ownedSkill[name] then
					count = count + 1
				end
			end
		end
		return count
	end

	function CDOTA_BaseNPC:GetSafeAbilitiesCount()
		local count = 0
		for i = 0, DOTA_MAX_ABILITIES - 1 do
			local ability = self:GetAbilityByIndex(i)
			if ability then
				local name = ability:GetName()
				if not DONOTREMOVE[name] then
					count = count + 1
				end
			end
		end
		return count
	end

	-- modifierEventTable = {
	--     caster = caster,
	--     parent = parent,
	--     ability = ability,
	--     original_duration = duration,
	--     modifier_name = modifier_name,
	-- }
	function CDOTA_BaseNPC:GetTenacity(modifierEventTable)
		local tenacity = 1
		for _, parent_modifier in pairs(self:FindAllModifiers()) do
			if parent_modifier.GetTenacity then
				tenacity = tenacity * (1- (parent_modifier:GetTenacity(modifierEventTable)/100))
			end
		end
		return tenacity
	end

	function CDOTA_BaseNPC:GetWillPower(modifierEventTable)
		local willpower = 1
		for _, parent_modifier in pairs(self:FindAllModifiers()) do
			if parent_modifier.GetWillPower then
				willpower = willpower * (1+ (parent_modifier:GetWillPower(modifierEventTable)/100))
			end
		end
		return willpower
	end

	function CDOTA_BaseNPC:GetSummonersBoost(modifierEventTable)
		local boost = 1
		for _, parent_modifier in pairs(self:FindAllModifiers()) do
			if parent_modifier.GetSummonersBoost then
				boost = boost * (1+ (parent_modifier:GetSummonersBoost(modifierEventTable)/100))
			end
		end
		return boost
	end

	function CDOTA_BaseNPC:GetBATReduction()
		local reduction = 0
		for _, parent_modifier in pairs(self:FindAllModifiers()) do
			if parent_modifier.GetBATReductionConstant then
				reduction = reduction - parent_modifier:GetBATReductionConstant()
			end
		end
		return reduction
	end

	function CDOTA_BaseNPC:GetBaseBAT()
		local reduction = 0
		local pct = 1
		local unit_data = GetUnitKeyValuesByName(self:GetUnitName())
		self.BAT = self.BAT or unit_data.AttackRate
		local time = self.BAT or 1.7
		for _, parent_modifier in pairs(self:FindAllModifiers()) do
			if parent_modifier.GetModifierBaseAttackTimeConstant then
				if parent_modifier:GetName() ~= "modifier_bat_manager" then
					time = parent_modifier:GetModifierBaseAttackTimeConstant()
				end
			end
			if parent_modifier.GetBATReductionConstant then
				reduction = reduction - parent_modifier:GetBATReductionConstant()
			end
			if parent_modifier.GetBATReductionPercentage then
				pct = pct - (parent_modifier:GetBATReductionPercentage() /100)
			end
		end
		time = time * pct
		return time-reduction
	end

	function CDOTA_BaseNPC:FixIllusion(source)
		-- Stats fixes
		if self.GetBaseStrength and source.GetBaseStrength then
			self:ModifyStrength(source:GetBaseStrength() - self:GetBaseStrength())
			self:ModifyIntellect(source:GetBaseIntellect() - self:GetBaseIntellect())
			self:ModifyAgility(source:GetBaseAgility() - self:GetBaseAgility())

			-- copy over all the Tome stat modifiers from the original hero
			if not self:HasModifier("modifier_stats_tome") then
				for _, v in pairs(source:FindAllModifiersByName("modifier_stats_tome")) do
					local instance = self:AddNewModifier(self, v:GetAbility(), "modifier_stats_tome", {stat = v.stat})
					instance:SetStackCount(v:GetStackCount())
				end
			end
		end

		-- Primary attribute fix
		if self.GetPrimaryAttribute and source.GetPrimaryAttribute then
			if self:GetPrimaryAttribute() ~= source:GetPrimaryAttribute() then
				self:SetPrimaryAttribute(source:GetPrimaryAttribute())
			end
		end

		-- Illusion perks fixes
		local perk_mod_name = "modifier_"..source:GetUnitName().."_perk"
		local perk_mod = source:FindModifierByName(perk_mod_name)
		if perk_mod then
			if perk_mod.apply_to_illusions then
				self:AddNewModifier(self, nil, perk_mod_name, {})
			end
		end

		-- Check if illusion has the hero abilities in the same slots
		local hasHeroAbilities = true
		for abilitySlot = 0, DOTA_MAX_ABILITIES - 1 do
			local illusionAbility = self:GetAbilityByIndex(abilitySlot)
			local heroAbility = source:GetAbilityByIndex(abilitySlot)
			if heroAbility then
				local heroAbilityName = heroAbility:GetAbilityName()
				if not DONOTREMOVE[heroAbilityName] then
					if illusionAbility then
						local illusionAbilityName = illusionAbility:GetAbilityName()
						if illusionAbilityName ~= heroAbilityName then
							hasHeroAbilities = false
							break
						end
					else
						hasHeroAbilities = false
						break
					end
				end
			elseif illusionAbility then
				hasHeroAbilities = false
				break
			end
		end

		if not hasHeroAbilities then
			-- Created illusion does not have the same abilities as the original hero. Fixing...
			-- Remove all abilities first
			for abilitySlot = 0, DOTA_MAX_ABILITIES - 1 do
				local ab = self:GetAbilityByIndex(abilitySlot)
				if ab then
					self:RemoveAbility(ab:GetAbilityName())
				end
			end
			-- Add all hero abilities to the illusion
			for abilitySlot = 0, DOTA_MAX_ABILITIES - 1 do
				local heroAbility = source:GetAbilityByIndex(abilitySlot)
				if heroAbility then
					if not DONOTREMOVE[heroAbility:GetAbilityName()] then -- illusions dont need those abilities
						local abilityName = heroAbility:GetAbilityName()
						local addedAbility = self:AddAbility(abilityName)
						local abilityLevel = heroAbility:GetLevel()
						if abilityLevel > 0 then
							if addedAbility then
								addedAbility:SetLevel(abilityLevel)
								-- Make sure that they are in a same toggled state
								if heroAbility:GetToggleState() ~= addedAbility:GetToggleState() and addedAbility:IsValidToggleAbilityForIllusions() then
									addedAbility:ToggleAbility()
								end
							end
						end
					end
				end
			end
		else
			-- Created Illusion has the same abilities as the hero. Fixing toggles only
			for abilitySlot = 0, DOTA_MAX_ABILITIES - 1 do
				local heroAbility = source:GetAbilityByIndex(abilitySlot)
				local illusionAbility = self:GetAbilityByIndex(abilitySlot)
				if heroAbility and illusionAbility then
					-- Make sure that they are in a same toggled state
					if heroAbility:GetToggleState() ~= illusionAbility:GetToggleState() and illusionAbility:IsValidToggleAbilityForIllusions() then
						illusionAbility:ToggleAbility()
					end
				end
			end
		end
	end

	function CDOTA_BaseNPC:HasAbilityWithFlag(flag)
		for i = 0, DOTA_MAX_ABILITIES - 1 do
			local ability = self:GetAbilityByIndex(i)
			if ability then
				if ability:HasAbilityFlag(flag) then
					return true
				end
			end
		end
		return false
	end

	function CDOTA_BaseNPC:HasUnitFlag(flag)
		return GameRules.perks[flag][self:GetName()] ~= nil
	end

	function CDOTA_BaseNPC:IsSleeping()
		return self:HasModifier("modifier_bane_nightmare") or self:HasModifier("modifier_elder_titan_echo_stomp") or self:HasModifier("modifier_sleep_cloud_effect") or self:HasModifier("modifier_naga_siren_song_of_the_siren")
	end

	function CDOTA_BaseNPC:FindItemByName(item_name)
		for i = DOTA_ITEM_SLOT_1, DOTA_ITEM_SLOT_6 do
			local item = self:GetItemInSlot(i)
			if item and item:GetAbilityName() == item_name then
				return item
			end
		end
		return nil
	end

	function CDOTA_BaseNPC:FindItemByNameEverywhere(item_name)
		for i = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6 do
			local item = self:GetItemInSlot(i)
			if item and item:GetAbilityName() == item_name then
				return i, item
			end
		end
		local tp_scroll = self:GetItemInSlot(DOTA_ITEM_TP_SCROLL)
		if tp_scroll then
			if tp_scroll:GetAbilityName() == item_name then
				return DOTA_ITEM_TP_SCROLL, tp_scroll
			end
		end
		local neutral_item = self:GetItemInSlot(DOTA_ITEM_NEUTRAL_SLOT)
		if neutral_item then
			if neutral_item:GetAbilityName() == item_name then
				return DOTA_ITEM_NEUTRAL_SLOT, neutral_item
			end
		end
		return nil, nil
	end

	function CDOTA_BaseNPC:PopupNumbers(target, pfx, color, lifetime, number, presymbol, postsymbol)
		local armor = target:GetPhysicalArmorValue(false)
		local damageReduction = ((0.02 * armor) / (1 + 0.02 * armor))
		number = number - (number * damageReduction)
		number = number * self:GetSpellAmplification(false)

		number = math.floor(number)
		local pfxPath = string.format("particles/msg_fx/msg_%s.vpcf", pfx)
		local pidx
		if pfx == "gold" or pfx == "lumber" then
			pidx = ParticleManager:CreateParticleForTeam(pfxPath, PATTACH_CUSTOMORIGIN, target, target:GetTeamNumber())
		else
			pidx = ParticleManager:CreateParticle(pfxPath, PATTACH_CUSTOMORIGIN, target)
		end

		local digits = 0
		if number ~= nil then
			digits = #tostring(number)
		end
		if presymbol ~= nil then
			digits = digits + 1
		end
		if postsymbol ~= nil then
			digits = digits + 1
		end

		ParticleManager:SetParticleControl(pidx, 0, target:GetAbsOrigin())
		ParticleManager:SetParticleControl(pidx, 1, Vector(tonumber(presymbol), tonumber(number), tonumber(postsymbol)))
		ParticleManager:SetParticleControl(pidx, 2, Vector(lifetime, digits, 0))
		ParticleManager:SetParticleControl(pidx, 3, color)
	end

end

if C_DOTA_BaseNPC then
	function C_DOTA_BaseNPC:IsSpiritBearCustom()
		return string.find(self:GetUnitName(), "npc_dota_lone_druid_bear")
	end

	function C_DOTA_BaseNPC:HasShardCustom()
		return self:HasModifier("modifier_item_aghanims_shard")
	end

	function C_DOTA_BaseNPC:IsLeashedCustom()
		local normal_leashes = {
			"modifier_furion_sprout_tether",
			"modifier_grimstroke_soul_chain",
			"modifier_puck_coiled",
			"modifier_rattletrap_cog_leash", -- not sure if this modifier exists
			"modifier_slark_pounce_leash",
			"modifier_tidehunter_anchor_clamp",
			--"modifier_mars_arena_of_blood_leash",
			--"modifier_faceless_void_time_zone_effect",
			-- custom:
		}

		-- Check for Leash immunities first
		-- if self:HasModifier("") then
			-- return false
		-- end

		-- Debuff Immunity interactions
		if self:IsDebuffImmune() then
			-- Grimstroke Soulbind always pierces debuff immunity
			if self:HasModifier("modifier_grimstroke_soul_chain") then
				return true
			end

			return false
		end

		for _, v in pairs(normal_leashes) do
			if self:HasModifier(v) then
				return true
			end
		end

		return false
	end
end
