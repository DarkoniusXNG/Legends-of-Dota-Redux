function FadeBlinkSetPosition( keys )
	local caster = keys.caster
	caster.point = ability:GetCursorPosition() --keys.target_points[1]
end

function FadeBlinkActive( keys )
	local caster = keys.caster
	ProjectileManager:ProjectileDodge(caster)
	if caster.point then
		FindClearSpaceForUnit(caster, caster.point, false)
	end
	caster:AddNoDraw()
	Timers:CreateTimer( 0.1, function()
		if caster and not caster:IsNull() then
			caster:RemoveNoDraw()
			caster.point = nil
		end
	end)
end

function ApplyInvisibility( keys )
	local caster = keys.caster
	local ability = keys.ability
	local invisTime = ability:GetLevelSpecialValueFor("fade_invis_time", ability:GetLevel() - 1)

	if caster:IsChanneling() then
		caster:AddNewModifier(caster, ability, "modifier_invisible", {Duration = invisTime})
		ability:ApplyDataDrivenModifier(caster, caster, "modifier_fade_invis", {Duration = invisTime})
	end
end

function StopChannelingSound(keys)
	keys.caster:StopSound("Hero_Nevermore.ROS_Cast_Flames")
end

function StopChannelingLoop(keys)
	keys.caster:StopSound("Hero_DeathProphet.Exorcism")
end