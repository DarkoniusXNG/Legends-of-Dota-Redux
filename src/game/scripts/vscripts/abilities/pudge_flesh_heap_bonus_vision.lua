pudge_flesh_heap_bonus_vision = class({})

LinkLuaModifier("modifier_flesh_heap_bonus_vision", "abilities/pudge_flesh_heap_bonus_vision.lua", LUA_MODIFIER_MOTION_NONE)

function pudge_flesh_heap_bonus_vision:Spawn()
	if IsServer() then
		local caster = self:GetCaster()
		-- Add kill tracker modifier
		if not caster:HasModifier("modifier_pudge_custom_flesh_heap_kill_tracker") then
			caster:AddNewModifier(caster, self, "modifier_pudge_custom_flesh_heap_kill_tracker", {})
		end
	end
end

function pudge_flesh_heap_bonus_vision:GetIntrinsicModifierName()
  return "modifier_flesh_heap_bonus_vision"
end

function pudge_flesh_heap_bonus_vision:GetCastRange(location, target)
  return self:GetSpecialValueFor("flesh_heap_range")
end

---------------------------------------------------------------------------------------------------

modifier_flesh_heap_bonus_vision = class({})

function modifier_flesh_heap_bonus_vision:IsHidden()
    return false
end

function modifier_flesh_heap_bonus_vision:IsDebuff()
	return false
end

function modifier_flesh_heap_bonus_vision:IsPurgable()
    return false
end

function modifier_flesh_heap_bonus_vision:RemoveOnDeath()
    return false
end

function modifier_flesh_heap_bonus_vision:OnCreated()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability or ability:IsNull() then
		self:Destroy()
		parent:CalculateStatBonus(true)
		return
	end

	self.flesh_heap_amount = ability:GetSpecialValueFor("flesh_heap_bonus_vision_buff_amount") or 0
	if IsServer() then
		local stacks = parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent)
		self:SetStackCount(stacks)
		parent:CalculateStatBonus(true)
	end
end

function modifier_flesh_heap_bonus_vision:OnRefresh()
	self:OnCreated()
end

function modifier_flesh_heap_bonus_vision:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_BONUS_DAY_VISION,
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
  }
end

function modifier_flesh_heap_bonus_vision:GetBonusDayVision()
  local parent = self:GetParent()
  return parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent) * self.flesh_heap_amount
end

function modifier_flesh_heap_bonus_vision:GetBonusNightVision()
  local parent = self:GetParent()
  return parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent) * self.flesh_heap_amount
end
