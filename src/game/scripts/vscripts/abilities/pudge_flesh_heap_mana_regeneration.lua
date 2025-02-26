pudge_flesh_heap_mana_regeneration = class({})

LinkLuaModifier("modifier_flesh_heap_mana_regeneration", "abilities/pudge_flesh_heap_mana_regeneration.lua", LUA_MODIFIER_MOTION_NONE)

function pudge_flesh_heap_mana_regeneration:Spawn()
	if IsServer() then
		local caster = self:GetCaster()
		-- Add kill tracker modifier
		if not caster:HasModifier("modifier_pudge_custom_flesh_heap_kill_tracker") then
			caster:AddNewModifier(caster, self, "modifier_pudge_custom_flesh_heap_kill_tracker", {})
		end
	end
end

function pudge_flesh_heap_mana_regeneration:GetIntrinsicModifierName()
  return "modifier_flesh_heap_mana_regeneration"
end

---------------------------------------------------------------------------------------------------

modifier_flesh_heap_mana_regeneration = class({})

function modifier_flesh_heap_mana_regeneration:IsHidden()
    return false
end

function modifier_flesh_heap_mana_regeneration:IsDebuff()
	return false
end

function modifier_flesh_heap_mana_regeneration:IsPurgable()
    return false
end

function modifier_flesh_heap_mana_regeneration:RemoveOnDeath()
    return false
end

function modifier_flesh_heap_mana_regeneration:OnCreated()
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

function modifier_flesh_heap_mana_regeneration:OnRefresh()
	self:OnCreated()
end

function modifier_flesh_heap_mana_regeneration:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
  }
end

function modifier_flesh_heap_mana_regeneration:GetModifierConstantManaRegen()
  local parent = self:GetParent()
  return parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent) * self.flesh_heap_amount
end
