pudge_flesh_heap_cast_range = class({})

LinkLuaModifier("modifier_flesh_heap_cast_range", "abilities/pudge_flesh_heap_cast_range.lua", LUA_MODIFIER_MOTION_NONE)

function pudge_flesh_heap_cast_range:Spawn()
	if IsServer() then
		local caster = self:GetCaster()
		-- Add kill tracker modifier
		if not caster:HasModifier("modifier_pudge_custom_flesh_heap_kill_tracker") then
			caster:AddNewModifier(caster, self, "modifier_pudge_custom_flesh_heap_kill_tracker", {})
		end
	end
end

function pudge_flesh_heap_cast_range:GetIntrinsicModifierName()
  return "modifier_flesh_heap_cast_range"
end

---------------------------------------------------------------------------------------------------

modifier_flesh_heap_cast_range = class({})

function modifier_flesh_heap_cast_range:IsHidden()
    return false
end

function modifier_flesh_heap_cast_range:IsDebuff()
	return false
end

function modifier_flesh_heap_cast_range:IsPurgable()
    return false
end

function modifier_flesh_heap_cast_range:RemoveOnDeath()
    return false
end

function modifier_flesh_heap_cast_range:OnCreated()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability or ability:IsNull() then
		self:Destroy()
		parent:CalculateStatBonus(true)
		return
	end

	self.flesh_heap_amount = ability:GetSpecialValueFor("flesh_heap_value_buff_amount") or 0
	if IsServer() then
		local stacks = parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent)
		self:SetStackCount(stacks)
		parent:CalculateStatBonus(true)
	end
end

function modifier_flesh_heap_cast_range:OnRefresh()
	self:OnCreated()
end

function modifier_flesh_heap_cast_range:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
  }
end

function modifier_flesh_heap_cast_range:GetModifierCastRangeBonusStacking()
  local parent = self:GetParent()
  return parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent) * self.flesh_heap_amount
end
