--------------------------------------------------------------------------------------------------------
--    Hero: Alchemist
--    Perk: Greevils Greed free level + 50% refund for consuming an item
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_alchemist_perk = modifier_npc_dota_hero_alchemist_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:IsPurgable()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:RemoveOnDeath()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_alchemist_perk:GetTexture()
  return "custom/npc_dota_hero_alchemist_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_alchemist_perk:OnCreated()
    if IsServer() then
        local caster = self:GetCaster()
        local alch = caster:FindAbilityByName("alchemist_goblins_greed")

        if alch then
            alch:UpgradeAbility(false)
        else 
            alch = caster:AddAbility("alchemist_goblins_greed")
            --alch:SetStolen(true)
            alch:SetActivated(true)
            alch:SetLevel(1)
        end
    end
end

function modifier_npc_dota_hero_alchemist_perk:DeclareFunctions()
    return {
        MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
    }
end

function modifier_npc_dota_hero_alchemist_perk:OnAbilityFullyCast(params)
    if params.unit == self:GetParent() then
        local item = params.ability
        if item:IsItem() and item:GetAbilityName() == "item_ultimate_scepter" or item:GetAbilityName() == "item_moon_shard" or string.find(item:GetAbilityName(),"consumable") then
            self:GetParent():ModifyGold( item:GetGoldCost(-1) * 0.5, true, 0 ) 
        end
    end
end
