--------------------------------------------------------------------------------------------------------
--
--		Hero: Doom Bringer
--		Perk: Doom's passives cannot be disabled.
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_doom_bringer_perk ~= "" then modifier_npc_dota_hero_doom_bringer_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:CheckState()
	local state = {
		[MODIFIER_STATE_PASSIVES_DISABLED] = false,
	}
	return state
end

function modifier_npc_dota_hero_doom_bringer_perk:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end