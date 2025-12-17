
LinkLuaModifier("modifier_skywrath_mage_concussive_break_break","abilities/skywrath_concussive_break.lua",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_skywrath_mage_concussive_break_slow","abilities/skywrath_concussive_break.lua",LUA_MODIFIER_MOTION_NONE)

skywrath_mage_concussive_break = skywrath_mage_concussive_break or class({})

function skywrath_mage_concussive_break:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self

  local particle_name = "particles/skywrath_mage_concussive_break/skywrath_mage_concussive_break.vpcf"
  local radius = ability:GetLevelSpecialValueFor( "slow_radius", ability:GetLevel() - 1 )
  local speed = ability:GetLevelSpecialValueFor( "speed", ability:GetLevel() - 1 )
  local targetTeam =  DOTA_UNIT_TARGET_TEAM_ENEMY --ability:GetAbilityTargetTeam()
  local targetType = DOTA_UNIT_TARGET_HERO -- ability:GetAbilityTargetType()
  local targetFlag = DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS -- ability:GetAbilityTargetFlags()

  -- pick up x nearest target heroes and create tracking projectile targeting the number of targets
  local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, ability:GetSpecialValueFor("launch_radius"), targetTeam, targetType, targetFlag, FIND_CLOSEST, false)

  -- Seek out target
  for k, v in pairs( units ) do
    if caster:CanEntityBeSeenByMyTeam(v) then
      local projTable = {
        EffectName = "particles/skywrath_mage_concussive_break/skywrath_mage_concussive_break.vpcf",
        Ability = ability,
        Target = v,
        Source = caster,
        bDodgeable = false,
        bProvidesVision = true,
        vSpawnOrigin = caster:GetAbsOrigin(),
        iMoveSpeed = speed,
        iVisionRadius = radius,
        iVisionTeamNumber = caster:GetTeamNumber(),
        iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
      }
    ProjectileManager:CreateTrackingProjectile( projTable )
    caster:EmitSound("Hero_SkywrathMage.ConcussiveShot.Cast")
      -- 2nd target for scepter
      if caster:HasScepter() then
        local unitsScepter = FindUnitsInRadius(caster:GetTeamNumber(), v:GetAbsOrigin(), caster, 700, targetTeam, targetType, targetFlag, FIND_ANY_ORDER, false)
        for _,unit in pairs(unitsScepter) do
          if #unitsScepter > 0 then
            local projTable = {
              EffectName = "particles/skywrath_mage_concussive_break/skywrath_mage_concussive_break.vpcf",
              Ability = ability,
              Target = unit,
              Source = caster,
              bDodgeable = false,
              bProvidesVision = true,
              vSpawnOrigin = caster:GetAbsOrigin(),
              iMoveSpeed = speed,
              iVisionRadius = radius,
              iVisionTeamNumber = caster:GetTeamNumber(),
              iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
            }
            ProjectileManager:CreateTrackingProjectile( projTable )
            return
          else 
            unitsScepter = FindUnitsInRadius(caster:GetTeamNumber(), v:GetAbsOrigin(), caster, 700, targetTeam, DOTA_UNIT_TARGET_BASIC, targetFlag, FIND_ANY_ORDER, false)
            if #unitsScepter > 0 then
              local projTable = {
                EffectName = "particles/skywrath_mage_concussive_break/skywrath_mage_concussive_break.vpcf",
                Ability = ability,
                Target = unit,
                Source = caster,
                bDodgeable = false,
                bProvidesVision = true,
                vSpawnOrigin = caster:GetAbsOrigin(),
                iMoveSpeed = speed,
                iVisionRadius = radius,
                iVisionTeamNumber = caster:GetTeamNumber(),
                iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
              }
              ProjectileManager:CreateTrackingProjectile( projTable )
            end
            return
          end
        end
      end
      break
    end
  end
end

function skywrath_mage_concussive_break:OnProjectileHit(hTarget,vLocation)
  local caster = self:GetCaster()
  local ability = self
  local target = hTarget

  local radius = ability:GetLevelSpecialValueFor( "slow_radius", ability:GetLevel() - 1 )
  local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )

  local units = FindUnitsInRadius(caster:GetTeamNumber(), vLocation, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )
  for _,unit in pairs(units) do
    unit:AddNewModifier(caster,ability,"modifier_skywrath_mage_concussive_break_slow",{duration = duration})
  end
  target:AddNewModifier(caster,ability,"modifier_skywrath_mage_concussive_break_break",{duration = duration})
  target:EmitSound("Hero_SkywrathMage.ConcussiveShot.Target")

  -- Create node
  ability:CreateVisibilityNode( vLocation, radius, duration )
end

---------------------------------------------------------------------------------------------------

modifier_skywrath_mage_concussive_break_slow = modifier_skywrath_mage_concussive_break_slow or class({})

function modifier_skywrath_mage_concussive_break_slow:IsDebuff()
  return true
end

function modifier_skywrath_mage_concussive_break_slow:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
  }
end

function modifier_skywrath_mage_concussive_break_slow:GetModifierMoveSpeedBonus_Percentage()
  return self:GetAbility():GetSpecialValueFor("movement_speed_pct")
end

---------------------------------------------------------------------------------------------------

modifier_skywrath_mage_concussive_break_break = modifier_skywrath_mage_concussive_break_break or class({})

function modifier_skywrath_mage_concussive_break_break:IsDebuff()
  return true
end

function modifier_skywrath_mage_concussive_break_break:CheckState()
  return {
    [MODIFIER_STATE_PASSIVES_DISABLED] = true,
  }
end

function modifier_skywrath_mage_concussive_break_break:GetEffectName()
  return "particles/items3_fx/silver_edge_slow.vpcf"
end
