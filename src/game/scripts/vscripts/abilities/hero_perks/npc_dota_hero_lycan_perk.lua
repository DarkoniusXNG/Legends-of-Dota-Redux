--------------------------------------------------------------------------------------------------------
--		Hero: Lycan
--		Perk: Bonus night vision + while transformed: Phased, reduced cds and mana costs
--------------------------------------------------------------------------------------------------------
modifier_npc_dota_hero_lycan_perk = modifier_npc_dota_hero_lycan_perk or class({})
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:IsPassive()
	return true
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:IsHidden()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:IsPurgable()
	return false
end
--------------------------------------------------------------------------------------------------------
function modifier_npc_dota_hero_lycan_perk:RemoveOnDeath()
	return false
end

function modifier_npc_dota_hero_lycan_perk:GetTexture()
	return "custom/npc_dota_hero_lycan_perk"
end

function modifier_npc_dota_hero_lycan_perk:CheckState()
  local state = {}

  -- Check for transformation
  if not self:GetParent():IsTransformedCustom() then
    state[MODIFIER_STATE_NO_UNIT_COLLISION] = true
  end

  return state
end

function modifier_npc_dota_hero_lycan_perk:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE_STACKING,
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
	}
end

function modifier_npc_dota_hero_lycan_perk:GetModifierPercentageCooldown(keys)
	local parent = self:GetParent()
	if parent:IsTransformedCustom() then
		return 25
	end
	return 0
end

function modifier_npc_dota_hero_lycan_perk:GetModifierPercentageManacostStacking(keys)
	local parent = self:GetParent()
	if parent:IsTransformedCustom() then
		return 25
	end
	return 0
end

function modifier_npc_dota_hero_lycan_perk:GetBonusNightVision()
	return 1000
end
