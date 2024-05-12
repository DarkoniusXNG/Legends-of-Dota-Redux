--------------------------------------------------------------------------------------------------------
--		Hero: Vengeful Spirit
--		Perk: Vengeance Aura free level
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_vengefulspirit_perk = modifier_npc_dota_hero_vengefulspirit_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:GetTexture()
	return "custom/npc_dota_hero_vengefulspirit_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_vengefulspirit_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_vengefulspirit_perk:OnCreated(keys)
    if IsServer() then
        local caster = self:GetCaster()
        local aura = caster:FindAbilityByName("vengefulspirit_command_aura")

        if aura then
            aura:UpgradeAbility(false)
        else
            aura = caster:AddAbility("vengefulspirit_command_aura")
            --aura:SetStolen(true)
            aura:SetActivated(true)
            aura:SetLevel(1)
        end
    end
end
