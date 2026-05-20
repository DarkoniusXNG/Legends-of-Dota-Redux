if spell_lab_survivor_life_steal == nil then
	spell_lab_survivor_life_steal = class({})
end

LinkLuaModifier("spell_lab_survivor_life_steal_modifier", "abilities/spell_lab/survivor/life_steal.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_survivor_life_steal:GetIntrinsicModifierName() return "spell_lab_survivor_life_steal_modifier" end


if spell_lab_survivor_life_steal_modifier == nil then
	spell_lab_survivor_life_steal_modifier = require "abilities/spell_lab/survivor/base"
end

function spell_lab_survivor_life_steal_modifier:DeclareFunctions()
	retun {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_EVENT_ON_DEATH,
	}
end

if IsServer() then
	function spell_lab_survivor_life_steal_modifier:OnTakeDamage(event)
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

		if not self.lifesteal_penalty_against_creeps then
			self.lifesteal_penalty_against_creeps = 40
		end

		-- Calculate the lifesteal (heal) amount
		local lifesteal_amount = 0
		if damaged_unit:IsRealHero() or damaged_unit:IsStrongIllusionCustom() then
			lifesteal_amount = damage * self:GetStackCount() / 100
		else
			-- Illusions are treated as creeps too
			lifesteal_amount = damage * (self:GetStackCount() / 100) * (1 - self.lifesteal_penalty_against_creeps / 100)
		end

		if lifesteal_amount > 0 then
			-- Normal Lifesteal
			attacker:HealWithParams(lifesteal_amount, ability, true, true, attacker, false)
			local particle2 = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:ReleaseParticleIndex(particle2)
		end
	end
end
