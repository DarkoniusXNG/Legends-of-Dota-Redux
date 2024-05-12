--------------------------------------------------------------------------------------------------------
--
--		Hero: Batrider
--		Perk: Increases Batrider's movement speed by 20% while Flying.
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_batrider_perk ~= "" then modifier_npc_dota_hero_batrider_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_batrider_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_batrider_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_batrider_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_batrider_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_batrider_perk:DeclareFunctions()
	return { MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_batrider_perk:GetModifierMoveSpeedBonus_Percentage()
	if self:GetCaster():HasFlyMovementCapability() then
 		return 20
	else 
		return 0
	end
end
