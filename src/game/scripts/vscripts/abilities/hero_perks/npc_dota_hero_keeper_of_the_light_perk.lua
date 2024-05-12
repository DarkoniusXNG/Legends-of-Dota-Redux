--------------------------------------------------------------------------------------------------------
--		Hero: KOTL
--		Perk: Aether Range free ability
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_keeper_of_the_light_perk = modifier_npc_dota_hero_keeper_of_the_light_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_keeper_of_the_light_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_keeper_of_the_light_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_keeper_of_the_light_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_keeper_of_the_light_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_keeper_of_the_light_perk:GetTexture()
	return "custom/npc_dota_hero_keeper_of_the_light_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_keeper_of_the_light_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local kotl = caster:FindAbilityByName("aether_range_lod")

        if kotl then
            kotl:UpgradeAbility(false)
        else
            kotl = caster:AddAbility("aether_range_lod")
			--kotl:SetStolen(true)
            kotl:SetActivated(true)
            kotl:SetLevel(1)
        end
    end
end
