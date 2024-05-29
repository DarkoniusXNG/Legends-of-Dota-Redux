sohei_quivering_palm = class({})

LinkLuaModifier("modifier_sohei_quivering_palm_passive", "abilities/oaa/sohei_quivering_palm.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_sohei_quivering_palm_debuff", "abilities/oaa/sohei_quivering_palm.lua", LUA_MODIFIER_MOTION_NONE) -- needs tooltip
LinkLuaModifier("modifier_sohei_quivering_palm_knockback", "abilities/oaa/sohei_quivering_palm.lua", LUA_MODIFIER_MOTION_NONE)

function sohei_quivering_palm:GetIntrinsicModifierName()
  return "modifier_sohei_quivering_palm_passive"
end

function sohei_quivering_palm:OnSpellStart()
  local caster = self:GetCaster()

  -- Find enemy heroes everywhere
  local heroes = FindUnitsInRadius(
    caster:GetTeamNumber(),
    caster:GetAbsOrigin(),
    nil,
    FIND_UNITS_EVERYWHERE,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO,
    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
    FIND_ANY_ORDER,
    false
  )

  if #heroes < 1 then
    --print("No enemy heroes on the map")
    self:EndCooldown()
    self:StartCooldown(1)
    self:RefundManaCost()
    return
  end

  local heroes_with_modifier = {}
  for _, hero in pairs(heroes) do
    if hero and not hero:IsNull() and hero:HasModifier("modifier_sohei_quivering_palm_debuff") then
      table.insert(heroes_with_modifier, hero)
    end
  end

  if #heroes_with_modifier < 1 then
    --print("No heroes with the modifier")
    self:EndCooldown()
    self:StartCooldown(1)
    self:RefundManaCost()
    return
  end

  local passive = caster:FindModifierByName("modifier_sohei_quivering_palm_passive")
  local last_attacked = passive.last_attacked_unit

  if last_attacked and not last_attacked:IsNull() then
    -- Check if target marked by the passive died or dispelled the debuff, if yes find a new one
    if not last_attacked:IsAlive() or not last_attacked:FindModifierByNameAndCaster("modifier_sohei_quivering_palm_debuff", caster) then
      last_attacked = self:FindLastAttackedWithDebuff(heroes_with_modifier, "modifier_sohei_quivering_palm_debuff")
    end
  else
    -- Target marked by the passive doesn't exist, find a new one
    last_attacked = self:FindLastAttackedWithDebuff(heroes_with_modifier, "modifier_sohei_quivering_palm_debuff")
  end

  self:QuiveringPalmEffect(last_attacked)
end

function sohei_quivering_palm:FindLastAttackedWithDebuff(candidates, debuff_name)
  local last_attacked = nil
  local current_time = GameRules:GetGameTime()
  local caster = self:GetCaster()
  local difference = self:GetSpecialValueFor("max_duration")
  for _, hero in pairs(candidates) do
    if hero and not hero:IsNull() then
      local debuff = hero:FindModifierByNameAndCaster(debuff_name, caster)
      if debuff then
        local debuff_creation_time = debuff:GetCreationTime()
        if current_time - debuff_creation_time < difference then
          difference = current_time - debuff_creation_time
          last_attacked = hero
        end
      end
    end
  end

  return last_attacked
end

function sohei_quivering_palm:QuiveringPalmEffect(victim)
  if not victim then
    --print("No valid target")
    self:EndCooldown()
    self:StartCooldown(1)
    self:RefundManaCost()
    return
  end

  if not victim:IsHero() then
    --print("No valid target")
    self:EndCooldown()
    self:StartCooldown(1)
    self:RefundManaCost()
    return
  end

  local caster = self:GetCaster()

  -- Sound
  victim:EmitSound("Sohei.QuiveringPalm")

  -- Kill illusions
  if victim:IsIllusion() then
    victim:Kill(self, caster)
    return
  end

	-- Knockback parameters
	local distance = self:GetSpecialValueFor("knockback_distance")
	local speed = self:GetSpecialValueFor("knockback_speed")

	local direction = -victim:GetForwardVector() -- victim:GetAbsOrigin() - position_in_front_of_them
	direction.z = 0
	direction = direction:Normalized()

	-- Interrupt existing motion controllers (it should also interrupt existing instances of this spell)
	if victim:IsCurrentlyHorizontalMotionControlled() then
		victim:InterruptMotionControllers(false)
	end

	-- Apply motion controller
	victim:AddNewModifier(caster, self, "modifier_sohei_quivering_palm_knockback", {
		distance = distance,
		speed = speed,
		direction_x = direction.x,
		direction_y = direction.y,
	})

  -- Calculate damage
  local caster_str = caster:GetStrength()
  local victim_str = victim:GetStrength()
  local diff_multiplier = self:GetSpecialValueFor("str_diff_multiplier")
  local base_damage = self:GetSpecialValueFor("base_damage")
  local attack_damage = caster:GetAverageTrueAttackDamage(nil)
  local bonus_damage = math.max((caster_str - victim_str) * diff_multiplier, 0)

  local damage_table = {
    attacker = caster,
    victim = victim,
    damage = base_damage + attack_damage + bonus_damage,
    damage_type = self:GetAbilityDamageType(),
    damage_flags = DOTA_DAMAGE_FLAG_BYPASSES_BLOCK,
    ability = self,
  }
  ApplyDamage(damage_table)
