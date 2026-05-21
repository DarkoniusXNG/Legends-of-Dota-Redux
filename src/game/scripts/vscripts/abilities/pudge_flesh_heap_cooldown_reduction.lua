pudge_flesh_heap_cooldown_reduction = class({})

LinkLuaModifier("modifier_flesh_heap_cooldown_reduction", "abilities/pudge_flesh_heap_cooldown_reduction.lua", LUA_MODIFIER_MOTION_NONE)

function pudge_flesh_heap_cooldown_reduction:Spawn()
	if IsServer() then
		local caster = self:GetCaster()
		-- Add kill tracker modifier
		if not caster:HasModifier("modifier_pudge_custom_flesh_heap_kill_tracker") then
			caster:AddNewModifier(caster, self, "modifier_pudge_custom_flesh_heap_kill_tracker", {})
		end
	end
end

function pudge_flesh_heap_cooldown_reduction:GetIntrinsicModifierName()
  return "modifier_flesh_heap_cooldown_reduction"
end

function pudge_flesh_heap_cooldown_reduction:GetCastRange(location, target)
  return self:GetSpecialValueFor("flesh_heap_range")
end

---------------------------------------------------------------------------------------------------

modifier_flesh_heap_cooldown_reduction = class({})

function modifier_flesh_heap_cooldown_reduction:IsHidden()
    return false
end

function modifier_flesh_heap_cooldown_reduction:IsDebuff()
	return false
end

function modifier_flesh_heap_cooldown_reduction:IsPurgable()
    return false
end

function modifier_flesh_heap_cooldown_reduction:RemoveOnDeath()
    return false
end

function modifier_flesh_heap_cooldown_reduction:OnCreated()
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

function modifier_flesh_heap_cooldown_reduction:OnRefresh()
	self:OnCreated()
end

function modifier_flesh_heap_cooldown_reduction:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
  }
end

function modifier_flesh_heap_cooldown_reduction:GetModifierPercentageCooldown()
	local parent = self:GetParent()
	if parent:PassivesDisabled() then
		return 0
	end
	return math.min(math.floor(parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent) * self.flesh_heap_amount), 100)
end
