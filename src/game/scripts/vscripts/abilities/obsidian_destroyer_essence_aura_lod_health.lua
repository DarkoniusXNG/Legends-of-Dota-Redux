function RestoreHealth(keys)
    local trigger_ability = keys.event_ability
    if util:IsIgnoredForEssenceAura(trigger_ability) then return end

    -- Grab ability
    local target = keys.unit
    local ability = keys.ability
	local caster = keys.caster
	
	if caster:PassivesDisabled() then return end
	
    -- Validate level
    local abLevel = ability:GetLevel()
    if abLevel <= 0 then return end

    -- Calculate how much hp to restore
    local restorePercentage = ability:GetLevelSpecialValueFor("restore_amount", abLevel - 1)
    local restoreAmount = target:GetMaxHealth() * restorePercentage / 100

	-- Heal
	target:HealWithParams(restoreAmount, ability, false, false, caster, false)

    -- Fire effects
    local prt = ParticleManager:CreateParticle('particles/items2_fx/urn_of_shadows_heal_c.vpcf', PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(prt)

    -- Fire sound
    target:EmitSound('DOTA_Item.FaerieSpark.Activate')
end
