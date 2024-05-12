--------------------------------------------------------------------------------------------------------
--
--		Hero: Centaur
--		Perk: Centaur Warrunner has 30% CDR for Self-Damaging spells.
--
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_centaur_perk = modifier_npc_dota_hero_centaur_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_centaur_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_centaur_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_centaur_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_centaur_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_centaur_perk:GetTexture()
	return "custom/npc_dota_hero_centaur_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_centaur_perk:OnCreated(keys)
	local cooldownPercentReduction = 30
	self.cooldownReduction = 1 - (cooldownPercentReduction / 100)
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_centaur_perk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_centaur_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if hero == keys.unit and ability and ability:HasAbilityFlag("self_damage") then
	  local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
	end
  end
end
