--------------------------------------------------------------------------------------------------------
--
--		Hero: Sand King
--		Perk: Channeling abilities refund 50% of their manacost when cast by Sand King. 
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_sand_king_perk ~= "" then modifier_npc_dota_hero_sand_king_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_sand_king_perk:GetTexture()
	return "custom/npc_dota_hero_sand_king_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:OnCreated()
  local manaRefund = 50
  local cooldownReduction = 50

  self.manaRefund = manaRefund * 0.01
  self.cooldownReduction = 1 - (cooldownReduction * 0.01)
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sand_king_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    if keys.ability:HasAbilityFlag("channeled") and keys.unit == self:GetParent() then
      local cooldown = keys.ability:GetCooldownTimeRemaining()
      keys.ability:EndCooldown()
      keys.ability:StartCooldown(cooldown*self.cooldownReduction)
      self:GetParent():GiveMana(keys.ability:GetManaCost(keys.ability:GetLevel()-1)*self.manaRefund)
    end
  end
end
