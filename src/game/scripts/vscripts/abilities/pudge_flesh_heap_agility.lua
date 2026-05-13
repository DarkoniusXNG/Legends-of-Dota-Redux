pudge_flesh_heap_agility = class({})

LinkLuaModifier("modifier_flesh_heap_agi", "abilities/pudge_flesh_heap_agility.lua", LUA_MODIFIER_MOTION_NONE)

function pudge_flesh_heap_agility:Spawn()
	if IsServer() then
		local caster = self:GetCaster()
		-- Add kill tracker modifier
		if not caster:HasModifier("modifier_pudge_custom_flesh_heap_kill_tracker") then
			caster:AddNewModifier(caster, self, "modifier_pudge_custom_flesh_heap_kill_tracker", {})
		end
	end
end

function pudge_flesh_heap_agility:GetIntrinsicModifierName()
	return "modifier_flesh_heap_agi"
end

function pudge_flesh_heap_agility:GetCastRange(location, target)
	return self:GetSpecialValueFor("flesh_heap_range")
end

---------------------------------------------------------------------------------------------------

modifier_flesh_heap_agi = class({})

function modifier_flesh_heap_agi:IsHidden()
    return false
end

function modifier_flesh_heap_agi:IsDebuff()
	return false
end

function modifier_flesh_heap_agi:IsPurgable()
    return false
end

function modifier_flesh_heap_agi:RemoveOnDeath()
    return false
end

function modifier_flesh_heap_agi:OnCreated()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability or ability:IsNull() then
		self:Destroy()
		parent:CalculateStatBonus(true)
		return
	end

	self.flesh_heap_amount = ability:GetSpecialValueFor("flesh_heap_agility_buff_amount") or 0
	if IsServer() then
		local stacks = parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent)
		self:SetStackCount(stacks)
		parent:CalculateStatBonus(true)
	end
end

function modifier_flesh_heap_agi:OnRefresh()
	self:OnCreated()
end

function modifier_flesh_heap_agi:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
end

function modifier_flesh_heap_agi:GetModifierBonusStats_Agility()
	local parent = self:GetParent()
	return parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent) * self.flesh_heap_amount
end
