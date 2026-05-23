--Taken from the spelllibrary, credits go to valve

modifier_alchemist_chemical_rage_ai = modifier_alchemist_chemical_rage_ai or class({})

function modifier_alchemist_chemical_rage_ai:IsHidden()
    return not IsInToolsMode()
end

function modifier_alchemist_chemical_rage_ai:IsPurgable()
	return false
end

function modifier_alchemist_chemical_rage_ai:RemoveOnDeath()
    return false
end

function modifier_alchemist_chemical_rage_ai:IsPermanent()
	return true
end

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

		if not ability or ability:IsNull() then
			self:Destroy()
			return
		end

		if ability:GetLevel() < 1 then
			return
		end

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

		if not caster:IsAlive() or not caster:IsRealHero() or caster:IsStunned() or caster:IsSilenced() or caster:IsChanneling() then
			return
		end

		if caster:GetHealthPercent() <= 75 and ability:IsFullyCastable() then
			local cooldown = ability:GetCooldown(ability:GetLevel() - 1)
			--caster:CastAbilityImmediately(ability, caster:GetPlayerOwnerID())
			ability:OnSpellStart()
			--ability:StartCooldown( cooldown )
			ability:UseResources(true, true, false, true)
			caster:EmitSound("Hero_Alchemist.ChemicalRage.Cast")
		end
	end
end

function modifier_alchemist_chemical_rage_ai:GetTexture()
	return "alchemist_chemical_rage"
end

