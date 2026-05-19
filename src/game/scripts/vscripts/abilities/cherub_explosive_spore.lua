function CreateExplosiveSpore(keys)
	local caster = keys.caster
    local ability = keys.ability
    local point = ability:GetCursorPosition() -- --keys.target_points[1]

    local ability_level = ability:GetLevel()
    local owner = caster:GetOwner()
    local fv = caster:GetForwardVector()
    local playerid = caster:GetPlayerID()

    local duration = ability:GetLevelSpecialValueFor("delay", ability_level - 1)

    local spore = CreateUnitByName("explosive_spore", point, false, owner, owner, caster:GetTeamNumber() )
    spore:SetControllableByPlayer(playerid, true)
    spore:SetForwardVector(fv)

    ability:ApplyDataDrivenModifier(caster, spore, "modifier_explosive_spore", {})
    spore:AddNewModifier(caster, nil, "modifier_phased", {duration = 0.03})
    spore:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})

    spore:EmitSound("Hero_Broodmother.SpawnSpiderlings")
end

function ExplosiveSporeDamageAndHeal(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

    local ability_level = ability:GetLevel()
    local damage = ability:GetLevelSpecialValueFor("damage", ability_level - 1)
    local spell_lifesteal = ability:GetLevelSpecialValueFor("lifesteal_hero", ability_level - 1)

    local spell_lifesteal_penalty_against_creeps = 80

    -- Needs to be done before the damage
    local isTargetHero = target:IsRealHero() or target:IsStrongIllusionCustom()

	local damage_table = {
        attacker = caster,
        ability = ability,
        victim = target,
        damage = damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
    }

    local damage_done = ApplyDamage(damage_table)

    -- Don't heal while dead
    if not caster:IsAlive() then
        return
    end

    -- Check damage if 0 or negative
    if damage_done <= 0 then
        return
    end

    -- Calculate the lifesteal (heal) amount
    local spell_lifesteal_amount = 0
    if isTargetHero then
        spell_lifesteal_amount = damage_done * spell_lifesteal / 100
    else
        -- Illusions are treated as creeps too
        spell_lifesteal_amount = damage_done * (spell_lifesteal / 100) * (1 - spell_lifesteal_penalty_against_creeps / 100)
    end

    -- Particle and spell lifesteal
    if spell_lifesteal_amount > 0 then
        -- Spell Lifesteal
        caster:HealWithParams(spell_lifesteal_amount, ability, false, true, caster, true)
        local particle1 = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ParticleManager:SetParticleControl(particle1, 0, caster:GetAbsOrigin())
        ParticleManager:ReleaseParticleIndex(particle1)
    end
end
