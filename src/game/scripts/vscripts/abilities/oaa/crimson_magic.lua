LinkLuaModifier("modifier_crimson_magic_oaa", "abilities/oaa/crimson_magic.lua", LUA_MODIFIER_MOTION_NONE)

crimson_magic_oaa = class({})

function crimson_magic_oaa:GetIntrinsicModifierName()
  return "modifier_crimson_magic_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_crimson_magic_oaa = class({})

function modifier_crimson_magic_oaa:IsHidden()
  return false -- to see current bonus
end

function modifier_crimson_magic_oaa:IsDebuff()
  return false
end

function modifier_crimson_magic_oaa:IsPurgable()
  return false
end

function modifier_crimson_magic_oaa:RemoveOnDeath()
  return false
end

function modifier_crimson_magic_oaa:OnCreated()
  self.bonus_spell_amp_per_health = 0.008
end

modifier_crimson_magic_oaa.OnRefresh = modifier_crimson_magic_oaa.OnCreated

function modifier_crimson_magic_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
  }
end

function modifier_crimson_magic_oaa:GetModifierSpellAmplify_Percentage()
  local parent = self:GetParent()
  return self.bonus_spell_amp_per_health * parent:GetMaxHealth()
end

function modifier_crimson_magic_oaa:GetTexture()
  return "item_vitality_booster"
end
