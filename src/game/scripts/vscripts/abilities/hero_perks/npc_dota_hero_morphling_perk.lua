--------------------------------------------------------------------------------------------------------
--		Hero: Morphling
--		Perk: Morphling gains 50% bonus movement speed and 500 cast range in the river.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_morphling_perk = modifier_npc_dota_hero_morphling_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_morphling_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_morphling_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_morphling_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_morphling_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_morphling_perk:GetTexture()
	return "custom/npc_dota_hero_morphling_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_morphling_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_morphling_perk:GetModifierMoveSpeedBonus_Percentage()
	local caster = self:GetCaster()
	local height = caster:GetAbsOrigin().z
	-- 128 is the height of the river, 140 is around the edges -- dota map river is now at 0 not 128
	if height <= 10 then
		return 50
	else
		return 0
	end
end
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_morphling_perk:GetModifierCastRangeBonusStacking()
	local caster = self:GetCaster()
	local height = caster:GetAbsOrigin().z
	-- 128 is the height of the river, 140 is around the edges -- dota map river is now at 0 not 128
	if height <= 10 then
		return 500
	else
		return 0
	end
end
