--------------------------------------------------------------------------------------------------------
--		Hero: Leshrac
--		Perk: Octarine Vampirism free ability
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_leshrac_perk = modifier_npc_dota_hero_leshrac_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_leshrac_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_leshrac_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_leshrac_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_leshrac_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_leshrac_perk:GetTexture()
	return "custom/npc_dota_hero_leshrac_perk"
end

function modifier_npc_dota_hero_leshrac_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local bonus_ability = caster:FindAbilityByName("octarine_vampirism_lod")

        if bonus_ability then
            bonus_ability:UpgradeAbility(false)
        else 
            bonus_ability = caster:AddAbility("octarine_vampirism_lod")
            --bonus_ability:SetStolen(true)
            bonus_ability:SetActivated(true)
            bonus_ability:SetLevel(1)
        end
    end
end
