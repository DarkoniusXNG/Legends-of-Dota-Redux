LinkLuaModifier("modifier_summoner_tesla_coil", "abilities/dusk/summoner_tesla_coil.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_summoner_tesla_coil_slow", "abilities/dusk/summoner_tesla_coil.lua", LUA_MODIFIER_MOTION_NONE)

summoner_tesla_coil = class({})

function summoner_tesla_coil:GetCastRange(location, target)
  return self:GetSpecialValueFor("radius")
end

function summoner_tesla_coil:GetIntrinsicModifierName()
  return "modifier_summoner_tesla_coil"
end
---------------------------------------------------------------------------------------------------

modifier_summoner_tesla_coil = class({})

function modifier_summoner_tesla_coil:IsHidden()
  return true
end

function modifier_summoner_tesla_coil:IsDebuff()
  return false
end

function modifier_summoner_tesla_coil:IsPurgable()
  return false
end

function modifier_summoner_tesla_coil:OnCreated(event)
  local ability = self:GetAbility()
  local parent = self:GetParent()

  if not ability or ability:IsNull() then
    return
  end

  if IsServer() then
    -- Aura damage stuff
    local dmg_interval = ability:GetSpecialValueFor("interval")
    self.dmg_radius = ability:GetSpecialValueFor("radius")
    self.dmg_per_interval = ability:GetSpecialValueFor("damage")

    -- start thinking
    self:OnIntervalThink()
    self:StartIntervalThink(dmg_interval)
  end
end

function modifier_summoner_tesla_coil:OnRefresh(event)
  -- Stop the previous instance of thinking
  if IsServer() then
    self:StartIntervalThink(-1)
  end

  self:OnCreated(event)
end

function modifier_summoner_tesla_coil:OnIntervalThink()
  if not IsServer() then
    return
  end

  local ability = self:GetAbility()
  local parent = self:GetParent()

  if not parent or parent:IsNull() or not ability or ability:IsNull() then
    return
  end
  
  -- Check if parent is dead or affected by break
  if not parent:IsAlive() or parent:PassivesDisabled() then
    return
  end

  local parentOrigin = parent:GetAbsOrigin()

  local enemies = FindUnitsInRadius(
    parent:GetTeamNumber(),
    parentOrigin,
    nil,
    self.dmg_radius,
    ability:GetAbilityTargetTeam(),
    ability:GetAbilityTargetType(),
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER,
    false
  )

  -- Find random enemy
  local enemy = enemies[RandomInt(1, #enemies)]

  if not enemy or enemy:IsNull() then
    return
  end

  local damage_table = {
    attacker = parent,
    victim = enemy,
    damage = self.dmg_per_interval,
    damage_type = DAMAGE_TYPE_MAGICAL,
    damage_flags = DOTA_DAMAGE_FLAG_NONE,
    ability = ability,
  }

  -- Hit Particle
  local part = ParticleManager:CreateParticle("particles/items_fx/chain_lightning.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
  ParticleManager:SetParticleControlEnt(part, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetAbsOrigin(), true)
  ParticleManager:SetParticleControlEnt(part, 1, parent, PATTACH_POINT_FOLLOW, "attach_hitloc", parentOrigin, true)
  ParticleManager:ReleaseParticleIndex(part)
  --local part = ParticleManager:CreateParticle("particles/units/heroes/hero_summoner/tesla_coil_bolt.vpcf", PATTACH_CUSTOMORIGIN, parent)
  --ParticleManager:SetParticleControl(part, 0, Vector(parentOrigin.x, parentOrigin.y, parentOrigin.z + parent:GetBoundingMaxs().z ))
  --ParticleManager:SetParticleControl(part, 1, Vector(enemy:GetAbsOrigin().x, enemy:GetAbsOrigin().y, enemy:GetAbsOrigin().z + enemy:GetBoundingMaxs().z ))

  -- Hit Sound
  enemy:EmitSound("Hero_Zuus.ArcLightning.Target")
  
  -- Apply slow
  enemy:AddNewModifier(parent, ability, "modifier_summoner_tesla_coil_slow", {duration = ability:GetSpecialValueFor("slow_duration")})

  -- Apply damage
  ApplyDamage(damage_table)
end

---------------------------------------------------------------------------------------------------

modifier_summoner_tesla_coil_slow = class({})

function modifier_summoner_tesla_coil_slow:IsHidden()
  return false
end

function modifier_summoner_tesla_coil_slow:IsDebuff()
  return true
end

function modifier_summoner_tesla_coil_slow:IsPurgable()
  return false
end

function modifier_summoner_tesla_coil_slow:OnCreated(event)
  local ability = self:GetAbility()
  local parent = self:GetParent()

  if not ability or ability:IsNull() then
    return
  end

  self.slow = ability:GetSpecialValueFor("slow")
end

function modifier_summoner_tesla_coil_slow:OnRefresh(event)
  self:OnCreated(event)
end

function modifier_summoner_tesla_coil_slow:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
  }
end

function modifier_summoner_tesla_coil_slow:GetModifierMoveSpeedBonus_Percentage()
  return 0 - math.abs(self.slow)
end

function modifier_summoner_tesla_coil_slow:GetModifierAttackSpeedPercentage()
  return 0 - math.abs(self.slow)
end
