-- Blood Magic (OAA version)
LinkLuaModifier("modifier_blood_magic_oaa", "abilities/oaa/blood_magic.lua", LUA_MODIFIER_MOTION_NONE)

blood_magic_oaa = class({})

function blood_magic_oaa:GetIntrinsicModifierName()
  return "modifier_blood_magic_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_blood_magic_oaa = class({})

function modifier_blood_magic_oaa:IsHidden()
  return true
end

function modifier_blood_magic_oaa:IsDebuff()
  return false
end

function modifier_blood_magic_oaa:IsPurgable()
  return false
end

function modifier_blood_magic_oaa:RemoveOnDeath()
  return false
end

function modifier_blood_magic_oaa:OnCreated()
  local parent = self:GetParent()
  local ability = self:GetAbility()
  self.base_mana = 75
  self.bonus_hp = parent:GetMaxMana() - self.base_mana
  self.bonus_hp_regen = parent:GetManaRegen()
  self.bonus_mana = 0 - self.bonus_hp
  self.health_cost_multiplier = ability:GetSpecialValueFor("health_cost_multiplier")
  self.spell_lifesteal = ability:GetSpecialValueFor("spell_lifesteal")
  self.spell_lifesteal_penalty_against_creeps = 80
  if IsServer() and parent:IsHero() then
    parent:CalculateStatBonus(true)
    self:StartIntervalThink(0.5)
  end
end

function modifier_blood_magic_oaa:OnRefresh()
  local ability = self:GetAbility()
  self.health_cost_multiplier = ability:GetSpecialValueFor("health_cost_multiplier")
  self.spell_lifesteal = ability:GetSpecialValueFor("spell_lifesteal")
end

function modifier_blood_magic_oaa:OnIntervalThink()
  local parent = self:GetParent()
  if not parent or parent:IsNull() then
    self:StartIntervalThink(-1)
    self:Destroy()
	return
  end
  if parent:IsIllusion() then
    self:StartIntervalThink(-1)
    self:Destroy()
	return
  end

  self.bonus_hp = math.max(self.bonus_hp + parent:GetMaxMana(), 0) - self.base_mana
  self.bonus_hp_regen = math.max(parent:GetManaRegen(), 0)
  self.bonus_mana = 0 - self.bonus_hp

  if IsServer() and parent:IsHero() then
    parent:CalculateStatBonus(true)
  end
end

function modifier_blood_magic_oaa:OnDestroy()
  local parent = self:GetParent()
  if not parent or parent:IsNull() then
	return
  end
  if IsServer() and parent and parent:IsHero() then
    parent:CalculateStatBonus(true)
    parent:GiveMana(self.bonus_hp + self.base_mana)
  end
end

function modifier_blood_magic_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_HEALTH_BONUS,
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
    MODIFIER_PROPERTY_MANA_BONUS,
    MODIFIER_PROPERTY_SPELLS_REQUIRE_HP, -- doesnt work properly, thx Valve
    MODIFIER_EVENT_ON_ABILITY_EXECUTED, -- reinventing Health Cost
	MODIFIER_EVENT_ON_TAKEDAMAGE, -- for spell lifesteal
  }
end

function modifier_blood_magic_oaa:GetModifierConstantHealthRegen()
  local parent = self:GetParent()
  if parent:PassivesDisabled() then
    return 0
  end
  return self.bonus_hp_regen or 0
end

if IsServer() then
  function modifier_blood_magic_oaa:GetModifierHealthBonus()
    return self.bonus_hp
  end
  function modifier_blood_magic_oaa:GetModifierManaBonus()
    return self.bonus_mana
  end
end

function modifier_blood_magic_oaa:GetModifierSpellsRequireHP()
  -- On Client: it shows mana cost x this number as health cost
  -- On Server: it doesnt spend health for most spells, but at least it turns mana cost per second into health per second x this number for some spells
  return self.health_cost_multiplier
end

-- Reinventing Amplified Health Cost that is not affected by magic resist
if IsServer() then
  function modifier_blood_magic_oaa:OnAbilityExecuted(event)
    local parent = self:GetParent()

    local cast_ability = event.ability
    local caster = event.unit

    -- Check if caster has this modifier
    if caster ~= parent then
      return
    end

    if not cast_ability then
      return
    end

    local mana_cost = cast_ability:GetManaCost(-1)
    local self_damage = mana_cost * self.health_cost_multiplier
    local damage_table = {
      attacker = parent,
      victim = parent,
      damage = self_damage,
      damage_type = DAMAGE_TYPE_PURE,
      damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
      ability = cast_ability
    }
    ApplyDamage(damage_table)
  end

	function modifier_blood_magic_oaa:OnTakeDamage(event)
		local parent = self:GetParent()
		local ability = self:GetAbility()
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

		if parent:PassivesDisabled() or parent:IsIllusion() then
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

		-- Buildings, wards and illusions can't lifesteal
		if attacker:IsTower() or attacker:IsBarracks() or attacker:IsBuilding() or attacker:IsOther() or attacker:IsIllusion() then
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
		if dmg_type == DAMAGE_TYPE_PURE then
			if not isSuccubus then
				return
			end
		end

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
			spell_lifesteal_amount = damage * self.spell_lifesteal / 100
		else
			-- Illusions are treated as creeps too
			spell_lifesteal_amount = damage * (self.spell_lifesteal / 100) * (1 - self.spell_lifesteal_penalty_against_creeps / 100)
		end

		-- Particle and spell lifesteal
		if spell_lifesteal_amount > 0 then
			-- Spell Lifesteal
			attacker:HealWithParams(spell_lifesteal_amount, ability, false, true, attacker, true)
			local particle1 = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
			ParticleManager:SetParticleControl(particle1, 0, attacker:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(particle1)
		end
	end
end
