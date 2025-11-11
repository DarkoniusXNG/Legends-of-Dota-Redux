require('lib/physics')
lysander_phantom_fleet = lysander_phantom_fleet or class({})

LinkLuaModifier("modifier_phantom_fleet_slow","abilities/dusk/lysander_phantom_fleet",LUA_MODIFIER_MOTION_NONE)

function lysander_phantom_fleet:OnSpellStart()
	local caster = self:GetCaster()
	local pos = self:GetCursorPosition()

	self.ship_number = self.ship_number or 0
	self.p_main = self.p_main or {}

	self.ship_number = self.ship_number+1

	local ship_number = self.ship_number

	local direction = (pos - caster:GetAbsOrigin()):Normalized()

	local start_pos = caster:GetAbsOrigin() - direction*1200

	local duration = self:GetSpecialValueFor("duration")
	local speed = self:GetSpecialValueFor("speed")
	local vision_radius = self:GetSpecialValueFor("vision_radius")

	local unit = FastDummy(start_pos,caster:GetTeam(),duration,vision_radius)
	unit:EmitSound("Ability.Ghostship")

	-- Slow aura
	unit:AddNewModifier(caster, self, "modifier_phantom_fleet_slow", {duration=duration})

	self.p_main[ship_number] = ParticleManager:CreateParticle("particles/units/heroes/hero_lysander/phantom_fleet_ship_main.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)
	ParticleManager:SetParticleControl(self.p_main[ship_number], 0, unit:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.p_main[ship_number], 1, unit:GetAbsOrigin()+direction*speed*duration*3)

	Physics:Unit(unit)
	unit:SetPhysicsFriction(0)
	unit:PreventDI(true)
	unit:FollowNavMesh(false)
	unit:SetAutoUnstuck(false)
	unit:SetNavCollisionType(PHYSICS_NAV_NOTHING)
	unit:SetPhysicsVelocity(direction * speed)
	unit:SetPhysicsAcceleration(Vector(0,0,-speed*4))

	local ability = self
	Timers:CreateTimer("fleet_timer_ship"..ship_number,{
		endTime = 1.5,
		callback = function()
			if not unit or unit:IsNull() or not caster or caster:IsNull() then
				return
			end
			local direction = RotatePosition(Vector(0,0,0), QAngle(0,RandomInt(-8,8),0), direction)
			direction.z = 0
			local info = {
				Ability = ability,
				EffectName = "particles/units/heroes/hero_lysander/phantom_fleet_cannoball.vpcf",
				vSpawnOrigin = unit:GetAbsOrigin()+Vector(0,0,100)+direction*350+(Vector(0,0,0)*direction),
				fDistance = speed*duration,
				fStartRadius = 100,
				fEndRadius = 100,
				Source = caster,
				bHasFrontalCone = false,
				bReplaceExisting = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
				fExpireTime = GameRules:GetGameTime() + 10.0,
				vVelocity = direction * 1500,
				bProvidesVision = true,
				iVisionRadius = vision_radius,
				iVisionTeamNumber = caster:GetTeamNumber()
			}
			ProjectileManager:CreateLinearProjectile(info)
			unit:EmitSound("Hero_Gyrocopter.HomingMissile.Destroy")
			ScreenShake(unit:GetCenter(), 100, 4, 0.4, 1200, 0, true)
			return 1
		end
	})

	Timers:CreateTimer("fleet_timer2_ship"..ship_number,{
		endTime = 1,
		callback = function()
			if not unit or unit:IsNull() or not caster or caster:IsNull() then
				return
			end
			local direction = RotatePosition(Vector(0,0,0), QAngle(0,RandomInt(-8,8),0), direction)
			direction.z = 0
			local info = {
				Ability = ability,
				EffectName = "particles/units/heroes/hero_lysander/phantom_fleet_cannoball.vpcf",
				vSpawnOrigin = unit:GetAbsOrigin()+Vector(0,0,100)+direction*350+(Vector(0,0,0)*direction),
				fDistance = speed*duration,
				fStartRadius = 100,
				fEndRadius = 100,
				Source = caster,
				bHasFrontalCone = false,
				bReplaceExisting = false,
				iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
				iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
				fExpireTime = GameRules:GetGameTime() + 10.0,
				vVelocity = direction * 1500,
				bProvidesVision = true,
				iVisionRadius = vision_radius,
				iVisionTeamNumber = caster:GetTeamNumber()
			}
			ProjectileManager:CreateLinearProjectile(info)
			unit:EmitSound("Hero_Gyrocopter.HomingMissile.Destroy")
			ScreenShake(unit:GetCenter(), 100, 4, 0.4, 1200, 0, true)
			return 1
		end
	})

	Timers:CreateTimer(duration, function()
		ParticleManager:DestroyParticle(ability.p_main[ship_number],false)
		ParticleManager:ReleaseParticleIndex(ability.p_main[ship_number])
		ability.p_main[ship_number] = nil
		Timers:RemoveTimer("fleet_timer_ship"..ship_number)
		Timers:RemoveTimer("fleet_timer2_ship"..ship_number)
	end)
end

function lysander_phantom_fleet:OnProjectileHit(hTarget, vLocation)
	if hTarget then
		local caster = self:GetCaster()
		local stun = self:GetSpecialValueFor("ministun")
		local damage = self:GetSpecialValueFor("damage")
		-- Mini-stun
		hTarget:AddNewModifier(caster, self, "modifier_stunned", {duration=stun})
		-- Quarter damage to buildings
		if hTarget:IsBuilding() then
			damage = damage / 4
		end
		InflictDamage(hTarget, caster, self, damage, DAMAGE_TYPE_PHYSICAL, DOTA_DAMAGE_FLAG_BYPASSES_PHYSICAL_BLOCK)
	end
end

---------------------------------------------------------------------------------------------------

modifier_phantom_fleet_slow = modifier_phantom_fleet_slow or class({})

function modifier_phantom_fleet_slow:IsHidden()
	return true
end

function modifier_phantom_fleet_slow:IsDebuff()
	return false
end

function modifier_phantom_fleet_slow:IsPurgable()
	return false
end

function modifier_phantom_fleet_slow:IsAura()
	return true
end

function modifier_phantom_fleet_slow:GetAuraDuration()
	return 0.5
end

function modifier_phantom_fleet_slow:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("slow_radius")
end

function modifier_phantom_fleet_slow:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_phantom_fleet_slow:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP
end

function modifier_phantom_fleet_slow:GetModifierAura()
	return "modifier_phantom_fleet_slow_buff"
end

---------------------------------------------------------------------------------------------------

modifier_phantom_fleet_slow_buff = modifier_phantom_fleet_slow_buff or class({})

function modifier_phantom_fleet_slow_buff:IsHidden()
	return false
end

function modifier_phantom_fleet_slow_buff:IsDebuff()
	return true
end

function modifier_phantom_fleet_slow_buff:IsPurgable()
	return true
end

function modifier_phantom_fleet_slow_buff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
	}
