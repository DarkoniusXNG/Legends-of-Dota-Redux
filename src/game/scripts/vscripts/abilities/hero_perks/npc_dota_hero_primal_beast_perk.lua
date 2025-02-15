--------------------------------------------------------------------------------------------------------
--		Hero: Primal Beast
--		Perk: Bonus move speed and turn speed while disarmed.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_primal_beast_perk = modifier_npc_dota_hero_primal_beast_perk or class({})

function modifier_npc_dota_hero_primal_beast_perk:IsPassive()
	return true
end

function modifier_npc_dota_hero_primal_beast_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_primal_beast_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_primal_beast_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_primal_beast_perk:GetTexture()
	return "primal_beast_uproar"
end

function modifier_npc_dota_hero_primal_beast_perk:OnCreated()
	
end
