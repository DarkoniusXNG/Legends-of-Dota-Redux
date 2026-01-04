--------------------------------------------------------------------------------------------------------
--		Hero: Spectre
--		Perk: Desolate free ability
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_spectre_perk = modifier_npc_dota_hero_spectre_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_spectre_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_spectre_perk:GetTexture()
	return "custom/npc_dota_hero_spectre_perk"
end

function modifier_npc_dota_hero_spectre_perk:OnCreated()
	if IsServer() then
        local caster = self:GetCaster()
        local bonus_ability = caster:FindAbilityByName("spectre_dispersion")

        if bonus_ability then
            bonus_ability:UpgradeAbility(false)
        else 
            bonus_ability = caster:AddAbility("spectre_dispersion")
            --bonus_ability:SetStolen(true)
            bonus_ability:SetActivated(true)
            bonus_ability:SetLevel(1)
        end
    end
end

