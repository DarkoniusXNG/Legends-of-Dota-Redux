--------------------------------------------------------------------------------------------------------
--
--		Hero: Riki
--		Perk: Increases Riki's health regeneration by 2% while invisible. 
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_riki_perk", "abilities/hero_perks/npc_dota_hero_riki_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
npc_dota_hero_riki_perk = npc_dota_hero_riki_perk or class({})
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_riki_perk				
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_riki_perk = modifier_npc_dota_hero_riki_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_riki_perk:IsPassive()
	return true
end

--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_riki_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_riki_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_riki_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_riki_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_TOTAL_PERCENTAGE,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_riki_perk:GetModifierHealthRegenPercentage()
	if self:GetCaster():IsInvisible() then
 		return 2
	else 
		return 0
	end
end

function modifier_npc_dota_hero_riki_perk:GetModifierTotalPercentageManaRegen()
	if self:GetCaster():IsInvisible() then
 		return 2
	else 
		return 0
	end
end
