--[[	Author: Firetoad
		Date: 06.09.2015	]]

require('lib/util_imba')

function AIControl( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- If the ability is on cooldown or tower is affected by break, do nothing
	if not ability:IsCooldownReady() or caster:PassivesDisabled() then
		return
	end

	-- Parameters
	local tower_loc = caster:GetAbsOrigin()
	local nearbyEnemyRadius = 800 -- normal night vision
	local nearbyAllyRadius = 1200 -- normal aura (same as ability cast range)
	local veryCloseEnemyRadius = 600 -- within tower attack range
	local veryCloseAllyRadius = 800 -- normal night vision / maximum tpscroll teleport distance

	-- Find nearby enemies
	local EnemyInRange = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, nearbyEnemyRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
	if #EnemyInRange == 0 then return end

	local enemy_buildings = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	local closest_building = enemy_buildings[1]
	if not closest_building then return end

	local AllyInRange = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, nearbyAllyRadius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
	local veryCloseAllies = 0
	for _, ally in pairs(AllyInRange) do
		if (tower_loc - ally:GetAbsOrigin()):Length2D() <= veryCloseAllyRadius then
			veryCloseAllies = veryCloseAllies + 1
		end
	end

	-- IF TOWER IS VULNERABLE AND DOES NOT HAVE BACK DOOR PROTECTION AND ONLY 1 or 0 ENEMY NEARBY -> attack the tower
	-- IF TOWER IS INVULNERABLE -> scare the bots away
	for _,enemy in pairs(EnemyInRange) do
		if enemy and not enemy:IsNull() then
			if util:isPlayerBot(enemy:GetPlayerID()) and not enemy:IsChanneling() then
				local distance = (tower_loc - enemy:GetAbsOrigin()):Length2D()
				-- IF BOT IS ABOUT TO DIE, SAVE IT AND TELEPORT IT TO THE NEAREST (allied to the bot) BUILDING WITH FULL HP and MP only if there are no enemies (to the bot)
				if enemy:GetHealth() < 300 and not enemy:HasModifier("modifier_pugna_decrepify") and #AllyInRange == 0 then
					enemy:AddNewModifier(caster, ability, "modifier_pugna_decrepify", {duration = 5})
					--enemy:AddNewModifier(caster, ability, "modifier_chen_test_of_faith_teleport", {duration = 5}) -- this doesnt teleport them to base anymore lmao
					ability:StartCooldown(ability:GetCooldown(-1))
					Timers:CreateTimer(1, function()
						if enemy and not enemy:IsNull() then
							enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = 4})
						end
					end)
					Timers:CreateTimer(5, function()
						if enemy and not enemy:IsNull() and enemy:IsAlive() then
							local random_loc = closest_building:GetAbsOrigin() + RandomVector(veryCloseAllyRadius)
							FindClearSpaceForUnit(enemy, random_loc, true)
							enemy:SetHealth(enemy:GetMaxHealth())
							enemy:SetMana(enemy:GetMaxMana())
							--enemy:AddNewModifier(caster, ability, "modifier_dark_seer_surge", {duration = 30}) -- doesnt work, 0 bonus ms
							enemy:AddExperience(100, DOTA_ModifyXP_Unspecified, true, false)
							enemy:ModifyGold(100, false, DOTA_ModifyGold_Unspecified)
						end
					end)
	            elseif #AllyInRange <= 1 then
					local invulnerable = caster:HasModifier("modifier_tower_anti_rat") or caster:HasModifier("modifier_invulnerable") or caster:HasModifier("modifier_backdoor_protection_active")
					if distance <= veryCloseEnemyRadius then
						if invulnerable then
							--if caster:HasModifier("modifier_tower_anti_rat") then
								--enemy:AddNewModifier(caster, ability, "modifier_chen_test_of_faith_teleport", {duration = 4}) -- this doesnt teleport them to base anymore lmao
							--end
							local abilityRoar = caster:FindAbilityByName("lone_druid_savage_roar_tower")
							if abilityRoar then
								caster:CastAbilityImmediately(abilityRoar, caster:GetPlayerOwnerID())
							end
							enemy:AddNewModifier(caster, ability, "modifier_phased", {duration = 4})
							--enemy:AddNewModifier(caster, ability, "modifier_dark_seer_surge", {duration = 4}) -- doesnt work, 0 bonus ms
							ability:StartCooldown(ability:GetCooldown(-1))
						elseif enemy:GetHealth() > enemy:GetMaxHealth() * 0.75 and veryCloseAllies == 0 and not enemy:HasModifier("modifier_axe_berserkers_call") then
							enemy:AddNewModifier(caster, ability, "modifier_axe_berserkers_call", {duration = 1.5})
							ability:StartCooldown(ability:GetCooldown(-1))
						end
					elseif not enemy:HasModifier("modifier_lone_druid_savage_roar") and not enemy:HasModifier("modifier_pugna_decrepify") and #AllyInRange == 0 and not invulnerable and not enemy:HasModifier("modifier_axe_berserkers_call") then
						enemy:AddNewModifier(caster, ability, "modifier_axe_berserkers_call", {duration = 1.5})
						ability:StartCooldown(ability:GetCooldown(-1))
					end
				end
			end
		end
	end