end

function sohei_quivering_palm:OnUnStolen()
  local caster = self:GetCaster()
  local modifier = caster:FindModifierByName("modifier_sohei_quivering_palm_passive")
  if modifier then
    caster:RemoveModifierByName("modifier_sohei_quivering_palm_passive")
  end
end

---------------------------------------------------------------------------------------------------

modifier_sohei_quivering_palm_passive = class({})

function modifier_sohei_quivering_palm_passive:IsHidden()
  return true
end

function modifier_sohei_quivering_palm_passive:IsDebuff()
  return false
end

function modifier_sohei_quivering_palm_passive:IsPurgable()
  return false
end

function modifier_sohei_quivering_palm_passive:RemoveOnDeath()
  return false
end

function modifier_sohei_quivering_palm_passive:DeclareFunctions()
  return {
    MODIFIER_EVENT_ON_ATTACK_LANDED,
  }
end

if IsServer() then
  function modifier_sohei_quivering_palm_passive:OnAttackLanded(event)
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local attacker = event.attacker
    local target = event.target

    -- Check if attacker exists
    if not attacker or attacker:IsNull() then
      return
    end

    if attacker ~= parent then
      return
    end

    -- Check if attacker is an illusion
    if attacker:IsIllusion() then
      return
    end

    -- Check if attacked entity exists
    if not target or target:IsNull() then
      return
    end

    -- Check if its an item, rune, or something weird
    if target.GetUnitName == nil then
      return
    end

    -- Check if its a hero or illusion of a hero
    if not target:IsHero() then
      return
    end

    -- Applying the debuff
    target:AddNewModifier(attacker, ability, "modifier_sohei_quivering_palm_debuff", {duration = ability:GetSpecialValueFor("max_duration")})

    -- Last attacked hero (can be illusion too)
    self.last_attacked_unit = target
  end
end

---------------------------------------------------------------------------------------------------

modifier_sohei_quivering_palm_debuff = class({})

function modifier_sohei_quivering_palm_debuff:IsHidden()
  return false
end

function modifier_sohei_quivering_palm_debuff:IsDebuff()
  return true
end

function modifier_sohei_quivering_palm_debuff:IsPurgable()
  return true
end

function modifier_sohei_quivering_palm_debuff:RemoveOnDeath()
  return true
end

---------------------------------------------------------------------------------------------------

modifier_sohei_quivering_palm_knockback = class({})

function modifier_sohei_quivering_palm_knockback:IsDebuff()
  return true
end

function modifier_sohei_quivering_palm_knockback:IsHidden()
  return true
end

function modifier_sohei_quivering_palm_knockback:IsPurgable()
  return true
end

function modifier_sohei_quivering_palm_knockback:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
  }
end

function modifier_sohei_quivering_palm_knockback:GetOverrideAnimation()
  return ACT_DOTA_FLAIL
end

function modifier_sohei_quivering_palm_knockback:GetPriority()
  return DOTA_MOTION_CONTROLLER_PRIORITY_HIGHEST
end

function modifier_sohei_quivering_palm_knockback:CheckState()
  return {
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    --[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
  }
end

if IsServer() then
  function modifier_sohei_quivering_palm_knockback:OnCreated(event)
    -- Data sent with AddNewModifier (not available on the client)
    self.direction = Vector(event.direction_x, event.direction_y, 0)
    self.distance = event.distance + 1
    self.speed = event.speed

    if self:ApplyHorizontalMotionController() == false then
      self:Destroy()
      return
    end
  end

  function modifier_sohei_quivering_palm_knockback:OnDestroy()
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local parent_origin = parent:GetAbsOrigin()

    parent:RemoveHorizontalMotionController(self)

    -- Unstuck the parent
    --FindClearSpaceForUnit(parent, parent_origin, false)
    ResolveNPCPositions(parent_origin, 128)
  end

  function modifier_sohei_quivering_palm_knockback:UpdateHorizontalMotion(parent, deltaTime)
    if not parent or parent:IsNull() or not parent:IsAlive() then
      return
    end

    local parentOrigin = parent:GetAbsOrigin()
    local parentTeam = parent:GetTeamNumber()
    local caster = self:GetCaster()
    local casterTeam = caster:GetTeamNumber()

    -- Check if enemy and if spell-immune 
    local isParentDispelled = parentTeam ~= casterTeam and parent:IsMagicImmune())

    if isParentDispelled then
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

      -- Check for trees; GridNav:IsBlocked( tickOrigin ) doesn't give good results; Trees are destroyed on impact;
      if GridNav:IsNearbyTree(tickOrigin, 120, false) then
        GridNav:DestroyTreesAroundPoint(tickOrigin, 120, false)
        self:Destroy()
        return
      end      
    end

    -- Move the unit to the new location if nothing above was detected;
    -- Unstucking (ResolveNPCPositions) is happening OnDestroy;
    parent:SetAbsOrigin(tickOrigin)
  end

  function modifier_sohei_quivering_palm_knockback:OnHorizontalMotionInterrupted()
    self:Destroy()
  end
end

