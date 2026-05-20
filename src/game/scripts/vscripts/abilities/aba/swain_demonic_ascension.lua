LinkLuaModifier("modifier_swain_demonic_ascension_buff", "abilities/aba/swain_demonic_ascension.lua", LUA_MODIFIER_MOTION_NONE) -- needs tooltip
LinkLuaModifier("modifier_swain_demonic_ascension_debuff", "abilities/aba/swain_demonic_ascension.lua", LUA_MODIFIER_MOTION_NONE) -- needs tooltip
LinkLuaModifier("modifier_swain_demon_flare_debuff", "abilities/aba/swain_demonic_ascension.lua", LUA_MODIFIER_MOTION_NONE) -- needs tooltip
LinkLuaModifier("modifier_swain_demon_flare_cd", "abilities/aba/swain_demonic_ascension.lua", LUA_MODIFIER_MOTION_NONE) -- needs tooltip

swain_demonic_ascension = swain_demonic_ascension or class({})

function swain_demonic_ascension:GetAOERadius()
  return self:GetSpecialValueFor("radius") -- 650
end

function swain_demonic_ascension:OnSpellStart()
  local caster = self:GetCaster()
  local max_buff_duration = self:GetSpecialValueFor("max_buff_duration") -- 100

  -- Apply buff
  caster:AddNewModifier(caster, self, "modifier_swain_demonic_ascension_buff", {duration = max_buff_duration})
  
  -- Sound
  caster:EmitSound("Hero_Nightstalker.Trickling_Fear")
end

---------------------------------------------------------------------------------------------------

modifier_swain_demonic_ascension_buff = modifier_swain_demonic_ascension_buff or class({})

function modifier_swain_demonic_ascension_buff:IsHidden()
  return false
end

function modifier_swain_demonic_ascension_buff:IsDebuff()
  return false
end

function modifier_swain_demonic_ascension_buff:IsPurgable()
  return false -- League of Legends does not have dispels; it's an ultimate and transformation
end

function modifier_swain_demonic_ascension_buff:OnCreated()
  if not IsServer() then
    return
  end
  local ability = self:GetAbility()
  if not ability or ability:IsNull() then
	return
  end
  -- KVs that are needed
  local max_demonic_energy = ability:GetSpecialValueFor("max_demonic_energy") -- 50
  local interval = ability:GetSpecialValueFor("interval") -- 0.5
  local radius = ability:GetSpecialValueFor("radius") -- 650
  
  -- AoE particle
  self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_night_stalker/nightstalker_crippling_fear_aura.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
  ParticleManager:SetParticleControl(self.particle, 2, Vector(radius, radius, radius))

  self:SetStackCount(max_demonic_energy)
  self:OnIntervalThink()
  self:StartIntervalThink(interval)
end

