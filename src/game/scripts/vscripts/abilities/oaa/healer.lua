LinkLuaModifier("modifier_healer_oaa", "abilities/oaa/healer.lua", LUA_MODIFIER_MOTION_NONE)

healer_oaa = class({})

function healer_oaa:GetIntrinsicModifierName()
	return "modifier_healer_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_healer_oaa = class({})

function modifier_healer_oaa:IsHidden()
  return true
end

function modifier_healer_oaa:IsDebuff()
  return false
end

function modifier_healer_oaa:IsPurgable()
  return false
end

function modifier_healer_oaa:RemoveOnDeath()
  return false
end

function modifier_healer_oaa:OnCreated()
  self.heal_amp = 75
end

function modifier_healer_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_SOURCE,
    --MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
  }
end

function modifier_healer_oaa:GetModifierHealAmplify_PercentageSource()
  return self.heal_amp
end

-- function modifier_healer_oaa:GetModifierHealAmplify_PercentageTarget()
  -- return self.heal_amp
-- end

--function modifier_healer_oaa:GetTexture()
  --return "item_holy_locket"
--end
