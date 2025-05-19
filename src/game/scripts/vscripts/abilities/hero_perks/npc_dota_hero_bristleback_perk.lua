--------------------------------------------------------------------------------------------------------
--
--      Hero: Bristleback
--      Perk: Bristleback reduces the cooldown of all spells which cost less than 70 mana by 25%. 
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

function modifier_npc_dota_hero_bristleback_perk:OnCreated()
	local cooldownReduction = 25

	self.cooldownReduction = 1 - (cooldownReduction * 0.01)
	self.manaThreshold = 70
end

function modifier_npc_dota_hero_bristleback_perk:DeclareFunctions()
  return {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
end

if IsServer() then
  function modifier_npc_dota_hero_bristleback_perk:OnAbilityFullyCast(keys)
    local hero = self:GetCaster()
    local ability = keys.ability

    if hero == keys.unit and ability and ability:GetManaCost(-1) < self.manaThreshold then
      local cooldown = ability:GetCooldownTimeRemaining()
      ability:EndCooldown()
      ability:StartCooldown(cooldown*self.cooldownReduction)
    end
  end
end
