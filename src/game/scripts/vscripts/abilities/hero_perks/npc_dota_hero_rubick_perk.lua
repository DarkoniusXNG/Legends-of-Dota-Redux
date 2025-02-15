--------------------------------------------------------------------------------------------------------
--		Hero: Rubick
--		Perk: Null Field free level
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_rubick_perk = modifier_npc_dota_hero_rubick_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rubick_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rubick_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rubick_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rubick_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_rubick_perk:GetTexture()
	return "custom/npc_dota_hero_rubick_perk"
end

function modifier_npc_dota_hero_rubick_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local bonus_ability = caster:FindAbilityByName("rubick_null_field")

        if bonus_ability then
            bonus_ability:UpgradeAbility(false)
        else
            bonus_ability = caster:AddAbility("rubick_null_field")
            --bonus_ability:SetStolen(true)
            bonus_ability:SetActivated(true)
            bonus_ability:SetLevel(1)
        end
    end
end
--------------------------------------------------------------------------------------------------------
