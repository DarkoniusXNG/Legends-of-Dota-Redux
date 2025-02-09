--------------------------------------------------------------------------------------------------------
--		Hero: Brewmaster
--		Perk: Brewmaster gains a free level of Drunken Brawler, whether he has it or not.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_brewmaster_perk = modifier_npc_dota_hero_brewmaster_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_brewmaster_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_brewmaster_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_brewmaster_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_brewmaster_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_brewmaster_perk:GetTexture()
	return "custom/npc_dota_hero_brewmaster_perk"
end

function modifier_npc_dota_hero_brewmaster_perk:OnCreated()
	if IsServer() then
		local caster = self:GetParent()
		local bonus_ability = caster:FindAbilityByName("brewmaster_drunken_brawler")

		if bonus_ability then
			bonus_ability:UpgradeAbility(false)
		else
			bonus_ability = caster:AddAbility("brewmaster_drunken_brawler")
			--bonus_ability:SetStolen(true)
			bonus_ability:SetActivated(true)
			bonus_ability:SetLevel(1)
		end
	end
end

