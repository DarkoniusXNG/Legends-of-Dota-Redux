if spell_lab_souls_tenacity == nil then
	spell_lab_souls_tenacity = class({})
end

LinkLuaModifier("spell_lab_souls_tenacity_modifier", "abilities/spell_lab/souls/tenacity.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_souls_tenacity:GetIntrinsicModifierName() return "spell_lab_souls_tenacity_modifier" end


if spell_lab_souls_tenacity_modifier == nil then
	spell_lab_souls_tenacity_modifier = require "abilities/spell_lab/souls/base"
end

function spell_lab_souls_tenacity_modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_SLOW_RESISTANCE_STACKING,
    	MODIFIER_EVENT_ON_DEATH,
	}
end

function spell_lab_souls_tenacity_modifier:GetModifierStatusResistanceStacking()
	local parent = self:GetParent()
	if parent:PassivesDisabled() then
		return 0
	end
	return math.min(math.floor(self:GetSoulsBonus() * self:GetAbility():GetSpecialValueFor("per_soul")), 100)
end

function spell_lab_souls_tenacity_modifier:GetModifierSlowResistance_Stacking()
	local parent = self:GetParent()
	if parent:PassivesDisabled() then
		return 0
	end
	return math.min(math.floor(self:GetSoulsBonus() * self:GetAbility():GetSpecialValueFor("per_soul")), 100)
end

function spell_lab_souls_tenacity_modifier:GetColour ()
	return {222,12,184}
end
