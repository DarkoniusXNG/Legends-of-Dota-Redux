pudge_flesh_heap_minion_damage = class({})

LinkLuaModifier("modifier_flesh_heap_minion_damage", "abilities/deathtal/pudge_flesh_heap_minion_damage.lua" ,LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_flesh_heap_minion_damage_creep", "abilities/deathtal/pudge_flesh_heap_minion_damage.lua" ,LUA_MODIFIER_MOTION_NONE)

function pudge_flesh_heap_minion_damage:Spawn()
	if IsServer() then
		local caster = self:GetCaster()
		-- Add kill tracker modifier
		if not caster:HasModifier("modifier_pudge_custom_flesh_heap_kill_tracker") then
			caster:AddNewModifier(caster, self, "modifier_pudge_custom_flesh_heap_kill_tracker", {})
		end
	end
end

function pudge_flesh_heap_minion_damage:GetIntrinsicModifierName()
	return "modifier_flesh_heap_minion_damage"
end

---------------------------------------------------------------------------------------------------

modifier_flesh_heap_minion_damage = class({})

function modifier_flesh_heap_minion_damage:IsHidden()
    return false
end

function modifier_flesh_heap_minion_damage:IsDebuff()
	return false
end

function modifier_flesh_heap_minion_damage:IsPurgable()
    return false
end

function modifier_flesh_heap_minion_damage:RemoveOnDeath()
    return false
end

function modifier_flesh_heap_minion_damage:OnCreated()
	local parent = self:GetParent()
	local ability = self:GetAbility()

	if not ability or ability:IsNull() then
		self:Destroy()
		parent:CalculateStatBonus(true)
		return
	end

	self.flesh_heap_amount = ability:GetSpecialValueFor("flesh_heap_minion_damage_amount") or 0
	if IsServer() then
		local stacks = parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent)
		self:SetStackCount(stacks)
		parent:CalculateStatBonus(true)
	end
end

function modifier_flesh_heap_minion_damage:OnRefresh()
	self:OnCreated()
end


function modifier_flesh_heap_minion_damage:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP,
	}
end

function modifier_flesh_heap_minion_damage:OnTooltip(keys)
	return self.flesh_heap_amount * self:GetStackCount()
end

function modifier_flesh_heap_minion_damage:IsAura()
  return true
end

function modifier_flesh_heap_minion_damage:GetModifierAura()
  return "modifier_flesh_heap_minion_damage_creep"
end

function modifier_flesh_heap_minion_damage:GetAuraRadius()
  return 50000
end

function modifier_flesh_heap_minion_damage:GetAuraSearchTeam()
  return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_flesh_heap_minion_damage:GetAuraSearchType()
  return bit.bor(DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_OTHER)
end

function modifier_flesh_heap_minion_damage:GetAuraEntityReject(hEntity)
	local caster = self:GetCaster()
	-- Dont provide dmg to illusions
	if hEntity:IsIllusion() then
		return true
	end
	-- Dont provide the aura effect to allies that you can't control
	if hEntity ~= caster then
		if hEntity.GetPlayerOwnerID then
			if hEntity:GetPlayerOwnerID() ~= caster:GetPlayerOwnerID() then
				return true
			end
		end
	else
		return true
	end

	return false
end

---------------------------------------------------------------------------------------------------

modifier_flesh_heap_minion_damage_creep = class({})


function modifier_flesh_heap_minion_damage_creep:IsPurgable()
	return false
end


function modifier_flesh_heap_minion_damage_creep:IsHidden()
	return true
end


function modifier_flesh_heap_minion_damage_creep:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_flesh_heap_minion_damage_creep:GetModifierTotalDamageOutgoing_Percentage()
	local parent = self:GetParent()
	local owner = parent:GetOwner()

	if not owner or owner:IsNull() then
		return 0
	end
	
	if not owner.HasModifier then
		return 0
	end

	local flesh_heap = owner:FindModifierByName("modifier_flesh_heap_minion_damage")
	if flesh_heap then
		local dmg_increase_per_stack = flesh_heap.flesh_heap_amount
		local stacks = flesh_heap:GetStackCount()

		return stacks * dmg_increase_per_stack
	end
	return 0
end
