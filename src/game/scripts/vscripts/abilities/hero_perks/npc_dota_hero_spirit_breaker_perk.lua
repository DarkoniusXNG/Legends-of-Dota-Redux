--------------------------------------------------------------------------------------------------------
--		Hero: Spirit Breaker
--		Perk: When Spirit Breaker bashes, he also applies Break.
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_spirit_breaker_perk_break", "abilities/hero_perks/npc_dota_hero_spirit_breaker_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_spirit_breaker_perk = modifier_npc_dota_hero_spirit_breaker_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_spirit_breaker_perk:GetTexture()
	return "custom/npc_dota_hero_spirit_breaker_perk"
end
--------------------------------------------------------------------------------------------------------
--    Modifier: modifier_npc_dota_hero_spirit_breaker_perk_break
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_spirit_breaker_perk_break = modifier_npc_dota_hero_spirit_breaker_perk_break or class({})
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk_break:CheckState()
  return {
    [MODIFIER_STATE_PASSIVES_DISABLED] = true,
  }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk_break:IsPurgable()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk_break:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spirit_breaker_perk_break:GetTexture()
	return "custom/npc_dota_hero_spirit_breaker_perk"
end

function modifier_npc_dota_hero_spirit_breaker_perk_break:GetEffectName()
	return "particles/items3_fx/silver_edge.vpcf"
end

function modifier_npc_dota_hero_spirit_breaker_perk_break:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
--------------------------------------------------------------------------------------------------------
function perkSpaceCow(filterTable)  --ModifierGainedFilter
  local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  if not parent_index or not caster_index or not ability_index then
    return true
  end
  local parent = EntIndexToHScript( parent_index )
  local caster = EntIndexToHScript( caster_index )
  local ability = EntIndexToHScript( ability_index )
  if ability then
    if caster:HasModifier("modifier_npc_dota_hero_spirit_breaker_perk") and ability:HasAbilityFlag("bash") and parent:GetTeamNumber() ~= caster:GetTeamNumber() then
        local modifierDuration = filterTable["duration"]
        parent:AddNewModifier(caster, nil,"modifier_npc_dota_hero_spirit_breaker_perk_break",{duration = modifierDuration})
    end
  end
end
