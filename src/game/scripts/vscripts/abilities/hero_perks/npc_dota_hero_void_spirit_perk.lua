--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_void_spirit_perk = modifier_npc_dota_hero_void_spirit_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_void_spirit_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_void_spirit_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_void_spirit_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_void_spirit_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_void_spirit_perk:GetTexture()
	return "custom/npc_dota_hero_void_spirit_perk"
end

function modifier_npc_dota_hero_void_spirit_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local bonus_ability = caster:FindAbilityByName("black_drake_magic_amplification_aura")

		if bonus_ability then
			bonus_ability:UpgradeAbility(false)
		else
			bonus_ability = caster:AddAbility("black_drake_magic_amplification_aura")
			--bonus_ability:SetStolen(true)
			bonus_ability:SetActivated(true)
			bonus_ability:SetLevel(1)
			bonus_ability:SetHidden(false)
		end
	end
end
