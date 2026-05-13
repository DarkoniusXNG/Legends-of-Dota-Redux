--------------------------------------------------------------------------------------------------------
--
--		Hero: Treant
--		Perk: Treant gets healed for the mana cost of any Nature ability he uses.
--
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_treant_perk = modifier_npc_dota_hero_treant_perk or class({})
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

function modifier_npc_dota_hero_treant_perk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end

if IsServer() then
	function modifier_npc_dota_hero_treant_perk:OnAbilityFullyCast(keys)
		local parent = self:GetParent()
		local ability = keys.ability

		if parent:GetHealth() == parent:GetMaxHealth() then return end

		if keys.unit == parent and ability and ability:HasAbilityFlag("nature") then
			local heal_amount = ability:GetManaCost(ability:GetLevel()-1)
			parent:Heal(heal_amount, ability)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, parent, heal_amount, nil)
			local healParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath_heal.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
			ParticleManager:ReleaseParticleIndex(healParticle)
		end
	end
end
