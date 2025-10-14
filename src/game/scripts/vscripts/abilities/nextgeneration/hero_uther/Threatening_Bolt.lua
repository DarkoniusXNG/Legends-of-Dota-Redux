function Launch_Bolt (keys) -- KV OnSpellStart
	local caster = keys.caster
	local ability = keys.ability
	local target_point = keys.target_points[1]
	local duration = ability:GetLevelSpecialValueFor("bolt_duration", ability:GetLevel() -1)
	local attacksneeded = ability:GetLevelSpecialValueFor("attacks_needed", ability:GetLevel() -1)

	local caster_loc = caster:GetOrigin()
	local bolt_direction = (target_point - caster_loc):Normalized()
	local bolt = CreateUnitByName("npc_bolt_unit", caster_loc, true, caster, caster, caster:GetTeamNumber())
	bolt:SetControllableByPlayer(caster:GetPlayerID(), false)
	bolt:SetOwner(caster)
	bolt:SetForwardVector(bolt_direction)
	bolt:EmitSound("Hero_Chen.HolyPersuasionCast")
	ability:ApplyDataDrivenModifier(caster, bolt, "modifier_bolt_dummy",{duration = duration})
	bolt:SetHealth(attacksneeded)
	bolt.initial_destination = target_point
end

function Direct_Bolt (keys) -- KV OnIntervalThink
	local target = keys.target
	local caster = keys.caster
	--local hammersize = caster:FindAbilityByName("uther_Hurl_Hammer"):GetSpecialValueFor("Hammer_Size")

	if target.initial_destination then
		target:MoveToPosition(target.initial_destination)
		target.initial_destination = nil
	end

	-- Check if it's near the hammer
	if caster.utherhammer and not caster.utherhammer:IsNull() then
		local distance = (caster.utherhammer:GetAbsOrigin() - target:GetAbsOrigin()):Length2D()
		if distance <= 100 then
			target:RemoveModifierByName("modifier_bolt_dummy")
		end
	end
end

function LoseHP (keys) -- KV OnAttacked
	local caster = keys.caster
	local attacker = keys.attacker
	local target = keys.target
	target.attacksneeded = target:GetHealth()

	--If uther himself attacks then destroy else remove 1 hp

	if caster:GetTeamNumber() == attacker:GetTeamNumber() then
		target:RemoveModifierByName("modifier_bolt_dummy")
	elseif caster:GetTeamNumber() ~= attacker:GetTeamNumber() then
		target.attacksneeded = target.attacksneeded - 1
		if target.attacksneeded > 0 then
			target:SetHealth(target.attacksneeded)
		end
		if target.attacksneeded <= 0 then
			target:RemoveModifierByName("modifier_bolt_dummy")
		end
	end
end


function destroy (keys) -- KV OnDestroy
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	local explosionRadius = ability:GetSpecialValueFor("explosion_radius")

	--Damage every unit around

	local targets =  FindUnitsInRadius(caster:GetTeamNumber(), target:GetOrigin(), nil, explosionRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _, unit in pairs(targets) do
		local DamageTable =
		{
			victim = unit,
			attacker = caster,
			damage = ability:GetLevelSpecialValueFor("damage",ability:GetLevel()-1),
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = ability,
		}
		ApplyDamage(DamageTable)
	end
	target:EmitSound("Hero_Sven.StormBoltImpact")
	target:EmitSound("Hero_KeeperOfTheLight.BlindingLight")
	--Reset values
	target.attacksneeded = nil

	--Explosing effect
	local effect = ParticleManager:CreateParticle("particles/units/heroes/hero_sven/sven_storm_bolt_projectile_explosion.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:SetParticleControl(effect,0,target:GetOrigin())
	ParticleManager:SetParticleControl(effect,1,target:GetOrigin())
	ParticleManager:SetParticleControl(effect,2,target:GetOrigin())
	ParticleManager:SetParticleControl(effect,3,target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)

	local effect2 = ParticleManager:CreateParticle("particles/units/heroes/hero_keeper_of_the_light/keeper_of_the_light_recall_source.vpcf",PATTACH_ABSORIGIN,caster)
	ParticleManager:SetParticleControl(effect2,0,target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect2)
	-- Remove the unit from the game
	target:RemoveSelf()
end