function modifier_swain_demonic_ascension_buff:OnIntervalThink()
  if not IsServer() then
    return
  end
  local caster = self:GetParent()
  local ability = self:GetAbility()

  if not caster or caster:IsNull() or not ability or ability:IsNull() then
	return
  end

  local radius = ability:GetSpecialValueFor("radius") -- 650
  local min_buff_duration = ability:GetSpecialValueFor("min_buff_duration") -- 5
  local first_demon_flare_time = ability:GetSpecialValueFor("demon_flare_activate_time") -- 2
  -- Demonic Energy KVs
  local max_demonic_energy = ability:GetSpecialValueFor("max_demonic_energy") -- 50
  local demonic_energy_loss_per_interval = ability:GetSpecialValueFor("demonic_energy_decay") -- 5
  local additional_demonic_energy_loss_per_interval = ability:GetSpecialValueFor("additional_demonic_energy_decay") -- 3
  local demonic_energy_gain_per_interval = ability:GetSpecialValueFor("demonic_energy_gain") -- 10

  local caster_location = caster:GetAbsOrigin()

  -- Find enemies in a radius
  local enemies = FindUnitsInRadius(
    caster:GetTeamNumber(),
    caster_location,
    nil,
    radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    bit.bor(DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_BASIC),
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER,
    false
  )

  local found_enemy = false
  local found_hero = false
  for _, enemy in pairs(enemies) do
    if enemy and not enemy:IsNull() and not enemy:IsInvulnerable() and not enemy:IsMagicImmune() and not enemy:IsDebuffImmune() then
      found_enemy = true
      if enemy:IsRealHero() then
        found_hero = true
      end
      -- Apply debuff
      enemy:AddNewModifier(caster, ability, "modifier_swain_demonic_ascension_debuff", {})
    end
  end

  -- Sound
  if found_enemy then
    if self:GetElapsedTime() >= first_demon_flare_time and not caster:HasModifier("modifier_swain_demon_flare_cd") then
      self:DemonFlare()
    end
  end

  -- Current Demonic Energy
  local current_demonic_energy_before = self:GetStackCount()

  -- Decrease Demonic Energy always but check if min_buff_duration time passed
  local current_demonic_energy_after = 0
  if self:GetElapsedTime() >= min_buff_duration then
	current_demonic_energy_after = current_demonic_energy_before - demonic_energy_loss_per_interval - additional_demonic_energy_loss_per_interval
  else
	current_demonic_energy_after = current_demonic_energy_before - demonic_energy_loss_per_interval
  end

  -- Was there a hero nearby?
  if found_hero then
    -- Increase Demonic Energy if there is at least 1 hero around
    current_demonic_energy_after = current_demonic_energy_after + demonic_energy_gain_per_interval
    if current_demonic_energy_after > max_demonic_energy then
	  current_demonic_energy_after = max_demonic_energy
    end
  end

  self:SetStackCount(current_demonic_energy_after)

  -- Check if we are out of Demonic Energy
  if current_demonic_energy_after <= 0 then
	self:StartIntervalThink(-1)
	self:Destroy()
  end
end

function modifier_swain_demonic_ascension_buff:OnDestroy()
  if not IsServer() then
    return
  end

  -- Remove particle
  if self.particle then
    ParticleManager:DestroyParticle(self.particle, true)
    ParticleManager:ReleaseParticleIndex(self.particle)
    self.particle = nil
  end

  local caster = self:GetParent()
  local ability = self:GetAbility()

  if not caster or caster:IsNull() or not ability or ability:IsNull() then
	return
  end

  -- Do not release Demon Flare if dead
  if not caster:IsAlive() then
    return
  end

  if not caster:HasModifier("modifier_swain_demon_flare_cd") then
    self:DemonFlare()
  end
end

function modifier_swain_demonic_ascension_buff:DeclareFunctions()
  return {
    MODIFIER_EVENT_ON_DEATH,
  }
end

function modifier_swain_demonic_ascension_buff:CheckState()
  return {
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
  }
end

function modifier_swain_demonic_ascension_buff:DemonFlare()
  local caster = self:GetParent()
  local ability = self:GetAbility()

  -- Demon Flare KVs
  local slow_duration = ability:GetSpecialValueFor("demon_flare_slow_duration") -- 1.5
  local cd = ability:GetSpecialValueFor("demon_flare_cooldown") -- 8
  local radius = ability:GetSpecialValueFor("demon_flare_radius") -- 675
  local dmg = ability:GetSpecialValueFor("demon_flare_damage") -- 150/225/300

  local caster_location = caster:GetAbsOrigin()

  -- Particle
  local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_void_spirit/pulse/void_spirit_pulse.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
  ParticleManager:SetParticleControl(particle, 1, Vector(radius*2, radius*2, radius*2))
  ParticleManager:ReleaseParticleIndex(particle)

  -- Sound
  caster:EmitSound("Hero_VoidSpirit.Pulse")

  -- Find enemies in a radius
  local enemies = FindUnitsInRadius(
    caster:GetTeamNumber(),
    caster_location,
    nil,
    radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    bit.bor(DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_BASIC),
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER,
    false
  )

  local damage_table = {
    attacker = caster,
    damage =  dmg,
    damage_type = ability:GetAbilityDamageType(),
    ability = ability,
  }

  for _, enemy in pairs(enemies) do
    if enemy and not enemy:IsNull() and not enemy:IsInvulnerable() and not enemy:IsMagicImmune() then
      -- Apply debuff
      enemy:AddNewModifier(caster, ability, "modifier_swain_demon_flare_debuff", {duration = slow_duration})

	  -- Apply damage
	  damage_table.victim = enemy
	  ApplyDamage(damage_table)
    end
  end

  caster:AddNewModifier(caster, ability, "modifier_swain_demon_flare_cd", {duration = cd})
