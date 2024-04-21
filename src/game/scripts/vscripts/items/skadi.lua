LinkLuaModifier("modifier_item_skadi_lod_passive", "items/skadi.lua", LUA_MODIFIER_MOTION_NONE) -- hidden
LinkLuaModifier("modifier_item_skadi_lod_consumed", "items/skadi.lua", LUA_MODIFIER_MOTION_NONE) -- visible
LinkLuaModifier("modifier_item_skadi_lod_debuff", "items/skadi.lua", LUA_MODIFIER_MOTION_NONE) -- visible

item_skadi_consumable = item_skadi_consumable or class({})

function item_skadi_consumable:GetIntrinsicModifierName()
	return "modifier_item_skadi_lod_passive"
end

function item_skadi_consumable:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()

	-- Prevent Tempest Double abuse
	if caster:IsTempestDouble() or target:IsTempestDouble() then
		return
	end

	-- Stats for consumed item
	local stats = self:GetSpecialValueFor("bonus_all_stats")
	local hp = self:GetSpecialValueFor("bonus_health")
	local mana = self:GetSpecialValueFor("bonus_mana")
	local debuff_duration = self:GetSpecialValueFor("cold_duration")
	local ms_slow_melee = self:GetSpecialValueFor("cold_slow_melee")
	local ms_slow_ranged = self:GetSpecialValueFor("cold_slow_ranged")
	local as_slow_melee = self:GetSpecialValueFor("cold_attack_slow_melee")
	local as_slow_ranged = self:GetSpecialValueFor("cold_attack_slow_ranged")
	local heal_reduction = self:GetSpecialValueFor("heal_reduction")

	local table_to_send = {
		stats = stats,
		hp = hp,
		mana = mana,
		dur = debuff_duration,
		ms_slow_melee = ms_slow_melee,
		ms_slow_ranged = ms_slow_ranged,
		as_slow_melee = as_slow_melee,
		as_slow_ranged = as_slow_ranged,
		heal_reduction = heal_reduction,
	}

	if caster == target and not caster:HasModifier("modifier_item_skadi_lod_consumed") then
		caster:AddNewModifier(caster, self, "modifier_item_skadi_lod_consumed", table_to_send)
		caster:EmitSound("DOTA_Item.Cheese.Activate")
		self:SpendCharge()
	end
end

function item_skadi_consumable:CastFilterResultTarget(target)
	local caster = self:GetCaster()

	-- Check if its the caster thats targetted
	if caster ~= target then
		return UF_FAIL_CUSTOM
	end

	-- Check if already consumed
	if caster:HasModifier("modifier_item_skadi_lod_consumed") then
		return UF_FAIL_CUSTOM
	end

	return UF_SUCCESS
end

function item_skadi_consumable:GetCustomCastErrorTarget(target)
	local caster = self:GetCaster()

	if caster ~= target then
		return "#consumable_items_only_self"
	end

	if caster:HasModifier("modifier_item_skadi_lod_consumed") then
		return "#consumable_items_already_consumed"
	end
end

---------------------------------------------------------------------------------------------------

modifier_item_skadi_lod_passive = modifier_item_skadi_lod_passive or class({})

function modifier_item_skadi_lod_passive:IsHidden()
	return true
end

function modifier_item_skadi_lod_passive:IsDebuff()
	return false
end

function modifier_item_skadi_lod_passive:IsPurgable()
	return false
end

function modifier_item_skadi_lod_passive:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_skadi_lod_passive:IsFirstItemInInventory()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if parent:IsNull() or ability:IsNull() then
		return false
	end

	if not IsServer() then
		print("IsFirstItemInInventory will not return the correct result on the client!")
		return
	end

	return parent:FindAllModifiersByName(self:GetName())[1] == self
end

function modifier_item_skadi_lod_passive:OnCreated()
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.stats = ability:GetSpecialValueFor("bonus_all_stats")
		self.hp = ability:GetSpecialValueFor("bonus_health")
		self.mana = ability:GetSpecialValueFor("bonus_mana")
	end
end

modifier_item_skadi_lod_passive.OnRefresh = modifier_item_skadi_lod_passive.OnCreated

function modifier_item_skadi_lod_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end

function modifier_item_skadi_lod_passive:GetModifierProjectileName()
	if self:IsFirstItemInInventory() then
		return "particles/items2_fx/skadi_projectile.vpcf"
	end
end

function modifier_item_skadi_lod_passive:GetModifierBonusStats_Strength()
	return self.stats
end

function modifier_item_skadi_lod_passive:GetModifierBonusStats_Agility()
	return self.stats
end

function modifier_item_skadi_lod_passive:GetModifierBonusStats_Intellect()
	return self.stats
end

function modifier_item_skadi_lod_passive:GetModifierHealthBonus()
	return self.hp
end

function modifier_item_skadi_lod_passive:GetModifierManaBonus()
	return self.mana
end

