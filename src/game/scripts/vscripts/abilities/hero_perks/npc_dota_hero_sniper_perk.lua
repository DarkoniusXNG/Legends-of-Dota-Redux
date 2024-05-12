--------------------------------------------------------------------------------------------------------
--		Hero: Sniper
--		Perk: When Sniper uses Shrapnel it will have a global cast range.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_sniper_perk = modifier_npc_dota_hero_sniper_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sniper_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sniper_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sniper_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sniper_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_sniper_perk:GetTexture()
	return "custom/npc_dota_hero_sniper_perk"
end

function modifier_npc_dota_hero_sniper_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
	}
end

function modifier_npc_dota_hero_sniper_perk:GetModifierCastRangeBonusStacking(params)
	local ability = params.ability
	if ability then
		if ability:GetAbilityName() == "sniper_shrapnel" then
			return 25000
		end
	end
	return 0
end
