--------------------------------------------------------------------------------------------------------
--      Hero: Monkey King
--      Perk: Jingu Mastery free level
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_monkey_king_perk = modifier_npc_dota_hero_monkey_king_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_monkey_king_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_monkey_king_perk:IsHidden()
    return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_monkey_king_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_monkey_king_perk:RemoveOnDeath()
    return false
end

function modifier_npc_dota_hero_monkey_king_perk:GetTexture()
	return "custom/npc_dota_hero_monkey_king_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_monkey_king_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
		local jingu = caster:FindAbilityByName("monkey_king_jingu_mastery")

        if jingu then
            jingu:UpgradeAbility(false)
        else
            jingu = caster:AddAbility("monkey_king_jingu_mastery")
            --jingu:SetStolen(true)
            jingu:SetActivated(true)
            jingu:SetLevel(1)
        end
    end
end
