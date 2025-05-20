--------------------------------------------------------------------------------------------------------
--      Hero: Ringmaster
--      Perk: Ringmaster gains cast range, max mana and spell amp permanently each time he damages an enemy hero with a Skillshot ability. Enemy needs to be at least 450 range away from Ringmaster to gain a stack.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_ringmaster_perk = modifier_npc_dota_hero_ringmaster_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ringmaster_perk:IsPassive()
    return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ringmaster_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ringmaster_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_ringmaster_perk:RemoveOnDeath()
    return false
end

-- function modifier_npc_dota_hero_ringmaster_perk:GetTexture()
	-- return "custom/npc_dota_hero_ringmaster_perk"
-- end

function modifier_npc_dota_hero_ringmaster_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_CAST_RANGE_BONUS_STACKING,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

function modifier_npc_dota_hero_ringmaster_perk:GetModifierManaBonus()
	return self:GetStackCount()
end

function modifier_npc_dota_hero_ringmaster_perk:GetModifierCastRangeBonusStacking()
	return self:GetStackCount()
end

function modifier_npc_dota_hero_ringmaster_perk:GetModifierSpellAmplify_Percentage()
	return self:GetStackCount() * 0.01
end

if IsServer() then
	function modifier_npc_dota_hero_ringmaster_perk:OnTakeDamage(event)
		local attacker = event.attacker
		local inflictor = event.inflictor
		local victim = event.unit

		if not attacker or attacker:IsNull() or not inflictor or not victim or victim:IsNull() then
			return
		end

		local parent = self:GetParent()

		if attacker ~= parent then
			return
		end

		if inflictor:HasAbilityFlag("skillshot") and victim:IsRealHero() then
			local parent_loc = parent:GetAbsOrigin()
			local victim_loc = victim:GetAbsOrigin()
			local distance = (parent_loc - victim_loc):Length2D()
			if distance > 550 then
				self:IncrementStackCount()
				parent:CalculateStatBonus(true)
			end
		end
	end
end
