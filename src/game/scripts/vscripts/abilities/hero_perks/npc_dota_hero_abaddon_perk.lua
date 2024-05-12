--------------------------------------------------------------------------------------------------------
--		Hero: Abaddon
--      Perk: When Abaddon casts Borrowed Time, it lasts 33% longer.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_abaddon_perk = modifier_npc_dota_hero_abaddon_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abaddon_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abaddon_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abaddon_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abaddon_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_abaddon_perk:GetTexture()
	return "custom/npc_dota_hero_abaddon_perk"
end

function PerkAbaddon(filterTable)
  	local parent_index = filterTable["entindex_parent_const"]
  	local caster_index = filterTable["entindex_caster_const"]
  	local ability_index = filterTable["entindex_ability_const"]
  	local modifier_name = filterTable["name_const"]
  	if not parent_index or not caster_index or not ability_index then
    	return true
  	end
  	local parent = EntIndexToHScript( parent_index )
  	local caster = EntIndexToHScript( caster_index )
  	local ability = EntIndexToHScript( ability_index )
  	if ability then
  		if caster:GetUnitName() == "npc_dota_hero_abaddon" and string.find(ability:GetAbilityName(), "borrowed_time") then
			filterTable["duration"] = filterTable["duration"] * 1.33
		end
	end
end
