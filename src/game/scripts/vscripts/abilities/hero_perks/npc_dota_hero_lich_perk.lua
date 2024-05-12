--------------------------------------------------------------------------------------------------------
--
--		Hero: Lich
--		Perk: Denying a creep gives 25% of that creeps max health to lich
--
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_lich_perk ~= "" then modifier_npc_dota_hero_lich_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lich_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lich_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lich_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lich_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_lich_perk:GetTexture()
	return "custom/npc_dota_hero_lich_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lich_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_npc_dota_hero_lich_perk:OnDeath(params)
	if IsServer() then
		if params.attacker == self:GetParent() and params.attacker:GetTeamNumber() == params.unit:GetTeamNumber() then
			params.attacker:GiveMana(params.unit:GetMaxHealth()*0.5)
		end
	end
end

