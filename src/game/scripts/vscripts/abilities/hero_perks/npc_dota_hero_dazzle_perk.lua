--------------------------------------------------------------------------------------------------------
--
--		Hero: Dazzle
--		Perk: Support spells will have 25% cooldown reduction when cast by Dazzle.
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_dazzle_perk ~= "" then modifier_npc_dota_hero_dazzle_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_dazzle_perk:GetTexture()
	return "custom/npc_dota_hero_dazzle_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:OnCreated()
	self.cooldownPercentReduction = 25
	self.cooldownReduction = 1 - (self.cooldownPercentReduction / 100)
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:DeclareFunctions()
	local funcs = {
	  MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dazzle_perk:OnAbilityFullyCast(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local target = keys.target
    local ability = keys.ability
    if hero == keys.unit and ability and ability:HasAbilityFlag("support") then
	  local cooldown = ability:GetCooldownTimeRemaining() * self.cooldownReduction
      ability:EndCooldown()
      ability:StartCooldown(cooldown)
	end
  end
end
