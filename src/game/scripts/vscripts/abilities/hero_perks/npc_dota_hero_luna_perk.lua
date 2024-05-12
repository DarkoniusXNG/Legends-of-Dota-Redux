--------------------------------------------------------------------------------------------------------
--		Hero: Luna
--		Perk: Luna gains 1 free level of Lunar Blessing, whether she has it or not. 
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_luna_perk = modifier_npc_dota_hero_luna_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:RemoveOnDeath()
    return false
end

function modifier_npc_dota_hero_luna_perk:GetTexture()
	return "custom/npc_dota_hero_luna_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local blessing = caster:FindAbilityByName("luna_lunar_blessing")

        if blessing then
            blessing:UpgradeAbility(false)
        else 
            blessing = caster:AddAbility("luna_lunar_blessing")
            --blessing:SetStolen(true)
            blessing:SetActivated(true)
            blessing:SetLevel(1)
        end
    end
end
