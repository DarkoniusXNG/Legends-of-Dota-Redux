-- Armor Power
LinkLuaModifier("modifier_bad_design_1_oaa", "abilities/oaa/armor_power.lua", LUA_MODIFIER_MOTION_NONE)

armor_power_oaa = class({})

function armor_power_oaa:GetIntrinsicModifierName()
  return "modifier_bad_design_1_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_bad_design_1_oaa = class({})

function modifier_bad_design_1_oaa:IsHidden()
  return false -- to see current bonus
end

function modifier_bad_design_1_oaa:IsDebuff()
  return false
end

function modifier_bad_design_1_oaa:IsPurgable()
  return false
end

function modifier_bad_design_1_oaa:RemoveOnDeath()
  return false
end

function modifier_bad_design_1_oaa:OnCreated()
  self.bonus_dmg_per_armor = 4
end

modifier_bad_design_1_oaa.OnRefresh = modifier_bad_design_1_oaa.OnCreated

function modifier_bad_design_1_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
  }
end

function modifier_bad_design_1_oaa:GetModifierPreAttack_BonusDamage()
  local parent = self:GetParent()
  return self.bonus_dmg_per_armor * parent:GetPhysicalArmorValue(false)
end

function modifier_bad_design_1_oaa:GetTexture()
  return "item_helm_of_iron_will"
end
