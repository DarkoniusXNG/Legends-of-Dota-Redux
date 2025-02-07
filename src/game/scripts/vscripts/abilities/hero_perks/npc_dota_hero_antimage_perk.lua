--------------------------------------------------------------------------------------------------------
--
--		Hero: Antimage
--		Perk: After Anti-Mage blinks he will silence enemies within 250 radius for 2 seconds.
--
--------------------------------------------------------------------------------------------------------
LinkLuaModifier( "modifier_npc_dota_hero_antimage_silence", "abilities/hero_perks/npc_dota_hero_antimage_perk.lua" ,LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_antimage_perk = modifier_npc_dota_hero_antimage_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_antimage_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_antimage_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_antimage_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_antimage_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_antimage_perk:OnCreated()
	self.radius = 250
	self.duration = 2.5
end

function modifier_npc_dota_hero_antimage_perk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_EXECUTED,
	}
end

if IsServer() then
	function modifier_npc_dota_hero_antimage_perk:OnAbilityExecuted(params)
		local parent = self:GetParent()
		if params.unit ~= parent then return end
		local ability = params.ability -- For modifier icon
		if not ability or ability:IsNull() then return end
		if ability:HasAbilityFlag("blink") then
			local radius = self.radius
			local duration = self.duration
			Timers:CreateTimer(function()
				if not ability or ability:IsNull() then return end
				if not parent or parent:IsNull() then return end
				local pos = parent:GetAbsOrigin()
				local targets = FindUnitsInRadius(parent:GetTeamNumber(), pos, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false)
				for _, target in pairs(targets) do
					if target and not target:IsNull() then
						target:AddNewModifier(parent, ability, "modifier_npc_dota_hero_antimage_silence", {duration = duration})
					end
				end
			end)
		end
	end
end

modifier_npc_dota_hero_antimage_silence = modifier_npc_dota_hero_antimage_silence or class({})
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_antimage_silence:CheckState()
	return {
		[MODIFIER_STATE_SILENCED] = true,
	}
end

function modifier_npc_dota_hero_antimage_silence:GetEffectName()
	return "particles/generic_gameplay/generic_silence.vpcf"
end

function modifier_npc_dota_hero_antimage_silence:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end
