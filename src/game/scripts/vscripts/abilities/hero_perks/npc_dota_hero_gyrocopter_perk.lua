--------------------------------------------------------------------------------------------------------
--		Hero: Gyrocopter
--		Perk: Side Gunner free level
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_gyrocopter_perk = modifier_npc_dota_hero_gyrocopter_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_gyrocopter_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_gyrocopter_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_gyrocopter_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_gyrocopter_perk:GetTexture()
	return "custom/npc_dota_hero_gyrocopter_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_gyrocopter_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_gyrocopter_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local gunner = caster:FindAbilityByName("side_gunner_redux")

        if gunner then
            gunner:UpgradeAbility(false)
        else 
            gunner = caster:AddAbility("side_gunner_redux")
            --gunner:SetStolen(true)
            gunner:SetActivated(true)
            gunner:SetLevel(1)
        end
    end
end
