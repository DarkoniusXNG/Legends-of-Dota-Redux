--------------------------------------------------------------------------------------------------------
--		Hero: Gyrocopter
--		Perk: Side Gunner free ability
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

function modifier_npc_dota_hero_gyrocopter_perk:IsPurgable()
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

function modifier_npc_dota_hero_gyrocopter_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local bonus_ability = caster:FindAbilityByName("side_gunner_redux")

        if bonus_ability then
            bonus_ability:UpgradeAbility(false)
        else 
            bonus_ability = caster:AddAbility("side_gunner_redux")
            --bonus_ability:SetStolen(true)
            bonus_ability:SetActivated(true)
            bonus_ability:SetLevel(1)
        end
    end
end
