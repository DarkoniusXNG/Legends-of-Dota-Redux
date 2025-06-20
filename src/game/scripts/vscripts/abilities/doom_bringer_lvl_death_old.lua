LinkLuaModifier("modifier_doom_bringer_lvl_death_old_debuff", "abilities/doom_bringer_lvl_death_old.lua", LUA_MODIFIER_MOTION_NONE)

doom_bringer_lvl_death_old = class({})

function doom_bringer_lvl_death_old:OnSpellStart()
  local caster = self:GetCaster()
  local target = self:GetCursorTarget()

  -- Don't do anything if target has Linken's effect or it's spell-immune
  if target:TriggerSpellAbsorb(self) or target:IsMagicImmune() then
    return
  end

  -- Sound
  target:EmitSound("Hero_DoomBringer.LvlDeath")

  -- Particle and mini-stun
  target:AddNewModifier(caster, self, "modifier_doom_bringer_lvl_death_old_debuff", {duration = self:GetSpecialValueFor("stun_duration")})

  local base_dmg = self:GetSpecialValueFor("damage")
  local lvl_bonus_multiple = self:GetSpecialValueFor("lvl_bonus_multiple")
  local max_hp_dmg = self:GetSpecialValueFor("lvl_bonus_damage")
  local target_max_hp = target:GetMaxHealth()
  local target_level = target:GetLevel()

  -- Checking if it passes the level requirement
  local bonus_dmg = 0
  if target_level % lvl_bonus_multiple == 0 or target_level >= 30 then
    bonus_dmg = target_max_hp * max_hp_dmg * 0.01
  end

  local damage_table = {
    attacker = caster,
    victim = target,
    damage = base_dmg + bonus_dmg,
    damage_type = self:GetAbilityDamageType(),
    ability = self,
  }

  local particle
  if bonus_dmg > 0 then
    -- Create the bonus damage particle and apply the damage
    particle = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_lvl_death_bonus.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
    ParticleManager:ReleaseParticleIndex(particle)
  else
    particle = ParticleManager:CreateParticle("particles/units/heroes/hero_doom_bringer/doom_bringer_lvl_death.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)
    ParticleManager:ReleaseParticleIndex(particle)
  end

  ApplyDamage(damage_table)
end

--------------------------------------------------------------------------------

modifier_doom_bringer_lvl_death_old_debuff = class({})

function modifier_doom_bringer_lvl_death_old_debuff:IsHidden()
  return true
end

function modifier_doom_bringer_lvl_death_old_debuff:IsDebuff()
  return true
end

function modifier_doom_bringer_lvl_death_old_debuff:IsStunDebuff()
  return true
end

function modifier_doom_bringer_lvl_death_old_debuff:IsPurgable()
  return true
end

function modifier_doom_bringer_lvl_death_old_debuff:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_doom_bringer_lvl_death_old_debuff:GetEffectName()
  return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_doom_bringer_lvl_death_old_debuff:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
  }
end

function modifier_doom_bringer_lvl_death_old_debuff:GetOverrideAnimation()
  return ACT_DOTA_DISABLED
end

function modifier_doom_bringer_lvl_death_old_debuff:CheckState()
  return {
    [MODIFIER_STATE_STUNNED] = true,
  }
end
