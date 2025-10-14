alchemist_transmuted_scepter = class({})
LinkLuaModifier("modifier_alchemist_transmuted_scepter", "abilities/alchemist_transmuted_scepter", LUA_MODIFIER_MOTION_NONE)


function alchemist_transmuted_scepter:OnSpellStart()
  local caster = self:GetCaster()
  local ability = self
  local target = self:GetCursorTarget()   
  local sound_cast = "Hero_Alchemist.Scepter.Cast"
  local particle_midas = "particles/econ/items/alchemist/alchemist_midas_knuckles/alch_hand_of_midas.vpcf"

  -- Play cast sound
  EmitSoundOn(sound_cast, caster)

  -- Apply effect   
  local particle_midas_fx = ParticleManager:CreateParticle(particle_midas, PATTACH_ABSORIGIN_FOLLOW, caster) 
  ParticleManager:SetParticleControlEnt(particle_midas_fx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), false)

  ParticleManager:ReleaseParticleIndex(particle_midas_fx)

  target:AddNewModifier(caster, ability, "modifier_alchemist_transmuted_scepter", {})
end

function alchemist_transmuted_scepter:CastFilterResultTarget(target)
  local defaultFilterResult = self.BaseClass.CastFilterResultTarget(self, target)

  if target:HasModifier("modifier_alchemist_transmuted_scepter") then
    return UF_FAIL_CUSTOM
  end

  return defaultFilterResult
end

function alchemist_transmuted_scepter:GetCustomCastErrorTarget(target)
  if target:HasModifier("modifier_alchemist_transmuted_scepter") then
    return "#dota_hud_error_cant_cast_scepter_buff"
  end
end


-- scepter modifier
modifier_alchemist_transmuted_scepter = class({})

function modifier_alchemist_transmuted_scepter:IsDebuff()
  return false  
end

function modifier_alchemist_transmuted_scepter:IsHidden()
  return false
end

function modifier_alchemist_transmuted_scepter:IsPurgable()
  return false
end

function modifier_alchemist_transmuted_scepter:GetAttributes()
  return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_alchemist_transmuted_scepter:RemoveOnDeath()
  return false  
end

function modifier_alchemist_transmuted_scepter:OnCreated()
	local ability = self:GetAbility()
	if ability and not ability:IsNull() then
		self.stats = ability:GetSpecialValueFor("bonus_all_stats")
		self.hp = ability:GetSpecialValueFor("bonus_health")
		self.mana = ability:GetSpecialValueFor("bonus_mana")
	end
end

modifier_alchemist_transmuted_scepter.OnRefresh = modifier_alchemist_transmuted_scepter.OnCreated

function modifier_alchemist_transmuted_scepter:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_IS_SCEPTER,
    MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    MODIFIER_PROPERTY_HEALTH_BONUS,
    MODIFIER_PROPERTY_MANA_BONUS,
  }
end

function modifier_alchemist_transmuted_scepter:GetModifierScepter()
  return 1
end

function modifier_alchemist_transmuted_scepter:GetModifierBonusStats_Strength()
  return self.stats
end

function modifier_alchemist_transmuted_scepter:GetModifierBonusStats_Agility()
  return self.stats
end

function modifier_alchemist_transmuted_scepter:GetModifierBonusStats_Intellect()
  return self.stats
end

function modifier_alchemist_transmuted_scepter:GetModifierHealthBonus()
  return self.hp
end

function modifier_alchemist_transmuted_scepter:GetModifierManaBonus()
  return self.mana
end