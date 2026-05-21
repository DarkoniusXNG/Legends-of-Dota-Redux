pudge_flesh_heap_lifesteal = class({})

LinkLuaModifier("modifier_flesh_heap_lifesteal", "abilities/pudge_flesh_heap_lifesteal.lua", LUA_MODIFIER_MOTION_NONE)

function pudge_flesh_heap_lifesteal:Spawn()
	if IsServer() then
		local caster = self:GetCaster()
		-- Add kill tracker modifier
		if not caster:HasModifier("modifier_pudge_custom_flesh_heap_kill_tracker") then
			caster:AddNewModifier(caster, self, "modifier_pudge_custom_flesh_heap_kill_tracker", {})
		end
	end
end

function pudge_flesh_heap_lifesteal:GetIntrinsicModifierName()
	return "modifier_flesh_heap_lifesteal"
end

function pudge_flesh_heap_lifesteal:GetCastRange(location, target)
	return self:GetSpecialValueFor("flesh_heap_range")
end

---------------------------------------------------------------------------------------------------

modifier_flesh_heap_lifesteal = class({})

function modifier_flesh_heap_lifesteal:IsHidden()
	return false
end

function modifier_flesh_heap_lifesteal:IsDebuff()
	return false
end

function modifier_flesh_heap_lifesteal:IsPurgable()
	return false
end

function modifier_flesh_heap_lifesteal:RemoveOnDeath()
	return false
end

function modifier_flesh_heap_lifesteal:OnCreated()
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

	self.lifesteal_penalty_against_creeps = 40
end

function modifier_flesh_heap_lifesteal:OnRefresh()
	self:OnCreated()
end

function modifier_flesh_heap_lifesteal:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

if IsServer() then
	function modifier_flesh_heap_lifesteal:OnTakeDamage(event)
		local parent = self:GetParent()
		local ability = self:GetAbility()
		local attacker = event.attacker
		local damaged_unit = event.unit
		local damage = event.damage

		-- Check if attacker exists
		if not attacker or attacker:IsNull() then
			return
		end

		if parent:PassivesDisabled() or parent:IsIllusion() then
			return
		end

		-- Check if attacker has this modifier
		if attacker ~= parent then
			return
		end

		-- Don't heal while dead
		if not attacker:IsAlive() then
			return
		end

		-- Check if damaged entity exists
		if not damaged_unit or damaged_unit:IsNull() then
			return
		end

		-- Ignore self damage
		if damaged_unit == attacker then
			return
		end

		-- Check if entity is an item, rune or something weird
		if damaged_unit.GetUnitName == nil then
			return
		end

		-- Don't affect buildings, wards and invulnerable units.
		if damaged_unit:IsTower() or damaged_unit:IsBarracks() or damaged_unit:IsBuilding() or damaged_unit:IsOther() or damaged_unit:IsInvulnerable() then
			return
		end

		-- Check damage if 0 or negative
		if damage <= 0 then
			return
		end

		-- Normal lifesteal should not work for spells and magic damage attacks
		if event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK or event.damage_type ~= DAMAGE_TYPE_PHYSICAL or event.inflictor then
			return
		end

		-- Calculate the lifesteal (heal) amount
		local lifesteal_amount = 0
		local lifesteal_from_flesh_heap = parent:GetModifierStackCount("modifier_pudge_custom_flesh_heap_kill_tracker", parent) * self.flesh_heap_amount
		if damaged_unit:IsRealHero() or damaged_unit:IsStrongIllusionCustom() then
			lifesteal_amount = damage * lifesteal_from_flesh_heap / 100
		else
			-- Illusions are treated as creeps too
			lifesteal_amount = damage * (lifesteal_from_flesh_heap / 100) * (1 - self.lifesteal_penalty_against_creeps / 100)
		end

		if lifesteal_amount > 0 then
			-- Normal Lifesteal
			attacker:HealWithParams(lifesteal_amount, ability, true, true, attacker, false)
			local particle2 = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:ReleaseParticleIndex(particle2)
		end
	end
end

