erra_grave_guard = class({})

LinkLuaModifier("modifier_grave_guard","abilities/dusk/erra_grave_guard",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_grave_guard_recovery","abilities/dusk/erra_grave_guard",LUA_MODIFIER_MOTION_NONE)

function erra_grave_guard:GetIntrinsicModifierName()
	return "modifier_grave_guard"
end

function erra_grave_guard:ShouldUseResources()
	return true
end

---------------------------------------------------------------------------------------------------

modifier_grave_guard = class({})

function modifier_grave_guard:IsHidden()
	return true
end

function modifier_grave_guard:IsDebuff()
	return false
end

function modifier_grave_guard:IsPurgable()
	return false
end

function modifier_grave_guard:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

if IsServer() then
	function modifier_grave_guard:OnTakeDamage(params)
		local caster = self:GetParent()
		local ability = self:GetAbility()

		if params.unit ~= caster then return end

		if not caster:IsRealHero() then return end

		local duration = ability:GetSpecialValueFor("duration")
		local threshold = ability:GetSpecialValueFor("threshold")
		local cast_me = ability:IsCooldownReady() and ability:IsOwnersManaEnough()
		local hp = caster:GetHealthPercent()

		if hp < threshold and cast_me and caster:IsAlive() then
			caster:AddNewModifier(caster, ability, "modifier_grave_guard_recovery", {duration = duration})

			caster:EmitSound("Erra.GraveGuard")

			ability:UseResources(true, false, false, true)
		end
	end

end

---------------------------------------------------------------------------------------------------

modifier_grave_guard_recovery = class({})

function modifier_grave_guard_recovery:GetEffectName()
	return "particles/units/heroes/hero_erra/grave_guard_unit.vpcf"
end

function modifier_grave_guard_recovery:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}
end

function modifier_grave_guard_recovery:GetModifierConstantHealthRegen()
	return self:GetAbility():GetSpecialValueFor("hp_recovery")
end

function modifier_grave_guard_recovery:GetModifierConstantManaRegen()
	return self:GetAbility():GetSpecialValueFor("mp_recovery")
end
