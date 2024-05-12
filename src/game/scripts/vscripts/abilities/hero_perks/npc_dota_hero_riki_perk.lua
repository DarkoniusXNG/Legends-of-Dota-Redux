--------------------------------------------------------------------------------------------------------
--
--		Hero: Riki
--		Perk: Increases Riki's health and mana regeneration by 2% while invisible.
--
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

function modifier_npc_dota_hero_riki_perk:GetTexture()
	return "custom/npc_dota_hero_riki_perk"
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
