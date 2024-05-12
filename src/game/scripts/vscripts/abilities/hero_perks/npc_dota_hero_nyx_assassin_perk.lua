--------------------------------------------------------------------------------------------------------
--
--		Hero: Nyx Assassin
--		Perk: Nyx Assassin gains 25% Bonus movement speed when invisible.
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_nyx_assassin_perk ~= "" then modifier_npc_dota_hero_nyx_assassin_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nyx_assassin_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nyx_assassin_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nyx_assassin_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nyx_assassin_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_nyx_assassin_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
  }
  return funcs
end

function modifier_npc_dota_hero_nyx_assassin_perk:GetModifierMoveSpeedBonus_Percentage()
    local caster = self:GetParent()
    if caster:IsInvisible() then
      return 25
    else
      return 0
    end
end
