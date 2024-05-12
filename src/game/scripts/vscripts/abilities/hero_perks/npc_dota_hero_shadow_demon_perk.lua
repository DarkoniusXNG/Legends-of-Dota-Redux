--------------------------------------------------------------------------------------------------------
--		Hero: Shadow Demon
--		Perk: Demonic abilities cast by Shadow Demon will have 25% mana cost refunded and 25% cooldown reduction
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_shadow_demon_perk = modifier_npc_dota_hero_shadow_demon_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_shadow_demon_perk:GetTexture()
	return "custom/npc_dota_hero_shadow_demon_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:OnCreated()
	if IsServer() then
		local cooldownReductionPercent = 25
		local manacostReductionPercent = 25
		self.cooldownReduction = 1 - (cooldownReductionPercent / 100)
		self.manacostReduction = manacostReductionPercent / 100
	end
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_demon_perk:DeclareFunctions()
  return {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
end

function modifier_npc_dota_hero_shadow_demon_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetParent()
    local unit = keys.unit
    local ability = keys.ability

    if hero == unit and ability:HasAbilityFlag("demon") then
      local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      hero:GiveMana(ability:GetManaCost(ability:GetLevel()-1) * self.manacostReduction)
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
    end
  end
end

