-- Bad Design
LinkLuaModifier("modifier_bad_design_2_oaa", "abilities/oaa/bad_design.lua", LUA_MODIFIER_MOTION_NONE)

bad_design_oaa = class({})

function bad_design_oaa:GetIntrinsicModifierName()
  return "modifier_bad_design_2_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_bad_design_2_oaa = class({})

function modifier_bad_design_2_oaa:IsHidden()
  return false -- to see current bonus
end

function modifier_bad_design_2_oaa:IsDebuff()
  return false
end

function modifier_bad_design_2_oaa:IsPurgable()
  return false
end

function modifier_bad_design_2_oaa:RemoveOnDeath()
  return false
end

function modifier_bad_design_2_oaa:OnCreated()
  self.bonus_hp_per_int = 10
  self.bonus_hp_regen_per_int = 0.1
end

modifier_bad_design_2_oaa.OnRefresh = modifier_bad_design_2_oaa.OnCreated

function modifier_bad_design_2_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_HEALTH_BONUS,
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
  }
end

function modifier_bad_design_2_oaa:GetModifierHealthBonus()
  local parent = self:GetParent()
  return self.bonus_hp_per_int * parent:GetIntellect(false)
end

function modifier_bad_design_2_oaa:GetModifierConstantHealthRegen()
  local parent = self:GetParent()
  return self.bonus_hp_regen_per_int * parent:GetIntellect(false)
end

function modifier_bad_design_2_oaa:GetTexture()
  return "item_cornucopia"
end
