--------------------------------------------------------------------------------------------------------
--
--		Hero: Phantom Assassin
--		Perk: Dagger spells will have 50% of their manacost refunded, and their cooldown reduced by 2 seconds.
--
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_phantom_assassin_perk = modifier_npc_dota_hero_phantom_assassin_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_phantom_assassin_perk:GetTexture()
	return "custom/npc_dota_hero_phantom_assassin_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:OnCreated(keys)
	self.cooldownBaseReduction = 2
	self.manaPercentReduction = 50

	self.manaReduction = self.manaPercentReduction / 100
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_phantom_assassin_perk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end
--------------------------------------------------------------------------------------------------------
if IsServer() then
	function modifier_npc_dota_hero_phantom_assassin_perk:OnAbilityFullyCast(keys)
		local hero = self:GetCaster()
		local target = keys.target
		local ability = keys.ability
		if hero == keys.unit and ability and ability:HasAbilityFlag("dagger") then
			hero:GiveMana(ability:GetManaCost(-1) * self.manaReduction)
			if ability:GetCooldownTimeRemaining() > self.cooldownBaseReduction + 0.5 then
				local cooldown = ability:GetCooldownTimeRemaining() - self.cooldownBaseReduction
				ability:EndCooldown()
				ability:StartCooldown(cooldown)
			else
				local cooldown = ability:GetCooldownTimeRemaining() * 0.5
				ability:EndCooldown()
				ability:StartCooldown(cooldown)
			end
		end
	end
end
