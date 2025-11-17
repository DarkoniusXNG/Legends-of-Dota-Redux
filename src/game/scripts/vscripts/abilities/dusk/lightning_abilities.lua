require('lib/physics')

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

function DealDamage(target,attacker,damageAmount,damageType,damageFlags,ability)
  local target = target
  local attacker = attacker or target -- if nil we assume we're dealing self damage
  local dmg = damageAmount
  local dtype = damageType
  local flags = damageFlags or DOTA_DAMAGE_FLAG_NONE
  
  if not IsValidEntity(target) and type(target) == "table" then -- assume a table was passed
    for kd,vd in pairs(target) do
      if IsValidEntity(vd) then
        ApplyDamage({
          victim = vd,
          attacker = attacker,
          damage = dmg,
          damage_type = dtype,
          damage_flags = flags,
          ability = ability
        })
      end
    end
    return
  end

  ApplyDamage({
    victim = target,
    attacker = attacker,
    damage = dmg,
    damage_type = dtype,
    damage_flags = flags,
    ability = ability
  })
end

function thunder_wave(keys)
	local caster = keys.caster
	local target = keys.ability:GetCursorPosition() --keys.target_points[1]
	local modifier = "modifier_thunder_wave_generate"
	local speed = keys.speed
	local distance = keys.distance + caster:GetCastRangeBonus()
	local direction = (target - caster:GetAbsOrigin()):Normalized()

	local dummy = FastDummy(caster:GetAbsOrigin(),caster:GetTeam(),1 + distance/speed,100)
	keys.ability:ApplyDataDrivenModifier(caster, dummy, modifier, {})

	dummy.stop = false

	Physics:Unit(dummy)
  	dummy:SetPhysicsFriction(0.0)
  	dummy:PreventDI(true)

  	dummy:FollowNavMesh(false)
	dummy:SetAutoUnstuck(false)
	dummy:SetNavCollisionType(PHYSICS_NAV_NOTHING)
  
  	dummy:SetPhysicsVelocity(direction * distance)

  	Timers:CreateTimer(distance/speed, function()
		dummy:SetPhysicsVelocity(Vector(0,0,0))
		--FindClearSpaceForUnit(caster,caster:GetAbsOrigin(),true)
		dummy.stop = true
    end)
end

function generate_thunder(keys)
	local real_caster = keys.caster
	local caster = keys.target
	local radius = keys.radius
	local dmg = keys.damage
	local ldmg = keys.lightningdamage
	local vector = caster:GetAbsOrigin() + RandomVector(150)

	if caster.stop == false then
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_disruptor/disruptor_thuderstrike_aoe_area.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(particle, 0, vector)
		ParticleManager:SetParticleControl(particle, 2, vector)
		ParticleManager:ReleaseParticleIndex(particle)

		caster:EmitSound("Hero_Zuus.ArcLightning.Target")

		local enemy_found = FindUnitsInRadius(
			real_caster:GetTeamNumber(),
			vector,
			nil,
			radius,
			DOTA_UNIT_TARGET_TEAM_ENEMY,
			DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP,
			DOTA_UNIT_TARGET_FLAG_NONE,
			FIND_ANY_ORDER,
			false
		)

		for k,v in pairs(enemy_found) do
			DealDamage(v, real_caster, dmg, DAMAGE_TYPE_MAGICAL)
			keys.ability:ApplyDataDrivenModifier(real_caster, v, "modifier_thunder_wave_buff", {})
		end

		Timers:CreateTimer(1,function()
			local enemy_found = FindUnitsInRadius( 
				real_caster:GetTeamNumber(),
				vector,
				nil,
				radius,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_ANY_ORDER,
				false
			)
			caster:EmitSound("Hero_Zuus.LightningBolt")
			for k,v in pairs(enemy_found) do
				DealDamage(v, real_caster, ldmg, DAMAGE_TYPE_MAGICAL)
				keys.ability:ApplyDataDrivenModifier(real_caster, v, "modifier_thunder_wave_buff", {})
			end
			local targetmod = vector+Vector(0,0,800)
			local boltparticle  = ParticleManager:CreateParticle("particles/units/heroes/hero_lightning/thunder_wave_lightning_bolt.vpcf", PATTACH_ABSORIGIN, caster)
			ParticleManager:SetParticleControl(boltparticle,0,vector+Vector(0,0,25))
			ParticleManager:SetParticleControl(boltparticle,1,targetmod)
			ParticleManager:ReleaseParticleIndex(boltparticle)
		end)
	end
end

function overload(keys)
	local caster = keys.caster
	local ability1 = caster:FindAbilityByName("lightning_lightning_dagger")
	local ability2 = caster:FindAbilityByName("lightning_thunder_wave")

	ability1:EndCooldown()
	ability2:EndCooldown()
