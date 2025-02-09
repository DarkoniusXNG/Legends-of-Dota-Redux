--------------------------------------------------------------------------------------------------------
--		Hero: Luna
--		Perk: Luna gains 1 free level of Moon Glaives, whether she has it or not. Ultimate abilities have their cooldowns reduced by 25% during the night.
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_luna_perk = modifier_npc_dota_hero_luna_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_luna_perk:RemoveOnDeath()
    return false
end

function modifier_npc_dota_hero_luna_perk:GetTexture()
	return "custom/npc_dota_hero_luna_perk"
end

function modifier_npc_dota_hero_luna_perk:OnCreated()
	if IsServer() then
		local caster = self:GetParent()
		local bonus_ability = caster:FindAbilityByName("luna_moon_glaive")

		if bonus_ability then
			bonus_ability:UpgradeAbility(false)
		else
			bonus_ability = caster:AddAbility("luna_moon_glaive")
			--bonus_ability:SetStolen(true)
			bonus_ability:SetActivated(true)
			bonus_ability:SetLevel(1)
		end
		
		self:StartIntervalThink(1)
	end
end

function modifier_npc_dota_hero_luna_perk:OnIntervalThink()
	if GameRules:IsDaytime() then
		self:SetStackCount(0)
	else
		self:SetStackCount(-1) -- negative stack to not show on the hud
	end
end

function modifier_npc_dota_hero_luna_perk:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
  }
end

function modifier_npc_dota_hero_luna_perk:GetModifierPercentageCooldown(keys)
	local ability = keys.ability
	if ability and math.abs(self:GetStackCount()) == 1 then
		if ability:GetAbilityType() == ABILITY_TYPE_ULTIMATE then
			return 25
		end
	else
		return 0
	end
end
