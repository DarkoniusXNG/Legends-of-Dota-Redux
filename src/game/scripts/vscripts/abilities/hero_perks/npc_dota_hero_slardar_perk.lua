--------------------------------------------------------------------------------------------------------
--		Hero: Slardar
--		Perk: Bonus damage with Physical spells
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_slardar_perk = modifier_npc_dota_hero_slardar_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slardar_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slardar_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slardar_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_slardar_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_slardar_perk:GetTexture()
	return "custom/npc_dota_hero_slardar_perk"
end

function modifier_npc_dota_hero_slardar_perk:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end

if IsServer() then
	function modifier_npc_dota_hero_slardar_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
		if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then
			return 0
		end
		if keys.damage_type == DAMAGE_TYPE_PHYSICAL then
			return 50
		end
		return 0
	end
end
