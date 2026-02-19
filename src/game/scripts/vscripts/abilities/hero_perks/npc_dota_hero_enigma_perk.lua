--------------------------------------------------------------------------------------------------------
--		Hero: Enigma
--		Perk: Channeling spells and spells with long cast points cast by Enigma will have reduced cooldown.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_enigma_perk = modifier_npc_dota_hero_enigma_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_enigma_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_enigma_perk:GetTexture()
	return "custom/npc_dota_hero_enigma_perk"
end

function modifier_npc_dota_hero_enigma_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}
end

function modifier_npc_dota_hero_enigma_perk:GetModifierPercentageCooldown(keys)
	local ability = keys.ability
	if ability then
		if ability:IsChannelledCustom() or ability:HasAbilityFlag("channeled") then
			return 25
		end
	end
	return 0
end
