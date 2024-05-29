LinkLuaModifier("modifier_tinkerer_smart_missiles_stun", "abilities/oaa/tinkerer_smart_missiles.lua", LUA_MODIFIER_MOTION_NONE) -- needs tooltip

tinkerer_smart_missiles = class({})

function tinkerer_smart_missiles:OnSpellStart()
  local caster = self:GetCaster()
  local target = self:GetCursorPosition()
  local caster_loc = caster:GetAbsOrigin()

  if not target then
    return
  end

  local rocket_width = self:GetSpecialValueFor("rocket_width")
  local rocket_speed = self:GetSpecialValueFor("rocket_speed")
  local rocket_range = self:GetSpecialValueFor("rocket_range")
  local rocket_vision = self:GetSpecialValueFor("rocket_vision")

  -- Calculate offset and starting width
  local attachment = caster:ScriptLookupAttachment("attach_attack3")
  local rocket_spawn_loc = caster_loc
  local offset = 0
  if attachment ~= 0 then
    rocket_spawn_loc = caster:GetAttachmentOrigin(attachment)
    offset = (caster_loc - rocket_spawn_loc):Length2D()
  end
  local start_width = rocket_width + offset

  -- Calculate direction
  local direction = (target - rocket_spawn_loc):Normalized()

  -- Reverse cast direction for self point cast
  if target == caster_loc then
    direction = caster:GetForwardVector() * -1
  end

  -- Remove vertical component
  direction.z = 0

  local projectile_table = {
    Ability = self,
    EffectName = "particles/hero/tinkerer/rocket_projectile_linear.vpcf",
    vSpawnOrigin = rocket_spawn_loc,
    fDistance = rocket_range + caster:GetCastRangeBonus(),
    fStartRadius = start_width,
    fEndRadius = rocket_width,
    Source = caster,
    bHasFrontalCone = true,
    bReplaceExisting = false,
    iUnitTargetTeam = self:GetAbilityTargetTeam(),
    iUnitTargetType = self:GetAbilityTargetType(),
    iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, --DOTA_UNIT_TARGET_FLAG_NONE
    bDeleteOnHit = true,
    vVelocity = direction * rocket_speed,
    bProvidesVision = true,
    iVisionRadius = math.max(rocket_width, rocket_vision),
    iVisionTeamNumber = caster:GetTeamNumber(),
    ExtraData = {
      ox = tostring(caster_loc.x),
      oy = tostring(caster_loc.y),
      oz = tostring(caster_loc.z),
      multishot_bool = 0,
    }
  }

  -- Create projectile
  ProjectileManager:CreateLinearProjectile(projectile_table)

  -- Sound
  caster:EmitSound("Hero_Tinker.Heat-Seeking_Missile")
end

