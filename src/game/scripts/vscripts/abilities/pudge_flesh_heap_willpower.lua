pudge_flesh_heap_willpower = class({})

LinkLuaModifier("modifier_flesh_heap_willpower", "abilities/pudge_flesh_heap_willpower.lua", LUA_MODIFIER_MOTION_NONE)

function pudge_flesh_heap_willpower:Spawn()
	if IsServer() then
		local caster = self:GetCaster()
		-- Add kill tracker modifier
		if not caster:HasModifier("modifier_pudge_custom_flesh_heap_kill_tracker") then
			caster:AddNewModifier(caster, self, "modifier_pudge_custom_flesh_heap_kill_tracker", {})
		end
	end
end

function pudge_flesh_heap_willpower:GetIntrinsicModifierName()
  return "modifier_flesh_heap_willpower"
end

function pudge_flesh_heap_willpower:GetCastRange(location, target)
  return self:GetSpecialValueFor("flesh_heap_range")
end

---------------------------------------------------------------------------------------------------

modifier_flesh_heap_willpower = class({})

function modifier_flesh_heap_willpower:IsHidden()
    return false
end

function modifier_flesh_heap_willpower:IsDebuff()
	return false
end

function modifier_flesh_heap_willpower:IsPurgable()
    return false
end

function modifier_flesh_heap_willpower:RemoveOnDeath()
    return false
end

function modifier_flesh_heap_willpower:OnCreated()
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

function modifier_flesh_heap_willpower:OnRefresh()
	self:OnCreated()
end

function modifier_flesh_heap_willpower:GetWillPower(params)
  local parent = self:GetParent()
  return parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent) * self.flesh_heap_amount
end
