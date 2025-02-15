--------------------------------------------------------------------------------------------------------
--		Hero: Slark
--		Perk: Dark Pact free ability and casts it every 10 seconds. Also is immune to its self damage.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_slark_perk = modifier_npc_dota_hero_slark_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slark_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slark_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slark_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slark_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_slark_perk:GetTexture()
	return "custom/npc_dota_hero_slark_perk"
end
--------------------------------------------------------------------------------------------------------

function modifier_npc_dota_hero_slark_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_slark_perk:GetModifierIncomingDamage_Percentage(params)
	if IsClient() then return end
	if params.inflictor and params.inflictor:GetAbilityName() == "slark_dark_pact" and params.attacker == self:GetParent() then
		return -1000
	end
end

function modifier_npc_dota_hero_slark_perk:OnCreated()
	if IsServer() then
		local caster = self:GetParent()
		local bonus_ability = caster:FindAbilityByName("slark_dark_pact")

		if bonus_ability then
			bonus_ability:UpgradeAbility(false)
		else
			bonus_ability = caster:AddAbility("slark_dark_pact")
			--bonus_ability:SetStolen(true)
			bonus_ability:SetActivated(true)
			bonus_ability:SetLevel(1)
		end
		self:StartIntervalThink(10)
	end
end

function modifier_npc_dota_hero_slark_perk:OnIntervalThink()
	local hero = self:GetParent()
	local ability = hero:FindAbilityByName("slark_dark_pact")
	ability:OnSpellStart()
end
