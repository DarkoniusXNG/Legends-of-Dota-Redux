--------------------------------------------------------------------------------------------------------
--		Hero: Zeus
--		Perk: Zeus has 25% CDR and 25% manacost reduction for Lightning spells he casts.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_zuus_perk = modifier_npc_dota_hero_zuus_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_zuus_perk:GetTexture()
	return "custom/npc_dota_hero_zuus_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:OnCreated()
  local manaRefund = 25
  local cooldownReduction = 25

  self.manaRefund = manaRefund * 0.01
  self.cooldownReduction = 1 - (cooldownReduction * 0.01)
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_zuus_perk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end
--------------------------------------------------------------------------------------------------------
if IsServer() then
	function modifier_npc_dota_hero_zuus_perk:OnAbilityFullyCast(keys)
		if keys.ability:HasAbilityFlag("lightning") and keys.unit == self:GetParent() then
			local cooldown = keys.ability:GetCooldownTimeRemaining()
			keys.ability:EndCooldown()
			keys.ability:StartCooldown(cooldown*self.cooldownReduction)
			self:GetParent():GiveMana(keys.ability:GetManaCost(keys.ability:GetLevel()-1)*self.manaRefund)
		end
	end
end
