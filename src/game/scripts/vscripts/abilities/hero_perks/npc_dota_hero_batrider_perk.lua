--------------------------------------------------------------------------------------------------------
--		Hero: Batrider
--		Perk: Increases Batrider's movement speed by 20% and spell amp by 10% while Flying.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_batrider_perk = modifier_npc_dota_hero_batrider_perk or class({})
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

function modifier_npc_dota_hero_batrider_perk:GetTexture()
	return "custom/npc_dota_hero_batrider_perk"
end

function modifier_npc_dota_hero_batrider_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_batrider_perk:GetModifierMoveSpeedBonus_Percentage()
	if self:GetParent():HasFlyMovementCapability() then
 		return 20
	else 
		return 0
	end
end

function modifier_npc_dota_hero_batrider_perk:GetModifierSpellAmplify_Percentage()
	if self:GetParent():HasFlyMovementCapability() then
 		return 10
	else 
		return 0
	end
end
