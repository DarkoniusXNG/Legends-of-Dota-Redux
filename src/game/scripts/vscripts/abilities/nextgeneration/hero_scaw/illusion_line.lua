function CreateIllusionLine( keys )
	local caster = keys.caster
	local ability = keys.ability
	local player = caster:GetPlayerID()
	local point = keys.target_points[1]
	
	local duration = ability:GetLevelSpecialValueFor("duration", ability:GetLevel() - 1 )
	local delay = ability:GetLevelSpecialValueFor("illusion_delay", ability:GetLevel() - 1 )
	local incomingDamage = ability:GetLevelSpecialValueFor("incoming_damage", ability:GetLevel() - 1 )
	local outgoingDamage = ability:GetLevelSpecialValueFor("outgoing_damage", ability:GetLevel() - 1 )
	
	local origin = caster:GetAbsOrigin()
	local forwardVec = caster:GetForwardVector()
	local distance = (point - origin):Length2D()
	local location = origin + forwardVec * distance
	local sideVec = caster:GetRightVector()

	local randomPos = RandomInt(1,5)
	if caster:HasModifier("modifier_spirit_realm") then randomPos = 0 end

	local vec = {}

	vec[0] = origin
	vec[1] = location + sideVec * 350
	vec[2] = location + sideVec * 175
	vec[3] = location
	vec[4] = location + sideVec * -175
	vec[5] = location + sideVec * -350

	local casterVec = vec[randomPos]

	ProjectileManager:ProjectileDodge(caster)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_fire_spawn", {})

	local projectiles = {}

	for i = 1, 5 do
		distance = (vec[i] - origin):Length2D() + 0.1
		vector = (vec[i] - origin):Normalized()
		speed = distance / delay
		local projectileTable =
		{
			EffectName = "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant_trail.vpcf",
			Ability = ability,
			vSpawnOrigin = origin,
			vVelocity = Vector( vector.x * speed, vector.y * speed, 0 ),
			fDistance = distance,
			Source = caster,
			bHasFrontalCone = false,
			bReplaceExisting = false,
		}

		projectiles[i] = ProjectileManager:CreateLinearProjectile(projectileTable)

	end


	caster:AddNoDraw()
	caster:AddNewModifier(caster, ability, "modifier_disabled_invulnerable", {duration = delay})
	caster:AddNewModifier(caster, ability, "modifier_disarmed", {duration = delay})

	FindClearSpaceForUnit(caster, casterVec, false) 

	local illusion = {}
	local illu_table = {
		outgoing_damage = 100 - outgoingDamage,
		incoming_damage = incomingDamage - 100,
		bounty_base = 0,
		bounty_growth = 0,
		outgoing_damage_structure = 100 - outgoingDamage,
		outgoing_damage_roshan = 100 - outgoingDamage,
		duration = duration,
	}

	Timers:CreateTimer(delay, function()
		caster:RemoveNoDraw()
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_fire_spawn", {})
		if not caster:IsChanneling() then
			caster:MoveToPositionAggressive(casterVec)
		end

		for j = 1, 5 do
			if randomPos ~= j then
				illusion[j] = CreateIllusions(caster, caster, illu_table, 1, caster:GetHullRadius(), false, false)[1]

				--make sure this unit actually has stats
				if illusion[j].GetStrength then
					--copy over all the stat modifiers from the original hero
					for _, v in pairs(caster:FindAllModifiersByName("modifier_stats_tome")) do
						local instance = illusion[j]:AddNewModifier(caster, ability, "modifier_stats_tome", {stat = v.stat})
						instance:SetStackCount(v:GetStackCount())
					end
				end

				FindClearSpaceForUnit(illusion[j], vec[j], false) 
				illusion[j]:SetForwardVector(forwardVec)
				ability:ApplyDataDrivenModifier(caster, illusion[j], "modifier_fire_spawn", {})
				illusion[j]:EmitSound("Hero_Jakiro.LiquidFire")
			end
		end
	end)
end
--[[
function CheckDeath( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local target = keys.unit
	local ability = keys.ability

	if target:GetHealth() < 2 then
		
		local projTable = {
            EffectName = "particles/scawmar_illusion_line_fireball.vpcf",
            Ability = ability,
            Target = attacker,
            Source = target,
            bDodgeable = true,
            bProvidesVision = false,
            vSpawnOrigin = target:GetAbsOrigin(),
            iMoveSpeed = 700,
            iVisionRadius = 0,
            iVisionTeamNumber = caster:GetTeamNumber(),
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
        }
        ProjectileManager:CreateTrackingProjectile(projTable)
        target:ForceKill(false)
	end

end]]--
