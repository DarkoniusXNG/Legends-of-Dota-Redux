--------------------------------------------------------------------------------------------------------
--		Hero: Grimstroke
--		Perk: Spells with 800 range or more deal 15% extra damage.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_grimstroke_perk = modifier_npc_dota_hero_grimstroke_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_grimstroke_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_grimstroke_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_grimstroke_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_grimstroke_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_grimstroke_perk:GetTexture()
	return "custom/npc_dota_hero_grimstroke_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_grimstroke_perk:OnCreated()
  if IsServer() then
    self.range = 800
    self.amp = 15
  end
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_grimstroke_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
  }
  return funcs
end

function modifier_npc_dota_hero_grimstroke_perk:GetModifierSpellAmplify_Percentage(keys)
  if IsServer() then
    local hero = self:GetCaster()
    local unit = keys.attacker
    local ability = keys.ability or keys.inflictor

    if not hero == unit then return 0 end

    if ability and ability:GetCastRange(nil,nil) >= self.range then
      return self.amp
    end
	return 0
  end
end
