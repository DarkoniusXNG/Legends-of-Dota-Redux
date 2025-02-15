--------------------------------------------------------------------------------------------------------
--		Hero: Pangolier
--		Perk: Heartpiercer free level
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_pangolier_perk = modifier_npc_dota_hero_pangolier_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pangolier_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pangolier_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_pangolier_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pangolier_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_pangolier_perk:GetTexture()
	return "custom/npc_dota_hero_pangolier_perk"
end

function modifier_npc_dota_hero_pangolier_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local bonus_ability = caster:FindAbilityByName("pangolier_heartpiercer_old")

        if bonus_ability then
            bonus_ability:UpgradeAbility(false)
        else
            bonus_ability = caster:AddAbility("pangolier_heartpiercer_old")
            --bonus_ability:SetStolen(true)
            bonus_ability:SetActivated(true)
            bonus_ability:SetLevel(1)
        end
    end
end
