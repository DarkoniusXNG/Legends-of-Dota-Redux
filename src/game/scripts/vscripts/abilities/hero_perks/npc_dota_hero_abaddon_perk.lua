--------------------------------------------------------------------------------------------------------
--
--		Hero: Abaddon
--		27-7-18: Abaddon has a reduced cooldown on borrowed time
--		No longer used.
--		Old: For Abaddon, Mist Coil self-heals instead of damages and Aphotic Shield receives 2 charges.
--      Current: When Abaddon casts Borrowed Time, it lasts 33% longer.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_abaddon_perk", "abilities/hero_perks/npc_dota_hero_abaddon_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--LinkLuaModifier("modifier_charges", "abilities/modifiers/modifier_charges.lua", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------------------------------
npc_dota_hero_abaddon_perk = npc_dota_hero_abaddon_perk or class({})

function npc_dota_hero_abaddon_perk:GetIntrinsicModifierName()
    return "modifier_npc_dota_hero_abaddon_perk"
end
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_abaddon_perk				
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
	return false --self:GetCaster():HasModifier("modifier_charges")
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_abaddon_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
-- function modifier_npc_dota_hero_abaddon_perk:DeclareFunctions()
-- 	return {
		--MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	-- }
-- end

--[[function modifier_npc_dota_hero_abaddon_perk:OnIntervalThink()
	if not self.activated then
		local shield = self:GetParent():FindAbilityByName("abaddon_aphotic_shield")
		if shield and shield:GetLevel() > 0 then
			self:GetParent():AddNewModifier(self:GetParent(), shield, "modifier_charges",
				{
					max_count = 2,
					start_count = 1,
					replenish_time = shield:GetCooldown(-1)
				}
			)
			self.activated = true
		end
	end
end
]]

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
  		if caster:GetUnitName() == "npc_dota_hero_abaddon" then
      		if string.find(ability:GetAbilityName(),"borrowed_time") then
        		filterTable["duration"] = filterTable["duration"] * 1.33
      		end
    	end  
 	end
end
