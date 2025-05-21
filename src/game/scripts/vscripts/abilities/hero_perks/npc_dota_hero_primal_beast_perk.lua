--------------------------------------------------------------------------------------------------------
--		Hero: Primal Beast
--		Perk: Primal Beast gains spell amp for each level put in a Rage ability, 20% move speed, 50% turn speed and 10% base damage as long as it doesn't attack. Bonuses are lost for 2 seconds when the attack lands.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_primal_beast_perk = modifier_npc_dota_hero_primal_beast_perk or class({})

function modifier_npc_dota_hero_primal_beast_perk:IsPassive()
	return true
end

function modifier_npc_dota_hero_primal_beast_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_primal_beast_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_primal_beast_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_primal_beast_perk:GetTexture()
	return "primal_beast_uproar"
end

function modifier_npc_dota_hero_primal_beast_perk:OnCreated()
	self.bonusPerLevel = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_primal_beast_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and skill:HasAbilityFlag("rage") then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_primal_beast_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_npc_dota_hero_primal_beast_perk:GetModifierMoveSpeedBonus_Percentage()
	local parent = self:GetParent()
	if not parent:HasModifier("modifier_npc_dota_hero_primal_beast_perk_debuff") then
		return 20
	end
	return 0
end

function modifier_npc_dota_hero_primal_beast_perk:GetModifierTurnRate_Percentage()
	local parent = self:GetParent()
	if not parent:HasModifier("modifier_npc_dota_hero_primal_beast_perk_debuff") then
		return 50
	end
	return 0
end

function modifier_npc_dota_hero_primal_beast_perk:GetModifierBaseDamageOutgoing_Percentage()
	local parent = self:GetParent()
	if not parent:HasModifier("modifier_npc_dota_hero_primal_beast_perk_debuff") then
		return 10
	end
	return 0
end

function modifier_npc_dota_hero_primal_beast_perk:GetModifierSpellAmplify_Percentage()
	local parent = self:GetParent()
	if not parent:HasModifier("modifier_npc_dota_hero_primal_beast_perk_debuff") then
		return self:GetStackCount()
	end
	return 0
end

if IsServer() then
	function modifier_npc_dota_hero_primal_beast_perk:OnAttackLanded(event)
		local parent = self:GetParent()
		local attacker = event.attacker
		local target = event.target

		-- Check if attacker exists
		if not attacker or attacker:IsNull() then
			return
		end

		-- Check if attacker has this modifier
		if attacker ~= parent then
			return
		end
		
		-- Check if attacker is an illusion or dead
		if attacker:IsIllusion() or not attacker:IsAlive() then
			return
		end
		
		-- Check if attacked unit exists
		if not target or target:IsNull() then
			return
		end

		-- Check if attacked entity is an item, rune or something weird
		if target.GetUnitName == nil then
			return
		end
		
		-- Remove bonuses
		parent:AddNewModifier(parent, nil, "modifier_npc_dota_hero_primal_beast_perk_debuff", {duration = 2})
	end
end

LinkLuaModifier("modifier_npc_dota_hero_primal_beast_perk_debuff", "abilities/hero_perks/npc_dota_hero_primal_beast_perk.lua" , LUA_MODIFIER_MOTION_NONE)

modifier_npc_dota_hero_primal_beast_perk_debuff = modifier_npc_dota_hero_primal_beast_perk_debuff or class({})

function modifier_npc_dota_hero_primal_beast_perk_debuff:IsHidden()
  return false
end

function modifier_npc_dota_hero_primal_beast_perk_debuff:IsDebuff()
  return true
end

function modifier_npc_dota_hero_primal_beast_perk_debuff:IsPurgable()
  return false
end
