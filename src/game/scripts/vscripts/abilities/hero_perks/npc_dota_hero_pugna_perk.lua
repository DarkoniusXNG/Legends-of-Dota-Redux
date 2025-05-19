--------------------------------------------------------------------------------------------------------
--		Hero: Pugna
--		Perk: Drain abilities cast by Pugna will have reduced cooldown and mana cost.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_pugna_perk = modifier_npc_dota_hero_pugna_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pugna_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pugna_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pugna_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pugna_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_pugna_perk:GetTexture()
	return "custom/npc_dota_hero_pugna_perk"
end

function modifier_npc_dota_hero_pugna_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_npc_dota_hero_pugna_perk:GetModifierPercentageCooldown(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("drain") then
			return 35
		end
	end
	return 0
end

function modifier_npc_dota_hero_pugna_perk:GetModifierPercentageManacostStacking(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("drain") then
			return 35
		end
	end
	return 0
end
