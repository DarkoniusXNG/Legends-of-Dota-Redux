--------------------------------------------------------------------------------------------------------
--		Hero: Arc Warden
--		Perk: Bonus damage with Neutral spells
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_arc_warden_perk = modifier_npc_dota_hero_arc_warden_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_arc_warden_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_arc_warden_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_arc_warden_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_arc_warden_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_arc_warden_perk:GetTexture()
	return "custom/npc_dota_hero_arc_warden_perk"
end

function modifier_npc_dota_hero_arc_warden_perk:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end

if IsServer() then
	function modifier_npc_dota_hero_arc_warden_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
		local ability = keys.inflictor
		if not ability or ability:IsNull() then
			return 0
		end
		if ability:HasAbilityFlag("neutral") then
			return 25
		end
		return 0
	end
end
