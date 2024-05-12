--------------------------------------------------------------------------------------------------------
--
--		Hero: Winter Wyvern
--		Perk: When Winter Wyvern's health and mana are above 75% she gains flying status after a 3 second delay.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_winter_wyvern_flight_delay", "abilities/hero_perks/npc_dota_hero_winter_wyvern_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_npc_dota_hero_winter_wyvern_flying", "abilities/hero_perks/npc_dota_hero_winter_wyvern_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_winter_wyvern_perk ~= "" then modifier_npc_dota_hero_winter_wyvern_perk = class({}) end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_winter_wyvern_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_winter_wyvern_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_winter_wyvern_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_winter_wyvern_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_winter_wyvern_perk:GetTexture()
	return "winter_wyvern_arctic_burn"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_winter_wyvern_perk:OnCreated()
	if not IsServer() then return end

	self:GetCaster().flying = false
	self.flightDelay = 3
	self:StartIntervalThink(0.1)
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_winter_wyvern_perk:OnIntervalThink()
	if not IsServer() then return end
	local caster = self:GetParent()
	local check = caster:GetHealthPercent() > 75 and caster:GetManaPercent() > 75

	if not check then caster.flying = false end

	if caster:HasModifier("modifier_npc_dota_hero_winter_wyvern_flying") and not check then
		GridNav:DestroyTreesAroundPoint(caster:GetAbsOrigin(), 300, true)
		caster:RemoveModifierByName("modifier_npc_dota_hero_winter_wyvern_flying")
	elseif caster:HasModifier("modifier_npc_dota_hero_winter_wyvern_flight_delay") and not check then
		caster:RemoveModifierByName("modifier_npc_dota_hero_winter_wyvern_flight_delay")
	elseif not caster.flying and check then
		caster:AddNewModifier(caster, nil, "modifier_npc_dota_hero_winter_wyvern_flight_delay", {duration = self.flightDelay})
		caster.flying = true
	end
end
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_winter_wyvern_flight_delay ~= "" then modifier_npc_dota_hero_winter_wyvern_flight_delay = class({}) end
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_winter_wyvern_flight_delay:IsHidden()
	return false
end

function modifier_npc_dota_hero_winter_wyvern_flight_delay:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_winter_wyvern_flight_delay:GetTexture()
	return "winter_wyvern_arctic_burn"
end
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_winter_wyvern_flight_delay:OnDestroy()
	if not IsServer() then return end
	local caster = self:GetCaster()
	if caster.flying then
		caster:AddNewModifier(caster, nil, "modifier_npc_dota_hero_winter_wyvern_flying", {})
	end 
end
--------------------------------------------------------------------------------------------------------
if modifier_npc_dota_hero_winter_wyvern_flying ~= "" then modifier_npc_dota_hero_winter_wyvern_flying = class({}) end
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_winter_wyvern_flying:GetTexture()
	return "winter_wyvern_arctic_burn"
end
function modifier_npc_dota_hero_winter_wyvern_flying:CheckState()
	local states = {
		[MODIFIER_STATE_FLYING] = true,
	}
	return states
end
