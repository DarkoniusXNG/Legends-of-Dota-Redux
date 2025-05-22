--------------------------------------------------------------------------------------------------------
--		Hero: Magnus
--		Perk: Enemy-moving abilities cast by Magnus will have reduced cooldown and mana cost.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_magnataur_perk = modifier_npc_dota_hero_magnataur_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_magnataur_perk:GetTexture()
	return "custom/npc_dota_hero_magnataur_perk"
end

function modifier_npc_dota_hero_magnataur_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_npc_dota_hero_magnataur_perk:GetModifierPercentageCooldown(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("enemymoving") then
			return 25
		end
	end
	return 0
end

function modifier_npc_dota_hero_magnataur_perk:GetModifierPercentageManacostStacking(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("enemymoving") then
			return 25
		end
	end
	return 0
end
