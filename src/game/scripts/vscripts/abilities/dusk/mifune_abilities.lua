function FastDummy(target, team, duration, vision)
	local dur = duration or 0.03
	local vis = vision or 250
	local dummy = CreateUnitByName("npc_dummy_unit", target, false, nil, nil, team) -- change to npc_dummy_unit_dusk if it doesnt work
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

function ouichi(keys)
	local caster = keys.caster or keys.attacker
	local target = keys.target or keys.unit

	if caster:PassivesDisabled() then return end

	local targethp = target:GetHealthPercent()

	local damage = keys.dmg

	local t = keys.threshold

	local agi = caster:GetAgility()

	local fd = agi*damage

	if targethp > t then return end

	--if CheckClass(target,"npc_dota_building") then return end

	if caster:IsIllusion() then fd = fd * 0.25 end

	DealDamage(target,caster,fd,DAMAGE_TYPE_PURE)

	local tp,cp = PlayerResource:GetPlayer(target:GetPlayerOwnerID()),PlayerResource:GetPlayer(caster:GetPlayerOwnerID())
	SendOverheadEventMessage(tp or cp, OVERHEAD_ALERT_CRITICAL, target, math.ceil(fd), nil)

	ParticleManager:CreateParticle("particles/units/heroes/hero_skeletonking/skeleton_king_weapon_blur_critical.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster) --[[Returns:int
	Creates a new particle effect
	]]

	caster:EmitSound("Hero_SkeletonKing.CriticalStrike")

	keys.ability:StartCooldown(keys.ability:GetCooldown(keys.ability:GetLevel()-1))
end

function raigeki(keys)
	local caster = keys.caster
	local target = keys.target_points[1]
	local c_pos = caster:GetAbsOrigin()
	local dr = (target-c_pos):Normalized()
	local range = keys.range
	local delay = keys.delay

	local u = FastDummy(c_pos,caster:GetTeam(),3,0)

	Timers:CreateTimer(delay*0.30,function()
		u:EmitSound("Hero_Magnataur.Empower.Target")
	end)

	Timers:CreateTimer(delay*0.95,function()
		u:EmitSound("Hero_Magnataur.ReversePolarity.Anim")
		u:EmitSound("Hero_Magnataur.ShockWave.Target")
	end)

	Timers:CreateTimer(delay,function()
		local proj = {
			Ability = keys.ability,
        	EffectName = keys.EffectName,
        	vSpawnOrigin = u:GetAbsOrigin(),
        	fDistance = range,
        	fStartRadius = 100,
        	fEndRadius = 100,
        	Source = u,
        	bHasFrontalCone = false,
        	bReplaceExisting = false,
        	iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        	iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        	iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        	fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = dr*range*4,
			bProvidesVision = false,
			iVisionRadius = 0,
			iVisionTeamNumber = caster:GetTeamNumber()
		}
		ProjectileManager:CreateLinearProjectile(proj) --[[Returns:int
		Creates a linear projectile and returns the projectile ID
		]]
	end
	)
end

