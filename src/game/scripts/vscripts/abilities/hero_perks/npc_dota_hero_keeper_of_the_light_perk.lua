--------------------------------------------------------------------------------------------------------
--		Hero: KOTL
--		Perk: Aether Range free ability
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_keeper_of_the_light_perk = modifier_npc_dota_hero_keeper_of_the_light_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_keeper_of_the_light_perk:IsPassive()
	return true
end

function modifier_npc_dota_hero_keeper_of_the_light_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_keeper_of_the_light_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_keeper_of_the_light_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_keeper_of_the_light_perk:GetTexture()
	return "custom/npc_dota_hero_keeper_of_the_light_perk"
end

function modifier_npc_dota_hero_keeper_of_the_light_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local bonus_ability  = caster:FindAbilityByName("aether_range_lod")

		if bonus_ability  then
			bonus_ability :UpgradeAbility(false)
		else
			bonus_ability  = caster:AddAbility("aether_range_lod")
			--bonus_ability :SetStolen(true)
			bonus_ability :SetActivated(true)
			bonus_ability :SetLevel(1)
		end
	end
end
