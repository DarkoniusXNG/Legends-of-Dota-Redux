
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

	--ApplyDamage(
	--{
	--	victim = attacker_loc,
	--	attacker = caster,
	--	damage = adsorbVal,
	--	damage_type = DAMAGE_TYPE_PHYSICAL,
	--	ability = keys.ability
	--})
	--
	attacker_loc:Script_ReduceMana(adsorbVal, ability)
end


