--------------------------------------------------------------------------------------------------------
--
--		Hero: Magnus
--		Perk: When Magnus casts Enemy Moving abilities, they will have 25% mana refunded and cooldowns reduced by 25%.
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_magnataur_perk ~= "" then modifier_npc_dota_hero_magnataur_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:OnCreated()
  local manaRefund = 25
  local cooldownReduction = 25

  self.manaRefund = manaRefund * 0.01
  self.cooldownReduction = 1 - (cooldownReduction * 0.01)
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_magnataur_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end
--------------------------------------------------------------------------------------------------------
if IsServer() then
	function modifier_npc_dota_hero_magnataur_perk:OnAbilityFullyCast(keys)
		local parent = self:GetParent()
		local cast_ability = keys.ability
		if cast_ability:HasAbilityFlag("enemymoving") and keys.unit == parent then
			local cooldown = cast_ability:GetCooldownTimeRemaining()
			cast_ability:EndCooldown()
			cast_ability:StartCooldown(cooldown*self.cooldownReduction)
			parent:GiveMana(cast_ability:GetManaCost(cast_ability:GetLevel()-1)*self.manaRefund)
		end
	end
end