end

if IsServer() then
  function modifier_swain_demonic_ascension_buff:OnDeath(event)
    local caster = self:GetParent()
    local ability = self:GetAbility()

    if not caster or caster:IsNull() or not ability or ability:IsNull() then
	  return
    end

    local killer = event.attacker
    local dead = event.unit

    if not killer or killer:IsNull() then
      return
    end

    if killer ~= caster or dead == caster then
      return
    end

	if dead.IsRealHero == nil then
      return
    end

	if not dead:IsRealHero() then
      return
    end

    -- Don't trigger on Meepo Clones, Tempest Doubles and Spirit Bears
    if dead:IsClone() or dead:IsTempestDouble() or dead:IsSpiritBearCustom() then
      return
    end

	local max_demonic_energy = ability:GetSpecialValueFor("max_demonic_energy") -- 50
	self:SetStackCount(max_demonic_energy)
  end
end

---------------------------------------------------------------------------------------------------

modifier_swain_demonic_ascension_debuff = modifier_swain_demonic_ascension_debuff or class({})

function modifier_swain_demonic_ascension_debuff:IsHidden()
  return false
end

function modifier_swain_demonic_ascension_debuff:IsDebuff()
  return true
end

function modifier_swain_demonic_ascension_debuff:IsPurgable()
  return false -- League of Legends does not have dispels; it would get reapplied anyway
end

function modifier_swain_demonic_ascension_debuff:OnCreated()
  if not IsServer() then
    return
  end

  local caster = self:GetCaster()
  local parent = self:GetParent()
  local ability = self:GetAbility()

  if not caster or caster:IsNull() or not ability or ability:IsNull() then
    self:Destroy()
	return
  end

  if not caster:IsAlive() then
	self:Destroy()
	return
  end

  -- KVs that are needed
  local interval = ability:GetSpecialValueFor("interval") -- 0.5
  local max_buff_duration = ability:GetSpecialValueFor("max_buff_duration") -- 100
  
  local caster_location = caster:GetAbsOrigin()

  -- Particle
  self.nFX = ParticleManager:CreateParticle("particles/units/heroes/hero_death_prophet/death_prophet_spiritsiphon.vpcf", PATTACH_CUSTOMORIGIN, caster)
  ParticleManager:SetParticleControlEnt(self.nFX, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster_location, true)
  ParticleManager:SetParticleControlEnt(self.nFX, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parent:GetAbsOrigin(), true)
  ParticleManager:SetParticleControl(self.nFX, 5, Vector(max_buff_duration, 0, 0)) -- particle does not work without a duration (0 or -1 is not supported)

  -- Sound (only if hero)
  if parent:IsRealHero() then
    self.sound_is_played = true
    -- Sound on the caster
    EmitSoundOnLocationWithCaster(caster_location, "Hero_DeathProphet.SpiritSiphon.Cast", caster)
    -- Sound on the parent
    parent:EmitSound("Hero_DeathProphet.SpiritSiphon.Target")
  end

  -- Start thinking
  self:StartIntervalThink(interval)
end

