function onHealingWardSpawn(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local radius = ability:GetSpecialValueFor("radius")

    local particle = ParticleManager:CreateParticle("particles/juggernaut_healing_wardmana.vpcf", PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, 0, 0))
    ParticleManager:SetParticleControlEnt(particle, 2, target, PATTACH_POINT_FOLLOW, "flame_attachment", target:GetAbsOrigin(), true)
    target:FindModifierByName("modifier_healing_ward_mana_aura"):AddParticle(particle, false, false, 1, false, false)
    target:Interrupt()
    Timers:CreateTimer(function()
        target:MoveToNPC(caster)
        return
    end, DoUniqueString('move_ward'), 0.1)
end


function healingWardMana(keys)
    local ability = keys.ability
    local target = keys.target
    local healing_ward_mana_restore_pct = 0.01 * ability:GetLevelSpecialValueFor("healing_ward_mana_restore_pct",ability:GetLevel()-1) * 0.04
    
    target:GiveMana(target:GetMaxMana()*healing_ward_mana_restore_pct)
end
