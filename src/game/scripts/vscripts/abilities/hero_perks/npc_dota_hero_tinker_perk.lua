--------------------------------------------------------------------------------------------------------
--		Hero: Tinker
--		Perk: Bonus damage with Scientific spells
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_tinker_perk = modifier_npc_dota_hero_tinker_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_tinker_perk:GetTexture()
	return "custom/npc_dota_hero_tinker_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
    }
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_tinker_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
    local ability = keys.inflictor
	if not ability then
		return 0
	end
	if ability:HasAbilityFlag("scientific") then
		return 25
	end
	return 0
end

-- function modifier_npc_dota_hero_tinker_perk:DeclareFunctions()
	-- local funcs = {
		-- MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	-- }
	-- return funcs
-- end


-- function modifier_npc_dota_hero_tinker_perk:OnAbilityFullyCast(params)
	-- if params.unit == self:GetParent() then
		-- if params.ability:HasAbilityFlag("refresh") or params.ability:GetAbilityName() == "item_refresher" or params.ability:GetAbilityName() == "item_refresher_shard" then
			-- params.unit:GiveMana(params.ability:GetManaCost(-1) * 0.5)
		-- end
	-- end
-- end

