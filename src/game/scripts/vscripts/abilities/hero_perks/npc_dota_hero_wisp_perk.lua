--------------------------------------------------------------------------------------------------------
--		Hero: Wisp
--		Perk: Essence Aura 2 free levels
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_wisp_perk = modifier_npc_dota_hero_wisp_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_wisp_perk:GetTexture()
	return "wisp_spirits"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_wisp_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local essense = caster:FindAbilityByName("obsidian_destroyer_essence_aura_lod")

        if essense then
            essense:UpgradeAbility(false)
			--essense:SetLevel(2)
        else 
            essense = caster:AddAbility("obsidian_destroyer_essence_aura_lod")
            --essense:SetStolen(true)
            essense:SetActivated(true)
            essense:SetLevel(2)
        end
    end
end
