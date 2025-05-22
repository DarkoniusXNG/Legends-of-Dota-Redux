--------------------------------------------------------------------------------------------------------
--		Hero: Techies
--		Perk: Trap and Explosive abilities cast by Techies will have reduced cooldown and mana cost.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_techies_perk = modifier_npc_dota_hero_techies_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_techies_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_techies_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_techies_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_techies_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_techies_perk:GetTexture()
	return "custom/npc_dota_hero_techies_perk"
end

function modifier_npc_dota_hero_techies_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_npc_dota_hero_techies_perk:GetModifierPercentageCooldown(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("trap") or ability:HasAbilityFlag("explosive") then
			return 30
		end
	end
	return 0
end

function modifier_npc_dota_hero_techies_perk:GetModifierPercentageManacostStacking(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("trap") or ability:HasAbilityFlag("explosive") then
			return 30
		end
	end
	return 0
end
