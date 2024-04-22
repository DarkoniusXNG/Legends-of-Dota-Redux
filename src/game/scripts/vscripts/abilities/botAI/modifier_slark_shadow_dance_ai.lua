--Taken from the spelllibrary, credits go to valve

modifier_slark_shadow_dance_ai = class({})


--------------------------------------------------------------------------------

function modifier_slark_shadow_dance_ai:IsHidden()
    return true
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

		if caster:GetHealth() < 400 and ability and ability:IsFullyCastable() and caster:IsRealHero() and not (caster:IsStunned() or caster:IsSilenced())  then
			local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
			caster:CastAbilityImmediately(ability, caster:GetPlayerOwnerID())
			ability:StartCooldown( cooldown )
			caster:EmitSound("Hero_Slark.ShadowDance")
		end
	end
end

