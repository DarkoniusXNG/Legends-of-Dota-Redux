LinkLuaModifier("modifier_dazzle_bad_juju_redux_passive", "abilities/dazzle_bad_juju_redux.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_dazzle_bad_juju_redux_armor_reduction_debuff", "abilities/dazzle_bad_juju_redux.lua", LUA_MODIFIER_MOTION_NONE)

dazzle_bad_juju_redux = dazzle_bad_juju_redux or class({})

function dazzle_bad_juju_redux:GetIntrinsicModifierName()
	return "modifier_dazzle_bad_juju_redux_passive"
end

---------------------------------------------------------------------------------------------------

modifier_dazzle_bad_juju_redux_passive = modifier_dazzle_bad_juju_redux_passive or class({})

function modifier_dazzle_bad_juju_redux_passive:IsHidden()
	return true
end

function modifier_dazzle_bad_juju_redux_passive:IsDebuff()
	return false
end

function modifier_dazzle_bad_juju_redux_passive:IsPurgable()
	return false
end

function modifier_dazzle_bad_juju_redux_passive:OnRefresh()
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.cdr = ability:GetSpecialValueFor("cooldown_reduction")
	end
end

function modifier_dazzle_bad_juju_redux_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE, -- GetModifierPercentageCooldown
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end

function modifier_dazzle_bad_juju_redux_passive:GetModifierPercentageCooldown()
	if self:GetParent():PassivesDisabled() then return 0 end
	return self.cdr or self:GetAbility():GetSpecialValueFor("cooldown_reduction")
end

if IsServer() then
	function modifier_dazzle_bad_juju_redux_passive:OnAbilityFullyCast(event)
		local parent = self:GetParent()
		local bad_juju = self:GetAbility()
		local cast_ability = event.ability
		local caster = event.unit

		if parent:PassivesDisabled() then return end

		-- Check if caster has this modifier
		if caster ~= parent then return end

		if not cast_ability or cast_ability:IsNull() then
			return
		end
		if not cast_ability.GetAbilityKeyValues then
			return
		end

		local ability_data = cast_ability:GetAbilityKeyValues()
		local ability_mana_cost = cast_ability:GetManaCost(-1)
		local ability_cooldown = cast_ability:GetCooldown(-1)

		-- Ignore items
		if cast_ability:IsItem() then
			return
		end

		if not ability_data then
			return
		end

		-- Check behavior first
		local ability_behavior = ability_data.AbilityBehavior
		if string.find(ability_behavior, "DOTA_ABILITY_BEHAVIOR_TOGGLE") then
			return
		end

		-- If the ability costs no mana, do nothing
		if ability_mana_cost == 0 then
			return
		end

		-- If the ability has no cooldown, do nothing
		if ability_cooldown == 0 then
			return
		end

		local radius = bad_juju:GetSpecialValueFor('radius')
		local debuff_duration = bad_juju:GetSpecialValueFor("duration")

		-- Find the targets
		local enemies = FindUnitsInRadius(
			parent:GetTeam(),
			parent:GetOrigin(),
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false
		)
		for _, enemy in pairs(enemies) do
			-- Apply Armor Reduction debuff
			enemy:AddNewModifier(parent, bad_juju, "modifier_dazzle_bad_juju_redux_armor_reduction_debuff", {duration = debuff_duration})
		end
	end
end

---------------------------------------------------------------------------------------------------

modifier_dazzle_bad_juju_redux_armor_reduction_debuff = modifier_dazzle_bad_juju_redux_armor_reduction_debuff or class({})

function modifier_dazzle_bad_juju_redux_armor_reduction_debuff:IsHidden()
	return false
end

function modifier_dazzle_bad_juju_redux_armor_reduction_debuff:IsDebuff()
	return true
end

function modifier_dazzle_bad_juju_redux_armor_reduction_debuff:IsPurgable()
	return true
end

function modifier_dazzle_bad_juju_redux_armor_reduction_debuff:OnCreated()
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.armor_reduction = ability:GetSpecialValueFor("armor_reduction")
	end
	if IsServer() then
		self:SetStackCount(1)
	end
end

function modifier_dazzle_bad_juju_redux_armor_reduction_debuff:OnRefresh()
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.armor_reduction = ability:GetSpecialValueFor("armor_reduction")
	end

	if IsServer() then
		self:IncrementStackCount()
	end
end

function modifier_dazzle_bad_juju_redux_armor_reduction_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_dazzle_bad_juju_redux_armor_reduction_debuff:GetModifierPhysicalArmorBonus()
	return 0 - math.abs(self.armor_reduction * self:GetStackCount())
end

function modifier_dazzle_bad_juju_redux_armor_reduction_debuff:GetEffectName()
	return "particles/units/heroes/hero_dazzle/dazzle_armor_enemy.vpcf"
end

function modifier_dazzle_bad_juju_redux_armor_reduction_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
