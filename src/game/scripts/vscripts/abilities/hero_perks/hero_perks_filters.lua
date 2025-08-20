require('abilities/hero_perks/npc_dota_hero_troll_warlord_perk')
require('abilities/hero_perks/npc_dota_hero_spirit_breaker_perk')
require('abilities/hero_perks/npc_dota_hero_ancient_apparition_perk')
require('abilities/hero_perks/npc_dota_hero_viper_perk')
require('abilities/hero_perks/npc_dota_hero_silencer_perk')
require('abilities/hero_perks/npc_dota_hero_venomancer_perk')
require('abilities/hero_perks/npc_dota_hero_obsidian_destroyer_perk')
require('abilities/hero_perks/npc_dota_hero_doom_bringer_perk')

function heroPerksModifierFilter(filterTable)
  local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  if not parent_index or not caster_index or not ability_index then
      return filterTable
  end

  local caster = EntIndexToHScript( caster_index )

  local perks = {
    modifier_npc_dota_hero_ancient_apparition_perk = true,
    modifier_npc_dota_hero_doom_bringer_perk = true,
    modifier_npc_dota_hero_obsidian_destroyer_perk = true,
    modifier_npc_dota_hero_silencer_perk = true,
    modifier_npc_dota_hero_spirit_breaker_perk = true,
    modifier_npc_dota_hero_troll_warlord_perk = true,
    modifier_npc_dota_hero_venomancer_perk = true,
    modifier_npc_dota_hero_viper_perk = true,
  }
  local perkName = "modifier_" .. caster:GetName() .. "_perk"
  local targetPerk = caster:HasModifier(perkName)
  if not targetPerk then return filterTable end
  if not perks[perkName] then return filterTable end
  -- Perk for Ancient Apparition
  perkAncientApparition(filterTable)
  -- Perk for Doom
  perkDoom(filterTable)
  -- Perk for Outworld Devourer
  perkOD(filterTable)
  -- Perk for Venomancer
  perkVenomancer(filterTable)
  -- Perk for Silencer
  perkSilencer(filterTable)
  -- Perk for Viper
  perkViper(filterTable)
  -- Perk for Spirit Breaker
  perkSpaceCow(filterTable)
  -- Perk for Troll Warlord
  perkTrollWarlord(filterTable)

  -- Returning the filterTable
  return filterTable
end
