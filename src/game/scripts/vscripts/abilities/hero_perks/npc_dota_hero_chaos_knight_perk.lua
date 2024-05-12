--------------------------------------------------------------------------------------------------------
--		Hero: Chaos Knight
--		Perk: Cripple free ability
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_chaos_knight_perk = modifier_npc_dota_hero_chaos_knight_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chaos_knight_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chaos_knight_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chaos_knight_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_chaos_knight_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_chaos_knight_perk:GetTexture()
	return "custom/npc_dota_hero_chaos_knight_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_chaos_knight_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local ab = caster:FindAbilityByName("lycan_summon_wolves_critical_strike")
		if ab then
			ab:UpgradeAbility(false)
			--ab:SetLevel(1)
		else
			ab = caster:AddAbility("lycan_summon_wolves_critical_strike")
            --ab:SetStolen(true)
            ab:SetActivated(true)
            ab:SetLevel(1)
		end
	end
end
