pudge_flesh_heap_armor = class({})

LinkLuaModifier("modifier_flesh_heap_armor", "abilities/pudge_flesh_heap_armor.lua", LUA_MODIFIER_MOTION_NONE)

function pudge_flesh_heap_armor:Spawn()
	if IsServer() then
		local caster = self:GetCaster()
		-- Add kill tracker modifier
		if not caster:HasModifier("modifier_pudge_custom_flesh_heap_kill_tracker") then
			caster:AddNewModifier(caster, self, "modifier_pudge_custom_flesh_heap_kill_tracker", {})
		end
	end
end

function pudge_flesh_heap_armor:GetIntrinsicModifierName()
  return "modifier_flesh_heap_armor"
end

---------------------------------------------------------------------------------------------------

modifier_flesh_heap_armor = class({})

function modifier_flesh_heap_armor:IsHidden()
    return false
end

function modifier_flesh_heap_armor:IsDebuff()
	return false
end

function modifier_flesh_heap_armor:IsPurgable()
    return false
end

function modifier_flesh_heap_armor:RemoveOnDeath()
    return false
end

function modifier_flesh_heap_armor:OnCreated()
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

function modifier_flesh_heap_armor:OnRefresh()
	self:OnCreated()
end

function modifier_flesh_heap_armor:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
  }
end

function modifier_flesh_heap_armor:GetModifierPhysicalArmorBonus()
  local parent = self:GetParent()
  return parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent) * self.flesh_heap_amount
end
