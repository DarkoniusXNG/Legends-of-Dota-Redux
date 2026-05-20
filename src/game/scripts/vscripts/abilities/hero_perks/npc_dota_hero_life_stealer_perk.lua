--------------------------------------------------------------------------------------------------------
--		Hero: Lifestealer
--		Perk: Lifestealer gains 3% lifesteal for each level put in a Rage or Undead ability.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_life_stealer_perk = modifier_npc_dota_hero_life_stealer_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_life_stealer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_life_stealer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_life_stealer_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_life_stealer_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_life_stealer_perk:GetTexture()
	return "custom/npc_dota_hero_life_stealer_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_life_stealer_perk:OnCreated()
	self.bonusPerLevel = 3
	self.lifesteal_penalty_against_creeps = 40
	if IsServer() then
		self:StartIntervalThink(0.1)
	end
end

function modifier_npc_dota_hero_life_stealer_perk:OnIntervalThink()
	if IsServer() then
		local caster = self:GetParent()
		local stacks = 0
		for i = 0, caster:GetAbilityCount() - 1 do
			local skill = caster:GetAbilityByIndex(i)
			if skill and (skill:HasAbilityFlag("rage") or skill:HasAbilityFlag("undead")) then
				stacks = stacks + skill:GetLevel() * self.bonusPerLevel
			end
		end
		self:SetStackCount(stacks)
	end
end

function modifier_npc_dota_hero_life_stealer_perk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

if IsServer() then
  function modifier_npc_dota_hero_life_stealer_perk:OnTakeDamage(event)
    local parent = self:GetParent()
    local attacker = event.attacker
    local damaged_unit = event.unit
    local damage = event.damage

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

    -- Normal lifesteal should not work for spells and magic damage attacks
    if event.damage_category ~= DOTA_DAMAGE_CATEGORY_ATTACK or event.damage_type ~= DAMAGE_TYPE_PHYSICAL or event.inflictor then
      return
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
		attacker:HealWithParams(lifesteal_amount, nil, true, true, attacker, false)
		local particle2 = ParticleManager:CreateParticle("particles/generic_gameplay/generic_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, attacker)
		ParticleManager:ReleaseParticleIndex(particle2)
	end
  end
end
