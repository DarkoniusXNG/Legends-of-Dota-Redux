--------------------------------------------------------------------------------------------------------
--		Hero: Leshrac
--		Perk: Leshrac gains 1% Spell lifesteal and 1% Move Speed for each level put in a Light or Lightning ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_leshrac_perk = modifier_npc_dota_hero_leshrac_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_leshrac_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_leshrac_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_leshrac_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_leshrac_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_leshrac_perk:GetTexture()
	return "custom/npc_dota_hero_leshrac_perk"
end

function modifier_npc_dota_hero_leshrac_perk:OnCreated()
	self.bonusPerLevel = 1
	self.spell_lifesteal_against_creeps = 80
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_leshrac_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and (skill:HasAbilityFlag("light") or skill:HasAbilityFlag("lightning")) then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_leshrac_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_npc_dota_hero_leshrac_perk:GetModifierMoveSpeedBonus_Percentage()
	return self:GetStackCount()
end

if IsServer() then
	function modifier_npc_dota_hero_leshrac_perk:OnTakeDamage(event)
		local parent = self:GetParent()
		local attacker = event.attacker
		local damaged_unit = event.unit
		local dmg_flags = event.damage_flags
		local damage = event.damage
		local inflictor = event.inflictor
		local dmg_type = event.damage_type

		-- Check if attacker exists
		if not attacker or attacker:IsNull() then
			return
		end

		-- Check if attacker has this modifier
		if attacker ~= parent then
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

		-- Buildings and wards can't lifesteal
		if attacker:IsTower() or attacker:IsBarracks() or attacker:IsBuilding() or attacker:IsOther() then
			return
		end

		-- Don't affect buildings, wards and invulnerable units.
		if damaged_unit:IsTower() or damaged_unit:IsBarracks() or damaged_unit:IsBuilding() or damaged_unit:IsOther() or damaged_unit:IsInvulnerable() then
			return
		end
		
		-- If there is no inflictor, damage is not dealt by a spell or item
		if not inflictor or inflictor:IsNull() then
			return
		end

		local succubus = attacker:FindAbilityByName("queenofpain_succubus")
		local isSuccubus = succubus and succubus:GetLevel() > 0
		local spellLifestealReflected = false
		if isSuccubus then
			spellLifestealReflected = succubus:GetSpecialValueFor("lifesteal_reflected") == 1
		end
		
		-- Ignore pure damage
		--if dmg_type == DAMAGE_TYPE_PURE then
			--if not isSuccubus then
				--return
			--end
		--end

		-- Ignore damage that has the no-reflect flag
		if bit.band(dmg_flags, DOTA_DAMAGE_FLAG_REFLECTION) > 0 then
			-- Bondage spell lifesteal for reflected dmg only works if dmg is magical or pure
			if dmg_type ~= DAMAGE_TYPE_MAGICAL and dmg_type ~= DAMAGE_TYPE_PURE then
				return
			end
			if not spellLifestealReflected then
				return
			end
		end

		-- Ignore damage that has the no-spell-lifesteal flag
		if bit.band(dmg_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) > 0 then
			-- Bondage spell lifesteal for reflected dmg only works if dmg is magical or pure
			if dmg_type ~= DAMAGE_TYPE_MAGICAL and dmg_type ~= DAMAGE_TYPE_PURE then
				return
			end
			if not spellLifestealReflected then
				return
			end
		end

		-- Ignore damage with HP removal flag
		if bit.band(dmg_flags, DOTA_DAMAGE_FLAG_HPLOSS) > 0 then
			return
		end

		-- Ignore damage with no-spell-amplification flag
		if bit.band(dmg_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION) > 0 then
			return
		end

		-- Don't heal while dead
		if not attacker:IsAlive() then
			return
		end

		-- Check damage if 0 or negative
		if damage <= 0 then
			return
		end

		-- Calculate the lifesteal (heal) amount
		local spell_lifesteal_amount = 0
		if damaged_unit:IsRealHero() or damaged_unit:IsStrongIllusionCustom() then
			spell_lifesteal_amount = damage * self:GetStackCount() / 100
		else
			-- Illusions are treated as creeps too
			spell_lifesteal_amount = damage * (self:GetStackCount() / 100) * (1 - self.spell_lifesteal_against_creeps / 100)
		end

		-- Particle and spell lifesteal
		if spell_lifesteal_amount > 0 then
			-- Spell Lifesteal
			attacker:HealWithParams(spell_lifesteal_amount, inflictor, false, true, attacker, true)
			local particle1 = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:SetParticleControl(particle1, 0, attacker:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle1)
		end
	end
end
