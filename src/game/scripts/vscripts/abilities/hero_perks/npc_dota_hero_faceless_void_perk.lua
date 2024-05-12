--------------------------------------------------------------------------------------------------------
--		Hero: Faceless Void
--		Perk: Time Lock free level
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_faceless_void_perk = modifier_npc_dota_hero_faceless_void_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_faceless_void_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_faceless_void_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_faceless_void_perk:IsHidden()
	return false
end

function modifier_npc_dota_hero_faceless_void_perk:RemoveOnDeath()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_faceless_void_perk:GetTexture()
	return "custom/npc_dota_hero_faceless_void_perk"
end
--------------------------------------------------------------------------------------------------------
-- Add additional functions
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_faceless_void_perk:OnCreated()
	if IsServer() then
		local caster = self:GetCaster()
		local fv = caster:FindAbilityByName("faceless_void_time_lock")

		if fv then
			fv:UpgradeAbility(false)
		else
			fv = caster:AddAbility("faceless_void_time_lock")
			--fv:SetStolen(true)
			fv:SetActivated(true)
			fv:SetLevel(1)
		end
	end
end
