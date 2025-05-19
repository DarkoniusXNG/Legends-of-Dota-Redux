--------------------------------------------------------------------------------------------------------
--		Hero: Shadow Demon
--		Perk: Demonic abilities cast by Shadow Demon will have reduced cooldown and mana cost.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_shadow_demon_perk = modifier_npc_dota_hero_shadow_demon_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_shadow_demon_perk:GetTexture()
	return "custom/npc_dota_hero_shadow_demon_perk"
end

function modifier_npc_dota_hero_shadow_demon_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_npc_dota_hero_shadow_demon_perk:GetModifierPercentageCooldown(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("demon") then
			return 25
		end
	end
	return 0
end

function modifier_npc_dota_hero_shadow_demon_perk:GetModifierPercentageManacostStacking(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("demon") then
			return 25
		end
	end
	return 0
end