function zanmato_init( keys )
	-- Cannot cast multiple stacks
	if keys.caster.sleight_of_fist_active ~= nil and keys.caster.sleight_of_fist_action == true then
		keys.ability:RefundManaCost()
		return nil
	end

	-- Inheritted variables
	local caster = keys.caster
	local main_target = keys.target
	local targetPoint = main_target:GetAbsOrigin()
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local attack_interval = ability:GetLevelSpecialValueFor( "attack_interval", ability:GetLevel() - 1 )
	local modifierTargetName = "modifier_sleight_of_fist_target_datadriven"
	local modifierTargetMainName = "modifier_sleight_of_fist_main_target_datadriven"
	local modifierHeroName = "modifier_sleight_of_fist_target_hero_datadriven"
	local modifierCreepName = "modifier_sleight_if_fist_target_creep_datadriven"
	local casterModifierName = "modifier_sleight_of_fist_caster_datadriven"
	local dummyModifierName = "modifier_sleight_of_fist_dummy_datadriven"
	local particleSlashName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_tgt.vpcf"
	local particleTrailName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleightoffist_trail.vpcf"
	local particleCastName = "particles/units/heroes/hero_ember_spirit/ember_spirit_sleight_of_fist_cast.vpcf"
	local slashSound = "Hero_EmberSpirit.SleightOfFist.Damage"
	local abilityScepter = caster:FindAbilityByName("mifune_genso")

	-- Targeting variables
	local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
	local targetFlag = DOTA_UNIT_TARGET_FLAG_NO_INVIS
	local unitOrder = FIND_ANY_ORDER

	-- Necessary varaibles
	local counter = 0
	caster.sleight_of_fist_active = true
	local dummy = CreateUnitByName( caster:GetName(), caster:GetAbsOrigin(), false, caster, nil, caster:GetTeamNumber() )
	ability:ApplyDataDrivenModifier( caster, dummy, dummyModifierName, {} )

	-- Casting particles
	local castFxIndex = ParticleManager:CreateParticle( particleCastName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( castFxIndex, 0, targetPoint )
	ParticleManager:SetParticleControl( castFxIndex, 1, Vector( radius, 0, 0 ) )

	local castFxIndex2 = ParticleManager:CreateParticle( "particles/units/heroes/hero_mifune/mifune_blossoms.vpcf", PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( castFxIndex2, 0, caster:GetAbsOrigin()+Vector(0,0,300))
	ParticleManager:SetParticleControl( castFxIndex2, 1, caster:GetAbsOrigin())

	Timers:CreateTimer( 0.1, function()
			ParticleManager:DestroyParticle( castFxIndex, false )
			ParticleManager:ReleaseParticleIndex( castFxIndex )
		end
	)

	-- Start function
	local castFxIndex = ParticleManager:CreateParticle( particleCastName, PATTACH_CUSTOMORIGIN, caster )
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), targetPoint, caster, radius, targetTeam,
		targetType, targetFlag, unitOrder, false
	)

	for _, target in pairs( units ) do
		counter = counter + 1
		Timers:CreateTimer( counter * attack_interval, function()
				-- Only jump to it if it's alive
				if target:IsAlive() then
					-- Create trail particles and apply the target modifier
					if caster:HasScepter() then
						caster:SetCursorCastTarget(main_target)
						abilityScepter:OnSpellStart()
					end


					ability:ApplyDataDrivenModifier( caster, target, modifierTargetName, {} )
					local trailFxIndex = ParticleManager:CreateParticle( particleTrailName, PATTACH_CUSTOMORIGIN, target )
					ParticleManager:SetParticleControl( trailFxIndex, 0, target:GetAbsOrigin() )
					ParticleManager:SetParticleControl( trailFxIndex, 1, caster:GetAbsOrigin() )

					Timers:CreateTimer( 0.1, function()
							ParticleManager:DestroyParticle( trailFxIndex, false )
							ParticleManager:ReleaseParticleIndex( trailFxIndex )
							return nil
						end
					)

					-- Move hero there
					FindClearSpaceForUnit( caster, target:GetAbsOrigin(), false )

					if target:IsHero() then
						ability:ApplyDataDrivenModifier( caster, caster, modifierHeroName, {} )
					else
						ability:ApplyDataDrivenModifier( caster, caster, modifierCreepName, {} )
					end

					caster:PerformAttack( target, true, true, true, false, false )

					-- Slash particles
					local slashFxIndex = ParticleManager:CreateParticle( particleSlashName, PATTACH_ABSORIGIN_FOLLOW, target )
					StartSoundEvent( slashSound, caster )

					Timers:CreateTimer( 0.1, function()
							ParticleManager:DestroyParticle( slashFxIndex, false )
							ParticleManager:ReleaseParticleIndex( slashFxIndex )
							StopSoundEvent( slashSound, caster )
							return nil
						end
					)

					-- Clean up modifier
					caster:RemoveModifierByName( modifierHeroName )
					caster:RemoveModifierByName( modifierCreepName )
				end
				return nil
			end
		)
	end

	local stuntime = counter*attack_interval+0.6

	if stuntime < 1 then stuntime = 1 end

	ability:ApplyDataDrivenModifier( caster, main_target, modifierTargetMainName, {Duration = stuntime} )

	-- Return caster to origin position
	Timers:CreateTimer( ( counter + 1 ) * attack_interval, function()
			FindClearSpaceForUnit( caster, dummy:GetAbsOrigin(), false )
			dummy:RemoveSelf()
			for _,target in pairs(units) do
				target:RemoveModifierByName(modifierTargetName)
				if target ~= main_target then
				local info =
				  {
				  Target = main_target,
				  Source = target,
				  Ability = keys.ability,
				  EffectName = "particles/units/heroes/hero_mifune/mifune_orb.vpcf",
				  vSpawnOrigin = target:GetAbsOrigin(),
				  fDistance = distance,
				  fStartRadius = 20,
				  fEndRadius = 20,
				  bHasFrontalCone = false,
				  bReplaceExisting = false,
				  iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
				  iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
				  iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				  fExpireTime = GameRules:GetGameTime() + 10.0,
				  bDeleteOnHit = true,
				  iMoveSpeed = 800,
				  bProvidesVision = false,
				  iVisionRadius = 275,
				  iVisionTeamNumber = caster:GetTeamNumber(),
				  iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
				  }

		  		local projectile = ProjectileManager:CreateTrackingProjectile(info)
			end
			end
			caster:RemoveModifierByName( casterModifierName )
			caster.sleight_of_fist_active = false
			ParticleManager:DestroyParticle( castFxIndex2, false )
			return nil
		end
	)
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