end

function Laser( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local projectile_laser = keys.projectile_laser
	local sound_impact = keys.sound_impact

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return
	end

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return end

	-- Parameters
	local blind_aoe = ability:GetLevelSpecialValueFor("blind_aoe", ability_level)
	local projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", ability_level)
	local min_creeps = ability:GetLevelSpecialValueFor("min_creeps", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local creeps = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, blind_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, blind_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #creeps >= min_creeps or #heroes >= 1 then

		-- Emit sound
		caster:EmitSound(sound_impact)

		-- Create projectile
		local laser_projectile = {
			Source = caster,
			Ability = ability,
			EffectName = projectile_laser,
			bDodgeable = true,
			bProvidesVision = false,
			iMoveSpeed = projectile_speed,
		--	iVisionRadius = vision_radius,
		--	iVisionTeamNumber = caster:GetTeamNumber(),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		}

		-- Launch projectiles
		for _,enemy in pairs(creeps) do
			laser_projectile.Target = enemy
			ProjectileManager:CreateTrackingProjectile(laser_projectile)
		end
		for _,enemy in pairs(heroes) do
			laser_projectile.Target = enemy
			ProjectileManager:CreateTrackingProjectile(laser_projectile)
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function LaserHit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_blind = keys.modifier_blind
	local particle_blind = keys.particle_blind
	local sound_impact = keys.sound_impact

	-- Play sound
	target:EmitSound(sound_impact)

	-- Play hit particle
	local laser_pfx = ParticleManager:CreateParticle(particle_blind, PATTACH_OVERHEAD_FOLLOW, target)
	ParticleManager:SetParticleControl(laser_pfx, 1, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(laser_pfx)

	-- Apply blind modifier
	ability:ApplyDataDrivenModifier(caster, target, modifier_blind, {})
end

function HexAura( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_slow = keys.modifier_slow

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return
	end

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return end

	-- Parameters
	local hex_aoe = ability:GetLevelSpecialValueFor("hex_aoe", ability_level)
	local hex_duration = ability:GetLevelSpecialValueFor("hex_duration", ability_level)
	local min_creeps = ability:GetLevelSpecialValueFor("min_creeps", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local creeps = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, hex_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, hex_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #creeps >= min_creeps or #heroes >= 1 then

		-- Choose a random hero to be the modifier owner (having a non-hero hex modifier owner crashes the game)
		local hero_owner = HeroList:GetHero(0)

		-- Hex enemies
		for _,enemy in pairs(creeps) do
			if enemy:IsIllusion() then
				enemy:ForceKill(true)
			else
				enemy:AddNewModifier(hero_owner, ability, "modifier_sheepstick_debuff", {duration = hex_duration})
				ability:ApplyDataDrivenModifier(caster, enemy, modifier_slow, {})
			end
		end
		for _,enemy in pairs(heroes) do
			if enemy:IsIllusion() then
				enemy:ForceKill(true)
			else
				enemy:AddNewModifier(hero_owner, ability, "modifier_sheepstick_debuff", {duration = hex_duration})
				ability:ApplyDataDrivenModifier(caster, enemy, modifier_slow, {})
			end
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function ManaBurn( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local particle_burn = keys.particle_burn
	local sound_burn = keys.sound_burn

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return end

	if target.GetMaxMana == nil then
		return
	end

	-- If the target has no mana, do nothing
	if target:GetMaxMana() <= 0 then
		return
	end

	-- Parameters
	local mana_burn_pct = ability:GetLevelSpecialValueFor("mana_burn", ability_level)

	-- Calculate mana to burn
	local mana_to_burn = caster:GetAttackDamage() * mana_burn_pct / 100
	local current_mana = target:GetMana()
	local real_mana_to_burn = math.min(mana_to_burn, current_mana)

	-- Burn mana
	target:Script_ReduceMana(real_mana_to_burn, ability)

	-- Play sound
	target:EmitSound(sound_burn)

	-- Play mana burn particle
	local mana_burn_pfx = ParticleManager:CreateParticle(particle_burn, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(mana_burn_pfx, 0, target:GetAbsOrigin())
	ParticleManager:ReleaseParticleIndex(mana_burn_pfx)
end

function ManaFlare( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local particle_burn = keys.particle_burn
	local sound_burn = keys.sound_burn

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return nil end

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return
	end

	-- Parameters
	local burn_aoe = ability:GetLevelSpecialValueFor("burn_aoe", ability_level)
	local burn_pct = ability:GetLevelSpecialValueFor("burn_pct", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, burn_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #heroes >= 1 then

		-- Play sound
		caster:EmitSound(sound_burn)

		-- Iterate through enemies
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, burn_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			if enemy and not enemy:IsNull() then
				if enemy.GetMana ~= nil and enemy.GetMaxMana ~= nil then
					local max_mana = enemy:GetMaxMana()
					-- Check if enemy even has mana
					if max_mana ~= 0 then
						-- Burn mana
						local mana_to_burn = max_mana * burn_pct / 100
						local current_mana = enemy:GetMana()
						local real_mana_to_burn = math.min(mana_to_burn, current_mana)
						enemy:Script_ReduceMana(real_mana_to_burn, ability)

						-- Play mana burn particle
						local mana_burn_pfx = ParticleManager:CreateParticle(particle_burn, PATTACH_ABSORIGIN, enemy)
						ParticleManager:SetParticleControl(mana_burn_pfx, 0, enemy:GetAbsOrigin())
						ParticleManager:ReleaseParticleIndex(mana_burn_pfx)
					end
				end
			end
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function Permabash( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_bash = keys.sound_bash

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return
	end

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return end

	if target.HasModifier == nil then
		return
	end

	-- Parameters
	local bash_damage = ability:GetLevelSpecialValueFor("bash_damage", ability_level)
	local bash_duration = ability:GetLevelSpecialValueFor("bash_duration", ability_level)

	-- Play sound
	target:EmitSound(sound_bash)

	-- Apply bash modifiers
	target:AddNewModifier(caster, ability, "modifier_stunned", {duration = bash_duration})

	-- Deal damage
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = bash_damage, damage_type = DAMAGE_TYPE_MAGICAL})

	-- Put the ability on cooldown
	ability:StartCooldown(ability:GetCooldown(ability_level))
end

function Chronotower( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_stun = keys.sound_stun
	local modifier_stun = keys.modifier_stun

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return
	end

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return end

	-- Parameters
	local stun_radius = ability:GetLevelSpecialValueFor("stun_radius", ability_level)
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", ability_level)
	local min_creeps = ability:GetLevelSpecialValueFor("min_creeps", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local creeps = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, stun_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, stun_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #creeps >= min_creeps or #heroes >= 1 then

		-- Play sound
		caster:EmitSound(sound_stun)

		-- Stun enemies
		for _,enemy in pairs(creeps) do
			ability:ApplyDataDrivenModifier(caster, enemy, modifier_stun, {})
			enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
		end
		for _,enemy in pairs(heroes) do
			ability:ApplyDataDrivenModifier(caster, enemy, modifier_stun, {})
			enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function Fervor( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_fervor = keys.modifier_fervor

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return end

	-- Parameters
	local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", ability_level)

	-- Fetch current stack amount
	local current_stacks = caster:GetModifierStackCount(modifier_fervor, caster)

	-- Increase stacks if below the maximum amount
	if current_stacks < max_stacks then
		AddStacks(ability, caster, caster, modifier_fervor, 1, true)
	else
		AddStacks(ability, caster, caster, modifier_fervor, 0, true)
	end
end

function Berserk( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local modifier_berserk = keys.modifier_berserk

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return end

	-- Parameters
	local hp_per_stack = ability:GetLevelSpecialValueFor("hp_per_stack", ability_level)

	-- Calculate proper amount of stacks
	local current_hp_pct = caster:GetHealth() / caster:GetMaxHealth()
	local current_stacks = math.floor( ( 1 - current_hp_pct ) * 100 / hp_per_stack )

	-- Update stack amount
	caster:RemoveModifierByName(modifier_berserk)
	AddStacks(ability, caster, caster, modifier_berserk, current_stacks, true)
end

function Multihit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	if not ability:IsCooldownReady() then
		return
	end

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return end

	local cooldown = 0
	if caster.GetSecondsPerAttack ~= nil then
		cooldown = caster:GetSecondsPerAttack(false)
	end

	-- Parameters
	local bonus_attacks = ability:GetLevelSpecialValueFor("bonus_attacks", ability_level)
	local delay = ability:GetLevelSpecialValueFor("delay", ability_level)

	local useCastAttackOrb = true
	local processProcs = true
	local skipCooldown = true
	local ignoreInvis = true
	local useProjectile = caster:IsRangedAttacker()
	local fakeAttack = false
	local neverMiss = not caster:IsRangedAttacker()

	if cooldown <= 0 then
		cooldown = delay * (bonus_attacks + 1)
	end

	-- Perform bonus attacks
	for i = 1, bonus_attacks do
		Timers:CreateTimer(delay * i, function()
			caster:PerformAttack(target, useCastAttackOrb, processProcs, skipCooldown, ignoreInvis, useProjectile, fakeAttack, neverMiss)
		end)
	end

	ability:StartCooldown(cooldown)
end

-- used in: imba_tower_aegis_OP
function AegisUpdate( keys )
	local caster = keys.caster
	local ability = keys.ability

	-- Parameters
	local bonus_health = ability:GetLevelSpecialValueFor("bonus_health", 0)

	-- Update health
	caster:SetBaseMaxHealth(caster:GetBaseMaxHealth() + bonus_health)
	caster:SetMaxHealth(caster:GetMaxHealth() + bonus_health)
	caster:SetHealth(caster:GetHealth() + bonus_health)
end

function SelfRepairParticle( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local particle_regen = keys.particle_regen

	-- Create particle
	if not caster:IsHero() then
		local self_regen_pfx = ParticleManager:CreateParticle(particle_regen, PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(self_regen_pfx, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(self_regen_pfx, 1, caster:GetAbsOrigin())
		ParticleManager:ReleaseParticleIndex(self_regen_pfx)
	end
end

function Spacecow( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_creep = keys.sound_creep
	local sound_hero = keys.sound_hero

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return
	end

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return end

	-- Parameters
	local knockback_damage = ability:GetLevelSpecialValueFor("knockback_damage", ability_level)
	local knockback_distance = ability:GetLevelSpecialValueFor("knockback_distance", ability_level)
	local knockback_duration = ability:GetLevelSpecialValueFor("knockback_duration", ability_level)
	local knockback_origin = caster:GetAbsOrigin()

	-- Play appropriate sound
	if target:IsHero() then
		target:EmitSound(sound_hero)
	else
		target:EmitSound(sound_creep)
	end

	-- Knockback target
	local knockback_param =
	{	should_stun = 1,
		knockback_duration = knockback_duration,
		duration = knockback_duration,
		knockback_distance = knockback_distance,
		knockback_height = knockback_distance / 4,
		center_x = knockback_origin.x,
		center_y = knockback_origin.y,
		center_z = knockback_origin.z
	}
	target:RemoveModifierByName("modifier_knockback")
	target:AddNewModifier(caster, nil, "modifier_knockback", knockback_param)

	-- Deal damage
	ApplyDamage({attacker = caster, victim = target, ability = ability, damage = knockback_damage, damage_type = DAMAGE_TYPE_MAGICAL})

	-- Put the ability on cooldown
	ability:StartCooldown(ability:GetCooldown(ability_level))
end

function Force( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_force = keys.sound_force

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return
	end

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return end

	-- Parameters
	local force_aoe = ability:GetLevelSpecialValueFor("force_aoe", ability_level)
	local force_distance = ability:GetLevelSpecialValueFor("force_distance", ability_level)
	local force_duration = ability:GetLevelSpecialValueFor("force_duration", ability_level)
	local min_creeps = ability:GetLevelSpecialValueFor("min_creeps", ability_level)
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local creeps = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, force_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, force_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #creeps >= min_creeps or #heroes >= 1 then

		-- Play sound
		caster:EmitSound(sound_force)

		-- Set up knockback parameters
		local knockback_param =
		{	should_stun = 1,
			knockback_duration = force_duration,
			duration = force_duration,
			knockback_distance = force_distance,
			knockback_height = 0,
			center_x = tower_loc.x,
			center_y = tower_loc.y,
			center_z = tower_loc.z
		}

		-- Knockback creeps OUT
		for _, enemy in pairs(creeps) do
			enemy:RemoveModifierByName("modifier_knockback")
			enemy:AddNewModifier(caster, nil, "modifier_knockback", knockback_param)
		end
		-- Pull heroes IN
		for _, enemy in pairs(heroes) do
			-- Calculate distance from tower
			local distance = (enemy:GetAbsOrigin() - tower_loc):Length2D()
			local direction = (enemy:GetAbsOrigin() - tower_loc):Normalized()
			local knockback_source_loc = enemy:GetAbsOrigin() + direction * 150

			-- Set up knockback parameters
			knockback_param =
			{	should_stun = 0,
				knockback_duration = force_duration,
				duration = force_duration,
				knockback_distance = distance-180,
				knockback_height = 0,
				center_x = knockback_source_loc.x,
				center_y = knockback_source_loc.y,
				center_z = knockback_source_loc.z
			}

			enemy:RemoveModifierByName("modifier_knockback")
			enemy:AddNewModifier(caster, nil, "modifier_knockback", knockback_param)
			enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function Nature( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_root = keys.sound_root
	local modifier_root = keys.modifier_root

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return
	end

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return end

	-- Parameters
	local root_radius = ability:GetLevelSpecialValueFor("root_radius", ability_level)
	local min_creeps = ability:GetLevelSpecialValueFor("min_creeps", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local creeps = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, root_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, root_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #creeps >= min_creeps or #heroes >= 1 then

		-- Play sound
		caster:EmitSound(sound_root)

		-- Root enemies
		for _,enemy in pairs(creeps) do
			ability:ApplyDataDrivenModifier(caster, enemy, modifier_root, {})
		end
		for _,enemy in pairs(heroes) do
			ability:ApplyDataDrivenModifier(caster, enemy, modifier_root, {})
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function Mindblast( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_silence = keys.sound_silence
	local modifier_silence = keys.modifier_silence

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return
	end

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return end

	-- Parameters
	local silence_radius = ability:GetLevelSpecialValueFor("silence_radius", ability_level)
	local silence_duration = ability:GetLevelSpecialValueFor("silence_duration", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, silence_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #heroes >= 1 then

		-- Play sound
		caster:EmitSound(sound_silence)

		-- Silence enemies
		local enemies = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, silence_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
		for _, enemy in pairs(enemies) do
			if enemy and not enemy:IsNull() then
				ability:ApplyDataDrivenModifier(caster, enemy, modifier_silence, {duration = silence_duration})
			end
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function PlasmaField( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	if not ability:IsCooldownReady() then
		return
	end

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return end

	-- Parameters
	local plasma_radius = ability:GetLevelSpecialValueFor("radius", ability_level)
	local min_creeps = ability:GetLevelSpecialValueFor("min_creeps", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local heroes = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, plasma_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)
	local creeps = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, plasma_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #heroes >= 1 or #creeps >= min_creeps then
		local plasma = caster:FindAbilityByName("plasma_internal_tower")
		if not plasma then
			plasma = caster:AddAbility("plasma_internal_tower")
			plasma:SetHidden(true)
			plasma:SetLevel(ability_level)
		end
		plasma:SetLevel(ability_level)

		plasma:OnSpellStart()

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function DeathPulse( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1

	if not ability:IsCooldownReady() then
		return
	end

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return end

	-- Parameters
	local radius = ability:GetLevelSpecialValueFor("area_of_effect", ability_level)
	local tower_loc = caster:GetAbsOrigin()

	-- Find nearby enemies
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), tower_loc, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_ANY_ORDER, false)

	-- Check if the ability should be cast
	if #enemies >= 1 then
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_imba_tower_death_pulse_cast", {})
		ability:UseResources(true, false, false, true)
	end
end

function DeathPulseHit( keys )
	local ability = keys.ability
	local caster = keys.caster
	local target = keys.target
	if target and not target:IsNull() and ability and caster and not caster:IsNull() then
		local ability_level = ability:GetLevel() - 1
		local damageHeal = ability:GetLevelSpecialValueFor("healdamage", ability_level)
		if target:GetTeam() ~= caster:GetTeam() then
			ApplyDamage({victim = target, attacker = caster, ability = ability, damage = damageHeal, damage_type = DAMAGE_TYPE_MAGICAL})
		else
			target:Heal(damageHeal, ability)
		end
	end
end

function Forest( keys )
	local caster = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local sound_tree = keys.sound_tree
	local abilityName = ability:GetAbilityName()

	-- If the ability is on cooldown, do nothing
	if not ability:IsCooldownReady() then
		return
	end

	if not caster:IsRealHero() and not caster:IsBuilding() and abilityName ~= "imba_tower_forest_generator" then return end

	if caster:PassivesDisabled() then return end

	-- Parameters
	local tree_radius = ability:GetLevelSpecialValueFor("tree_radius", ability_level)
	local tree_duration = ability:GetLevelSpecialValueFor("tree_duration", ability_level)

	-- Tree generator for black forest mutator
	if abilityName == "imba_tower_forest_generator" then

		-- FOREST CALIBRATION SETTINGS
		local treeBufferDistance = 205 --How far trees should be apart
		local treeBufferDistanceRiver = 300
		local nearbyUnitsRadius = 300
		local nearbyTowersRadius = 600
		local nearbyNeutralCampRadius = 500
		local nearbyAncientRadius = 1000
		local nearbyShrineRadius = 400
		local nearbyShrineRadius = 400
		--local totalTreeLimit = 2000
		-- END SETTINGS

        local tree_loc = Vector(RandomInt(-7136, 7136), RandomInt(-7136, 7136), 384)
        tree_loc.z = GetGroundHeight(tree_loc, caster)

        --local allTrees = Entities:FindAllByClassnameWithin("dota_temp_tree",tree_loc, 99999)

        if tree_loc.z ~= 384 and tree_loc.z ~= 128 and tree_loc.z ~= 256 then
			return
		end

		--print(tree_loc.z)
		if tree_loc.z == 128 then treeBufferDistance = treeBufferDistanceRiver end -- If in river area, spreadout trees more

		-- Condition checks
		local nearbyUnits = FindUnitsInRadius(caster:GetTeamNumber(), tree_loc, nil, nearbyUnitsRadius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, FIND_ANY_ORDER, false)
		if #nearbyUnits > 0 then return end

		local nearbyTowers = Entities:FindAllByClassnameWithin("npc_dota_tower",tree_loc, nearbyTowersRadius)
        if #nearbyTowers > 0 then return end

        local nearbyCamp = Entities:FindByNameNearest("neutralcamp_*", tree_loc, nearbyNeutralCampRadius)
        if nearbyCamp then return end

        local nearbyAncients = Entities:FindByNameNearest("*_fort*", tree_loc, nearbyAncientRadius)
        if nearbyAncients then return end

        local nearbyShrines = Entities:FindAllByClassnameWithin("npc_dota_healer",tree_loc, nearbyShrineRadius)
        if #nearbyShrines > 0 then return end

        local nearbytrees = GridNav:GetAllTreesAroundPoint( tree_loc, treeBufferDistance, false )
        if #nearbytrees > 0 then return end

        if GridNav:IsTraversable(tree_loc) == false or GridNav:IsBlocked(tree_loc) then return end

		createTempTreePretty(tree_loc, tree_duration, caster)
	else
		-- Play sound
		caster:EmitSound(sound_tree)

		-- Create a tree on a random location
		local tree_loc = caster:GetAbsOrigin() + RandomVector(100):Normalized() * RandomInt(100, tree_radius)
		createTempTreePretty(tree_loc, tree_duration, caster)

		local unitsInRadius = FindUnitsInRadius(caster:GetTeamNumber(), tree_loc, nil, 256, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
		for _, unit in pairs(unitsInRadius) do
			FindClearSpaceForUnit(unit,unit:GetAbsOrigin(),true)
		end

		-- Put the ability on cooldown
		ability:StartCooldown(ability:GetCooldown(ability_level))
	end
end

function createTempTreePretty( tree_loc, duration, owner )
	CreateTempTree(tree_loc, duration)

	local nearbyTempTrees = Entities:FindAllInSphere(tree_loc, 10)
	for _, unit in pairs(nearbyTempTrees) do
		if unit:GetClassname() == "dota_temp_tree" then
			-- Figure out what side of the map is the tree on
			local treeSide
			local goodancients = Entities:FindAllByName("dota_goodguys_fort")
			local distancetoGoodAncient = CalcDistanceBetweenEntityOBB( goodancients[1], unit )

			local badancients = Entities:FindAllByName("dota_badguys_fort")
			distancetoBadAncient = CalcDistanceBetweenEntityOBB( badancients[1], unit )

			-- If its close enough to an ancient its safe to assume its on the dire/radiant side
			if distancetoGoodAncient < 7300 then
				treeSide = "radiant"
			elseif distancetoBadAncient < 7300 then
				treeSide = "dire"
			end

			-- If we couldnt determine side by measuring distance to ancients resort to measuring nearest neutral camps
			if treeSide == nil then
				local closestneutralcamp = Entities:FindByNameNearest("neutralcamp_*", unit:GetAbsOrigin(), 6000)
				local nameOfCamp = closestneutralcamp:GetName()
				if nameOfCamp:match("_good_") then
					treeSide = "radiant"
				elseif nameOfCamp:match("_evil_") then
					treeSide = "dire"
				end
			end
			if treeSide == nil then
				local team = owner:GetTeamNumber()
				if team == DOTA_TEAM_GOODGUYS then
					treeSide = "radiant"
				else
					treeSide = "dire"
				end
			end

			local chance
			if treeSide == "dire" then
				chance = RandomInt(1, 6)
			end
			if treeSide == "radiant" then
				chance = RandomInt(7, 13)
			end

			local Trees = {
			   [1] = {"models/props_tree/dire_tree001.vmdl", 1},
			   [2] = {"models/props_tree/dire_tree002.vmdl", 1},
			   [3] = {"models/props_tree/dire_tree004b_sfm.vmdl", 1},
			   [4] = {"models/props_tree/dire_tree007_sfm.vmdl", .5},
			   [5] = {"models/props_tree/dire_tree003.vmdl", 1.2},
			   [6] = {"models/props_tree/dire_tree005.vmdl", 1},
			   [7] = {"models/props_tree/tree_oak_01_sfm.vmdl", 0.5},
			   [8] = {"models/props_tree/tree_oak_00.vmdl", 1},
			   [9] = {"models/props_tree/tree_oak_01b_sfm.vmdl", 0.8},
			   [10] = {"models/props_tree/tree_oak_02_sfm.vmdl", 0.35},
			   [11] = {"models/props_tree/tree_pine_01_sfm.vmdl", 0.5},
			   [12] = {"models/props_tree/tree_pine_02_sfm.vmdl", 0.4},
			   [13] = {"models/props_tree/tree_pine_03b_sfm.vmdl", 1},
			}

			unit:SetModel(Trees[chance][1])
			unit:SetModelScale(Trees[chance][2])

			if RollPercentage(25) then
				local size = RandomFloat(.8, 1.6)
				unit:SetModelScale(unit:GetModelScale() * size)
			end

			if RollPercentage(1) then
				unit:SetModelScale(unit:GetModelScale() * 3)
			end

			if chance == 5 or chance == 6 then
				unit:SetRenderColor(160, 160, 160)
			end

			if chance == 7 or chance == 12 or chance == 11 or chance == 13 then
				local colorChance = RandomInt(1, 4)
				if colorChance == 2 then
					unit:SetRenderColor(255,192,203)
				elseif colorChance == 3 then
					unit:SetRenderColor(255,215,0)
				elseif colorChance == 3 then
					unit:SetRenderColor(162, 163, 3)
				end
			end
		end
	end
end

function Cannon( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local particle_explosion = keys.particle_explosion

	if caster:PassivesDisabled() then return end

	if not caster:IsRealHero() and not caster:IsBuilding() then return end

	-- Parameters
	local salvo_aoe = ability:GetLevelSpecialValueFor("salvo_aoe", ability_level)
	local salvo_dmg = ability:GetLevelSpecialValueFor("salvo_dmg", ability_level)
	local target_loc = target:GetAbsOrigin()

	-- Find nearby enemies
	local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target_loc, nil, salvo_aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

	-- Play particle
	target_loc = target_loc + Vector(0, 0, 100)
	local explosion_pfx = ParticleManager:CreateParticle(particle_explosion, PATTACH_CUSTOMORIGIN, caster)
	ParticleManager:SetParticleControl(explosion_pfx, 0, target_loc)
	ParticleManager:SetParticleControl(explosion_pfx, 3, target_loc)
	ParticleManager:ReleaseParticleIndex(explosion_pfx)

	-- Deal bonus damage to enemies
	for _, enemy in pairs(enemies) do
		if enemy and not enemy:IsNull() then
			ApplyDamage({attacker = caster, victim = enemy, ability = ability, damage = salvo_dmg, damage_type = DAMAGE_TYPE_MAGICAL})
		end
	end
end
