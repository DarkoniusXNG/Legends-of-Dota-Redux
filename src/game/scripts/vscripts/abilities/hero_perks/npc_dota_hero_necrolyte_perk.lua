--------------------------------------------------------------------------------------------------------
--		Hero: Necrolyte
--		Perk: HeartStopper Aura free level
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_necrolyte_perk = modifier_npc_dota_hero_necrolyte_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_necrolyte_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_necrolyte_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_necrolyte_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_necrolyte_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_necrolyte_perk:GetTexture()
	return "custom/npc_dota_hero_necrolyte_perk"
end

function modifier_npc_dota_hero_necrolyte_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local bonus_ability = caster:FindAbilityByName("necrolyte_heartstopper_aura")

        if bonus_ability then
            bonus_ability:UpgradeAbility(false)
        else 
            bonus_ability = caster:AddAbility("necrolyte_heartstopper_aura")
            --bonus_ability:SetStolen(true)
            bonus_ability:SetActivated(true)
            bonus_ability:SetLevel(1)
        end
    end
end
