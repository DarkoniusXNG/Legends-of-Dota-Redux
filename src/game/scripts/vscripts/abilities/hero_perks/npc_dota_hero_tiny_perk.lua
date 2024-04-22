--------------------------------------------------------------------------------------------------------
--
--		Hero: Tiny
--		Perk: Casting an ability that targetted a tree gives 5% tenacity, stacks diminishingly
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_tiny_perk", "abilities/hero_perks/npc_dota_hero_tiny_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
npc_dota_hero_tiny_perk = npc_dota_hero_tiny_perk or class({})
--------------------------------------------------------------------------------------------------------
--		Modifier: modifier_npc_dota_hero_tiny_perk				
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_tiny_perk = modifier_npc_dota_hero_tiny_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tiny_perk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
	return funcs
end

if IsServer() then
	function modifier_npc_dota_hero_tiny_perk:OnAbilityFullyCast(params)
		self.tenacity = 50
		local tenacityDuration = 60
		if params.unit == self:GetParent() then
			if params.target and params.target.IsStanding then
				self:IncrementStackCount()
				if not self.started then
					self:StartIntervalThink(tenacityDuration)
					self.started = true
				end
			end
		end
	end
end

function modifier_npc_dota_hero_tiny_perk:GetTenacity()
	local n = 1 - (self.tenacity / 100)
	return n^self:GetStackCount()
end

function modifier_npc_dota_hero_tiny_perk:OnIntervalThink()
	if self:GetStackCount() > 0 then
		self:DecrementStackCount()
	else
		self:StartIntervalThink(-1)
		self.started = false
	end
end
