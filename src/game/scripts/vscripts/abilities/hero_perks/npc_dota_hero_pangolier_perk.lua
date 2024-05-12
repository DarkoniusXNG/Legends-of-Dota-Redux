--------------------------------------------------------------------------------------------------------
--		Hero: Pangolier
--		Perk: Heartpiercer free level
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_pangolier_perk = modifier_npc_dota_hero_pangolier_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pangolier_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pangolier_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_pangolier_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_pangolier_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_pangolier_perk:GetTexture()
	return "custom/npc_dota_hero_pangolier_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_pangolier_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local pango = caster:FindAbilityByName("pangolier_heartpiercer")

        if pango then
            pango:UpgradeAbility(false)
        else
            pango = caster:AddAbility("pangolier_heartpiercer")
            --pango:SetStolen(true)
            pango:SetActivated(true)
            pango:SetLevel(1)
        end
    end
end
