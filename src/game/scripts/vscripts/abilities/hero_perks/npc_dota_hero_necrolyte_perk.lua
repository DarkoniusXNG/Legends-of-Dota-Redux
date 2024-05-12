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
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_necrolyte_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local necro = caster:FindAbilityByName("necrolyte_heartstopper_aura")

        if necro then
            necro:UpgradeAbility(false)
        else 
            necro = caster:AddAbility("necrolyte_heartstopper_aura")
            --necro:SetStolen(true)
            necro:SetActivated(true)
            necro:SetLevel(1)
        end
    end
end
