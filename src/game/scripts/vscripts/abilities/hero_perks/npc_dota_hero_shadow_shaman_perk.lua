--------------------------------------------------------------------------------------------------------
--    Hero: Shadow Shaman
--    Perk: When targeted by a spell, Hex the caster for 1 second. Has 15 second cooldown.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_shadow_shaman_perk = modifier_npc_dota_hero_shadow_shaman_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_shadow_shaman_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_shadow_shaman_perk:GetTexture()
	return "custom/npc_dota_hero_shadow_shaman_perk"
end

function modifier_npc_dota_hero_shadow_shaman_perk:OnCreated()
  if IsServer() then
    self.cooldownTime = 15
    self.hexDuration = 1

    self.cooldownReady = true
  end
end

function modifier_npc_dota_hero_shadow_shaman_perk:DestroyOnExpire ()
  return false
end

function modifier_npc_dota_hero_shadow_shaman_perk:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_ABSORB_SPELL
  }
end

function modifier_npc_dota_hero_shadow_shaman_perk:GetAbsorbSpell(keys)
  if IsServer() then
    if self.cooldownReady and keys.ability:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
      self:HexCaster(keys.ability:GetCaster(),keys.ability)
    end
  end
  return 0
end

function modifier_npc_dota_hero_shadow_shaman_perk:HexCaster (target,ability)
  target:AddNewModifier(self:GetParent(),ability,"modifier_shadow_shaman_voodoo",{duration = self.hexDuration})
  self:SetDuration(self.cooldownTime, true)
  self:StartIntervalThink(self.cooldownTime)
  self.cooldownReady = false
end

function modifier_npc_dota_hero_shadow_shaman_perk:OnIntervalThink ()
  if IsServer() then
    self.cooldownReady = true
    self:SetDuration(-1,true)
    self:StartIntervalThink(-1)
  end
end
