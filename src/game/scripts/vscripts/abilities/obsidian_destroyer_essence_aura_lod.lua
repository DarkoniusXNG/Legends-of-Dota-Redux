function RestoreMana(keys)
    local trigger_ability = keys.event_ability
    if util:IsIgnoredForEssenceAura(trigger_ability) then return end

    -- Grab ability
    local target = keys.unit
    local ability = keys.ability
	local caster = keys.caster
	
	if caster:PassivesDisabled() then return end
	
    -- Validate level
    if ability == nil or ability:GetLevel() <= 0 then return end
    local abLevel = ability:GetLevel()

    -- Calculate how much mana to restore
    local restorePercentage = ability:GetLevelSpecialValueFor("restore_amount", abLevel -1)
    local restoreAmount = target:GetMaxMana() * restorePercentage / 100
	
	-- Restore mana
	target:GiveMana(restoreAmount)

    -- Fire effects
    local prt = ParticleManager:CreateParticle('particles/units/heroes/hero_obsidian_destroyer/obsidian_destroyer_essence_effect.vpcf', PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(prt)

    -- Fire sound
    target:EmitSound('Hero_ObsidianDestroyer.EssenceFlux.Cast')
end
