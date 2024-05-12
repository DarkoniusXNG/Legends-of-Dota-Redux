--------------------------------------------------------------------------------------------------------
--		Hero: Bounty Hunter
--		Perk: Bounty Hunter deals 20% more damage to Stunned enemies. 
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_bounty_hunter_perk = modifier_npc_dota_hero_bounty_hunter_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bounty_hunter_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bounty_hunter_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bounty_hunter_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bounty_hunter_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_bounty_hunter_perk:GetTexture()
	return "custom/npc_dota_hero_bounty_hunter_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bounty_hunter_perk:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
    }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bounty_hunter_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
    if keys.target and (keys.target:HasModifier("modifier_stunned") or keys.target:IsStunned()) then
        return 20
    else 
        return 0
    end
end
