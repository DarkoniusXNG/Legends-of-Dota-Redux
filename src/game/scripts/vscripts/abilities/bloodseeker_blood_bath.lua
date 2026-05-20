bloodseeker_blood_bath2 = class({})

LinkLuaModifier( "modifier_bloodseeker_blood_bath_t", "abilities/bloodseeker_blood_bath.lua" ,LUA_MODIFIER_MOTION_NONE )

function bloodseeker_blood_bath2:GetIntrinsicModifierName()
  return "modifier_bloodseeker_blood_bath_t"
end

function bloodseeker_blood_bath2:GetCastRange(location, target)
  return self:GetSpecialValueFor("heal_radius")
end

------------------------------------------------------------------------
modifier_bloodseeker_blood_bath_t = class({})

function modifier_bloodseeker_blood_bath_t:IsHidden()
  return true
end
function modifier_bloodseeker_blood_bath_t:IsPurgable()
  return false
end
function modifier_bloodseeker_blood_bath_t:RemoveOnDeath()
  return false
end
function modifier_bloodseeker_blood_bath_t:IsPassive()
  return true
end

function modifier_bloodseeker_blood_bath_t:DeclareFunctions()
  return {
    MODIFIER_EVENT_ON_DEATH,
  }
end

if IsServer()
  function modifier_bloodseeker_blood_bath_t:OnDeath(keys)
    local killer = keys.attacker
    local dead = keys.unit
    local parent = self:GetParent()
    local ability = self:GetAbility()

    -- Check if parent exists
    if not parent or parent:IsNull() then
      return
    end

    -- Dont proc when affected by break, on illusions or when dead
    if parent:PassivesDisabled() or parent:IsIllusion() or not parent:IsAlive() then
      return
    end

    -- Check if ability exists
    if not ability or ability:IsNull() then
      return
    end

    -- Check if entity is an item, rune or something weird
    if dead.GetUnitName == nil then
      return
    end

    -- Ignore allied deaths
    if dead:GetTeamNumber() == parent:GetTeamNumber() then
      return
    end

    -- Don't affect buildings, wards, illusions and invulnerable units.
    if dead:IsTower() or dead:IsBarracks() or dead:IsBuilding() or dead:IsOther() or dead:IsInvulnerable() or dead:IsIllusion() then
      return
    end

    local healRadius = ability:GetSpecialValueFor("heal_radius")
    local heal_amount = 0
    local lifesteal_bool = false -- considered lifesteal when killed by parent
    if parent:GetRangeToUnit(dead) <= healRadius or killer == parent then
      if dead:IsRealHero() then
        local percentOfMaxHealth = ability:GetSpecialValueFor("hero_max_hp_heal") * 0.01
        heal_amount = percentOfMaxHealth * dead:GetMaxHealth()
      else
        local percentOfMaxHealth = ability:GetSpecialValueFor("non_hero_max_hp_heal") * 0.01
        heal_amount = percentOfMaxHealth * dead:GetMaxHealth()
      end
      if killer == parent then
        lifesteal_bool = true -- considered lifesteal when killed by parent
      end
      if heal_amount > 0 then
        --parent:Heal(heal_amount, ability) -- not affected by heal amp or heal reduction
        parent:HealWithParams(heal_amount, ability, lifesteal_bool, true, parent, false)
        -- Particles
        SendOverheadEventMessage(parent:GetPlayerOwner(), OVERHEAD_ALERT_HEAL, parent, heal_amount, nil)
        local healParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_bloodseeker/bloodseeker_bloodbath.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent)
        ParticleManager:ReleaseParticleIndex(healParticle)
      end
    end
  end
end
