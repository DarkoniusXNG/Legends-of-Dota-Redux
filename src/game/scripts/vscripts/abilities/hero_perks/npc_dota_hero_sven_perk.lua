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
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sven_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_sven_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_sven_perk:GetTexture()
	return "custom/npc_dota_hero_sven_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_sven_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local cleave = caster:FindAbilityByName("sven_great_cleave")

        if cleave then
            cleave:UpgradeAbility(false)
        else
            cleave = caster:AddAbility("sven_great_cleave")
            --cleave:SetStolen(true)
            cleave:SetActivated(true)
            cleave:SetLevel(1)
        end
    end
end
