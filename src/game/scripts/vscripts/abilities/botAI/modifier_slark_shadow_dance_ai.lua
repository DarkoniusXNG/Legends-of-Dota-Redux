--Taken from the spelllibrary, credits go to valve

modifier_slark_shadow_dance_ai = class({})


--------------------------------------------------------------------------------

function modifier_slark_shadow_dance_ai:IsHidden()
    return not IsInToolsMode()
end

--------------------------------------------------------------------------------

function modifier_slark_shadow_dance_ai:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------
function modifier_slark_shadow_dance_ai:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

if IsServer() then
	function modifier_slark_shadow_dance_ai:OnTakeDamage(event)
		local caster = self:GetParent()
		local ability = caster:FindAbilityByName("slark_shadow_dance")
		local attacker = event.attacker
		local damaged_unit = event.unit

		-- Check if attacker exists
		if not attacker or attacker:IsNull() then
			return
		end

		-- Check if damaged unit has this modifier
		if damaged_unit ~= caster then
			return
		end

		-- Ignore self damage
		if damaged_unit == attacker then
			return
		end

		if caster:GetHealthPercent() <= 25 and ability and ability:IsFullyCastable() and caster:IsRealHero() and not (caster:IsStunned() or caster:IsSilenced() or caster:IsChanneling())  then
			local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
			local duration = ability:GetSpecialValueFor("duration")
			if duration == 0 then
				duration = 3
			end
			--caster:CastAbilityImmediately(ability, caster:GetPlayerOwnerID())
			ability:OnSpellStart()
			ability:StartCooldown( cooldown )
			caster:AddNewModifier(caster, ability, "modifier_slark_shadow_dance_custom_redux", {duration = duration})
			caster:EmitSound("Hero_Slark.ShadowDance")
		end
	end
end

-- Slark Shadow Dance % bonus regen
LinkLuaModifier("modifier_slark_shadow_dance_custom_redux", "abilities/botAI/modifier_slark_shadow_dance_ai.lua", LUA_MODIFIER_MOTION_NONE)

modifier_slark_shadow_dance_custom_redux = modifier_slark_shadow_dance_custom_redux or class({})

function modifier_slark_shadow_dance_custom_redux:IsHidden()
  return true
end

function modifier_slark_shadow_dance_custom_redux:IsDebuff()
  return false
end

function modifier_slark_shadow_dance_custom_redux:IsPurgable()
  return false
end

function modifier_slark_shadow_dance_custom_redux:OnCreated()
  self.regen = 4
  local ability = self:GetAbility()
  if ability and not ability:IsNull() then
    self.regen = 4 + ability:GetLevel()
  end
end

modifier_slark_shadow_dance_custom_redux.OnRefresh = modifier_slark_shadow_dance_custom_redux.OnCreated

function modifier_slark_shadow_dance_custom_redux:DeclareFunctions()
  return {
    MODIFIER_PROPERTY_HEALTH_REGEN_PERCENTAGE,
  }
end

function modifier_slark_shadow_dance_custom_redux:GetModifierHealthRegenPercentage()
  return self.regen
end

