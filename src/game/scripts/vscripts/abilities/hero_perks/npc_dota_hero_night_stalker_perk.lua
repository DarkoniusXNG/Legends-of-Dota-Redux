--------------------------------------------------------------------------------------------------------
--		Hero: Night Stalker
--		Perk: Hunter in the Night free ability
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_night_stalker_perk = modifier_npc_dota_hero_night_stalker_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_night_stalker_perk:IsPassive()
	return true
end

function modifier_npc_dota_hero_night_stalker_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_night_stalker_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_night_stalker_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_night_stalker_perk:GetTexture()
	return "custom/npc_dota_hero_night_stalker_perk"
end

function modifier_npc_dota_hero_night_stalker_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local bonus_ability = caster:FindAbilityByName("night_stalker_hunter_in_the_night")

        if bonus_ability then
            bonus_ability:UpgradeAbility(false)
        else
            bonus_ability = caster:AddAbility("night_stalker_hunter_in_the_night")
            --bonus_ability:SetStolen(true)
            bonus_ability:SetActivated(true)
            bonus_ability:SetLevel(1)
        end
    end
end
