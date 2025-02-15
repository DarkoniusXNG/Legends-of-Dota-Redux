--------------------------------------------------------------------------------------------------------
--		Hero: Puck
--		Perk: Puck does 25% more damage with Mobility abilities and non-Mobility abilities have reduced cooldown by 10%.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_puck_perk = modifier_npc_dota_hero_puck_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_puck_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_puck_perk:GetTexture()
	return "custom/npc_dota_hero_puck_perk"
end

function modifier_npc_dota_hero_puck_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
	}
end

if IsServer() then
	function modifier_npc_dota_hero_puck_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
		local ability = keys.inflictor
		if not ability or ability:IsNull() then
			return 0
		end
		if ability:HasAbilityFlag("mobility") then
			return 25
		end
		return 0
	end

	function modifier_npc_dota_hero_puck_perk:GetModifierPercentageCooldown(keys)
		local ability = keys.ability
		if ability then
			if not ability:HasAbilityFlag("mobility") then
				return 10
			end
		else
			return 0
		end
		return 0
	end
end

