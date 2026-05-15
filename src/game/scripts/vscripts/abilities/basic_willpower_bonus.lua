basic_willpower_bonus=class({})
basic_willpower_bonus_op=class({})
modifier_basic_willpower_bonus = class({})
modifier_basic_willpower_bonus_op = class({})
LinkLuaModifier("modifier_basic_willpower_bonus", "abilities/basic_willpower_bonus.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_basic_willpower_bonus_op", "abilities/basic_willpower_bonus.lua", LUA_MODIFIER_MOTION_NONE)

function basic_willpower_bonus:GetIntrinsicModifierName()
  return "modifier_basic_willpower_bonus"
end

function basic_willpower_bonus_op:GetIntrinsicModifierName()
  return "modifier_basic_willpower_bonus_op"
end

---------------------------------------------------------------------------------------------------

function modifier_basic_willpower_bonus:IsHidden()
	return true
end

function modifier_basic_willpower_bonus:IsDebuff()
	return false
end

function modifier_basic_willpower_bonus:IsPurgable()
	return false
end

function modifier_basic_willpower_bonus:RemoveOnDeath()
	return false
end

function modifier_basic_willpower_bonus:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_CASTER,
	}
end

function modifier_basic_willpower_bonus:GetModifierStatusResistanceCaster()
	local parent = self:GetParent()
	if parent:PassivesDisabled() then
		return 0
	end
	return 0 - math.abs(self:GetAbility():GetSpecialValueFor("willpower_bonus"))
end

function modifier_basic_willpower_bonus:GetWillPower()
	local parent = self:GetParent()
	if parent:PassivesDisabled() then
		return 0
	end
	return self:GetAbility():GetSpecialValueFor("willpower_bonus")
end

---------------------------------------------------------------------------------------------------

function modifier_basic_willpower_bonus_op:IsHidden()
	return true
end

function modifier_basic_willpower_bonus_op:IsDebuff()
	return false
end

function modifier_basic_willpower_bonus_op:IsPurgable()
	return false
end

function modifier_basic_willpower_bonus_op:RemoveOnDeath()
	return false
end

function modifier_basic_willpower_bonus_op:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_CASTER,
	}
end

function modifier_basic_willpower_bonus_op:GetModifierStatusResistanceCaster()
	local parent = self:GetParent()
	if parent:PassivesDisabled() then
		return 0
	end
	return 0 - math.abs(self:GetAbility():GetSpecialValueFor("willpower_bonus"))
end

function modifier_basic_willpower_bonus_op:GetWillPower()
	local parent = self:GetParent()
	if parent:PassivesDisabled() then
		return 0
	end
	return self:GetAbility():GetSpecialValueFor("willpower_bonus")
end
