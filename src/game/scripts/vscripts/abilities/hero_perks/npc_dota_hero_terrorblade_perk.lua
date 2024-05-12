--------------------------------------------------------------------------------------------------------
--
--		Hero: Terrorblade
--		Perk: Terrorblade Illusions deal 15% more damage, but also take 15% more damage. 
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_terrorblade_perk ~= "" then modifier_npc_dota_hero_terrorblade_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_terrorblade_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_terrorblade_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_terrorblade_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_terrorblade_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_terrorblade_perk:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE, 
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_terrorblade_perk:GetModifierDamageOutgoing_Percentage(keys)
    if keys.attacker and keys.attacker:IsIllusion() then
        return 15
    else 
        return 0
    end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_terrorblade_perk:GetModifierIncomingDamage_Percentage(keys)
    if keys.attacker and keys.attacker:IsIllusion() then
        return 15
    else 
        return 0
    end
end
--------------------------------------------------------------------------------------------------------
