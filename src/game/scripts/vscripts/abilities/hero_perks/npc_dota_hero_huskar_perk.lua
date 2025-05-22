--------------------------------------------------------------------------------------------------------
--		Hero: Huskar
--		Perk: Berserker's Blood free level + Bonus damage with Self Damaging spells
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_huskar_perk = modifier_npc_dota_hero_huskar_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_huskar_perk:IsPassive()
	return true
end

function modifier_npc_dota_hero_huskar_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_huskar_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_huskar_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_huskar_perk:GetTexture()
	return "custom/npc_dota_hero_huskar_perk"
end

function modifier_npc_dota_hero_huskar_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local bonus_ability = caster:FindAbilityByName("huskar_berserkers_blood")

		if bonus_ability then
			bonus_ability:UpgradeAbility(false)
		else 
			bonus_ability = caster:AddAbility("huskar_berserkers_blood")
			--bonus_ability:SetStolen(true)
			bonus_ability:SetActivated(true)
			bonus_ability:SetLevel(1)
		end
	end
end

function modifier_npc_dota_hero_huskar_perk:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end

if IsServer() then
	function modifier_npc_dota_hero_huskar_perk:GetModifierTotalDamageOutgoing_Percentage(keys)
		local ability = keys.inflictor
		if not ability or ability:IsNull() then
			return 0
		end
		if ability:HasAbilityFlag("self_damage") and keys.target ~= self:GetParent() then
			return 20
		end
		return 0
	end
end
