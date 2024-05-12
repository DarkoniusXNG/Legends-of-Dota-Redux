--------------------------------------------------------------------------------------------------------
--		Hero: Venomancer
--		Perk: Increases the duration of all Poison effects Venomancer applies by 40%.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_venomancer_perk = modifier_npc_dota_hero_venomancer_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_venomancer_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_venomancer_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_venomancer_perk:IsPurgable()
	return false
end

function modifier_npc_dota_hero_venomancer_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_venomancer_perk:GetTexture()
	return "custom/npc_dota_hero_venomancer_perk"
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_venomancer_perk:OnCreated()
	if IsServer() then
		local poisonDurationBonusPct = 40
		self:GetCaster().poisonDurationBonus = poisonDurationBonusPct / 100
	end
end

--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function perkVenomancer(filterTable)
  local parent_index = filterTable["entindex_parent_const"]
  local caster_index = filterTable["entindex_caster_const"]
  local ability_index = filterTable["entindex_ability_const"]
  if not parent_index or not caster_index or not ability_index then
    return true
  end
  local parent = EntIndexToHScript( parent_index )
  local caster = EntIndexToHScript( caster_index )
  local ability = EntIndexToHScript( ability_index )
  if ability then
    if caster:HasModifier("modifier_npc_dota_hero_venomancer_perk") and ability:HasAbilityFlag("poison") and filterTable["duration"] ~= -1 then
        local modifierDuration = filterTable["duration"]
        local newDuration = modifierDuration + (modifierDuration * caster.poisonDurationBonus)
        filterTable["duration"] = newDuration
    end
  end
end
