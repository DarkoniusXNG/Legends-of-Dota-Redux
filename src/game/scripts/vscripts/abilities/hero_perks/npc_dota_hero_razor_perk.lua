--------------------------------------------------------------------------------------------------------
--		Hero: Razor
--		Perk: Razor gains cooldown reduction and mana cost reduction for all abilities and items while Razor is Static Linked to an enemy.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_razor_perk = modifier_npc_dota_hero_razor_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_razor_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_razor_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_razor_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_razor_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_razor_perk:GetTexture()
	return "custom/npc_dota_hero_razor_perk"
end

function modifier_npc_dota_hero_razor_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_npc_dota_hero_razor_perk:GetModifierPercentageCooldown(keys)
	local parent = self:GetParent()
	if parent:HasModifier("modifier_razor_static_link") then
		return 25
	end
	return 0
end

function modifier_npc_dota_hero_razor_perk:GetModifierPercentageManacostStacking(keys)
	local parent = self:GetParent()
	if parent:HasModifier("modifier_razor_static_link") then
		return 25
	end
	return 0
end
