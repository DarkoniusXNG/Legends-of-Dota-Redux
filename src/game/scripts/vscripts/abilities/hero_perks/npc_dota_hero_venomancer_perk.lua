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

---------------------------------------------------------------------------------------------------
-- Does not trigger on re-apply / refresh!
function perkVenomancer(filterTable)
	local parent_index = filterTable["entindex_parent_const"]
	local caster_index = filterTable["entindex_caster_const"]
	local ability_index = filterTable["entindex_ability_const"]
	if not parent_index or not caster_index or not ability_index then
		return
	end
	local parent = EntIndexToHScript( parent_index )
	local caster = EntIndexToHScript( caster_index )
	if parent:GetTeamNumber() == caster:GetTeamNumber() then return end
	local ability = EntIndexToHScript( ability_index )
	if ability then
		if caster:HasModifier("modifier_npc_dota_hero_venomancer_perk") and ability:HasAbilityFlag("poison") and filterTable["duration"] > 0 then
			local modifierDuration = filterTable["duration"]
			local newDuration = modifierDuration + (modifierDuration * 40/100)
			filterTable["duration"] = newDuration
		end
	end
end
