pudge_flesh_heap_spell_amp = class({})

LinkLuaModifier("modifier_flesh_heap_spell_amp", "abilities/pudge_flesh_heap_spell_amp.lua", LUA_MODIFIER_MOTION_NONE)

function pudge_flesh_heap_spell_amp:Spawn()
	if IsServer() then
		local caster = self:GetCaster()
		-- Add kill tracker modifier
		if not caster:HasModifier("modifier_pudge_custom_flesh_heap_kill_tracker") then
			caster:AddNewModifier(caster, self, "modifier_pudge_custom_flesh_heap_kill_tracker", {})
		end
	end
end

function pudge_flesh_heap_spell_amp:GetIntrinsicModifierName()
  return "modifier_flesh_heap_spell_amp"
end

---------------------------------------------------------------------------------------------------

modifier_flesh_heap_spell_amp = class({})

function modifier_flesh_heap_spell_amp:IsHidden()
    return false
end

function modifier_flesh_heap_spell_amp:IsDebuff()
	return false
end

function modifier_flesh_heap_spell_amp:IsPurgable()
    return false
end

function modifier_flesh_heap_spell_amp:RemoveOnDeath()
    return false
end

function modifier_flesh_heap_spell_amp:OnCreated()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability or ability:IsNull() then
		self:Destroy()
		parent:CalculateStatBonus(true)
		return
	end

	self.flesh_heap_amount = ability:GetSpecialValueFor("flesh_heap_spell_amp_buff_amount") or 0
	if IsServer() then
		local stacks = parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent)
		self:SetStackCount(stacks)
		parent:CalculateStatBonus(true)
	end
end

function modifier_flesh_heap_spell_amp:OnRefresh()
	self:OnCreated()
end

function modifier_flesh_heap_spell_amp:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
  }
end

function modifier_flesh_heap_spell_amp:GetModifierSpellAmplify_Percentage()
  local parent = self:GetParent()
  return parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent) * self.flesh_heap_amount
end
