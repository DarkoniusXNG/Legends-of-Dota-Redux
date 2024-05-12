--------------------------------------------------------------------------------------------------------
--
--    Hero: Oracle
--    Perk: Support items used by Oracle will have their cooldowns reduced by 25%.
--
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_oracle_perk = modifier_npc_dota_hero_oracle_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_oracle_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_oracle_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_oracle_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_oracle_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_oracle_perk:GetTexture()
	return "custom/npc_dota_hero_oracle_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_oracle_perk:OnCreated()
  if IsServer() then
    local cooldownPercentReduction = 25
    self.cooldownReduction = 1 - (cooldownPercentReduction / 100)
	-- Hard-coded due to being used in a listener for items purchased.
    self.limitedItems = {
		item_ancient_janggo = true,
		item_arcane_boots = true,
		item_arcane_ring = true,
		item_book_of_shadows = true,
		item_boots_of_bearing = true,
		item_buckler = true,
		item_crimson_guard = true,
		item_force_staff = true,
		item_glimmer_cape = true,
		item_guardian_greaves = true,
		item_holy_locket = true,
		item_iron_talon = true,
		item_lotus_orb = true,
		item_mechanical_arm = true,
		item_medallion_of_courage = true,
		item_mekansm = true,
		item_pavise = true,
		item_pipe = true,
		item_seer_stone = true,
		item_smoke_of_deceit = true,
		item_solar_crest = true,
		item_spirit_vessel = true,
		item_urn_of_shadows = true,
		item_veil_of_discord = true,
    }
  end
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_oracle_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end

function modifier_npc_dota_hero_oracle_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if hero == keys.unit and ability and self.limitedItems[ability:GetName()] then
      local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
    end
  end
end
