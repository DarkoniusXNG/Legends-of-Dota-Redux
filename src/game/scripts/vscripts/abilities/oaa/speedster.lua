-- Speedster
LinkLuaModifier("modifier_speedster_oaa", "abilities/oaa/speedster.lua", LUA_MODIFIER_MOTION_NONE)

speedster_oaa = class({})

function speedster_oaa:GetIntrinsicModifierName()
	return "modifier_speedster_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_speedster_oaa = class({})

function modifier_speedster_oaa:IsHidden()
  return true
end

function modifier_speedster_oaa:IsDebuff()
  return false
end

function modifier_speedster_oaa:IsPurgable()
  return false
end

function modifier_speedster_oaa:RemoveOnDeath()
  return false
end

function modifier_speedster_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
    MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
    MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
  }
end

function modifier_speedster_oaa:GetModifierMoveSpeedBonus_Percentage()
  return 30
end

function modifier_speedster_oaa:GetModifierAttackSpeedPercentage()
  return 30
end

function modifier_speedster_oaa:GetModifierTurnRate_Percentage()
  return 100
end

function modifier_speedster_oaa:GetModifierPercentageCasttime()
  if self:GetParent():HasModifier("modifier_no_cast_points_oaa") then
    return 0
  end
  return 30
end

function modifier_speedster_oaa:CheckState()
  return {
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
  }
end

--function modifier_speedster_oaa:GetTexture()
  --return "dark_seer_surge"
--end
