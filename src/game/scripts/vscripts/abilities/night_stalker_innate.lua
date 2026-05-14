night_stalker_innate_redux = class({})

LinkLuaModifier("modifier_night_stalker_innate_redux","abilities/night_stalker_innate.lua",LUA_MODIFIER_MOTION_NONE)

function night_stalker_innate_redux:GetIntrinsicModifierName()
  return "modifier_night_stalker_innate_redux"
end

---------------------------------------------------------------------------------------------------

modifier_night_stalker_innate_redux = class({})

function modifier_night_stalker_innate_redux:IsPassive()
  return true
end

function modifier_night_stalker_innate_redux:IsPurgable()
  return false
end

function modifier_night_stalker_innate_redux:RemoveOnDeath()
  return false
end

function modifier_night_stalker_innate_redux:IsHidden()
  return self:GetStackCount() == 1
end

function modifier_night_stalker_innate_redux:OnCreated()
  local ability = self:GetAbility()
  self.scepter_bonus_vision = ability:GetSpecialValueFor("scepter_bonus")
  if IsServer() then
    self:StartIntervalThink(0.3)
  end
end

function modifier_night_stalker_innate_redux:OnIntervalThink()
  local parent = self:GetParent()
  if not GameRules:IsDaytime() then
    self:SetStackCount(0)
    if parent:IsAlive() and not parent:PassivesDisabled() and not parent:HasScepter() and not parent:IsIllusion() then
      local ability = self:GetAbility()
      local vision = ability:GetSpecialValueFor("vision_radius")
      AddFOWViewer(parent:GetTeamNumber(), parent:GetAbsOrigin(), vision, 2 * 0.3, false)
    end
  else
    self:SetStackCount(1)
  end
end

function modifier_night_stalker_innate_redux:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
  }
end

function modifier_night_stalker_innate_redux:GetBonusNightVision()
  local parent = self:GetParent()
  if parent:HasScepter() and not parent:PassivesDisabled() and not parent:IsIllusion() then
    return self.scepter_bonus_vision
  end
end

function modifier_night_stalker_innate_redux:CheckState()
  local parent = self:GetParent()
  return {
    [MODIFIER_STATE_FORCED_FLYING_VISION] = parent:HasScepter() and self:GetStackCount() == 0 and not parent:PassivesDisabled() and not parent:IsIllusion(),
  }
end
