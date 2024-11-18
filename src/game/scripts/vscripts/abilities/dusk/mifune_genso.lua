mifune_genso = class({})

LinkLuaModifier("modifier_genso_illusion","abilities/dusk/mifune_genso",LUA_MODIFIER_MOTION_NONE)

function mifune_genso:OnSpellStart()
	local c = self:GetCaster()
	local t = self:GetCursorTarget()

	if t:TriggerSpellAbsorb(self) then return end

	local n = self:GetSpecialValueFor("illusions")
	local this = self

	while n > 0 do
		Timers:CreateTimer(0.10*n, function()
			GenIllusion(c, t, this)
		end)
		n = n - 1
	end
end

function GenIllusion(caster, target, ability)
	local origin = target:GetAbsOrigin() + RandomVector(128)
	local padding = caster:GetHullRadius()
	local duration = ability:GetLevelSpecialValueFor( "illusion_duration", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor( "illusion_damage", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor( "illusion_incoming", ability:GetLevel() - 1 )

	local illu_table = {
		outgoing_damage = outgoingDamage - 100,
		incoming_damage = incomingDamage,
		bounty_base = 0,
		bounty_growth = 0,
		outgoing_damage_structure = outgoingDamage - 100,
		outgoing_damage_roshan = outgoingDamage - 100,
		duration = duration,
	}

	local illusion = CreateIllusions(caster, caster, illu_table, 1, padding, true, true)[1]
	FindClearSpaceForUnit(illusion, origin, false)

	-- Particle
	local particleName = "particles/units/heroes/hero_terrorblade/terrorblade_reflection_cast.vpcf"
	local particle = ParticleManager:CreateParticle(particleName, PATTACH_POINT_FOLLOW, target)
	ParticleManager:SetParticleControl(particle, 3, Vector(1,0,0))
	ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle, 1, illusion, PATTACH_POINT_FOLLOW, "attach_hitloc", origin, true)
	ParticleManager:ReleaseParticleIndex(particle)

	-- Sound
	illusion:EmitSound("Hero_Terrorblade.Reflection")

	illusion:AddNewModifier(caster, ability, "modifier_genso_illusion", {duration = duration})

	local order = {
		UnitIndex = illusion:entindex(),
		OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
		TargetIndex = target:entindex()
	}

	ExecuteOrderFromTable(order)
	illusion:SetForceAttackTarget(target)

	illusion.attack_target = target
end

---------------------------------------------------------------------------------------------------

modifier_genso_illusion = class({})

function modifier_genso_illusion:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true
	}
	return state
end

function modifier_genso_illusion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

if IsServer() then
	function modifier_genso_illusion:OnDeath(params)
		local parent = self:GetParent()
		local u = params.unit
		local at = parent.attack_target

		if not at or at:IsNull() then return end

		if u == at and parent:IsAlive() then
			parent:Kill(self:GetAbility(),self:GetAbility():GetCaster())
		end
	end
end

function modifier_genso_illusion:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("illusion_bonus_movespeed")
end
