--------------------------------------------------------------------------------------------------------
--
--		Hero: Treant
--		Perk: Treant gets healed for the mana cost of any Nature ability he uses.
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_treant_perk ~= "" then modifier_npc_dota_hero_treant_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_treant_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
  }
  return funcs
end

if IsServer() then
	function modifier_npc_dota_hero_treant_perk:OnAbilityFullyCast(keys)
		local parent = self:GetParent()
		if parent:GetHealth() == parent:GetMaxHealth() then return end
		if keys.unit == parent and keys.ability:HasAbilityFlag("nature") then
			local heal_amount = keys.ability:GetManaCost(keys.ability:GetLevel()-1)
			parent:Heal(heal_amount, keys.ability)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, heal_amount, nil)
			local healParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
			--ParticleManager:SetParticleControl(healParticle, 1, Vector(radius, radius, radius))
			ParticleManager:ReleaseParticleIndex(healParticle)
		end
	end
end
