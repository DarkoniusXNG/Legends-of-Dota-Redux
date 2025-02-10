--------------------------------------------------------------------------------------------------------
--    Hero: Death Prophet
--    Perk: 
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_death_prophet_perk = modifier_npc_dota_hero_death_prophet_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_death_prophet_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_death_prophet_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_death_prophet_perk:RemoveOnDeath()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_death_prophet_perk:IsPurgable()
  return false
end

function modifier_npc_dota_hero_death_prophet_perk:GetTexture()
	return "custom/npc_dota_hero_death_prophet_perk"
end
