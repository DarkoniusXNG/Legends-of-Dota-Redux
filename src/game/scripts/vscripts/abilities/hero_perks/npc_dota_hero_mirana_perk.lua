--------------------------------------------------------------------------------------------------------
--    Hero: Mirana
--    Perk: When Mirana casts Skillshots, they will have 50% mana refunded and cooldowns reduced by 25%.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_mirana_perk = modifier_npc_dota_hero_mirana_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mirana_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mirana_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mirana_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mirana_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_mirana_perk:GetTexture()
	return "custom/npc_dota_hero_mirana_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_mirana_perk:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end

if IsServer() then
	function modifier_npc_dota_hero_mirana_perk:OnAbilityFullyCast(keys)
		local manaRefund = 50
		local cooldownReduction = 25

		manaRefund = 1 - (manaRefund * 0.01)
		cooldownReduction = 1 - (cooldownReduction * 0.01)

		if keys.ability:HasAbilityFlag("skillshot") and keys.unit == self:GetParent() then
			local cooldown = keys.ability:GetCooldownTimeRemaining()
			keys.ability:EndCooldown()
			keys.ability:StartCooldown(cooldown*cooldownReduction)
			self:GetParent():GiveMana(keys.ability:GetManaCost(keys.ability:GetLevel()-1)*manaRefund)
		end
	end
end
