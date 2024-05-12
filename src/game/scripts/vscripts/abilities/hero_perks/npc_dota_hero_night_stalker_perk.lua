--------------------------------------------------------------------------------------------------------
--		Hero: Night Stalker
--		Perk: Hunter in the Night free ability
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_night_stalker_perk = modifier_npc_dota_hero_night_stalker_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_night_stalker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_night_stalker_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_night_stalker_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_night_stalker_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_night_stalker_perk:GetTexture()
	return "custom/npc_dota_hero_night_stalker_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_night_stalker_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local night = caster:FindAbilityByName("night_stalker_hunter_in_the_night")

        if night then
            night:UpgradeAbility(false)
        else
            night = caster:AddAbility("night_stalker_hunter_in_the_night")
            --night:SetStolen(true)
            night:SetActivated(true)
            night:SetLevel(1)
        end
    end
end
