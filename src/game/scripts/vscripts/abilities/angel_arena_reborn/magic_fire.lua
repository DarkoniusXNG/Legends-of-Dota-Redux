function mana_burn_function( keys )
	-- Variables
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local damage_pct = keys.dmg_pct

	local current_mana = target:GetMana()
	local mana_burning = ability:GetLevelSpecialValueFor( "damage", ability:GetLevel() - 1 )
	local damageType = ability:GetAbilityDamageType()
	local mana_to_burn = math.min( current_mana, mana_burning )
	local bonus_dmg = target:GetHealth() * damage_pct / 100

	-- Fail check
	if target:IsMagicImmune() or target:IsDebuffImmune() then
		mana_to_burn = 0
	end

	if mana_to_burn ~= mana_burning then
		bonus_dmg = 0
	end
	-- Apply effect of ability
	target:Script_ReduceMana( mana_to_burn, ability )

	local damageTable = {
		victim = target,
		attacker = caster,
		damage = mana_to_burn + bonus_dmg,
		damage_type = damageType,
		ability = ability
	}
	ApplyDamage( damageTable )

	-- Particle constants
	local digits = string.len( math.floor( mana_to_burn ) ) + 1
	local life_time = 2.0
	local number_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn_msg.vpcf"
	local burn_particle_name = "particles/units/heroes/hero_nyx_assassin/nyx_assassin_mana_burn.vpcf"

	-- Particles
	local numberIndex = ParticleManager:CreateParticle( number_particle_name, PATTACH_OVERHEAD_FOLLOW, target )
	ParticleManager:SetParticleControl( numberIndex, 1, Vector( 1, mana_to_burn, 0 ) )
    ParticleManager:SetParticleControl( numberIndex, 2, Vector( life_time, digits, 0 ) )
	local burnIndex = ParticleManager:CreateParticle( burn_particle_name, PATTACH_ABSORIGIN, target )

	-- Create timer to properly destroy particles
	Timers:CreateTimer( life_time, function()
		ParticleManager:DestroyParticle( numberIndex, false )
		ParticleManager:DestroyParticle( burnIndex, false)
		ParticleManager:ReleaseParticleIndex(numberIndex)
		ParticleManager:ReleaseParticleIndex(burnIndex)
	end)
end