end

function check_pos(keys)
	local caster = keys.caster
	local pos = caster:GetAbsOrigin()

	if caster.poscount == nil then caster.poscount = -1 end
	if caster.lastpos == nil then caster.lastpos = pos else caster.lastpos = caster.lastpos end

	if pos == caster.lastpos then
		--print("[CHECK_POS] ADDING COUNT")
		caster.poscount = caster.poscount+1
	else
		caster.poscount = 0
	end

	if caster.poscount > 10 then
		--print("[CHECK_POS] REMOVING MODIFIER")
		caster:RemoveModifierByName("modifier_blinding_speed_active") --[[Returns:void
		Removes a modifier
		]]
		caster:RemoveModifierByName("modifier_bloodseeker_thirst_speed") --[[Returns:void
		Removes a modifier
		]]
		caster:RemoveModifierByName("modifier_blinding_speed_active_aghs") --[[Returns:void
		Removes a modifier
		]]
		caster.poscount = -1
	end

	caster.lastpos = pos
end

function blinding_speed(keys)
	local caster = keys.caster
	local aghs = caster:HasScepter()
	local modifier = "modifier_blinding_speed_active"
	local aghs_modifier = "modifier_blinding_speed_active_aghs"

	if aghs then
		keys.ability:ApplyDataDrivenModifier(caster, caster, aghs_modifier, {}) --[[Returns:void
		No Description Set
		]]
	else
		keys.ability:ApplyDataDrivenModifier(caster, caster, modifier, {}) --[[Returns:void
		No Description Set
		]]
	end
end

function purge(keys)
	local caster = keys.caster
	caster:Purge(false, true, false, true, false)
end

function blinding_speed_increase_stack(keys)
	local caster = keys.caster
	local ability = caster:FindAbilityByName("lightning_blinding_speed2")
	local mod = "modifier_blinding_speed_stack"
	local max_stacks_mod = "modifier_blinding_speed_max_stack"
	if not ability then return end
	local max_stacks = ability:GetLevelSpecialValueFor("max_stack", ability:GetLevel())
	local stacks = 0
	if caster:HasModifier(mod) then
		stacks = caster:GetModifierStackCount(mod,caster)
	end
	ability:ApplyDataDrivenModifier(caster, caster, mod, {})
	if stacks+1 >= max_stacks then
		ability:ApplyDataDrivenModifier(caster, caster, max_stacks_mod, {})
		caster:SetModifierStackCount(mod,caster,max_stacks)
	else
		caster:SetModifierStackCount(mod,caster,stacks+1)
	end
end

function blinding_speed_remove_modifiers(keys)
	local caster = keys.caster
	local mod = "modifier_blinding_speed_stack"
	local max_stacks_mod = "modifier_blinding_speed_max_stack"

	caster:RemoveModifierByName(mod) --[[Returns:void
	Removes a modifier
	]]
	caster:RemoveModifierByName(max_stacks_mod) --[[Returns:void
	Removes a modifier
	]]
end

function LightningDagger(keys)
	local caster = keys.caster
	local target = keys.target or keys.unit
	local ability = keys.ability

	ability:ApplyDataDrivenModifier(caster, target, "modifier_lightning_dagger_mark_slow", {})
end

function lightningDaggerMarkOnAttack(keys)
	local caster = keys.caster
	local attacker = keys.attacker
	local target = keys.target or keys.unit

	if attacker == caster then
		LightningDagger(keys)
		target:RemoveModifierByName("modifier_lightning_dagger_mark")
	end
end

function Spark(keys)
	local caster = keys.caster

	local spark = caster:FindAbilityByName("lightning_spark")

	if not spark then return end

	if caster:PassivesDisabled() then return end

	if spark:GetLevel() <= 0 then return end

	local damage = spark:GetLevelSpecialValueFor("bonus_damage", spark:GetLevel())
	local radius = spark:GetLevelSpecialValueFor("radius", spark:GetLevel())

	local enemy = FindUnitsInRadius( caster:GetTeamNumber(),
      caster:GetCenter(),
      nil,
        radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_CLOSEST,
        false)

	caster:EmitSound("Hero_Zuus.StaticField")

	for k,v in pairs(enemy) do
		DealDamage(v,caster,damage,DAMAGE_TYPE_MAGICAL)
		ParticleManager:CreateParticle("particles/units/heroes/hero_lightning/spark.vpcf", PATTACH_ABSORIGIN_FOLLOW, v)
		spark:ApplyDataDrivenModifier(caster, v, "modifier_spark_slow", {})
	end
end
