LinkLuaModifier("modifier_giant_form_oaa", "abilities/oaa/giant_form.lua", LUA_MODIFIER_MOTION_NONE)

giant_form_oaa = class({})

function giant_form_oaa:OnSpellStart()
  local caster = self:GetCaster()

  -- Apply Giant Form buff to caster
  caster:AddNewModifier(caster, self, "modifier_giant_form_oaa", {duration = self:GetSpecialValueFor("duration")})

  -- Activation Sound
  caster:EmitSound("Hero_Treant.Overgrowth.CastAnim")
end

---------------------------------------------------------------------------------------------------

modifier_giant_form_oaa = class({})

function modifier_giant_form_oaa:IsHidden()
  return false -- should be an active
end

function modifier_giant_form_oaa:IsDebuff()
  return false
end

function modifier_giant_form_oaa:IsPurgable()
  return true -- should be an active
end

function modifier_giant_form_oaa:RemoveOnDeath()
  return true -- should be an active
end

function modifier_giant_form_oaa:OnCreated()
  local ability = self:GetAbility()
  if not ability or ability:IsNull() then
    return
  end

  self.atkDmg = ability:GetSpecialValueFor("giant_attack_damage")
  self.atkSpeed = ability:GetSpecialValueFor("giant_attack_speed_reduction") -- 35
  self.scale = ability:GetSpecialValueFor("giant_scale") -- 60
  self.strength = ability:GetSpecialValueFor("giant_strength")
  self.aoe = ability:GetSpecialValueFor("giant_aoe_bonus") -- 50
  self.range = ability:GetSpecialValueFor("giant_attack_range_melee_bonus") -- 50
  self.strength_multiplier = ability:GetSpecialValueFor("giant_trample_strength_multiplier") -- 2
  self.damage_radius = ability:GetSpecialValueFor("giant_trample_radius") -- 300

  if not IsServer() then
    return
  end
  
  self.dmg_interval = ability:GetSpecialValueFor("giant_trample_interval") -- 1

  self:StartIntervalThink(self.dmg_interval)
end

function modifier_giant_form_oaa:OnIntervalThink()
  if not IsServer() then
    return
  end

  local parent = self:GetParent()
  local multiplier = self.strength_multiplier
  local radius = self.damage_radius
  local interval = self.dmg_interval

  -- Don't do anything while dead (don't do damage on the corpse)
  if not parent:IsAlive() then
    return
  end

  local damage_per_interval = parent:GetStrength() * multiplier * interval

  if parent:IsClone() then
    damage_per_interval = damage_per_interval / 3
  end

  local enemies = FindUnitsInRadius(
    parent:GetTeamNumber(),
    parent:GetAbsOrigin(),
    nil,
    radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    bit.bor(DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_BASIC),
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER,
    false
  )

  local damage_table = {
    attacker = parent,
    damage = damage_per_interval,
    damage_type = DAMAGE_TYPE_MAGICAL,
    damage_flags = DOTA_DAMAGE_FLAG_NONE,
  }

  local play_trample_particle = false
  
  for _, enemy in pairs(enemies) do
    if enemy and not enemy:IsNull() then
      play_trample_particle = true
	  damage_table.victim = enemy
      ApplyDamage(damage_table)
    end
  end
  
  -- Particle (displayed only if enemies nearby)
  if play_trample_particle then
    local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_sandking/sandking_epicenter.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(particle)
  end
end

function modifier_giant_form_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	MODIFIER_PROPERTY_AOE_BONUS_CONSTANT_STACKING,
	MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	MODIFIER_PROPERTY_MODEL_SCALE,
	MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
	MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
end

function modifier_giant_form_oaa:GetModifierBonusStats_Strength()
  return self.strength
end

function modifier_giant_form_oaa:GetModifierPreAttack_BonusDamage()
  return self.atkDmg
end

function modifier_giant_form_oaa:GetModifierAoEBonusConstantStacking()
  return self.aoe
end

function modifier_giant_form_oaa:GetModifierAttackRangeBonus()
  local parent = self:GetParent()

  -- Prevent working on ranged heroes
  if parent:IsRangedAttacker() then
    return 0
  end

  return self.range
end

function modifier_giant_form_oaa:GetModifierModelScale()
  return self.scale
end

function modifier_giant_form_oaa:GetModifierAttackSpeedPercentage()
  return 0 - math.abs(self.atkSpeed)
end

if IsServer() then
  function modifier_item_giant_form_grow:OnAttackLanded(event)
    local parent = self:GetParent()
    if event.attacker ~= parent then
      return
    end

    if not parent or parent:IsNull() then
      return
    end

    if parent:IsIllusion() or parent:IsRangedAttacker() then
      return
    end

    -- Prevent some instant attacks proccing the cleave
    if event.no_attack_cooldown then
      return
    end

    local target = event.target
    if not target or target:IsNull() then
      return
    end

    if target.GetUnitName == nil then
      return
    end

    -- Don't affect buildings, wards and invulnerable units.
    if target:IsTower() or target:IsBarracks() or target:IsBuilding() or target:IsOther() or target:IsInvulnerable() then
      return
    end

    local ability = self:GetAbility()
    if not ability or ability:IsNull() then
      return
    end

    local targetOrigin = target:GetAbsOrigin()

    -- set the targeting requirements for the actual targets
    local targetTeam = ability:GetAbilityTargetTeam()
    local targetType = ability:GetAbilityTargetType()
    local targetFlags = ability:GetAbilityTargetFlags()

    -- get the radius
    local splash_radius = ability:GetSpecialValueFor("giant_splash_radius")
    local splash_damage = ability:GetSpecialValueFor("giant_splash_damage")

    -- find all appropriate targets around the initial target
    local units = FindUnitsInRadius(
      parent:GetTeamNumber(),
      targetOrigin,
      nil,
      splash_radius,
      targetTeam,
      targetType,
      targetFlags,
      FIND_ANY_ORDER,
      false
    )

    -- get the wearer's damage
    local damage = event.original_damage

    -- get the damage modifier
    local actual_damage = damage*splash_damage*0.01

    -- Damage table
    local damage_table = {
      attacker = parent,
      damage = actual_damage,
      damage_type = DAMAGE_TYPE_PHYSICAL,
      damage_flags = bit.bor(DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL),
      ability = ability,
    }

    -- Show particle only if damage is above zero and only if there are units nearby
    if actual_damage > 0 and #units > 1 then
      local particle = ParticleManager:CreateParticle("particles/items/powertreads_splash.vpcf", PATTACH_POINT, target)
      ParticleManager:SetParticleControl(particle, 5, Vector(1, 0, splash_radius))
      ParticleManager:ReleaseParticleIndex(particle)
    end

    -- iterate through all targets
    for _, unit in pairs(units) do
      if unit and not unit:IsNull() and unit ~= target then
        damage_table.victim = unit
        ApplyDamage(damage_table)
      end
    end
  end
end

function modifier_giant_form_oaa:CheckState()
  return {
    [MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
  }
end

function modifier_giant_form_oaa:GetTexture()
  return "custom/giant_form" -- "item_giants_ring"
end
