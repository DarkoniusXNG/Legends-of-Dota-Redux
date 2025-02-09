--------------------------------------------------------------------------------------------------------
--		Hero: Tinker
--		Perk: Bonus damage with Scientific spells
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_tinker_perk = modifier_npc_dota_hero_tinker_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_tinker_perk:GetTexture()
	return "custom/npc_dota_hero_tinker_perk"
end

function modifier_npc_dota_hero_tinker_perk:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
    }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
	local ability = keys.inflictor
	if not ability or ability:IsNull() then
		return 0
	end
	if ability:HasAbilityFlag("scientific") then
		return 25
	end
	return 0
end
