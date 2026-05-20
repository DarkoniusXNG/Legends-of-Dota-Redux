-- Quick Spellcasting
LinkLuaModifier("modifier_no_cast_points_oaa", "abilities/oaa/quick_spellcasting.lua", LUA_MODIFIER_MOTION_NONE)

quick_spellcasting_oaa = class({})

function quick_spellcasting_oaa:GetIntrinsicModifierName()
	return "modifier_no_cast_points_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_no_cast_points_oaa = class({})

function modifier_no_cast_points_oaa:IsHidden()
  return true
end

function modifier_no_cast_points_oaa:IsDebuff()
  return false
end

function modifier_no_cast_points_oaa:IsPurgable()
  return false
end

function modifier_no_cast_points_oaa:RemoveOnDeath()
  return false
end

function modifier_no_cast_points_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_CASTTIME_PERCENTAGE,
    MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
  }
end

if IsServer() then
  function modifier_no_cast_points_oaa:GetModifierPercentageCasttime()
    return 100
  end

  function modifier_no_cast_points_oaa:GetModifierIgnoreCastAngle()
    return 1
  end
end

--function modifier_no_cast_points_oaa:GetTexture()
  --return "wisp_spirits"
--end
