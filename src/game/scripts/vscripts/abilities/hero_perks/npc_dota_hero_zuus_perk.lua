--------------------------------------------------------------------------------------------------------
--		Hero: Zeus
--		Perk: Lightning abilities cast by Zeus will have reduced cooldown and mana cost.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_zuus_perk = modifier_npc_dota_hero_zuus_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_zuus_perk:GetTexture()
	return "custom/npc_dota_hero_zuus_perk"
end

function modifier_npc_dota_hero_zuus_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_npc_dota_hero_zuus_perk:GetModifierPercentageCooldown(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("lightning") then
			return 25
		end
	end
	return 0
end

function modifier_npc_dota_hero_zuus_perk:GetModifierPercentageManacostStacking(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("lightning") then
			return 25
		end
	end
	return 0
end
