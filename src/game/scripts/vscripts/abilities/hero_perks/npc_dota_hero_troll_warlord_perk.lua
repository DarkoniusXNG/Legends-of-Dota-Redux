--------------------------------------------------------------------------------------------------------
--		Hero: Troll Warlord
--		Perk: Increases the duration of all Rage effects on Troll Warlord by 20%.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_troll_warlord_perk = modifier_npc_dota_hero_troll_warlord_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_troll_warlord_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_troll_warlord_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_troll_warlord_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_troll_warlord_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_troll_warlord_perk:OnCreated()
	if IsServer() then
		local rageDurationBonusPct = 20
		self:GetCaster().rageDurationBonus = rageDurationBonusPct / 100
	end
end

function modifier_npc_dota_hero_troll_warlord_perk:GetTexture()
	return "custom/npc_dota_hero_troll_warlord_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function perkTrollWarlord(filterTable)
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
    if caster:HasModifier("modifier_npc_dota_hero_troll_warlord_perk") and ability:HasAbilityFlag("rage") and filterTable["duration"] ~= -1 then
        local modifierDuration = filterTable["duration"]
        local newDuration = modifierDuration + (modifierDuration * caster.rageDurationBonus)
        filterTable["duration"] = newDuration
    end
  end
end
