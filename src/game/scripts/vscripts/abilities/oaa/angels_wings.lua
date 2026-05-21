-- Angel's Wings
LinkLuaModifier("modifier_angel_wings_oaa", "abilities/oaa/angels_wings.lua", LUA_MODIFIER_MOTION_NONE)

angel_wings_oaa = class({})

function angel_wings_oaa:GetIntrinsicModifierName()
  return "modifier_angel_wings_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_angel_wings_oaa = class({})

function modifier_angel_wings_oaa:IsHidden()
  return true
end

function modifier_angel_wings_oaa:IsDebuff()
  return false
end

function modifier_angel_wings_oaa:IsPurgable()
  return false
end

function modifier_angel_wings_oaa:RemoveOnDeath()
  return false
end

function modifier_angel_wings_oaa:OnCreated()
  self.vision = 200
  self.ms = 30
  self.status_resist = -30
end

modifier_angel_wings_oaa.OnRefresh = modifier_angel_wings_oaa.OnCreated

function modifier_angel_wings_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_BONUS_DAY_VISION,
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
  }
end

function modifier_angel_wings_oaa:GetBonusDayVision()
  return self.vision
end

function modifier_angel_wings_oaa:GetBonusNightVision()
  return self.vision
end

function modifier_angel_wings_oaa:GetModifierMoveSpeedBonus_Percentage()
  return self.ms
end

function modifier_angel_wings_oaa:GetModifierStatusResistanceStacking()
  return 0 - math.abs(self.status_resist)
end

function modifier_angel_wings_oaa:CheckState()
  return {
    [MODIFIER_STATE_FLYING] = true,
    [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
    [MODIFIER_STATE_FORCED_FLYING_VISION] = true,
  }
end

function modifier_angel_wings_oaa:GetEffectName()
  return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_ally.vpcf"
  -- "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf"
end

function modifier_angel_wings_oaa:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

--function modifier_angel_wings_oaa:GetStatusEffectName()
  --return "particles/status_fx/status_effect_guardian_angel.vpcf"
--end

--function modifier_angel_wings_oaa:StatusEffectPriority()
  --return MODIFIER_PRIORITY_SUPER_ULTRA + 10000
--end

--function modifier_angel_wings_oaa:GetTexture()
  --return "omniknight_guardian_angel"
--end
