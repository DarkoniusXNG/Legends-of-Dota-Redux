--------------------------------------------------------------------------------------------------------
--		Hero: Broodmother
--		Perk: Non-ultimate Summon abilities cast by Broodmother will have reduced cooldown and mana cost.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_broodmother_perk = modifier_npc_dota_hero_broodmother_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_broodmother_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_broodmother_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_broodmother_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_broodmother_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_broodmother_perk:GetTexture()
	return "custom/npc_dota_hero_broodmother_perk"
end

function modifier_npc_dota_hero_broodmother_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_npc_dota_hero_broodmother_perk:GetModifierPercentageCooldown(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("summon_non_ult") then
			return 25
		end
	end
	return 0
end

function modifier_npc_dota_hero_broodmother_perk:GetModifierPercentageManacostStacking(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("summon_non_ult") then
			return 25
		end
	end
	return 0
end