if IsServer() then
	function modifier_item_skadi_lod_passive:OnAttackLanded(event)
		if not self:IsFirstItemInInventory() then
			return
		end

		local parent = self:GetParent()
		local ability = self:GetAbility()
		local target = event.target

		if parent ~= event.attacker then
			return
		end

		-- Skadi doesnt work on illusions (projectile is changed though)
		if parent:IsIllusion() then
			return
		end

		-- To prevent crashes:
		if not target or target:IsNull() then
			return
		end

		-- Check for existence of GetUnitName method to determine if target is a unit or an item (or rune)
		-- items don't have that method -> nil; if the target is an item, don't continue
		if target.GetUnitName == nil then
			return
		end

		-- Doesn't work when attacking allies
		if target:GetTeamNumber() == parent:GetTeamNumber() then
			return
		end

		-- Doesn't work when attacking buildings or wards
		if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() then
			return
		end

		local debuff_duration = ability:GetSpecialValueFor("cold_duration")
		--if parent:IsRangedAttacker() then
		--  duration = ability:GetSpecialValueFor("cold_duration_ranged")
		--end
		target:AddNewModifier(parent, ability, "modifier_item_skadi_lod_debuff", {duration = debuff_duration})
	end
end

---------------------------------------------------------------------------------------------------

modifier_item_skadi_lod_consumed = modifier_item_skadi_lod_consumed or class({})

function modifier_item_skadi_lod_consumed:IsHidden()
	return false
end

function modifier_item_skadi_lod_consumed:IsDebuff()
	return false
end

function modifier_item_skadi_lod_consumed:IsPurgable()
	return false
end

function modifier_item_skadi_lod_consumed:RemoveOnDeath()
	return false
end

function modifier_item_skadi_lod_consumed:GetTexture()
	return "item_skadi"
end

function modifier_item_skadi_lod_consumed:OnCreated(event)
	if IsServer() then
		self.stats = event.stats
		self.hp = event.hp
		self.mana = event.mana
		self.dur = event.dur
		self.ms_slow_melee = event.ms_slow_melee
		self.ms_slow_ranged = event.ms_slow_ranged
		self.as_slow_melee = event.as_slow_melee
		self.as_slow_ranged = event.as_slow_ranged
		self.heal_reduction = event.heal_reduction
		self:SetHasCustomTransmitterData(true)
	end
end

function modifier_item_skadi_lod_consumed:OnRefresh(event)
	if IsServer() then
		self.stats = self.stats or event.stats
		self.hp = self.hp or event.hp
		self.mana = self.mana or event.mana
		self.dur = self.dur or event.dur
		self:SendBuffRefreshToClients()
	end
end

-- server-only function that is called whenever SetHasCustomTransmitterData(true) or SendBuffRefreshToClients() is called
function modifier_item_skadi_lod_consumed:AddCustomTransmitterData()
	return {
		stats = self.stats,
	}
end

-- client-only function that is called with the table returned by AddCustomTransmitterData()
function modifier_item_skadi_lod_consumed:HandleCustomTransmitterData(data)
	self.stats = data.stats
end

function modifier_item_skadi_lod_consumed:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PROJECTILE_NAME,
	}
end

function modifier_item_skadi_lod_consumed:GetModifierProjectileName()
	if not self:GetParent():HasModifier("modifier_item_skadi_lod_passive") then
		return "particles/items2_fx/skadi_projectile.vpcf"
	end
end

function modifier_item_skadi_lod_consumed:GetModifierBonusStats_Strength()
	return self.stats
end

function modifier_item_skadi_lod_consumed:GetModifierBonusStats_Agility()
	return self.stats
end

function modifier_item_skadi_lod_consumed:GetModifierBonusStats_Intellect()
	return self.stats
end

function modifier_item_skadi_lod_consumed:GetModifierHealthBonus()
	return self.hp
end

function modifier_item_skadi_lod_consumed:GetModifierManaBonus()
	return self.mana
end

if IsServer() then
	function modifier_item_skadi_lod_consumed:OnAttackLanded(event)
		local parent = self:GetParent()

		if parent:HasModifier("modifier_item_skadi_lod_passive") then
			return
		end

		local target = event.target

		if parent ~= event.attacker then
			return
		end

		if parent:IsIllusion() then
			return
		end

		-- To prevent crashes:
		if not target or target:IsNull() then
			return
		end

		-- Check for existence of GetUnitName method to determine if target is a unit or an item (or rune)
		-- items don't have that method -> nil; if the target is an item, don't continue
		if target.GetUnitName == nil then
			return
		end

		-- Doesn't work when attacking allies
		if target:GetTeamNumber() == parent:GetTeamNumber() then
			return
		end

		-- Doesn't work when attacking buildings or wards
		if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() then
			return
		end

		local table_to_send = {
			duration = self.dur,
			ms_slow_melee = self.ms_slow_melee,
			ms_slow_ranged = self.ms_slow_ranged,
			as_slow_melee = self.as_slow_melee,
			as_slow_ranged = self.as_slow_ranged,
			heal_reduction = self.heal_reduction,
		}

		-- Apply passive debuff
		target:AddNewModifier(parent, nil, "modifier_item_skadi_lod_debuff", table_to_send)
	end
end

---------------------------------------------------------------------------------------------------

modifier_item_skadi_lod_debuff = modifier_item_skadi_lod_debuff or class({})

