--------------------------------------------------------------------------------------------------------
--
--		Hero: Earthshaker
--		Perk: Earth abilities Earthshaker uses heal him for 3% of his max health.
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_earthshaker_perk ~= "" then modifier_npc_dota_hero_earthshaker_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earthshaker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earthshaker_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earthshaker_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earthshaker_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_earthshaker_perk:GetTexture()
	return "custom/npc_dota_hero_earthshaker_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_earthshaker_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end

if IsServer() then
	function modifier_npc_dota_hero_earthshaker_perk:OnAbilityFullyCast(keys)
		local healPercent = 3 * 0.01
		local parent = self:GetParent()

		if parent:GetHealth() == parent:GetMaxHealth() then return end

		if keys.unit == parent and keys.ability:HasAbilityFlag("earth") then
			local heal_amount = parent:GetMaxHealth() * healPercent
			parent:Heal(heal_amount, keys.ability)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, heal_amount, nil)
			local healParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
			--ParticleManager:SetParticleControl(healParticle, 1, Vector(radius, radius, radius))
			ParticleManager:ReleaseParticleIndex(healParticle)
		end
	end
end
