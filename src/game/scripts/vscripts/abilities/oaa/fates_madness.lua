-- Fate's Madness
LinkLuaModifier("modifier_mr_phys_weak_oaa", "abilities/oaa/fates_madness.lua", LUA_MODIFIER_MOTION_NONE)

fates_madness_oaa = class({})

function fates_madness_oaa:OnSpellStart()
  local caster = self:GetCaster()

  -- Apply Giant Form buff to caster
  caster:AddNewModifier(caster, self, "modifier_mr_phys_weak_oaa", {duration = self:GetSpecialValueFor("duration")})

  -- Activation Sound
  caster:EmitSound("DOTA_Item.MaskOfMadness.Activate")
end

---------------------------------------------------------------------------------------------------

modifier_mr_phys_weak_oaa = class({})

function modifier_mr_phys_weak_oaa:IsHidden()
  return false -- should be an active
end

function modifier_mr_phys_weak_oaa:IsDebuff()
  return false
end

function modifier_mr_phys_weak_oaa:IsPurgable()
  return true -- should be an active
end

function modifier_mr_phys_weak_oaa:RemoveOnDeath()
  return true -- should be an active
end

function modifier_mr_phys_weak_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
  }
end

function modifier_mr_phys_weak_oaa:GetModifierIncomingDamage_Percentage(keys)
  if self:GetParent():IsDebuffImmune() then
    return 0
  end
  if keys.damage_type == DAMAGE_TYPE_PHYSICAL then
    return 40
  end
end

function modifier_mr_phys_weak_oaa:GetModifierMagicalResistanceBonus()
  return 75
end

function modifier_mr_phys_weak_oaa:GetModifierAttackSpeedBonus_Constant()
  return 120
end

function modifier_mr_phys_weak_oaa:GetEffectName()
  return "particles/units/heroes/hero_slardar/slardar_amp_damage.vpcf"
end

function modifier_mr_phys_weak_oaa:GetEffectAttachType()
  return PATTACH_OVERHEAD_FOLLOW
end

function modifier_mr_phys_weak_oaa:GetTexture()
  return "pangolier_heartpiercer"
end
