function mirage( keys )
  local caster = keys.caster
  local ability = keys.ability
  local target = keys.target

  local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel()-1)
  local outgoingDamage = ability:GetLevelSpecialValueFor("illusion_dealt", ability:GetLevel()-1)
  local incomingDamage = ability:GetLevelSpecialValueFor("illusion_taken", ability:GetLevel()-1)

  local padding = caster:GetHullRadius()
  local position = caster:GetAbsOrigin()
  local forwardVec = caster:GetForwardVector()

  local illu_table = {
    outgoing_damage = outgoingDamage - 100,
    incoming_damage = incomingDamage,
    bounty_base = 0,
    bounty_growth = 0,
    outgoing_damage_structure = outgoingDamage - 100,
    outgoing_damage_roshan = outgoingDamage - 100,
    duration = duration,
  }

  -- Create an illusion of the caster where the caster is
  local illusion = CreateIllusions(caster, caster, illu_table, 1, padding, false, false)[1]
  FindClearSpaceForUnit(illusion, position, false)

  -- Make the illusion face the same way as the caster
  illusion:SetForwardVector(forwardVec)

  -- Order the illusion to attack-move
  local order = {
    UnitIndex = illusion:entindex(),
    OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
    --TargetIndex = target:entindex(),
    Position = position,
  }

  ExecuteOrderFromTable(order)

  -- Disjoint projectiles on caster
  ProjectileManager:ProjectileDodge(caster)
end