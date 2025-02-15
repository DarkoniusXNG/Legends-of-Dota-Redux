--------------------------------------------------------------------------------------------------------
--		Hero: Sven
--		Perk: Great Cleave free ability
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_sven_perk = modifier_npc_dota_hero_sven_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sven_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sven_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_sven_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sven_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_sven_perk:GetTexture()
	return "custom/npc_dota_hero_sven_perk"
end

function modifier_npc_dota_hero_sven_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local bonus_ability = caster:FindAbilityByName("sven_great_cleave")

        if bonus_ability then
            bonus_ability:UpgradeAbility(false)
        else
            bonus_ability = caster:AddAbility("sven_great_cleave")
            --bonus_ability:SetStolen(true)
            bonus_ability:SetActivated(true)
            bonus_ability:SetLevel(1)
        end
    end
end
