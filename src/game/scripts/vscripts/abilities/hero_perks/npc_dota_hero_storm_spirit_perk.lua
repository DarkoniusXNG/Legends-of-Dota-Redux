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

function modifier_npc_dota_hero_storm_spirit_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local bonus_ability = caster:FindAbilityByName("forest_troll_high_priest_mana_aura")

		if bonus_ability then
			bonus_ability:UpgradeAbility(false)
		else
			bonus_ability = caster:AddAbility("forest_troll_high_priest_mana_aura")
			--bonus_ability:SetStolen(true)
			bonus_ability:SetActivated(true)
			bonus_ability:SetLevel(1)
		end
	end
end
