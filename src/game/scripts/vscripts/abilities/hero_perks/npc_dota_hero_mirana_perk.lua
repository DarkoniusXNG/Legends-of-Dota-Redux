--------------------------------------------------------------------------------------------------------
--    Hero: Mirana
--    Perk: Skillshot abilities cast by Mirana will have reduced cooldown and mana cost.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_mirana_perk = modifier_npc_dota_hero_mirana_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mirana_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mirana_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mirana_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mirana_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_mirana_perk:GetTexture()
	return "custom/npc_dota_hero_mirana_perk"
end

function modifier_npc_dota_hero_mirana_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_npc_dota_hero_mirana_perk:GetModifierPercentageCooldown(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("skillshot") then
			return 25
		end
	end
	return 0
end

function modifier_npc_dota_hero_mirana_perk:GetModifierPercentageManacostStacking(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("skillshot") then
			return 25
		end
	end
	return 0
end
