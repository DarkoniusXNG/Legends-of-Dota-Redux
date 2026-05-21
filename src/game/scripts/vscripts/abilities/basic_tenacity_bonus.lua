basic_tenacity_bonus=class({})
basic_tenacity_bonus_op=class({})
modifier_basic_tenacity_bonus = class({})
modifier_basic_tenacity_bonus_op = class({})
LinkLuaModifier("modifier_basic_tenacity_bonus","abilities/basic_tenacity_bonus.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_basic_tenacity_bonus_op","abilities/basic_tenacity_bonus.lua",LUA_MODIFIER_MOTION_NONE)

function basic_tenacity_bonus:GetIntrinsicModifierName()
  return "modifier_basic_tenacity_bonus"
end

function basic_tenacity_bonus_op:GetIntrinsicModifierName()
  return "modifier_basic_tenacity_bonus_op"
end

---------------------------------------------------------------------------------------------------

function modifier_basic_tenacity_bonus:IsHidden()
	return true
end

function modifier_basic_tenacity_bonus:IsDebuff()
	return false
end

function modifier_basic_tenacity_bonus:IsPurgable()
	return false
end

function modifier_basic_tenacity_bonus:RemoveOnDeath()
	return false
end

function modifier_basic_tenacity_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_SLOW_RESISTANCE_STACKING,
	}
end

function modifier_basic_tenacity_bonus:GetModifierStatusResistanceStacking()
	local parent = self:GetParent()
	if parent:PassivesDisabled() then
		return 0
	end
	return self:GetAbility():GetSpecialValueFor("status_resist")
end

function modifier_basic_tenacity_bonus:GetModifierSlowResistance_Stacking()
	local parent = self:GetParent()
	if parent:PassivesDisabled() then
		return 0
	end
	return self:GetAbility():GetSpecialValueFor("slow_resist")
end

---------------------------------------------------------------------------------------------------

function modifier_basic_tenacity_bonus_op:IsHidden()
	return true
end

function modifier_basic_tenacity_bonus_op:IsDebuff()
	return false
end

function modifier_basic_tenacity_bonus_op:IsPurgable()
	return false
end

function modifier_basic_tenacity_bonus_op:RemoveOnDeath()
	return false
end

function modifier_basic_tenacity_bonus_op:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
		MODIFIER_PROPERTY_SLOW_RESISTANCE_STACKING,
	}
end

function modifier_basic_tenacity_bonus_op:GetModifierStatusResistanceStacking()
	local parent = self:GetParent()
	if parent:PassivesDisabled() then
		return 0
	end
	return self:GetAbility():GetSpecialValueFor("status_resist")
end

function modifier_basic_tenacity_bonus_op:GetModifierSlowResistance_Stacking()
	local parent = self:GetParent()
	if parent:PassivesDisabled() then
		return 0
	end
	return self:GetAbility():GetSpecialValueFor("slow_resist")
end

