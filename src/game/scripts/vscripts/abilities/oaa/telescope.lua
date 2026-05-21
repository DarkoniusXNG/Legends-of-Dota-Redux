-- Telescope
LinkLuaModifier("modifier_range_increase_oaa", "abilities/oaa/telescope.lua", LUA_MODIFIER_MOTION_NONE)

telescope_oaa = class({})

function telescope_oaa:GetIntrinsicModifierName()
	return "modifier_range_increase_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_range_increase_oaa = class({})

function modifier_range_increase_oaa:IsHidden()
  return true
end

function modifier_range_increase_oaa:IsDebuff()
  return false
end

function modifier_range_increase_oaa:IsPurgable()
  return false
end

function modifier_range_increase_oaa:RemoveOnDeath()
  return false
end

function modifier_range_increase_oaa:OnCreated()
  self.bonus_cast_range = 350
  self.bonus_vision = 350
  self.bonus_attack_range_melee = 150
  self.bonus_attack_range_ranged = 350
end

function modifier_range_increase_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
    MODIFIER_PROPERTY_BONUS_DAY_VISION,
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
  }
end

function modifier_range_increase_oaa:GetModifierCastRangeBonusStacking()
  return self.bonus_cast_range
end

function modifier_range_increase_oaa:GetModifierAttackRangeBonus()
  local parent = self:GetParent()
  if not parent:IsRangedAttacker() then
    return self.bonus_attack_range_melee
  end
  return self.bonus_attack_range_ranged
end

function modifier_range_increase_oaa:GetBonusDayVision()
  return self.bonus_vision
end

function modifier_range_increase_oaa:GetBonusNightVision()
  return self.bonus_vision
end

--function modifier_range_increase_oaa:GetTexture()
  --return "item_spy_gadget"
--end
