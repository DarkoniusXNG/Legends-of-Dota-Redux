-- Timeless Relic
LinkLuaModifier("modifier_debuff_duration_oaa", "abilities/oaa/timeless_relic.lua", LUA_MODIFIER_MOTION_NONE)

timeless_relic_oaa = class({})

function timeless_relic_oaa:GetIntrinsicModifierName()
	return "modifier_debuff_duration_oaa"
end

---------------------------------------------------------------------------------------------------

modifier_debuff_duration_oaa = class({})

function modifier_debuff_duration_oaa:IsHidden()
  return true
end

function modifier_debuff_duration_oaa:IsDebuff()
  return false
end

function modifier_debuff_duration_oaa:IsPurgable()
  return false
end

function modifier_debuff_duration_oaa:RemoveOnDeath()
  return false
end

function modifier_debuff_duration_oaa:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_STATUS_RESISTANCE_CASTER,
    MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,    -- GetModifierSpellAmplify_Percentage
  }
end

if IsServer() then
  function modifier_debuff_duration_oaa:GetModifierStatusResistanceCaster() -- Debuff Amp for vanilla spells
    local parent = self:GetParent()
	if parent:PassivesDisabled() then
		return 0
	end
	return -25
  end
end

function modifier_debuff_duration_oaa:GetModifierSpellAmplify_Percentage()
  return 25
end

function modifier_debuff_duration_oaa:GetWillPower() -- Debuff Amp for custom spells
	local parent = self:GetParent()
	if parent:PassivesDisabled() then
		return 0
	end
	return self:GetAbility():GetSpecialValueFor("debuff_amp")
end

function modifier_debuff_duration_oaa:WillPowerDebuffAmpOnly()
	return true
end

--function modifier_debuff_duration_oaa:GetTexture()
  --return "item_timeless_relic"
--end
