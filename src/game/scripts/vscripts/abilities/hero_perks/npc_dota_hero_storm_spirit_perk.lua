--------------------------------------------------------------------------------------------------------
--    Hero: Storm Spirit
--    Perk: Mana Aura free ability
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_storm_spirit_perk = modifier_npc_dota_hero_storm_spirit_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:IsPassive()
  return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:IsHidden()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:RemoveOnDeath()
  return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_storm_spirit_perk:IsPurgable()
  return false
end

function modifier_npc_dota_hero_storm_spirit_perk:GetTexture()
	return "custom/npc_dota_hero_storm_spirit_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_storm_spirit_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local mana_aura = caster:FindAbilityByName("forest_troll_high_priest_mana_aura")

		if mana_aura then
			mana_aura:UpgradeAbility(false)
		else
			mana_aura = caster:AddAbility("forest_troll_high_priest_mana_aura")
			--mana_aura:SetStolen(true)
			mana_aura:SetActivated(true)
			mana_aura:SetLevel(1)
		end
	end
end
