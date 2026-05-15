if spell_lab_survivor_tenacity == nil then
	spell_lab_survivor_tenacity = class({})
end

if spell_lab_survivor_tenacity_op == nil then
  spell_lab_survivor_tenacity_op = class({})
end

LinkLuaModifier("spell_lab_survivor_tenacity_modifier", "abilities/spell_lab/survivor/tenacity.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_tenacity:GetIntrinsicModifierName() return "spell_lab_survivor_tenacity_modifier" end

function spell_lab_survivor_tenacity_op:GetIntrinsicModifierName() return "spell_lab_survivor_tenacity_modifier" end


if spell_lab_survivor_tenacity_modifier == nil then
	spell_lab_survivor_tenacity_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_tenacity_modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_SLOW_RESISTANCE_STACKING,
    	MODIFIER_EVENT_ON_DEATH,
	}
end

function spell_lab_survivor_tenacity_modifier:GetModifierStatusResistanceStacking()
	if self:GetParent():PassivesDisabled() then
		return 0
	end
	return math.min(math.floor(self:GetStackCount()), 100)
end

function spell_lab_survivor_tenacity_modifier:GetModifierSlowResistance_Stacking()
	if self:GetParent():PassivesDisabled() then
		return 0
	end
	return math.min(math.floor(self:GetStackCount()), 100)
end
