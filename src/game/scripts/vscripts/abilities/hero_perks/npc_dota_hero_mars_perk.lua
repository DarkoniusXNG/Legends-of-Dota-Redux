--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_mars_perk = modifier_npc_dota_hero_mars_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mars_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mars_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mars_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mars_perk:RemoveOnDeath()
	return false
end

-- function modifier_npc_dota_hero_mars_perk:GetTexture()
	-- return "custom/npc_dota_hero_mars_perk"
-- end

function modifier_npc_dota_hero_mars_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local bonus_ability = caster:FindAbilityByName("mars_bulwark")

        if bonus_ability then
            bonus_ability:UpgradeAbility(false)
        else
            bonus_ability = caster:AddAbility("mars_bulwark")
            --bonus_ability:SetStolen(true)
            bonus_ability:SetActivated(true)
            bonus_ability:SetLevel(1)
        end
    end
end
