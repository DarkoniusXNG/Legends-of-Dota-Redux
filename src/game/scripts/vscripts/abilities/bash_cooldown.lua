LinkLuaModifier('modifier_bash_cooldown', 'abilities/bash_cooldown.lua', LUA_MODIFIER_MOTION_NONE)

modifier_bash_cooldown = class({
	IsPurgable = function() return false end,
	GetTexture = function() return 'spirit_breaker_greater_bash' end,
})

function BashCooldown( filterTable )
	local pIndex = filterTable.entindex_parent_const
	local cIndex = filterTable.entindex_caster_const
	local aIndex = filterTable.entindex_ability_const
	if not pIndex or not cIndex or not aIndex then
		return true
	end

	local parent = EntIndexToHScript(pIndex)
	local caster = EntIndexToHScript(cIndex)
	local ability = EntIndexToHScript(aIndex)
	local modifierName = filterTable.name_const
	local duration = filterTable.duration
	local bFilter
	if ability and not ability:IsNull() then
		local abilityName = ability:GetAbilityName()
		-- Reflect only modifiers created by abilities with 'bash' flag
		-- All bash abilities adds passive modifier on it's caster, so we should ignore it
		if (ability:HasAbilityFlag('bash') or abilityName == "item_basher" or abilityName == "item_abyssal_blade") and parent ~= caster then
			bFilter = true
		end
	elseif modifierName == "modifier_bashed" and parent ~= caster then
		bFilter = true
	end

	if bFilter then
		if parent:HasModifier('modifier_bash_cooldown') then
			-- Unit was bashed in a short time. Don't add this modifier
			return false
		else
			-- Unit already bashed. Add cooldown modifier for 5s, so it won't be bashed again
			parent:AddNewModifier(caster, nil, 'modifier_bash_cooldown', {duration = 5})
			Timers:CreateTimer(function() trackModifier( filterTable ) end)
		end
	end
	return true
end

function trackModifier( filterTable )
	local parentIndex = filterTable["entindex_parent_const"]
	local casterIndex = filterTable["entindex_caster_const"]
	if not parentIndex or not casterIndex then
		return
	end
	local parent = EntIndexToHScript( parentIndex )
	local caster = EntIndexToHScript( casterIndex )
	local modifierName = filterTable["name_const"]
	local duration = filterTable["duration"]

	Timers:CreateTimer(0.1, function()
		if not parent or parent:IsNull() or not caster or caster:IsNull() then return end
		local modifier = parent:FindModifierByNameAndCaster(modifierName, caster)
		if not modifier or modifier:IsNull() then return end
		local elapsed = modifier:GetElapsedTime()
		local remaining = modifier:GetRemainingTime()

		modifier.prevElapsed = modifier.prevElapsed or elapsed

		if parent:HasModifier("modifier_bash_cooldown") then
			-- Check if duration of the original bash is extended
			if elapsed > duration or remaining > duration or modifier.prevElapsed > elapsed then
				modifier:Destroy()
			end
			return 0.1
		else
			return
		end
	end)
end
