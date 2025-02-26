pudge_flesh_heap_str = class({})

LinkLuaModifier("modifier_flesh_heap_str", "abilities/pudge_flesh_heap_str.lua", LUA_MODIFIER_MOTION_NONE)

function pudge_flesh_heap_str:Spawn()
	if IsServer() then
		local caster = self:GetCaster()
		-- Add kill tracker modifier
		if not caster:HasModifier("modifier_pudge_custom_flesh_heap_kill_tracker") then
			caster:AddNewModifier(caster, self, "modifier_pudge_custom_flesh_heap_kill_tracker", {})
		end
	end
end

function pudge_flesh_heap_str:GetIntrinsicModifierName()
  return "modifier_flesh_heap_str"
end

---------------------------------------------------------------------------------------------------

modifier_flesh_heap_str = class({})

function modifier_flesh_heap_str:IsHidden()
    return false
end

function modifier_flesh_heap_str:IsDebuff()
	return false
end

function modifier_flesh_heap_str:IsPurgable()
    return false
end

function modifier_flesh_heap_str:RemoveOnDeath()
    return false
end

function modifier_flesh_heap_str:OnCreated()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability or ability:IsNull() then
		self:Destroy()
		parent:CalculateStatBonus(true)
		return
	end

	self.flesh_heap_amount = ability:GetSpecialValueFor("flesh_heap_strength_buff_amount") or 0
	if IsServer() then
		local stacks = parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent)
		self:SetStackCount(stacks)
		parent:CalculateStatBonus(true)
	end
end

function modifier_flesh_heap_str:OnRefresh()
	self:OnCreated()
end

function modifier_flesh_heap_str:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
  }
end

function modifier_flesh_heap_str:GetModifierBonusStats_Strength()
  local parent = self:GetParent()
  return parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent) * self.flesh_heap_amount
end
