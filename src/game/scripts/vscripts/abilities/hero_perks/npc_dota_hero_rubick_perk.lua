--------------------------------------------------------------------------------------------------------
--		Hero: Rubick
--		Perk: Null Field free level
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_rubick_perk = modifier_npc_dota_hero_rubick_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rubick_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rubick_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rubick_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rubick_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_rubick_perk:GetTexture()
	return "custom/npc_dota_hero_rubick_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_rubick_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local nullField = caster:FindAbilityByName("rubick_null_field")

        if nullField then
            nullField:UpgradeAbility(false)
        else
            nullField = caster:AddAbility("rubick_null_field")
            --nullField:SetStolen(true)
            nullField:SetActivated(true)
            nullField:SetLevel(1)
        end
    end
end
--------------------------------------------------------------------------------------------------------
