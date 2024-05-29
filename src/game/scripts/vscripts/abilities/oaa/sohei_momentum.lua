LinkLuaModifier("modifier_sohei_momentum_passive", "abilities/oaa/sohei_momentum.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sohei_polarizing_palm_movement", "abilities/oaa/sohei_momentum.lua", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("modifier_sohei_polarizing_palm_stun", "abilities/oaa/sohei_momentum.lua", LUA_MODIFIER_MOTION_NONE) -- needs tooltip
LinkLuaModifier("modifier_sohei_polarizing_palm_slow", "abilities/oaa/sohei_momentum.lua", LUA_MODIFIER_MOTION_NONE) -- needs tooltip

sohei_momentum = class({})

function sohei_momentum:GetAbilityTextureName()
  local baseName = self.BaseClass.GetAbilityTextureName(self)

  if self:GetSpecialValueFor("trigger_distance") <= 0 then
    return baseName
  end

  if self.intrMod and not self.intrMod:IsNull() and not self.intrMod:IsMomentumReady() then
    return baseName .. "_inactive"
  end

  return baseName
end

function sohei_momentum:GetIntrinsicModifierName()
	return "modifier_sohei_momentum_passive"
end

function sohei_momentum:ShouldUseResources()
  return true
end

---------------------------------------------------------------------------------------------------
-- Momentum's passive modifier
modifier_sohei_momentum_passive = class({})

function modifier_sohei_momentum_passive:IsHidden()
  return true
end

function modifier_sohei_momentum_passive:IsPurgable()
  return false
end

function modifier_sohei_momentum_passive:IsDebuff()
  return false
end

function modifier_sohei_momentum_passive:RemoveOnDeath()
  return false
end

function modifier_sohei_momentum_passive:IsMomentumReady()
  local ability = self:GetAbility()
  local distanceFull = ability:GetSpecialValueFor("trigger_distance")
  if IsServer() then
    return self:GetStackCount() >= distanceFull and ability:IsCooldownReady()
  else
    return self:GetStackCount() >= distanceFull
  end
end

function modifier_sohei_momentum_passive:OnCreated()
  self:GetAbility().intrMod = self

  self.parentOrigin = self:GetParent():GetAbsOrigin()
  self.attackPrimed = false -- necessary for cases when sohei starts an attack while moving
  -- i.e. force staff
  -- and gets charged before the attack finishes, causing an attack with knockback but no crit
  if IsServer() then
    self:StartIntervalThink( 1 / 30 )
  end
end

if IsServer() then
  function modifier_sohei_momentum_passive:OnIntervalThink()
    -- Update position
    local parent = self:GetParent()
    local spell = self:GetAbility()
    local oldOrigin = self.parentOrigin
    self.parentOrigin = parent:GetAbsOrigin()

    if not self:IsMomentumReady() then
      if spell:IsCooldownReady() and not parent:PassivesDisabled() then
        self:SetStackCount( self:GetStackCount() + ( self.parentOrigin - oldOrigin ):Length2D() )
      end
    end
  end

  function modifier_sohei_momentum_passive:DeclareFunctions()
    return {
      MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
      MODIFIER_EVENT_ON_ATTACK_LANDED,
    }
  end

  function modifier_sohei_momentum_passive:GetModifierPreAttack_CriticalStrike(event)
    local parent = self:GetParent()
    local spell = self:GetAbility()
    local target = event.target

    -- Check if attacked entity exists
    if not target or target:IsNull() then
      return 0
    end

    -- Check if attacked entity is an item, rune or something weird
    if target.GetUnitName == nil then
      return 0
    end

    if self:IsMomentumReady() and not parent:PassivesDisabled() then -- or target:FindModifierByNameAndCaster("modifier_sohei_momentum_strike_knockback", parent)

      -- make sure the target is valid
      local ufResult = UnitFilter(
        target,
        spell:GetAbilityTargetTeam(),
        spell:GetAbilityTargetType(),
        bit.bor(DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, DOTA_UNIT_TARGET_FLAG_NO_INVIS, DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE),
        parent:GetTeamNumber()
      )

      if ufResult ~= UF_SUCCESS then
        return 0
      end

      self.attackPrimed = true

      local crit_damage = spell:GetSpecialValueFor("crit_damage")

      return crit_damage
    end

    self.attackPrimed = false
    return 0
  end

  function modifier_sohei_momentum_passive:OnAttackLanded(event)
    local parent = self:GetParent()
    local attacker = event.attacker
    local target = event.target

    -- Check if attacker exists
    if not attacker or attacker:IsNull() then
      return
    end

    -- Check if attacker has this modifier
    if attacker ~= parent then
      return
    end

    -- Check if attacked entity exists
    if not target or target:IsNull() then
      return
    end

    -- Check if attacked entity is an item, rune or something weird
    if target.GetUnitName == nil then
      return
    end

    if self.attackPrimed == false then
      return
    end

    local spell = self:GetAbility()

    -- Reset stack counter - Momentum attack landed
    self:SetStackCount(0)

    -- Knock the enemy back
    local distance = spell:GetSpecialValueFor( "knockback_distance" )
    local speed = spell:GetSpecialValueFor( "knockback_speed" )
	local direction = target:GetAbsOrigin() - parent:GetAbsOrigin() -- pushing direction
	-- Normalize direction
	direction.z = 0
	direction = direction:Normalized()

	-- Interrupt existing motion controllers (it should also interrupt existing instances of this spell)
	if target:IsCurrentlyHorizontalMotionControlled() then
		target:InterruptMotionControllers(false)
	end

	-- Sound
	target:EmitSound("Sohei.Momentum")

	-- Apply motion controller
	target:AddNewModifier(parent, spell, "modifier_sohei_polarizing_palm_movement", {
		distance = distance,
		speed = speed,
		direction_x = direction.x,
		direction_y = direction.y,
	})

	-- Particle
    local particleName1 = "particles/hero/sohei/momentum.vpcf"
    local particle_enemy = ParticleManager:CreateParticle(particleName1, PATTACH_ABSORIGIN_FOLLOW, parent)
    ParticleManager:SetParticleControl(particle_enemy, 0, target:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(particle_enemy)

    -- start momentum cooldown
    spell:UseResources(false, false, false, true)
  end
end

local function FindAllBuildingsInRadius(position, radius)
	return FindUnitsInRadius(DOTA_TEAM_NEUTRALS, position, nil, radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
end

-- Repulsive Palm motion controller
modifier_sohei_polarizing_palm_movement = class({})

function modifier_sohei_polarizing_palm_movement:IsDebuff()
  local parent = self:GetParent()
  local caster = self:GetCaster()

  if parent:GetTeamNumber() == caster:GetTeamNumber() then
    return false
  end

  return true
end

function modifier_sohei_polarizing_palm_movement:IsHidden()
  return true
end

function modifier_sohei_polarizing_palm_movement:IsPurgable()
  return true
end

function modifier_sohei_polarizing_palm_movement:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
  }
end

function modifier_sohei_polarizing_palm_movement:GetOverrideAnimation()
  return ACT_DOTA_FLAIL
end

function modifier_sohei_polarizing_palm_movement:GetPriority()
  return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST
end

function modifier_sohei_polarizing_palm_movement:GetEffectName()
  return "particles/hero/sohei/knockback.vpcf"
end

function modifier_sohei_polarizing_palm_movement:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_sohei_polarizing_palm_movement:CheckState()
  return {
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    --[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
  }
end

if IsServer() then
  function modifier_sohei_polarizing_palm_movement:OnCreated(event)
    -- Data sent with AddNewModifier (not available on the client)
    self.direction = Vector(event.direction_x, event.direction_y, 0)
    self.distance = event.distance + 1
    self.speed = event.speed

    if self:ApplyHorizontalMotionController() == false then
      self:Destroy()
      return
    end
  end

  function modifier_sohei_polarizing_palm_movement:OnDestroy()
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local parent_origin = parent:GetAbsOrigin()

    parent:RemoveHorizontalMotionController(self)

    -- Unstuck the parent
    --FindClearSpaceForUnit(parent, parent_origin, false)
    ResolveNPCPositions(parent_origin, 128)

    self:ApplySlow(parent, caster, ability)
  end

  function modifier_sohei_polarizing_palm_movement:UpdateHorizontalMotion(parent, deltaTime)
    if not parent or parent:IsNull() or not parent:IsAlive() then
      return
    end

    local parentOrigin = parent:GetAbsOrigin()
    local parentTeam = parent:GetTeamNumber()
    local caster = self:GetCaster()
    local casterTeam = caster:GetTeamNumber()

    -- Check if an ally and if affected by nullifier
    local isParentNullified = parentTeam == casterTeam and parent:HasModifier("modifier_item_nullifier_mute")
    -- Check if enemy and if spell-immune 
    local isParentDispelled = parentTeam ~= casterTeam and parent:IsMagicImmune())

    if isParentNullified or isParentDispelled then
      self:Destroy()
      return
    end

    local tickTraveled = deltaTime * self.speed
    tickTraveled = math.min(tickTraveled, self.distance)
    if tickTraveled <= 0 then
      self:Destroy()
    end
    local tickOrigin = parentOrigin + tickTraveled * self.direction
    tickOrigin = Vector(tickOrigin.x, tickOrigin.y, GetGroundHeight(tickOrigin, parent))

    self.distance = self.distance - tickTraveled

    if parentTeam ~= casterTeam then
      local ability = self:GetAbility()

      -- Check for phantom (thinkers) blockers (Fissure, Ice Shards etc.)
      local thinkers = Entities:FindAllByClassnameWithin("npc_dota_thinker", tickOrigin, 70)
      for _, thinker in pairs(thinkers) do
        if thinker and thinker:IsPhantomBlocker() then
          self:ApplyStun(parent, caster, ability)
          self:Destroy()
          return
        end
      end

      -- Check for high ground
      local previous_loc = GetGroundPosition(parentOrigin, parent)
      local new_loc = GetGroundPosition(tickOrigin, parent)
      if new_loc.z-previous_loc.z > 10 and not GridNav:IsTraversable(tickOrigin) then
        self:ApplyStun(parent, caster, ability)
        self:Destroy()
        return
      end

      -- Check for trees; GridNav:IsBlocked( tickOrigin ) doesn't give good results; Trees are destroyed on impact;
      if GridNav:IsNearbyTree(tickOrigin, 120, false) then
        self:ApplyStun(parent, caster, ability)
        GridNav:DestroyTreesAroundPoint(tickOrigin, 120, false)
        self:Destroy()
        return
      end

      -- Check for buildings
      if #FindAllBuildingsInRadius(tickOrigin, 30) > 0 then
        self:ApplyStun(parent, caster, ability)
        self:Destroy()
        return
      end

      -- Check if another enemy hero is on a hero's knockback path, if yes apply debuffs and damage to both heroes
      if parent:IsHero() then
        local heroes = FindUnitsInRadius(
          casterTeam,
          tickOrigin,
          nil,
          parent:GetPaddedCollisionRadius(),
          DOTA_UNIT_TARGET_TEAM_ENEMY,
          DOTA_UNIT_TARGET_HERO,
          DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
          FIND_CLOSEST,
          false
        )
        local hero_to_impact = heroes[1]
        if hero_to_impact == parent then
          hero_to_impact = heroes[2]
        end
        if hero_to_impact then
          self:ApplyStun(parent, caster, ability)
          self:ApplyStun(hero_to_impact, caster, ability)
          self:Destroy()
          return
        end
      end
    end

    -- Move the unit to the new location if nothing above was detected;
    -- Unstucking (ResolveNPCPositions) is happening OnDestroy;
    parent:SetAbsOrigin(tickOrigin)
  end

  function modifier_sohei_polarizing_palm_movement:OnHorizontalMotionInterrupted()
    self:Destroy()
  end

  function modifier_sohei_polarizing_palm_movement:ApplyStun(unit, caster, ability)
    if not unit or unit:IsMagicImmune() then
      return
    end

    local stun_duration = ability:GetSpecialValueFor("stun_duration")

    -- Apply stun debuff
    unit:AddNewModifier(caster, ability, "modifier_sohei_polarizing_palm_stun", {duration = stun_duration})

    -- Collision Impact Sound
    unit:EmitSound("Sohei.Momentum.Collision")
  end

  function modifier_sohei_polarizing_palm_movement:ApplySlow(unit, caster, ability)
    if not unit or unit:IsMagicImmune() or unit:GetTeamNumber() == caster:GetTeamNumber() then
      return
    end

    local slow_duration = ability:GetSpecialValueFor("slow_duration")

    -- Apply slow debuff
    unit:AddNewModifier(caster, ability, "modifier_sohei_polarizing_palm_slow", {duration = slow_duration})
  end
end

---------------------------------------------------------------------------------------------------

-- Repulsive Palm Stun debuff
modifier_sohei_polarizing_palm_stun = class({})

function modifier_sohei_polarizing_palm_stun:IsHidden()
  return false
end

function modifier_sohei_polarizing_palm_stun:IsDebuff()
  return true
end

function modifier_sohei_polarizing_palm_stun:IsStunDebuff()
  return true
end

function modifier_sohei_polarizing_palm_stun:IsPurgable()
  return true
end

function modifier_sohei_polarizing_palm_stun:GetEffectName()
  return "particles/generic_gameplay/generic_stunned.vpcf"
end

function modifier_sohei_polarizing_palm_stun:GetEffectAttachType()
  return PATTACH_OVERHEAD_FOLLOW
end

function modifier_sohei_polarizing_palm_stun:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
  }
end

function modifier_sohei_polarizing_palm_stun:GetOverrideAnimation()
  return ACT_DOTA_DISABLED
end

function modifier_sohei_polarizing_palm_stun:CheckState()
  return {
    [MODIFIER_STATE_STUNNED] = true,
  }
end

---------------------------------------------------------------------------------------------------
-- Repulsive Palm Slow debuff
modifier_sohei_polarizing_palm_slow = class({})

function modifier_sohei_polarizing_palm_slow:IsHidden()
  return self:GetParent():HasModifier("modifier_sohei_polarizing_palm_stun")
end

function modifier_sohei_polarizing_palm_slow:IsDebuff()
  return true
end

function modifier_sohei_polarizing_palm_slow:IsPurgable()
  return true
end

function modifier_sohei_polarizing_palm_slow:OnCreated()
  local ability = self:GetAbility()
  local move_speed_slow = ability:GetSpecialValueFor("move_speed_slow_pct")
  local attack_speed_slow = ability:GetSpecialValueFor("attack_speed_slow")

  self.move_speed_slow = move_speed_slow
  self.attack_speed_slow = attack_speed_slow
end

function modifier_sohei_polarizing_palm_slow:OnRefresh()
  self:OnCreated()
end

function modifier_sohei_polarizing_palm_slow:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
  }
end

function modifier_sohei_polarizing_palm_slow:GetModifierMoveSpeedBonus_Percentage()
  return 0 - math.abs(self.move_speed_slow)
end

function modifier_sohei_polarizing_palm_slow:GetModifierAttackSpeedBonus_Constant()
  return 0 - math.abs(self.attack_speed_slow)
end
