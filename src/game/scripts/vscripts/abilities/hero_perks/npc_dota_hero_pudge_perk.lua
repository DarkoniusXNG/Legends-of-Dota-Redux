--------------------------------------------------------------------------------------------------------
--		Hero: Pudge
--		Perk: vanilla Flesh Heap free level
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_pudge_perk = modifier_npc_dota_hero_pudge_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pudge_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pudge_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pudge_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pudge_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_pudge_perk:GetTexture()
	return "custom/npc_dota_hero_pudge_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_pudge_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local pudge = caster:FindAbilityByName("pudge_flesh_heap")

        if pudge then
            pudge:UpgradeAbility(false)
        else
            pudge = caster:AddAbility("pudge_flesh_heap")
            --pudge:SetStolen(true)
            pudge:SetActivated(true)
            pudge:SetLevel(1)
        end
    end
end
