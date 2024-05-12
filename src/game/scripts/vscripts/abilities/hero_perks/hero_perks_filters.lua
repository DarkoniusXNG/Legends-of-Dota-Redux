--require('abilities/hero_perks/npc_dota_hero_shadow_demon_perk')
--require('abilities/hero_perks/npc_dota_hero_puck_perk')
require('abilities/hero_perks/npc_dota_hero_bane_perk')
require('abilities/hero_perks/npc_dota_hero_troll_warlord_perk')
require('abilities/hero_perks/npc_dota_hero_spirit_breaker_perk')
require('abilities/hero_perks/npc_dota_hero_dragon_knight_perk')
require('abilities/hero_perks/npc_dota_hero_ancient_apparition_perk')
require('abilities/hero_perks/npc_dota_hero_slardar_perk')
require('abilities/hero_perks/npc_dota_hero_viper_perk')
require('abilities/hero_perks/npc_dota_hero_silencer_perk')
require('abilities/hero_perks/npc_dota_hero_venomancer_perk')
require('abilities/hero_perks/npc_dota_hero_obsidian_destroyer_perk')
require('abilities/hero_perks/npc_dota_hero_death_prophet_perk')
require('abilities/hero_perks/npc_dota_hero_abaddon_perk')

--[[function heroPerksProjectileFilter(filterTable)
  local targetIndex = filterTable["entindex_target_const"]
  local target = EntIndexToHScript(targetIndex)
  local casterIndex = filterTable["entindex_source_const"]
  local caster = EntIndexToHScript(casterIndex)
  local abilityIndex = filterTable["entindex_ability_const"]
  local ability = EntIndexToHScript(abilityIndex)

  -- Perk for Puck
  PerkPuckReflectSpell(caster,target,ability)
  if not target.FindAbilityByName then return filterTable end
  local targetPerk = target:FindAbilityByName(target:GetName() .. "_perk")
  if targetPerk and targetPerks_projectile[targetPerk:GetName()] then
    target.perkTarget = caster
    target.perkAbility = ability
  end
  -- Returning the filterTable
  return filterTable
end]]--

function heroPerksOrderFilter(filterTable)
  local units = filterTable["units"]
  local order_type = filterTable["order_type"]
  local issuer = filterTable["issuer_player_id_const"]
  local abilityIndex = filterTable["entindex_ability"]
  local targetIndex = filterTable["entindex_target"]
  local unit = EntIndexToHScript(units["0"])
  local target = EntIndexToHScript(targetIndex)
  local ability = EntIndexToHScript(abilityIndex)

    -- Perk for Shadow Demon
  --perkShadowDemon(filterTable)

  return filterTable
end

function heroPerksModifierFilter(filterTable)
  local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  if not parent_index or not caster_index or not ability_index then
      return filterTable
  end

  local caster = EntIndexToHScript( caster_index )

  local perks = {
    modifier_npc_dota_hero_dragon_knight_perk = true,
    modifier_npc_dota_hero_ancient_apparition_perk = true,
    modifier_npc_dota_hero_death_prophet_perk = true,
    modifier_npc_dota_hero_obsidian_destroyer_perk = true,
    modifier_npc_dota_hero_venomancer_perk = true,
    modifier_npc_dota_hero_silencer_perk = true,
    modifier_npc_dota_hero_viper_perk = true,
    modifier_npc_dota_hero_spirit_breaker_perk = true,
    modifier_npc_dota_hero_troll_warlord_perk = true,
    modifier_npc_dota_hero_abaddon_perk = true,
  }
  local perkName = "modifier_" .. caster:GetName() .. "_perk"
  local targetPerk = caster:HasModifier(perkName)
  if not targetPerk then return filterTable end
  if not perks[perkName] then return filterTable end
  PerkAbaddon(filterTable)
  -- Perk for Dragon Knight
  PerkDragonKnight(filterTable)
  -- Perk for Ancient Apparition
  perkAncientApparition(filterTable)
  -- Perk for Death Prophet
  perkDeathProphet(filterTable)
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

function heroPerksDamageFilter(filterTable)
  local victim_index = filterTable["entindex_victim_const"]
  local attacker_index = filterTable["entindex_attacker_const"]
  if not victim_index or not attacker_index then
    return filterTable
  end

  local caster = EntIndexToHScript( attacker_index )

  local perks = {
    modifier_npc_dota_hero_bane_perk = true,
    modifier_npc_dota_hero_slardar_perk = true,
  }
  local perkName = "modifier_" .. caster:GetName() .. "_perk"
  local targetPerk = caster:HasModifier(perkName)
  if not targetPerk then return filterTable end
  if not perks[perkName] then return filterTable end
  -- Perk for Bane
  PerkBane(filterTable)
  -- Perk for Slardar
  perkSlardar(filterTable)

  return filterTable
end

function heroPerksAbilityTuningValueFilter(filterTable)
  return filterTable
end

