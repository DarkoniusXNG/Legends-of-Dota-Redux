--------------------------------------------------------------------------------------------------------
--		Hero: Witch Doctor
--		Perk: 25% Healing Amp
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_witch_doctor_perk = modifier_npc_dota_hero_witch_doctor_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_witch_doctor_perk:GetTexture()
	return "custom/npc_dota_hero_witch_doctor_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE,
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		--MODIFIER_EVENT_ON_HEAL_RECEIVED,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_witch_doctor_perk:OnCreated()
	self.bonusHealPercent = 25
end
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_witch_doctor_perk:GetModifierHealAmplify_PercentageSource()
	return self.bonusHealPercent
end

function modifier_npc_dota_hero_witch_doctor_perk:GetModifierHealAmplify_PercentageTarget()
	return self.bonusHealPercent
end
