LinkLuaModifier("modifier_hylonome_anemic_aura", "abilities/nextgeneration/hero_hylonome/hylonome_anemic_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hylonome_anemic_aura_debuff", "abilities/nextgeneration/hero_hylonome/hylonome_anemic_aura.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_hylonome_anemic_aura_thinker", "abilities/nextgeneration/hero_hylonome/hylonome_anemic_aura.lua", LUA_MODIFIER_MOTION_NONE)

hylonome_anemic_aura = class({})

function hylonome_anemic_aura:GetIntrinsicModifierName()
  return "modifier_hylonome_anemic_aura"
end

---------------------------------------------------------------------------------------------------
-- Aura applier
modifier_hylonome_anemic_aura = class({})

function modifier_hylonome_anemic_aura:IsHidden()
  return true
end

function modifier_hylonome_anemic_aura:IsPurgable()
  return false
end

function modifier_hylonome_anemic_aura:IsDebuff()
  return false
end

function modifier_hylonome_anemic_aura:RemoveOnDeath()
  return false
end

function modifier_hylonome_anemic_aura:IsAura()
  if self:GetParent():PassivesDisabled() then
    return false
  end
  return true
end

function modifier_hylonome_anemic_aura:GetModifierAura()
  return "modifier_hylonome_anemic_aura_debuff"
end

function modifier_hylonome_anemic_aura:GetAuraSearchTeam()
  return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_hylonome_anemic_aura:GetAuraSearchType()
  return DOTA_UNIT_TARGET_HERO
end

function modifier_hylonome_anemic_aura:GetAuraSearchFlags()
  return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function modifier_hylonome_anemic_aura:GetAuraRadius()
  return self:GetAbility():GetSpecialValueFor("radius")
end

---------------------------------------------------------------------------------------------------
-- Aura effect
modifier_hylonome_anemic_aura_debuff = class({})

function modifier_hylonome_anemic_aura_debuff:IsHidden()
  return false
end

function modifier_hylonome_anemic_aura_debuff:IsDebuff()
  return true
end

function modifier_hylonome_anemic_aura_debuff:IsPurgable()
  return false
end

function modifier_hylonome_anemic_aura_debuff:OnCreated()
  local ability = self:GetAbility()
  if not ability or ability:IsNull() then
    return
  end

  self.heal_reduction = ability:GetSpecialValueFor("heal_reduction")
  self.bleed_chance = ability:GetSpecialValueFor("chance")
  self.bleed_duration = ability:GetSpecialValueFor("duration")
end

modifier_hylonome_anemic_aura_debuff.OnRefresh = modifier_hylonome_anemic_aura_debuff.OnCreated

function modifier_hylonome_anemic_aura_debuff:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_RESTORATION_AMPLIFICATION,
    MODIFIER_EVENT_ON_TAKEDAMAGE,
    --MODIFIER_EVENT_ON_HEALTH_GAINED,
  }
end

function modifier_hylonome_anemic_aura_debuff:GetModifierPropertyRestorationAmplification()
  return 0 - math.abs(self.heal_reduction)
end

if IsServer() then
  function modifier_hylonome_anemic_aura_debuff:OnTakeDamage(event)
    local parent = self:GetParent()
    local caster = self:GetCaster()
    local ability = self:GetAbility()
    local attacker = event.attacker
    local damaged_unit = event.unit
    local inflictor = event.inflictor
    local damage = event.damage

    -- Check if attacker exists
    if not attacker or attacker:IsNull() then
      return
    end

    -- Check if attacker has the stuff
    if attacker.IsHero == nil then
      return
    end
	
    if not attacker:IsHero() then
      return
    end

    -- Check if damaged entity exists
    if not damaged_unit or damaged_unit:IsNull() then
      return
    end
	
    -- Check if damaged_unit has this modifier
    if damaged_unit ~= parent then
      return
    end

    -- Check damage if 0 or negative
    if damage <= 0 then
      return
    end
	
    -- Ignore damage from Anemic Aura
    if inflictor == ability then
      return
    end
	
    if RandomInt(1, 100) <= self.bleed_chance then
      parent:AddNewModifier(caster, ability, "modifier_hylonome_anemic_aura_thinker", {duration = self.bleed_duration})
    end
  end

  function modifier_hylonome_anemic_aura_debuff:OnHealthGained(event)
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local unit_that_gained_hp = event.unit

    -- Check if unit has this modifier
    if unit_that_gained_hp ~= parent then
      return
    end

    local gained_hp = event.gain

    -- Check if gained health is negative or 0
    if gained_hp <= 0 then
      return
    end

    -- Imitate heal reduction and health restoration reduction
    local heal_to_damage = math.abs(self.heal_reduction)
    local damage = gained_hp * heal_to_damage / 100
    local damage_table = {
      victim = unit_that_gained_hp,
      attacker = caster,
      damage = damage,
      damage_type = DAMAGE_TYPE_PURE,
      damage_flags = bit.bor(DOTA_DAMAGE_FLAG_HPLOSS, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL, DOTA_DAMAGE_FLAG_NON_LETHAL, DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION, DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS),
      ability = self:GetAbility(),
    }

    ApplyDamage(damage_table)
  end
end

function modifier_hylonome_anemic_aura_debuff:GetEffectName()
  return "particles/items3_fx/star_emblem_shield_glow.vpcf"
end

function modifier_hylonome_anemic_aura_debuff:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW -- attach_origin
end

function modifier_hylonome_anemic_aura_debuff:GetStatusEffectName()
  return "particles/status_fx/status_effect_rupture.vpcf"
end

function modifier_hylonome_anemic_aura_debuff:StatusEffectPriority()
  return 1
end

---------------------------------------------------------------------------------------------------
-- Bleed effect
modifier_hylonome_anemic_aura_thinker = class({})

function modifier_hylonome_anemic_aura_thinker:IsHidden()
  return false
end

function modifier_hylonome_anemic_aura_thinker:IsDebuff()
  return true
end

function modifier_hylonome_anemic_aura_thinker:IsPurgable()
  return true
end

function modifier_hylonome_anemic_aura_thinker:OnCreated()
  self:OnRefresh()
  
  if IsServer() then
    self:StartIntervalThink(1)
  end
end

function modifier_hylonome_anemic_aura_thinker:OnRefresh()
  local ability = self:GetAbility()
  if not ability or ability:IsNull() then
    return
  end
  self.bleed_dmg = ability:GetSpecialValueFor("bleed_damage")
  if IsServer() then
	self:OnIntervalThink()
  ned
end

function modifier_hylonome_anemic_aura_thinker:OnIntervalThink()
  local caster = self:GetCaster()
  local parent = self:GetParent()
  local ability = self:GetAbility()

  local attacker = caster
  if not caster or caster:IsNull() then
    attacker = parent
  elseif caster:IsIllusion() then
    attacker = parent
  end

  local actual_dmg = math.ceil(self.bleed_dmg * parent:GetHealth() * 0.01)

  local damageTable = {
    victim = parent,
    attacker = attacker,
    damage = actual_dmg,
    damage_type = DAMAGE_TYPE_PURE,
    damage_flags = DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL,
    ability = ability,
  }

  ApplyDamage(damageTable)
end

function modifier_hylonome_anemic_aura_thinker:GetEffectName()
  return "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff_arcs.vpcf"
end

function modifier_hylonome_anemic_aura_thinker:GetEffectAttachType()
  return PATTACH_ABSORIGIN_FOLLOW -- follow_origin
end

