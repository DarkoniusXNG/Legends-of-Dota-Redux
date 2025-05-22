--------------------------------------------------------------------------------------------------------
--		Hero: Kez
--		Perk: Blade abilities cast by Kez will have reduced cooldown and mana cost.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_kez_perk = modifier_npc_dota_hero_kez_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_kez_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_kez_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_kez_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_kez_perk:RemoveOnDeath()
	return false
end

-- function modifier_npc_dota_hero_kez_perk:GetTexture()
	-- return "custom/npc_dota_hero_kez_perk"
-- end

function modifier_npc_dota_hero_kez_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
	}
end

function modifier_npc_dota_hero_kez_perk:GetModifierPercentageCooldown(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("blades") then
			return 25
		end
	end
	return 0
end

function modifier_npc_dota_hero_kez_perk:GetModifierPercentageManacostStacking(keys)
	local ability = keys.ability
	if ability then
		if ability:HasAbilityFlag("blades") then
			return 25
		end
	end
	return 0
end


