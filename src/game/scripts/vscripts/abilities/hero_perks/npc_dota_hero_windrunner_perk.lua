--------------------------------------------------------------------------------------------------------
--		Hero: Windranger
--		Perk: If Windranger has no passives, all her active spells will refund 25% mana and have 25% reduced cooldowns.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_windrunner_perk = modifier_npc_dota_hero_windrunner_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_windrunner_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_windrunner_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_windrunner_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_windrunner_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_windrunner_perk:GetTexture()
	return "custom/npc_dota_hero_windrunner_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_windrunner_perk:OnCreated()
	if IsServer() then
		self.noPassives = true
		local caster = self:GetCaster()

		for i = 0, caster:GetAbilityCount() - 1 do
			local ability = caster:GetAbilityByIndex(i)
			if ability and ability:IsPassive() and not ability:IsHidden() and not util:IsTalent(ability) and SkillManager:isPassive(ability:GetName()) then
				self.noPassives = false
			end
		end
		if self.noPassives then
			local cooldownReductionPercent = 25
			local manaReductionPercent = 25

			self.cooldownReduction = 1 - (cooldownReductionPercent / 100)
			self.manaReduction = manaReductionPercent / 100
		end
	end
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_windrunner_perk:DeclareFunctions()
	return {
	  MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_windrunner_perk:OnAbilityFullyCast(keys)
  if IsServer() and self.noPassives then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if hero == keys.unit and ability then
      hero:GiveMana(ability:GetManaCost(ability:GetLevel() - 1) * self.manaReduction)
      local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
    end
  end
end
