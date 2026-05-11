LinkLuaModifier("modifier_cursed_attack_oaa", "abilities/oaa/cursed_attack.lua", LUA_MODIFIER_MOTION_NONE)

cursed_attack_oaa = class({})

function cursed_attack_oaa:GetIntrinsicModifierName()
	return "modifier_cursed_attack_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_cursed_attack_oaa = class({})

function modifier_cursed_attack_oaa:IsHidden()
  return true -- passive
end

function modifier_cursed_attack_oaa:IsDebuff()
  return true
end

function modifier_cursed_attack_oaa:IsPurgable()
  return false
end

function modifier_cursed_attack_oaa:RemoveOnDeath()
  return false
end

function modifier_cursed_attack_oaa:DeclareFunctions()
  return {
    --MODIFIER_PROPERTY_MISS_PERCENTAGE,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PURE,
    --MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
  }
end

--function modifier_cursed_attack_oaa:GetModifierMiss_Percentage(keys)
  --return 50
--end

function modifier_cursed_attack_oaa:GetModifierBonusStats_Agility()
  return -9999
end

function modifier_cursed_attack_oaa:GetModifierProcAttack_BonusDamage_Pure()
  if RandomInt(1, 100) <= 50 then
    return 350
  end
  return 0
end

--function modifier_cursed_attack_oaa:GetModifierPreAttack_BonusDamage()
  --return -125
--end

function modifier_cursed_attack_oaa:GetEffectName()
  return "particles/units/heroes/hero_axe/axe_battle_hunger.vpcf"
end

function modifier_cursed_attack_oaa:GetEffectAttachType()
  return PATTACH_OVERHEAD_FOLLOW
end

--function modifier_cursed_attack_oaa:GetTexture()
  --return "antimage_mana_overload"
--end
