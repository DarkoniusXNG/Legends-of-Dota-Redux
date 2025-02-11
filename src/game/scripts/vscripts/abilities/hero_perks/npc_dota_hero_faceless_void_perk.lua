--------------------------------------------------------------------------------------------------------
--		Hero: Faceless Void
--		Perk: Time Lock free ability
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_faceless_void_perk = modifier_npc_dota_hero_faceless_void_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_faceless_void_perk:IsPassive()
	return true
end

function modifier_npc_dota_hero_faceless_void_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_faceless_void_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_faceless_void_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_faceless_void_perk:GetTexture()
	return "custom/npc_dota_hero_faceless_void_perk"
end

function modifier_npc_dota_hero_faceless_void_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local bonus_ability = caster:FindAbilityByName("faceless_void_time_lock")

		if bonus_ability then
			bonus_ability:UpgradeAbility(false)
		else
			bonus_ability = caster:AddAbility("faceless_void_time_lock")
			--bonus_ability:SetStolen(true)
			bonus_ability:SetActivated(true)
			bonus_ability:SetLevel(1)
		end
	end
end
