--------------------------------------------------------------------------------------------------------
--		Hero: Lich
--		Perk: Lich gains 1% Spell lifesteal and 1% Mana Cost Reduction for each level put in an Ice or Undead ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_lich_perk = modifier_npc_dota_hero_lich_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lich_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lich_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lich_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lich_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_lich_perk:GetTexture()
	return "custom/npc_dota_hero_lich_perk"
end

function modifier_npc_dota_hero_lich_perk:OnCreated()
	self.bonusPerLevel = 1
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_lich_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and (skill:HasAbilityFlag("ice") or skill:HasAbilityFlag("undead")) then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_lich_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_npc_dota_hero_lich_perk:GetModifierPercentageManacostStacking()
	return self:GetStackCount()
end

if IsServer() then
  function modifier_npc_dota_hero_lich_perk:OnTakeDamage(event)
    local parent = self:GetParent()
    local attacker = event.attacker
    local damaged_unit = event.unit
    local damage = event.damage
    local inflictor = event.inflictor
    local dmg_flags = event.damage_flags

    -- Check if attacker exists
    if not attacker or attacker:IsNull() then
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

    -- If there is no inflictor, damage is not dealt by a spell or item
    if not inflictor or inflictor:IsNull() then
      return
    end

    -- Ignore damage that has the no-reflect flag
    if bit.band(dmg_flags, DOTA_DAMAGE_FLAG_REFLECTION) > 0 then
      return
    end

    -- Ignore damage with HP removal flag
    if bit.band(dmg_flags, DOTA_DAMAGE_FLAG_HPLOSS) > 0 then
      return
    end

    -- Ignore damage that has the no-spell-lifesteal flag
    if bit.band(dmg_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) > 0 then
      return
    end

    -- Ignore damage that has the no-spell-amplification flag
    if bit.band(dmg_flags, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION) > 0 then
      return
    end

    -- Calculate the lifesteal (heal) amount
    local heal_amount = damage * self:GetStackCount() * 0.01

    if heal_amount > 0 then
      -- Spell Lifesteal
      attacker:HealWithParams(heal_amount, inflictor, false, true, attacker, true)
      local particle1 = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
      ParticleManager:SetParticleControl(particle1, 0, attacker:GetAbsOrigin())
      ParticleManager:ReleaseParticleIndex(particle1)
    end
  end
end
