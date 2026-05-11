-- Guardian's Weakness
LinkLuaModifier("modifier_bonus_armor_negative_magic_resist_oaa", "abilities/oaa/guardians_weakness.lua", LUA_MODIFIER_MOTION_NONE)

guardian_weakness_oaa = class({})

function guardian_weakness_oaa:OnSpellStart()
  local caster = self:GetCaster()

  -- Apply Giant Form buff to caster
  caster:AddNewModifier(caster, self, "modifier_bonus_armor_negative_magic_resist_oaa", {duration = self:GetSpecialValueFor("duration")})

  -- Activation Sound
  caster:EmitSound("Hero_Marci.Guardian.Applied")
end

---------------------------------------------------------------------------------------------------

modifier_bonus_armor_negative_magic_resist_oaa = class({})

function modifier_bonus_armor_negative_magic_resist_oaa:IsHidden()
  return false -- should be an active
end

function modifier_bonus_armor_negative_magic_resist_oaa:IsDebuff()
  return false
end

function modifier_bonus_armor_negative_magic_resist_oaa:IsPurgable()
  return true -- should be an active
end

function modifier_bonus_armor_negative_magic_resist_oaa:RemoveOnDeath()
  return true -- should be an active
end

function modifier_bonus_armor_negative_magic_resist_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
  }
end

function modifier_bonus_armor_negative_magic_resist_oaa:GetModifierPhysicalArmorBonus()
  return 200
end

function modifier_bonus_armor_negative_magic_resist_oaa:GetModifierMagicalResistanceBonus()
  return -200
end

function modifier_bonus_armor_negative_magic_resist_oaa:GetEffectName()
  return "particles/units/heroes/hero_omniknight/omniknight_guardian_angel_omni.vpcf"
end

function modifier_bonus_armor_negative_magic_resist_oaa:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_bonus_armor_negative_magic_resist_oaa:GetStatusEffectName()
  return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_bonus_armor_negative_magic_resist_oaa:StatusEffectPriority()
  return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_bonus_armor_negative_magic_resist_oaa:GetTexture()
  return "marci_bodyguard"
end
