--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_mars_perk ~= "" then modifier_npc_dota_hero_mars_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mars_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mars_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mars_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mars_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_mars_perk:GetTexture()
	return "custom/npc_dota_hero_mars_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_mars_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local mars = caster:FindAbilityByName("mars_bulwark")

        if mars then
            mars:UpgradeAbility(false)
        else
            mars = caster:AddAbility("mars_bulwark")
            --mars:SetStolen(true)
            mars:SetActivated(true)
            mars:SetLevel(1)
        end
    end
end
