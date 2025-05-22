--------------------------------------------------------------------------------------------------------
--		Hero: Centaur
--		Perk: Self-Damaging abilities cast by Centaur will have reduced cooldown.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_centaur_perk = modifier_npc_dota_hero_centaur_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_centaur_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_centaur_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_centaur_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_centaur_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_centaur_perk:GetTexture()
	return "custom/npc_dota_hero_centaur_perk"
end

function modifier_npc_dota_hero_centaur_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_centaur_perk:GetModifierPercentageCooldown(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("self_damage") then
			return 30
		end
	end
	return 0
end