function tinkerer_smart_missiles:OnProjectileHit_ExtraData(target, location, data)
  if not target or not location then
    return false
  end

  local caster = self:GetCaster()
  local base_damage = self:GetSpecialValueFor("base_damage")

  -- Damage table
  local damage_table = {
    attacker = caster,
    victim = target,
    damage = base_damage,
    damage_type = self:GetAbilityDamageType(),
    ability = self,
  }

  -- Glance (go through them, damage them but don't explode) neutral creeps and ignore couriers completely
  if target:GetTeamNumber() == DOTA_TEAM_NEUTRALS or target:IsCourier() then
    if not target:IsMagicImmune() then
      ApplyDamage(damage_table)
    end
    return false
  end

  -- Check if target is already affected by this ability (and caster) to prevent being affected by multishot missiles
  local rocket_debuff = target:FindModifierByNameAndCaster("modifier_tinkerer_smart_missiles_stun", caster)
  if rocket_debuff and data.multishot_bool == 1 then
    if not target:IsMagicImmune() then
      ApplyDamage(damage_table)
    end
    return false
  end

  local bonus_damage_max_range = self:GetSpecialValueFor("bonus_damage_max_range")
  local bonus_hp_damage_max = self:GetSpecialValueFor("bonus_hp_damage_max")
  local bonus_hp_damage_min = self:GetSpecialValueFor("bonus_hp_damage_min")
  local rocket_debuff_duration = self:GetSpecialValueFor("slow_duration")
  local rocket_vision = self:GetSpecialValueFor("rocket_vision")
  local rocket_explode_vision = self:GetSpecialValueFor("rocket_explode_vision")
  local vision_duration = self:GetSpecialValueFor("vision_duration")

  -- Calculate traveled distance
  local origin_position = Vector(tonumber(data.ox), tonumber(data.oy), tonumber(data.oz))
  local travel_distance = math.min((location - origin_position):Length2D(), bonus_damage_max_range)

  -- Multiplier from 0.0 to 1.0 for bonus damage based on travel distance
  local dist_mult = travel_distance / bonus_damage_max_range

  -- Bonus damage based on target's max health, max health multiplier is based traveled distance
  local max_hp_mult = (bonus_hp_damage_max - bonus_hp_damage_min) * dist_mult + bonus_hp_damage_min
  local bonus_damage = target:GetMaxHealth() * max_hp_mult * 0.01

  -- Calculate total damage
  local total_damage = base_damage + bonus_damage
  damage_table.damage = total_damage

  -- Particle
  local particle_name = "particles/units/heroes/hero_tinker/tinker_missle_explosion.vpcf"
  local particle = ParticleManager:CreateParticle(particle_name, PATTACH_ABSORIGIN_FOLLOW, target)
  ParticleManager:ReleaseParticleIndex(particle)

  -- Apply slow and damage - slow before the damage (Applying slow after damage is bad)
  if not target:IsMagicImmune() then
    target:AddNewModifier(caster, self, "modifier_tinkerer_smart_missiles_stun", {duration = rocket_debuff_duration})
    ApplyDamage(damage_table)
  end

  -- Add vision
  local vision_radius = math.max(rocket_vision, rocket_explode_vision)
  AddFOWViewer(caster:GetTeamNumber(), location, vision_radius, vision_duration, false)

  -- Sound
  local sound_name = "Hero_Tinker.Heat-Seeking_Missile.Impact"
  EmitSoundOnLocationWithCaster(location, sound_name, caster)

  -- Missile explosion affects nearby units
  local explode_radius = self:GetSpecialValueFor("explode_radius")
  local enemies = FindUnitsInRadius(
    caster:GetTeamNumber(),
    target:GetAbsOrigin(),
    nil,
    explode_radius,
    self:GetAbilityTargetTeam(),
    self:GetAbilityTargetType(),
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER,
    false
  )

  for _, enemy in pairs(enemies) do
    if enemy and not enemy:IsNull() and enemy ~= target and not enemy:IsMagicImmune() then
      -- Apply Slow before damage (Applying slow after damage is bad)
      enemy:AddNewModifier(caster, self, "modifier_tinkerer_smart_missiles_stun", {duration = rocket_debuff_duration})

      -- Damage (make sure damage is based on the enemy's max hp and not the target's)
      damage_table.victim = enemy
      damage_table.damage = base_damage + enemy:GetMaxHealth() * max_hp_mult * 0.01

      ApplyDamage(damage_table)
    end
  end

  return true
end

function tinkerer_smart_missiles:ProcsMagicStick()
  return true
end

---------------------------------------------------------------------------------------------------

modifier_tinkerer_smart_missiles_stun = class({})

function modifier_tinkerer_smart_missiles_stun:IsHidden()
  return false
end

function modifier_tinkerer_smart_missiles_stun:IsDebuff()
  return true
end

function modifier_tinkerer_smart_missiles_stun:IsPurgable()
  return true
end

function modifier_tinkerer_smart_missiles_stun:OnCreated()
  local move_speed_slow = 100
  local attack_speed_slow = 100

  local ability = self:GetAbility()
  if ability and not ability:IsNull() then
    move_speed_slow = ability:GetSpecialValueFor("move_speed_slow")
    attack_speed_slow = ability:GetSpecialValueFor("attack_speed_slow")
  end

  self.move_speed_slow = move_speed_slow
  self.attack_speed_slow = attack_speed_slow
end

modifier_tinkerer_smart_missiles_stun.OnRefresh = modifier_tinkerer_smart_missiles_stun.OnCreated

function modifier_tinkerer_smart_missiles_stun:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
  }
end

function modifier_tinkerer_smart_missiles_stun:GetModifierMoveSpeedBonus_Percentage()
  return 0 - math.abs(self.move_speed_slow)
end

function modifier_tinkerer_smart_missiles_stun:GetModifierAttackSpeedBonus_Constant()
  return 0 - math.abs(self.attack_speed_slow)
end

function modifier_tinkerer_smart_missiles_stun:GetOverrideAnimation()
  return ACT_DOTA_FLAIL
end
