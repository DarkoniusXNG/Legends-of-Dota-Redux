--------------------------------------------------------------------------------------------------------
--
--      Hero: Bristleback
--      Perk: Bristleback reduces the cooldown of all spells which cost less than 70 mana by 15%. 
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_bristleback_perk ~= "" then modifier_npc_dota_hero_bristleback_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bristleback_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bristleback_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bristleback_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bristleback_perk:RemoveOnDeath()
    return false
end

function modifier_npc_dota_hero_bristleback_perk:GetTexture()
	return "custom/npc_dota_hero_bristleback_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bristleback_perk:OnCreated(keys)
    self.manaThreshold = 70
    self.cooldownPercentReduction = 25
    self.cooldownReduction = 1 - (self.cooldownPercentReduction / 100)
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bristleback_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_bristleback_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if hero == keys.unit and ability and ability:GetManaCost(-1) < self.manaThreshold then
      local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
    end
  end
end
