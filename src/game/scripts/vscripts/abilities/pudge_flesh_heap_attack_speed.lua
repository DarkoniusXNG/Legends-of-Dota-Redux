pudge_flesh_heap_attack_speed = class({})

LinkLuaModifier("modifier_flesh_heap_attack_speed", "abilities/pudge_flesh_heap_attack_speed.lua", LUA_MODIFIER_MOTION_NONE)

function pudge_flesh_heap_attack_speed:Spawn()
	if IsServer() then
		local caster = self:GetCaster()
		-- Add kill tracker modifier
		if not caster:HasModifier("modifier_pudge_custom_flesh_heap_kill_tracker") then
			caster:AddNewModifier(caster, self, "modifier_pudge_custom_flesh_heap_kill_tracker", {})
		end
	end
end

function pudge_flesh_heap_attack_speed:GetIntrinsicModifierName()
  return "modifier_flesh_heap_attack_speed"
end

---------------------------------------------------------------------------------------------------

modifier_flesh_heap_attack_speed = class({})

function modifier_flesh_heap_attack_speed:IsHidden()
    return false
end

function modifier_flesh_heap_attack_speed:IsDebuff()
	return false
end

function modifier_flesh_heap_attack_speed:IsPurgable()
    return false
end

function modifier_flesh_heap_attack_speed:RemoveOnDeath()
    return false
end

function modifier_flesh_heap_attack_speed:OnCreated()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability or ability:IsNull() then
		self:Destroy()
		parent:CalculateStatBonus(true)
		return
	end

	self.flesh_heap_amount = ability:GetSpecialValueFor("flesh_heap_attack_speed_buff_amount") or 0
	if IsServer() then
		local stacks = parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent)
		self:SetStackCount(stacks)
		parent:CalculateStatBonus(true)
	end
end

function modifier_flesh_heap_attack_speed:OnRefresh()
	self:OnCreated()
end

function modifier_flesh_heap_attack_speed:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_ATTACK_SPEED_BONUS,
  }
end

function modifier_flesh_heap_attack_speed:GetModifierAttackSpeedBonus()
  local parent = self:GetParent()
  return parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent) * self.flesh_heap_amount
end
