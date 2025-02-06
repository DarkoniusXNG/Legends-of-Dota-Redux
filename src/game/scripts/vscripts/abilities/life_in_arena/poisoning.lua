
function SetAdsorbFromKret( keys )
	local attacker_loc = keys.attacker
	local caster = keys.caster
	local ability = keys.ability
	local adsorbVal = keys.adsorbVal
	--
	if attacker_loc:IsInvulnerable() then 
		return 
	end

	if caster:PassivesDisabled() then return end

	attacker_loc:Script_ReduceMana(adsorbVal, ability)
end


