--------------------------------------------------------------------------------------------------------
--		Hero: Muerta
--		Perk: Bonus spell amp while ethereal
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_muerta_perk = modifier_npc_dota_hero_muerta_perk or class({})

function modifier_npc_dota_hero_muerta_perk:IsPassive()
	return true
end

function modifier_npc_dota_hero_muerta_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_muerta_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_muerta_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_muerta_perk:GetTexture()
	return "muerta_pierce_the_veil"
end

function modifier_npc_dota_hero_muerta_perk:OnCreated()
	
end
