--[[
	Author: Noya
	Date: 25.01.2015.
	Creates a dummy unit to apply the Blizzard thinker modifier which does the waves
]]
function BlizzardStart( event )
	-- Variables
	local caster = event.caster
	local ability = event.ability
	local point = ability:GetCursorPosition() --event.target_points[1]

	caster.blizzard_dummy = CreateUnitByName("dummy_unit", point, false, caster, caster, caster:GetTeam())
	local wave_interval = ability:GetSpecialValueFor("wave_interval")
	local wave_count = ability:GetSpecialValueFor("wave_count")	

	local duration = (wave_count-1) * wave_interval + 0.1 -- total thinker (blizzard) duration

	ability:ApplyDataDrivenModifier(caster, caster.blizzard_dummy, "modifier_blizzard_thinker", {duration = duration})
end

-- Create the particles with small delays between each other
function BlizzardWave( event )
	local caster = event.caster

	local target_position = event.target:GetAbsOrigin() --event.target_points[1]
    local particleName = "particles/units/heroes/hero_crystalmaiden/maiden_freezing_field_explosion.vpcf"
    local distance = 100

    -- Center explosion
    local particle1 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
	ParticleManager:SetParticleControl( particle1, 0, target_position )
	ParticleManager:ReleaseParticleIndex(particle1)

    Timers:CreateTimer(0.05,function()
		local particle2 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( particle2, 0, target_position+RandomVector(distance) )
		ParticleManager:ReleaseParticleIndex(particle2)
	end)

    Timers:CreateTimer(0.1,function()
		local particle3 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( particle3, 0, target_position-RandomVector(distance) )
		ParticleManager:ReleaseParticleIndex(particle3)
	end)

    Timers:CreateTimer(0.15,function()
		local particle4 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( particle4, 0, target_position+RandomVector(RandomInt(50,distance)) )
		ParticleManager:ReleaseParticleIndex(particle4)
	end)

    Timers:CreateTimer(0.2,function()
		local particle5 = ParticleManager:CreateParticle( particleName, PATTACH_CUSTOMORIGIN, caster )
		ParticleManager:SetParticleControl( particle5, 0, target_position-RandomVector(RandomInt(50,distance)) )
		ParticleManager:ReleaseParticleIndex(particle5)
	end)
end

function BlizzardEnd( event )
	local caster = event.caster

	caster.blizzard_dummy:RemoveSelf()
	StopSoundOn("hero_Crystal.freezingField.wind", caster)
end
