--Taken from the spelllibrary, credits go to valve

modifier_alchemist_chemical_rage_ai = class({})


--------------------------------------------------------------------------------

function modifier_alchemist_chemical_rage_ai:IsHidden()
    return true
end

--------------------------------------------------------------------------------

function modifier_alchemist_chemical_rage_ai:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------
function modifier_alchemist_chemical_rage_ai:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
end

if IsServer() then
	function modifier_alchemist_chemical_rage_ai:OnTakeDamage(event)
		local caster = self:GetParent()
		local ability = caster:FindAbilityByName("alchemist_chemical_rage")
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
		
		if caster:GetHealthPercent() < 75 and ability and ability:IsFullyCastable() and not caster:IsChanneling() and caster:IsRealHero() and not (caster:IsStunned() or caster:IsSilenced()) then
			local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
			caster:CastAbilityImmediately(ability, caster:GetPlayerOwnerID())
			ability:StartCooldown( cooldown )
			caster:EmitSound("Hero_Alchemist.ChemicalRage.Cast")
		end
	end
end

