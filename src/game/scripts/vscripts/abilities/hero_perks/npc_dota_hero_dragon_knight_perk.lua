--------------------------------------------------------------------------------------------------------
--
--		Hero: Dragon Knight
--		Perk: While Dragon Knight is in Elder Dragon Form, all of Dragon Knight's abilities apply Dragon Form debuffs. This includes towers.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_dragon_knight_perk", "abilities/hero_perks/npc_dota_hero_dragon_knight_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
npc_dota_hero_dragon_knight_perk = npc_dota_hero_dragon_knight_perk or class({})

function npc_dota_hero_dragon_knight_perk:GetIntrinsicModifierName()
    return "modifier_npc_dota_hero_dragon_knight_perk"
end

--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_dragon_knight_perk				
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_dragon_knight_perk = modifier_npc_dota_hero_dragon_knight_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_dragon_knight_perk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

-- Spells that do damage will trigger this
function modifier_npc_dota_hero_dragon_knight_perk:OnTakeDamage(event)
	local parent = self:GetParent()
	local attacker = event.attacker
	local damaged_unit = event.unit

	-- Check if attacker exists
	if not attacker or attacker:IsNull() then
		return
	end

	-- Check if attacker has this modifier
	if parent ~= attacker then
		return
	end

	-- Check if damaged unit has this modifier
	if damaged_unit ~= caster then
		return
	end

	-- Check if damaged unit is something weird
	if damaged_unit.GetTeamNumber == nil or damaged_unit.AddNewModifier == nil then
		return
	end
	
	-- Check if self damage or allied damage
	if parent == damaged_unit or parent:GetTeamNumber() == damaged_unit:GetTeamNumber() then
		return
	end

	-- Check if attacker has Elder Dragon Form ability
	local dragonForm = parent:FindAbilityByName("dragon_knight_elder_dragon_form")
	if not dragonForm then
		return
	end
	
	local inflictor = event.inflictor
	if inflictor ~= dragonForm then
		if parent:HasModifier("modifier_dragon_knight_corrosive_breath") then
			local duration = dragonForm:GetSpecialValueFor("corrosive_breath_duration")
			damaged_unit:AddNewModifier(parent, dragonForm, "modifier_dragon_knight_corrosive_breath_dot", {duration = duration})
		end
		if parent:HasModifier("modifier_dragon_knight_frost_breath") then
			local duration = dragonForm:GetSpecialValueFor("frost_duration")
			damaged_unit:AddNewModifier(parent, dragonForm, "modifier_dragon_knight_frost_breath_slow", {duration = duration})
		end
	end
end

-- Spells that apply modifiers will trigger this
function PerkDragonKnight(filterTable)
	local parent_index = filterTable["entindex_parent_const"]
  	local caster_index = filterTable["entindex_caster_const"]
  	local ability_index = filterTable["entindex_ability_const"]
  	if not parent_index or not caster_index or not ability_index then
      	return true
  	end
  	local parent = EntIndexToHScript( parent_index )
  	local caster = EntIndexToHScript( caster_index )
  	local ability = EntIndexToHScript( ability_index )
	if parent:GetTeamNumber() == caster:GetTeamNumber() then return end
	if ability then
    	if caster:GetUnitName() == "npc_dota_hero_dragon_knight" then
		    local dragonForm = caster:FindAbilityByName("dragon_knight_elder_dragon_form")
		    if dragonForm and dragonForm ~= ability then
			    if caster:HasModifier("modifier_dragon_knight_corrosive_breath") then
				  	local duration = dragonForm:GetSpecialValueFor("corrosive_breath_duration")
				  	parent:AddNewModifier(caster, dragonForm, "modifier_dragon_knight_corrosive_breath_dot", {duration = duration})
			    end
			    if caster:HasModifier("modifier_dragon_knight_frost_breath") then
				    local duration = dragonForm:GetSpecialValueFor("frost_duration")
				    parent:AddNewModifier(caster, dragonForm, "modifier_dragon_knight_frost_breath_slow", {duration = duration})
			    end
    		end
    	end
	end
  end
