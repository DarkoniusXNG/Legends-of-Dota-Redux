--------------------------------------------------------------------------------------------------------
--		Hero: Chaos Knight
--		Perk: Chaos Strike free ability + CK illusions do bonus damage
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

function modifier_npc_dota_hero_chaos_knight_perk:OnCreated()
	if IsServer() and not self:GetParent():IsIllusion() then
		local caster = self:GetParent()
		local bonus_ability = caster:FindAbilityByName("chaos_knight_chaos_strike")
		if bonus_ability then
			bonus_ability:UpgradeAbility(false)
		else
			bonus_ability = caster:AddAbility("chaos_knight_chaos_strike")
			--bonus_ability:SetStolen(true)
			bonus_ability:SetActivated(true)
			bonus_ability:SetLevel(1)
		end
		self.apply_to_illusions = true
	end
end

function modifier_npc_dota_hero_chaos_knight_perk:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE,
    }
end

function modifier_npc_dota_hero_chaos_knight_perk:GetModifierTotalDamageOutgoing_Percentage()
    if self:GetParent():IsIllusion() then
        return 25
    else 
        return 0
    end
end
