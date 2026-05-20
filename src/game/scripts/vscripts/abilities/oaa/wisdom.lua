LinkLuaModifier("modifier_wisdom_oaa", "abilities/oaa/wisdom.lua", LUA_MODIFIER_MOTION_NONE)

wisdom_oaa = class({})

function wisdom_oaa:GetIntrinsicModifierName()
	return "modifier_wisdom_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_wisdom_oaa = class({})

function modifier_wisdom_oaa:IsHidden()
  return false -- to see current bonus
end

function modifier_wisdom_oaa:IsDebuff()
  return false
end

function modifier_wisdom_oaa:IsPurgable()
  return false
end

function modifier_wisdom_oaa:RemoveOnDeath()
  return false
end

function modifier_wisdom_oaa:OnCreated()
  self.bonus_int_per_lvl = 2
  self.bonus_spell_amp_per_mana = 0.008
end

function modifier_wisdom_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
  }
end

function modifier_wisdom_oaa:GetModifierBonusStats_Intellect()
  local parent = self:GetParent()
  return self.bonus_int_per_lvl * parent:GetLevel()
end

function modifier_wisdom_oaa:GetModifierSpellAmplify_Percentage()
  local parent = self:GetParent()
  return self.bonus_spell_amp_per_mana * parent:GetMaxMana()
end

function modifier_wisdom_oaa:GetTexture()
  return "item_staff_of_wizardry"
end
