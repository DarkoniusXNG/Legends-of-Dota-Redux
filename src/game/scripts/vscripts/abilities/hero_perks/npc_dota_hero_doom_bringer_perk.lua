--------------------------------------------------------------------------------------------------------
--		Hero: Doom Bringer
--		Perk: Bonus damage with Demon spells. Silence spells also apply mute for a few seconds.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_doom_bringer_perk = modifier_npc_dota_hero_doom_bringer_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_doom_bringer_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_doom_bringer_perk:GetTexture()
	return "custom/npc_dota_hero_doom_bringer_perk"
end

function modifier_npc_dota_hero_doom_bringer_perk:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end

if IsServer() then
	function modifier_npc_dota_hero_doom_bringer_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
		local ability = keys.inflictor
		if not ability or ability:IsNull() then
			return 0
		end
		if ability:HasAbilityFlag("demon") then
			return 15
		end
		return 0
	end
end

--------------------------------------------------------------------------------------------------------
LinkLuaModifier("modifier_npc_dota_hero_doom_perk_mute", "abilities/hero_perks/npc_dota_hero_doom_bringer_perk.lua", LUA_MODIFIER_MOTION_NONE)

modifier_npc_dota_hero_doom_perk_mute = modifier_npc_dota_hero_doom_perk_mute or class({})

function modifier_npc_dota_hero_doom_perk_mute:IsHidden()
	return not self:GetParent():IsSilenced()
end

function modifier_npc_dota_hero_doom_perk_mute:IsDebuff()
	return true
end

function modifier_npc_dota_hero_doom_perk_mute:IsPurgable()
	return true
end

function modifier_npc_dota_hero_doom_perk_mute:RemoveOnDeath()
	return true -- we remove this modifier on death for sure
end

function modifier_npc_dota_hero_doom_perk_mute:CheckState()
	if self:GetParent():IsSilenced() then
		return {
			[MODIFIER_STATE_MUTED] = true,
		}
	end
	return {}
end

function modifier_npc_dota_hero_doom_perk_mute:GetTexture()
	return "custom/npc_dota_hero_doom_bringer_perk"
end

---------------------------------------------------------------------------------------------------
-- Does not trigger on re-apply / refresh!
function perkDoom(filterTable)
	local parent_index = filterTable["entindex_parent_const"]
	local caster_index = filterTable["entindex_caster_const"]
	local ability_index = filterTable["entindex_ability_const"]
	if not parent_index or not caster_index or not ability_index then
		return
	end
	local parent = EntIndexToHScript( parent_index )
	local caster = EntIndexToHScript( caster_index )
	if parent:GetTeamNumber() == caster:GetTeamNumber() then return end
	local ability = EntIndexToHScript( ability_index )
	if ability then
		if caster:HasModifier("modifier_npc_dota_hero_doom_bringer_perk") and ability:HasAbilityFlag("silence") then
			--local modifierDuration = filterTable["duration"]
			parent:AddNewModifier(caster, ability, "modifier_npc_dota_hero_doom_perk_mute", {duration = 2})
		end
	end
end
