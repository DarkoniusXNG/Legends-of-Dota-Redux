--------------------------------------------------------------------------------------------------------
--		Hero: Huskar
--		Perk: Bonus damage with Self Damaging spells
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_huskar_perk = modifier_npc_dota_hero_huskar_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_huskar_perk:IsPassive()
	return true
end

function modifier_npc_dota_hero_huskar_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_huskar_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_huskar_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_huskar_perk:GetTexture()
	return "custom/npc_dota_hero_huskar_perk"
end

function modifier_npc_dota_hero_huskar_perk:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end

if IsServer() then
	function modifier_npc_dota_hero_huskar_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
		local ability = keys.inflictor
		if not ability or ability:IsNull() then
			return 0
		end
		if ability:HasAbilityFlag("self_damage") then
			return 15
		end
		return 0
	end
end
