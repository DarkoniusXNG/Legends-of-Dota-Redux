--------------------------------------------------------------------------------------------------------
--		Hero: Marci
--		Perk: Abilities cast on allies by Marci will grant a stackable +20 attack damage and +10% move speed to both Marci and the ally for 7 seconds.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_marci_perk = modifier_npc_dota_hero_marci_perk or class({})

function modifier_npc_dota_hero_marci_perk:IsPassive()
	return true
end

function modifier_npc_dota_hero_marci_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_marci_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_marci_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_marci_perk:GetTexture()
	return "marci_unleash"
end

function modifier_npc_dota_hero_marci_perk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end

if IsServer() then
	function modifier_npc_dota_hero_marci_perk:OnAbilityFullyCast(params)
	 	local parent = self:GetParent()
		local caster = params.unit
		local target = params.target
		local ability = params.ability

		if caster == parent and target and ability then
			if target ~= caster and target:GetTeamNumber() == caster:GetTeamNumber() and not ability:IsItem() then
				caster:AddNewModifier(caster, ability, "modifier_npc_dota_hero_marci_perk_buff", {duration = 7})
				target:AddNewModifier(caster, ability, "modifier_npc_dota_hero_marci_perk_buff", {duration = 7})
			end
		end
	end
end

--------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_npc_dota_hero_marci_perk_buff", "abilities/hero_perks/npc_dota_hero_marci_perk.lua", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_marci_perk_buff = modifier_npc_dota_hero_marci_perk_buff or class({})

function modifier_npc_dota_hero_marci_perk_buff:IsHidden()
	return true
end

function modifier_npc_dota_hero_marci_perk_buff:IsDebuff()
	return false
end

function modifier_npc_dota_hero_marci_perk_buff:IsPurgable()
	return false
end

function modifier_npc_dota_hero_marci_perk_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_npc_dota_hero_marci_perk_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_marci_perk_buff:GetModifierPreAttack_BonusDamage()
	return 20
end

function modifier_npc_dota_hero_marci_perk_buff:GetModifierMoveSpeedBonus_Percentage()
	return 10
end
