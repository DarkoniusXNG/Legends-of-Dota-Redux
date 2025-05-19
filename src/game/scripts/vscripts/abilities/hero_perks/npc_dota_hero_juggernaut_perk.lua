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

function modifier_npc_dota_hero_juggernaut_perk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end

if IsServer() then
	function modifier_npc_dota_hero_juggernaut_perk:OnAbilityFullyCast(params)
	 	local parent = self:GetParent()
		local unit = params.unit
		local target = params.target
		local ability = params.ability

		if unit == parent and target and ability then
			if string.find(ability:GetAbilityName(), "omni_slash") then
				target:AddNewModifier(parent, ability, "modifier_silver_edge_debuff", {duration = 3})
			end
		end
	end
end
