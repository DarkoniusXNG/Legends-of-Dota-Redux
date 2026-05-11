LinkLuaModifier("modifier_smurf_oaa", "abilities/oaa/smurf.lua", LUA_MODIFIER_MOTION_NONE)

smurf_oaa = class({})

function smurf_oaa:GetIntrinsicModifierName()
	return "modifier_smurf_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_smurf_oaa = class({})

function modifier_smurf_oaa:IsHidden()
  return false -- to see current bonus
end

function modifier_smurf_oaa:IsDebuff()
  return false
end

function modifier_smurf_oaa:IsPurgable()
  return false
end

function modifier_smurf_oaa:RemoveOnDeath()
  return false
end

function modifier_smurf_oaa:OnCreated()
  self.bonus_str_per_lvl = 5
  self.scale = -50
  self.aoe = -50
  self.attack_range_penalty = -50 -- only melee
end

function modifier_smurf_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_MODEL_SCALE,
    MODIFIER_PROPERTY_AOE_BONUS_CONSTANT_STACKING,
    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
  }
end

function modifier_smurf_oaa:GetModifierBonusStats_Strength()
  local parent = self:GetParent()
  return self.bonus_str_per_lvl * parent:GetLevel()
end

function modifier_smurf_oaa:GetModifierModelScale()
  return self.scale
end

function modifier_smurf_oaa:GetModifierAoEBonusConstantStacking()
  return 0 - math.abs(self.aoe) -- TODO: test if it accepts negative values
end

function modifier_smurf_oaa:GetModifierAttackRangeBonus()
  local parent = self:GetParent()
  if not parent:IsRangedAttacker() then
    return 0 - math.abs(self.attack_range_penalty)
  end
  return 0
end

function modifier_smurf_oaa:GetTexture()
  return "custom/smurf"
end
