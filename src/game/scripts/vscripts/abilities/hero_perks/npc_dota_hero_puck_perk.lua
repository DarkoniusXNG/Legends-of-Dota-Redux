--------------------------------------------------------------------------------------------------------
--		Hero: Puck
--		Perk: Time Warp Aura free ability
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_puck_perk = modifier_npc_dota_hero_puck_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_puck_perk:GetTexture()
	return "custom/npc_dota_hero_puck_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local time_warp_aura = caster:FindAbilityByName("frostbitten_golem_time_warp_aura")

        if time_warp_aura then
            time_warp_aura:UpgradeAbility(false)
        else
            time_warp_aura = caster:AddAbility("frostbitten_golem_time_warp_aura")
            time_warp_aura:SetActivated(true)
            time_warp_aura:SetLevel(1)
        end
    end
end