end

function modifier_phantom_fleet_slow_buff:GetModifierMoveSpeedBonus_Percentage()
	return 0 - math.abs(self:GetAbility():GetSpecialValueFor("slow"))
end

---------------------------------------------------------------------------------------------------

function InflictDamage(target,attacker,ability,damage,damage_type,flags)
	local flags = flags or 0
	ApplyDamage({
	    victim = target,
	    attacker = attacker,
	    damage = damage,
	    damage_type = damage_type,
	    damage_flags = flags,
	    ability = ability
  	})
end

function FastDummy(target, team, duration, vision)
	local dur = duration or 0.03
	local vis = vision or 250
	local dummy = CreateUnitByName("npc_dummy_unit", target, false, nil, nil, team)
	if dummy ~= nil then
		dummy:SetAbsOrigin(target)
		dummy:SetDayTimeVisionRange(vis)
		dummy:SetNightTimeVisionRange(vis)
		dummy:AddNewModifier(dummy, nil, "modifier_phased", {})
		dummy:AddNewModifier(dummy, nil, "modifier_invulnerable", {})
		dummy:AddNewModifier(dummy, nil, "modifier_kill", {duration = dur})
		Timers:CreateTimer(dur+0.03, function()
			if dummy and not dummy:IsNull() then
				dummy:ForceKill(false)
				UTIL_Remove(dummy)
			end
		end)
	end
	return dummy
end
