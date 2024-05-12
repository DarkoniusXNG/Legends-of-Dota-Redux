--------------------------------------------------------------------------------------------------------
--
--		Hero: Juggernaut
--		Perk: Omnislash breaks
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_juggernaut_perk ~= "" then modifier_npc_dota_hero_juggernaut_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_juggernaut_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_juggernaut_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_juggernaut_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_juggernaut_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_juggernaut_perk:GetTexture()
	return "custom/npc_dota_hero_juggernaut_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_juggernaut_perk:DeclareFunctions()
  local funcs = {
    MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
  }
  return funcs
end

function modifier_npc_dota_hero_juggernaut_perk:OnAbilityFullyCast(params)
	if IsServer() and params.unit == self:GetParent() then
		if string.find(params.ability:GetAbilityName(), "omni_slash") then
			params.target:AddNewModifier(params.unit, params.ability, "modifier_silver_edge_debuff", {duration = 3})
		end
	end
end
