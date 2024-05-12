--------------------------------------------------------------------------------------------------------
--      Hero: Shadow Fiend
--      Perk: Necromastery free level
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_nevermore_perk = modifier_npc_dota_hero_nevermore_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nevermore_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nevermore_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nevermore_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nevermore_perk:RemoveOnDeath()
    return false
end

function modifier_npc_dota_hero_nevermore_perk:GetTexture()
	return "custom/npc_dota_hero_nevermore_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_nevermore_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local necromastery = caster:FindAbilityByName("nevermore_necromastery")
		local necromasteryOP = caster:FindAbilityByName("nevermore_necromastery_op")

        if necromastery then
            necromastery:UpgradeAbility(false)
        elseif not necromasteryOP then
            necromastery = caster:AddAbility("nevermore_necromastery")
            --necromastery:SetStolen(true)
            necromastery:SetActivated(true)
            necromastery:SetLevel(1)
        end
    end
end
