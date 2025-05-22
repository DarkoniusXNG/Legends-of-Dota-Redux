--------------------------------------------------------------------------------------------------------
--		Hero: Lycan
--		Perk: 
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_lycan_perk = modifier_npc_dota_hero_lycan_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_lycan_perk:GetTexture()
	return "custom/npc_dota_hero_lycan_perk"
end
