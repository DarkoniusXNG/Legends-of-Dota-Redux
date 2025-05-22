--------------------------------------------------------------------------------------------------------
--		Hero: Dazzle
--		Perk: Support spells will have 25% cooldown reduction when cast by Dazzle.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_dazzle_perk = modifier_npc_dota_hero_dazzle_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_dazzle_perk:GetTexture()
	return "custom/npc_dota_hero_dazzle_perk"
end

function modifier_npc_dota_hero_dazzle_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_dazzle_perk:GetModifierPercentageCooldown(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("support") then
			return 25
		end
	end
	return 0
end