function modifier_swain_demonic_ascension_debuff:OnIntervalThink()
  if not IsServer() then
    return
  end

  local caster = self:GetCaster()
  local parent = self:GetParent()
  local ability = self:GetAbility()

  -- If needed parameters don't exist then destroy this debuff
  if not caster or caster:IsNull() or not parent or parent:IsNull() or not ability or ability:IsNull() then
    self:StartIntervalThink(-1)
    self:Destroy()
    return
  end

  -- If caster is dead or doesnt have the buff then destroy this debuff
  if not caster:IsAlive() or not caster:HasModifier("modifier_swain_demonic_ascension_buff") then
    self:StartIntervalThink(-1)
    self:Destroy()
    return
  end

  -- If parent is dead or becomes spell-immune, invulnerable or banished then destroy this debuff
  if not parent:IsAlive() or parent:IsMagicImmune() or parent:IsDebuffImmune() or parent:IsInvulnerable() or parent:IsOutOfGame() then
    self:StartIntervalThink(-1)
    self:Destroy()
    return
  end

  local distance = (caster:GetAbsOrigin() - parent:GetAbsOrigin()):Length2D()
  local radius = ability:GetSpecialValueFor("radius") -- 650

  -- If parent goes out of range then destroy this debuff
  if distance > radius then
    self:StartIntervalThink(-1)
    self:Destroy()
    return
  end

  -- KVs that are needed
  local interval = ability:GetSpecialValueFor("interval") -- 0.5
  local dmg_per_second = ability:GetSpecialValueFor("dps") -- 20/40/60
  local heal_per_second = ability:GetSpecialValueFor("heal_per_second") -- 15/27.5/40
  local heal_penalty_against_creeps = ability:GetSpecialValueFor("heal_penalty") -- 90

  -- Reduce heal percent percent against illusions and creeps - same rule as spell lifesteal
  if not parent:IsRealHero() then
    heal_per_second = heal_per_second * (1 - heal_penalty_against_creeps/100)
  end

  local damage_table = {
    attacker = caster,
    victim = parent,
    damage =  dmg_per_second * interval,
    damage_type = ability:GetAbilityDamageType(),
    ability = ability,
  }

  -- Apply damage to the parent
  ApplyDamage(damage_table)

  -- Calculate heal amount indepently from the dmg
  local heal_amount = heal_per_second * interval
  -- Heal the caster (like spell lifesteal)
  --caster:Heal(heal_amount, ability) -- Heal amp and heal reduction doesnt work with Heal method -> using HealWithParams instead
  caster:HealWithParams(heal_amount, ability, false, true, caster, true)

  -- Particle
  --local particle = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
  --ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin())
  --ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_swain_demonic_ascension_debuff:OnDestroy()
  if IsServer() then
    -- Stop sound
    local parent = self:GetParent()
    if parent and not parent:IsNull() and self.sound_is_played then
      parent:StopSound("Hero_DeathProphet.SpiritSiphon.Target")
    end
    -- Remove particle
    if self.nFX then
      ParticleManager:DestroyParticle(self.nFX, true)
      ParticleManager:ReleaseParticleIndex(self.nFX)
      self.nFX = nil
    end
  end
end

---------------------------------------------------------------------------------------------------
modifier_swain_demon_flare_debuff = modifier_swain_demon_flare_debuff or class({})

function modifier_swain_demon_flare_debuff:IsHidden()
  return false
end

function modifier_swain_demon_flare_debuff:IsDebuff()
  return true
end

function modifier_swain_demon_flare_debuff:IsPurgable()
  return true -- League of Legends does not have dispels
end

function modifier_swain_demon_flare_debuff:OnCreated()
  local caster = self:GetCaster()
  local parent = self:GetParent()
  local ability = self:GetAbility()

  if not caster or caster:IsNull() or not ability or ability:IsNull() then
	return
  end

  self.move_slow = 0 - math.abs(ability:GetSpecialValueFor("demon_flare_move_speed_slow")) -- 60
  self.attack_slow = 0 - math.abs(ability:GetSpecialValueFor("demon_flare_attack_speed_slow")) -- 60
  self.max_duration = ability:GetSpecialValueFor("demon_flare_slow_duration") -- 1.5
end

function modifier_swain_demon_flare_debuff:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
  }
end

function modifier_swain_demon_flare_debuff:GetModifierMoveSpeedBonus_Percentage()
  return self.move_slow * (1 - self:GetElapsedTime() / self.max_duration) -- decaying slow
end

function modifier_swain_demon_flare_debuff:GetModifierAttackSpeedBonus_Constant()
  return self.move_slow * (1 - self:GetElapsedTime() / self.max_duration) -- decaying slow
end

---------------------------------------------------------------------------------------------------

modifier_swain_demon_flare_cd = modifier_swain_demon_flare_cd or class({})

function modifier_swain_demon_flare_cd:IsHidden()
  return false
end

function modifier_swain_demon_flare_cd:IsDebuff()
  return false -- it needs to be false because of Debuff Immunity
end

function modifier_swain_demon_flare_cd:IsPurgable()
  return false
end
