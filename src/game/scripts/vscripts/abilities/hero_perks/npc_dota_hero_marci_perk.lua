--------------------------------------------------------------------------------------------------------
--		Hero: Marci
--		Perk: Targeting allies with abilities gives Marci and the ally +20 DMG and MS for 7 seconds. Stacks decay independently.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_marci_perk = modifier_npc_dota_hero_marci_perk or class({})

function modifier_npc_dota_hero_marci_perk:IsPassive()
	return true
end

function modifier_npc_dota_hero_marci_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_marci_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_marci_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_marci_perk:GetTexture()
	return "marci_grapple"
end

function modifier_npc_dota_hero_marci_perk:OnCreated()
	
end
