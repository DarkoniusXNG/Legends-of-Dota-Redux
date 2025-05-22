--------------------------------------------------------------------------------------------------------
--		Hero: Nature's Prophet
--		Perk: Nature and Teleportation abilities cast by Nature's Prophet will have reduced cooldown and mana cost.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_furion_perk = modifier_npc_dota_hero_furion_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_furion_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_furion_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_furion_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_furion_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_furion_perk:GetTexture()
	return "custom/npc_dota_hero_furion_perk"
end

function modifier_npc_dota_hero_furion_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_npc_dota_hero_furion_perk:GetModifierPercentageCooldown(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("nature") or ability:HasAbilityFlag("teleport") then
			return 25
		end
	end
	return 0
end

function modifier_npc_dota_hero_furion_perk:GetModifierPercentageManacostStacking(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("nature") or ability:HasAbilityFlag("teleport") then
			return 25
		end
	end
	return 0
end