function modifier_item_skadi_lod_debuff:IsHidden()
	return false
end

function modifier_item_skadi_lod_debuff:IsDebuff()
	return true
end

function modifier_item_skadi_lod_debuff:IsPurgable()
	return true
end

function modifier_item_skadi_lod_debuff:OnCreated(event)
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.ms_slow_melee = ability:GetSpecialValueFor("cold_slow_melee")
		self.ms_slow_ranged = ability:GetSpecialValueFor("cold_slow_ranged")
		self.as_slow_melee = ability:GetSpecialValueFor("cold_attack_slow_melee")
		self.as_slow_ranged = ability:GetSpecialValueFor("cold_attack_slow_ranged")
		self.heal_reduction = ability:GetSpecialValueFor("heal_reduction")
	else
		if IsServer() then
			self.ms_slow_melee = event.ms_slow_melee
			self.ms_slow_ranged = event.ms_slow_ranged
			self.as_slow_melee = event.as_slow_melee
			self.as_slow_ranged = event.as_slow_ranged
			self.heal_reduction = event.heal_reduction
			self:SetHasCustomTransmitterData(true)
		end
	end
end

function modifier_item_skadi_lod_debuff:OnRefresh(event)
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.ms_slow_melee = ability:GetSpecialValueFor("cold_slow_melee")
		self.ms_slow_ranged = ability:GetSpecialValueFor("cold_slow_ranged")
		self.as_slow_melee = ability:GetSpecialValueFor("cold_attack_slow_melee")
		self.as_slow_ranged = ability:GetSpecialValueFor("cold_attack_slow_ranged")
		self.heal_reduction = ability:GetSpecialValueFor("heal_reduction")
	else
		if IsServer() then
			self.ms_slow_melee = self.ms_slow_melee or event.ms_slow_melee
			self.ms_slow_ranged = self.ms_slow_ranged or event.ms_slow_ranged
			self.as_slow_melee = self.as_slow_melee or event.as_slow_melee
			self.as_slow_ranged = self.as_slow_ranged or event.as_slow_ranged
			self.heal_reduction = self.heal_reduction or event.heal_reduction
			self:SendBuffRefreshToClients()
		end
	end
end

-- server-only function that is called whenever SetHasCustomTransmitterData(true) or SendBuffRefreshToClients() is called
function modifier_item_skadi_lod_debuff:AddCustomTransmitterData()
    return {
		ms_slow_melee = self.ms_slow_melee,
		ms_slow_ranged = self.ms_slow_ranged,
		as_slow_melee = self.as_slow_melee,
		as_slow_ranged = self.as_slow_ranged,
		heal_reduction = self.heal_reduction,
    }
end

-- client-only function that is called with the table returned by AddCustomTransmitterData()
function modifier_item_skadi_lod_debuff:HandleCustomTransmitterData(data)
	self.ms_slow_melee = data.ms_slow_melee
	self.ms_slow_ranged = data.ms_slow_ranged
	self.as_slow_melee = data.as_slow_melee
	self.as_slow_ranged = data.as_slow_ranged
	self.heal_reduction = data.heal_reduction
end

function modifier_item_skadi_lod_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		--MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_LIFESTEAL_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_LIFESTEAL_AMPLIFY_PERCENTAGE,
	}
end

function modifier_item_skadi_lod_debuff:GetModifierMoveSpeedBonus_Percentage()
	local parent = self:GetParent()
	if parent:IsRangedAttacker() then
		return 0 - math.abs(self.ms_slow_ranged)
	else
		return 0 - math.abs(self.ms_slow_melee)
	end
end

-- function modifier_item_skadi_lod_debuff:GetModifierAttackSpeedBonus_Constant()
	-- local parent = self:GetParent()
	-- if parent:IsRangedAttacker() then
		-- return 0 - math.abs(self.as_slow_ranged)
	-- else
		-- return 0 - math.abs(self.as_slow_melee)
	-- end
-- end

function modifier_item_skadi_lod_debuff:GetModifierAttackSpeedPercentage()
	local parent = self:GetParent()
	if parent:IsRangedAttacker() then
		return 0 - math.abs(self.as_slow_ranged)
	else
		return 0 - math.abs(self.as_slow_melee)
	end
end

function modifier_item_skadi_lod_debuff:GetModifierHPRegenAmplify_Percentage()
	return 0 - math.abs(self.heal_reduction)
end

function modifier_item_skadi_lod_debuff:GetModifierHealAmplify_PercentageTarget()
	return 0 - math.abs(self.heal_reduction)
end

function modifier_item_skadi_lod_debuff:GetModifierLifestealRegenAmplify_Percentage()
	return 0 - math.abs(self.heal_reduction)
end

function modifier_item_skadi_lod_debuff:GetModifierSpellLifestealRegenAmplify_Percentage()
	return 0 - math.abs(self.heal_reduction)
end

function modifier_item_skadi_lod_debuff:GetStatusEffectName()
  return "particles/status_fx/status_effect_frost.vpcf"
end

function modifier_item_skadi_lod_debuff:GetTexture()
	return "item_skadi"
end
