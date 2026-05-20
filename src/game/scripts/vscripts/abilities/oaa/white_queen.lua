-- White Queen
LinkLuaModifier("modifier_hero_anti_stun_oaa", "abilities/oaa/white_queen.lua", LUA_MODIFIER_MOTION_NONE)

white_queen_oaa = class({})

function white_queen_oaa:GetIntrinsicModifierName()
	return "modifier_hero_anti_stun_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_hero_anti_stun_oaa = class({})

function modifier_hero_anti_stun_oaa:IsHidden()
  return true
end

function modifier_hero_anti_stun_oaa:IsDebuff()
  return false
end

function modifier_hero_anti_stun_oaa:IsPurgable()
  return false
end

function modifier_hero_anti_stun_oaa:RemoveOnDeath()
  return false
end

function modifier_hero_anti_stun_oaa:OnCreated()
  self.status_resist = 15
  self.slow_resist = 15
end

function modifier_hero_anti_stun_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING,
    MODIFIER_PROPERTY_SLOW_RESISTANCE_STACKING,
  }
end

function modifier_hero_anti_stun_oaa:GetModifierStatusResistanceStacking()
  return self.status_resist
end

function modifier_hero_anti_stun_oaa:GetModifierSlowResistance_Stacking()
  return self.slow_resist
end

function modifier_hero_anti_stun_oaa:CheckState()
  local parent = self:GetParent()
  local current_ability = parent:GetCurrentActiveAbility()
  if (current_ability and (current_ability:IsInAbilityPhase() or current_ability:IsChanneling())) or parent:IsChanneling() then
    return {
      [MODIFIER_STATE_DEBUFF_IMMUNE] = true,
    }
  end
  return {}
end

--function modifier_hero_anti_stun_oaa:GetTexture()
  --return "custom/modifiers/white_queen"
--end
