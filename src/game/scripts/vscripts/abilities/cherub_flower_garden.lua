function GardenCheck( keys )
    local caster = keys.caster
    local ability = keys.ability
    local healthCost = caster:GetMaxHealth()*0.001

    if not caster:HasModifier("modifier_npc_dota_hero_enchantress_perk") then
        if caster:GetHealth() > healthCost then
            caster:ModifyHealth( caster:GetHealth() - healthCost, ability, false, 0 )
        else
            caster:Stop()
            caster:RemoveModifierByName("modifier_garden_channel")
        end
    end
end

function SetAbilityLevel( keys )
    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target


    for i=0,5 do
        local flowerAbility = target:GetAbilityByIndex(i)
        flowerAbility:SetLevel(ability:GetLevel())
    end
end

function PlantSetHealth( keys )
    local caster = keys.caster
    local owner = caster:GetPlayerOwner():GetAssignedHero()
    local target = keys.target
    local ability = keys.ability
    local abilityLevel = ability:GetLevel()
    local health = ability:GetLevelSpecialValueFor("flower_health", abilityLevel - 1 )
    local whiteDamage = ability:GetLevelSpecialValueFor("white_flower_damage", abilityLevel - 1 )
    local redDamage = ability:GetLevelSpecialValueFor("red_flower_damage", abilityLevel - 1 )

    target:SetControllableByPlayer(owner:GetPlayerID(), true)
    target:SetBaseMaxHealth(health)
    if target:GetUnitName() == "white_flower" then
        target:SetBaseDamageMin(whiteDamage - 5)
        target:SetBaseDamageMax(whiteDamage + 5)
    elseif target:GetUnitName() == "red_flower" or target:GetUnitName() == "red_flower_OP" then
        target:SetBaseDamageMin(redDamage - 10)
        target:SetBaseDamageMax(redDamage + 10)
    end
    if owner:HasScepter() then
        ability:ApplyDataDrivenModifier(owner, target, "modifier_aghs_thorns", {})
    end
end

function DamageCooldown( keys )
    local caster = keys.caster
    local ability = keys.ability

    ability:StartCooldown(3)
end

function PlantWhite( keys )
    local caster = keys.caster
    local owner = caster:GetOwner()
    local ownerAbility = owner:FindAbilityByName("cherub_flower_garden")

    owner.whiteFlowerTable = owner.whiteFlowerTable or {}

    local maxFlowers = 6
    local casterLocation = caster:GetAbsOrigin()
    if ownerAbility then
        local whiteFlower = CreateUnitByName( "white_flower", casterLocation, false, owner, owner, owner:GetTeamNumber() )
        ownerAbility:ApplyDataDrivenModifier(owner, whiteFlower, "modifier_white_flower", {})
        whiteFlower:AddNewModifier(owner, nil, "modifier_phased", {Duration = 0.03})
        --whiteFlower:SetBaseMaxHealth(flowerHealth)
        --whiteFlower:SetBaseDamageMax(flowerDamage + 5)
        --whiteFlower:SetBaseDamageMin(flowerDamage - 5)

        table.insert(owner.whiteFlowerTable, whiteFlower)
		
		local whiteFlowerCount = 0
		for k, v in pairs(owner.whiteFlowerTable) do
			if v and not v:IsNull() and v:IsAlive() then
				whiteFlowerCount = whiteFlowerCount + 1
			end
		end

        if whiteFlowerCount > maxFlowers then
			for k, f in pairs(owner.whiteFlowerTable) do
				if f and not f:IsNull() and f:IsAlive() and f ~= whiteFlower then
					f:ForceKill(false)
					break
				end
			end
        end
    end
    caster:ForceKill(false)
end

function PlantWhiteBase( keys )
    local caster = keys.caster
    local owner = caster
    local ownerAbility = owner:FindAbilityByName("garden_white_flower_base")
    local point = keys.ability:GetCursorPosition() --keys.target_points[1]

    owner.whiteFlowerTable = owner.whiteFlowerTable or {}

    local maxFlowers = 6
    local casterLocation = caster:GetAbsOrigin()
    if ownerAbility then
        local whiteFlower = CreateUnitByName( "white_flower", point, false, owner, owner, owner:GetTeamNumber() )
        ownerAbility:ApplyDataDrivenModifier(owner, whiteFlower, "modifier_white_flower", {})
        whiteFlower:AddNewModifier(owner, nil, "modifier_phased", {Duration = 0.03})

        table.insert(owner.whiteFlowerTable, whiteFlower)
		
		local whiteFlowerCount = 0
		for k, v in pairs(owner.whiteFlowerTable) do
			if v and not v:IsNull() and v:IsAlive() then
				whiteFlowerCount = whiteFlowerCount + 1
			end
		end

        if whiteFlowerCount > maxFlowers then
			for k, f in pairs(owner.whiteFlowerTable) do
				if f and not f:IsNull() and f:IsAlive() and f ~= whiteFlower then
					f:ForceKill(false)
					break
				end
			end
        end
    end
end

function OnDestroyWhite( keys )
    local owner = keys.unit:GetOwner()
    local unit = keys.unit
    for i = 1, #owner.whiteFlowerTable do
        if owner.whiteFlowerTable[i] == unit then
            table.remove(owner.whiteFlowerTable, i)
            break
        end
    end
end

function PlantRed( keys )
    local caster = keys.caster
    local owner = caster:GetOwner()
    local ownerAbility = owner:FindAbilityByName("cherub_flower_garden")
    --local flowerHealth = ownerAbility:GetLevelSpecialValueFor("flowerHealth", (ability:GetLevel() - 1))
    --local flowerDamage = ownerAbility:GetLevelSpecialValueFor("redflowerDamage", (ability:GetLevel() - 1))

    owner.redFlowerTable = owner.redFlowerTable or {}

    local maxFlowers = 6
    local casterLocation = caster:GetAbsOrigin()
    if ownerAbility then
        local redFlower = CreateUnitByName( "red_flower", casterLocation, false, owner, owner, owner:GetTeamNumber() )
        ownerAbility:ApplyDataDrivenModifier(owner, redFlower, "modifier_red_flower", {})
        redFlower:AddNewModifier(owner, nil, "modifier_phased", {Duration = 0.03})
        --redFlower:SetBaseMaxHealth(flowerHealth)
        --redFlower:SetBaseDamageMax(flowerDamage + 10)
        --redFlower:SetBaseDamageMin(flowerDamage - 10)

        table.insert(owner.redFlowerTable, redFlower)
		
		local redFlowerCount = 0
		for k, v in pairs(owner.redFlowerTable) do
			if v and not v:IsNull() and v:IsAlive() then
				redFlowerCount = redFlowerCount + 1
			end
		end

        if redFlowerCount > maxFlowers then
			for k, f in pairs(owner.redFlowerTable) do
				if f and not f:IsNull() and f:IsAlive() and f ~= redFlower then
					f:ForceKill(false)
					break
				end
			end
        end
    end
    caster:ForceKill(false)
end

function PlantRedBase( keys )
    local caster = keys.caster
    local owner = caster
    local ownerAbility = owner:FindAbilityByName("garden_red_flower_base")
    local point = keys.ability:GetCursorPosition() --keys.target_points[1]
    --local flowerHealth = ownerAbility:GetLevelSpecialValueFor("flowerHealth", (ability:GetLevel() - 1))
    --local flowerDamage = ownerAbility:GetLevelSpecialValueFor("redflowerDamage", (ability:GetLevel() - 1))

    owner.redFlowerTable = owner.redFlowerTable or {}

    local maxFlowers = 6
    local casterLocation = caster:GetAbsOrigin()
    if ownerAbility then
        local redFlower = CreateUnitByName( "red_flower", point, false, owner, owner, owner:GetTeamNumber() )
        ownerAbility:ApplyDataDrivenModifier(owner, redFlower, "modifier_red_flower", {})
        redFlower:AddNewModifier(owner, nil, "modifier_phased", {Duration = 0.03})

        table.insert(owner.redFlowerTable, redFlower)
		
		local redFlowerCount = 0
		for k, v in pairs(owner.redFlowerTable) do
			if v and not v:IsNull() and v:IsAlive() then
				redFlowerCount = redFlowerCount + 1
			end
		end

        if redFlowerCount > maxFlowers then
			for k, f in pairs(owner.redFlowerTable) do
				if f and not f:IsNull() and f:IsAlive() and f ~= redFlower then
					f:ForceKill(false)
					break
				end
			end
        end
    end
end

function PlantRedBaseOP( keys )
    local caster = keys.caster
    local owner = caster
    local ownerAbility = owner:FindAbilityByName("garden_red_flower_base_OP")
    local point = keys.ability:GetCursorPosition() --keys.target_points[1]
    --local flowerHealth = ownerAbility:GetLevelSpecialValueFor("flowerHealth", (ability:GetLevel() - 1))
    --local flowerDamage = ownerAbility:GetLevelSpecialValueFor("redflowerDamage", (ability:GetLevel() - 1))

    owner.redFlowerTable = owner.redFlowerTable or {}

    local maxFlowers = 10
    local casterLocation = caster:GetAbsOrigin()
    if ownerAbility then
        local redFlower = CreateUnitByName( "red_flower_OP", point, false, owner, owner, owner:GetTeamNumber() )
        ownerAbility:ApplyDataDrivenModifier(owner, redFlower, "modifier_red_flower", {})
        redFlower:AddNewModifier(owner, nil, "modifier_phased", {Duration = 0.03})

        table.insert(owner.redFlowerTable, redFlower)
		
		local redFlowerCount = 0
		for k, v in pairs(owner.redFlowerTable) do
			if v and not v:IsNull() and v:IsAlive() then
				redFlowerCount = redFlowerCount + 1
			end
		end

        if redFlowerCount > maxFlowers then
			for k, f in pairs(owner.redFlowerTable) do
				if f and not f:IsNull() and f:IsAlive() and f ~= redFlower then
					f:ForceKill(false)
					break
				end
			end
        end
    end
end

function OnDestroyRed( keys )
    local owner = keys.unit:GetOwner()
    local unit = keys.unit
    for i = 1, #owner.redFlowerTable do
        if owner.redFlowerTable[i] == unit then
            table.remove(owner.redFlowerTable, i)
            break
        end
    end
end

function PlantPink( keys )
    local caster = keys.caster
    local owner = caster:GetOwner()
    local ownerAbility = owner:FindAbilityByName("cherub_flower_garden")
    --local flowerHealth = ownerAbility:GetLevelSpecialValueFor("flowerHealth", (ability:GetLevel() - 1))

    owner.pinkFlowerTable = owner.pinkFlowerTable or {}

    local maxFlowers = 3
    local casterLocation = caster:GetAbsOrigin()
    if ownerAbility then
        local pinkFlower = CreateUnitByName( "pink_flower", casterLocation, false, owner, owner, owner:GetTeamNumber() )
        ownerAbility:ApplyDataDrivenModifier(pinkFlower, pinkFlower, "modifier_pink_flower", {})
        pinkFlower:AddNewModifier(owner, nil, "modifier_phased", {Duration = 0.03})
        --pinkFlower:SetBaseMaxHealth(flowerHealth)

        table.insert(owner.pinkFlowerTable, pinkFlower)
		
		local pinkFlowerCount = 0
		for k, v in pairs(owner.pinkFlowerTable) do
			if v and not v:IsNull() and v:IsAlive() then
				pinkFlowerCount = pinkFlowerCount + 1
			end
		end

		if pinkFlowerCount > maxFlowers then
			for k, f in pairs(owner.pinkFlowerTable) do
				if f and not f:IsNull() and f:IsAlive() and f ~= pinkFlower then
					f:ForceKill(false)
					break
				end
			end
        end
    end
    caster:ForceKill(false)
end

function PlantPinkBase( keys )
    local caster = keys.caster
    local owner = caster
    local ownerAbility = owner:FindAbilityByName("garden_pink_blossom_base")
    local point = keys.ability:GetCursorPosition() --keys.target_points[1]
    --local flowerHealth = ownerAbility:GetLevelSpecialValueFor("flowerHealth", (ability:GetLevel() - 1))

    owner.pinkFlowerTable = owner.pinkFlowerTable or {}

    local maxFlowers = 3
    local casterLocation = caster:GetAbsOrigin()
    if ownerAbility then
        local pinkFlower = CreateUnitByName( "pink_flower", point, false, owner, owner, owner:GetTeamNumber() )
        ownerAbility:ApplyDataDrivenModifier(pinkFlower, pinkFlower, "modifier_pink_flower", {})
        pinkFlower:AddNewModifier(owner, nil, "modifier_phased", {Duration = 0.03})

        table.insert(owner.pinkFlowerTable, pinkFlower)
		
		local pinkFlowerCount = 0
		for k, v in pairs(owner.pinkFlowerTable) do
			if v and not v:IsNull() and v:IsAlive() then
				pinkFlowerCount = pinkFlowerCount + 1
			end
		end

		if pinkFlowerCount > maxFlowers then
			for k, f in pairs(owner.pinkFlowerTable) do
				if f and not f:IsNull() and f:IsAlive() and f ~= pinkFlower then
					f:ForceKill(false)
					break
				end
			end
        end
    end
end

function HealUnits(keys)
    local caster = keys.caster
    local ability = keys.ability
    local projectileName = keys.projectile

    local nearby_allied_units = FindHealUnits(caster)

    for i, unit in ipairs(nearby_allied_units) do
        local projTable = {
            EffectName = projectileName,
            Ability = ability,
            Target = unit,
            Source = caster,
            bDodgeable = true,
            bProvidesVision = false,
            vSpawnOrigin = caster:GetAbsOrigin(),
            iMoveSpeed = 550,
            iVisionRadius = 0,
            iVisionTeamNumber = caster:GetTeamNumber(),
            iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION
        }
        ProjectileManager:CreateTrackingProjectile(projTable)
    end

end

function FindHealUnits( caster )
    local count = 0
    local maxCount = 3
    local result = {}

    local nearby_allied_units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, 500,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

    for i, unit in ipairs(nearby_allied_units) do
        if unit and unit:GetHealthPercent() < 100 then
            table.insert(result, unit)
            count = count + 1
            if count == maxCount then
                return result
            end
        end
    end
    return result
end

function OnDestroyPink( keys )
    local owner = keys.unit:GetOwner()
    local unit = keys.unit
    for i = 1, #owner.pinkFlowerTable do
        if owner.pinkFlowerTable[i] == unit then
            table.remove(owner.pinkFlowerTable, i)
            break
        end
    end
end

function PlantBlue( keys )
    local caster = keys.caster
    local owner = caster:GetOwner()
    local ownerAbility = owner:FindAbilityByName("cherub_flower_garden")
    --local flowerHealth = ownerAbility:GetLevelSpecialValueFor("flowerHealth", (ability:GetLevel() - 1))

    owner.blueFlowerTable = owner.blueFlowerTable or {}

    local maxFlowers = 4
    local casterLocation = caster:GetAbsOrigin()
    if ownerAbility then
        local blueFlower = CreateUnitByName( "blue_flower", casterLocation, false, owner, owner, owner:GetTeamNumber() )
        ownerAbility:ApplyDataDrivenModifier(blueFlower, blueFlower, "modifier_blue_flower", {})
        blueFlower:AddNewModifier(owner, nil, "modifier_phased", {Duration = 0.03})
        --blueFlower:SetBaseMaxHealth(flowerHealth)

        table.insert(owner.blueFlowerTable, blueFlower)
		
		local blueFlowerCount = 0
		for k, v in pairs(owner.blueFlowerTable) do
			if v and not v:IsNull() and v:IsAlive() then
				blueFlowerCount = blueFlowerCount + 1
			end
		end

		if blueFlowerCount > maxFlowers then
			for k, f in pairs(owner.blueFlowerTable) do
				if f and not f:IsNull() and f:IsAlive() and f ~= blueFlower then
					f:ForceKill(false)
					break
				end
			end
        end
    end
    caster:ForceKill(false)
end

function PlantBlueBase( keys )
    local caster = keys.caster
    local owner = caster
    local ownerAbility = owner:FindAbilityByName("garden_blue_blossom_base")
    local point = keys.ability:GetCursorPosition() --keys.target_points[1]
    --local flowerHealth = ownerAbility:GetLevelSpecialValueFor("flowerHealth", (ability:GetLevel() - 1))

    owner.blueFlowerTable = owner.blueFlowerTable or {}

    local maxFlowers = 4
    local casterLocation = caster:GetAbsOrigin()
    if ownerAbility then
        local blueFlower = CreateUnitByName( "blue_flower", point, false, owner, owner, owner:GetTeamNumber() )
        ownerAbility:ApplyDataDrivenModifier(blueFlower, blueFlower, "modifier_blue_flower", {})
        blueFlower:AddNewModifier(owner, nil, "modifier_phased", {Duration = 0.03})

        table.insert(owner.blueFlowerTable, blueFlower)
		
		local blueFlowerCount = 0
		for k, v in pairs(owner.blueFlowerTable) do
			if v and not v:IsNull() and v:IsAlive() then
				blueFlowerCount = blueFlowerCount + 1
			end
		end

		if blueFlowerCount > maxFlowers then
			for k, f in pairs(owner.blueFlowerTable) do
				if f and not f:IsNull() and f:IsAlive() and f ~= blueFlower then
					f:ForceKill(false)
					break
				end
			end
        end
    end
end

function BlueFlowerRestoreMana( keys )
    keys.caster:EmitSound("DOTA_Item.ArcaneBoots.Activate")
    local fxIndex = ParticleManager:CreateParticle("particles/items_fx/arcane_boots.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.caster)
    ParticleManager:ReleaseParticleIndex(fxIndex)

    local nearby_allied_units = FindUnitsInRadius(keys.caster:GetTeam(), keys.caster:GetAbsOrigin(), nil, keys.ReplenishRadius,
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)

    for i, individual_unit in ipairs(nearby_allied_units) do  --Restore mana and play a particle effect for every found ally.
        individual_unit:GiveMana(keys.ReplenishAmount)
        local fxIndex2 = ParticleManager:CreateParticle("particles/items_fx/arcane_boots_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, individual_unit)
        ParticleManager:ReleaseParticleIndex(fxIndex2)
    end
end

function OnDestroyBlue( keys )
    local owner = keys.unit:GetOwner()
    local unit = keys.unit
    for i = 1, #owner.blueFlowerTable do
        if owner.blueFlowerTable[i] == unit then
            table.remove(owner.blueFlowerTable, i)
            break
        end
    end
end

function PlantYellow( keys )
    local caster = keys.caster
    local owner = caster:GetOwner()
    local ownerAbility = owner:FindAbilityByName("cherub_flower_garden")
    --local flowerHealth = ownerAbility:GetLevelSpecialValueFor("flowerHealth", (ability:GetLevel() - 1))

    owner.yellowFlowerTable = owner.yellowFlowerTable or {}

    local maxFlowers = 2
    local casterLocation = caster:GetAbsOrigin()
    if ownerAbility then
        local yellowFlower = CreateUnitByName( "yellow_flower", casterLocation, false, owner, owner, owner:GetTeamNumber() )
        ownerAbility:ApplyDataDrivenModifier(yellowFlower, yellowFlower, "modifier_yellow_flower", {})
        yellowFlower:AddNewModifier(owner, nil, "modifier_phased", {Duration = 0.03})
        --yellow_flower:SetBaseMaxHealth(flowerHealth)

        table.insert(owner.yellowFlowerTable, yellowFlower)
		
		local yellowFlowerCount = 0
		for k, v in pairs(owner.yellowFlowerTable) do
			if v and not v:IsNull() and v:IsAlive() then
				yellowFlowerCount = yellowFlowerCount + 1
			end
		end

		if yellowFlowerCount > maxFlowers then
			for k, f in pairs(owner.yellowFlowerTable) do
				if f and not f:IsNull() and f:IsAlive() and f ~= yellowFlower then
					f:ForceKill(false)
					break
				end
			end
        end
    end
    caster:ForceKill(false)
end

function PlantYellowBase( keys )
    local caster = keys.caster
    local owner = caster
    local ownerAbility = owner:FindAbilityByName("garden_yellow_daisy_base")
    local point = keys.ability:GetCursorPosition() --keys.target_points[1]
    --local flowerHealth = ownerAbility:GetLevelSpecialValueFor("flowerHealth", (ability:GetLevel() - 1))

    owner.yellowFlowerTable = owner.yellowFlowerTable or {}

    local maxFlowers = 2
    local casterLocation = caster:GetAbsOrigin()
    if ownerAbility then
        local yellowFlower = CreateUnitByName( "yellow_flower", point, false, owner, owner, owner:GetTeamNumber() )
        ownerAbility:ApplyDataDrivenModifier(yellowFlower, yellowFlower, "modifier_yellow_flower", {})
        yellowFlower:AddNewModifier(owner, nil, "modifier_phased", {Duration = 0.03})

        table.insert(owner.yellowFlowerTable, yellowFlower)
		
		local yellowFlowerCount = 0
		for k, v in pairs(owner.yellowFlowerTable) do
			if v and not v:IsNull() and v:IsAlive() then
				yellowFlowerCount = yellowFlowerCount + 1
			end
		end

		if yellowFlowerCount > maxFlowers then
			for k, f in pairs(owner.yellowFlowerTable) do
				if f and not f:IsNull() and f:IsAlive() and f ~= yellowFlower then
					f:ForceKill(false)
					break
				end
			end
        end
    end
end

function OnDestroyYellow( keys )
    local owner = keys.unit:GetOwner()
    local unit = keys.unit
    for i = 1, #owner.yellowFlowerTable do
        if owner.yellowFlowerTable[i] == unit then
            table.remove(owner.yellowFlowerTable, i)
            break
        end
    end
end

function PlantPurple( keys )
    local caster = keys.caster
    local owner = caster:GetOwner()
    local ownerAbility = owner:FindAbilityByName("cherub_flower_garden")
    --local flowerHealth = ownerAbility:GetLevelSpecialValueFor("flowerHealth", (ability:GetLevel() - 1))

    owner.purpleFlowerTable = owner.purpleFlowerTable or {}

    local maxFlowers = 2
    local casterLocation = caster:GetAbsOrigin()
    if ownerAbility then
        local purpleFlower = CreateUnitByName( "purple_flower", casterLocation, false, owner, owner, owner:GetTeamNumber() )
        ownerAbility:ApplyDataDrivenModifier(purpleFlower, purpleFlower, "modifier_purple_flower", {})
        purpleFlower:AddNewModifier(owner, nil, "modifier_phased", {Duration = 0.03})
        --purple_flower:SetBaseMaxHealth(flowerHealth)

        table.insert(owner.purpleFlowerTable, purpleFlower)
		
		local purpleFlowerCount = 0
		for k, v in pairs(owner.purpleFlowerTable) do
			if v and not v:IsNull() and v:IsAlive() then
				purpleFlowerCount = purpleFlowerCount + 1
			end
		end

		if purpleFlowerCount > maxFlowers then
			for k, f in pairs(owner.purpleFlowerTable) do
				if f and not f:IsNull() and f:IsAlive() and f ~= purpleFlower then
					f:ForceKill(false)
					break
				end
			end
        end
    end
    caster:ForceKill(false)
end

function PlantPurpleBase( keys )
    local caster = keys.caster
    local owner = caster
    local ownerAbility = owner:FindAbilityByName("garden_purple_lotus_base")
    local point = keys.ability:GetCursorPosition() --keys.target_points[1]
    --local flowerHealth = ownerAbility:GetLevelSpecialValueFor("flowerHealth", (ability:GetLevel() - 1))

    owner.purpleFlowerTable = owner.purpleFlowerTable or {}

    local maxFlowers = 2
    local casterLocation = caster:GetAbsOrigin()
    if ownerAbility then
        local purpleFlower = CreateUnitByName( "purple_flower", point, false, owner, owner, owner:GetTeamNumber() )
        ownerAbility:ApplyDataDrivenModifier(purpleFlower, purpleFlower, "modifier_purple_flower", {})
        purpleFlower:AddNewModifier(owner, nil, "modifier_phased", {Duration = 0.03})

        table.insert(owner.purpleFlowerTable, purpleFlower)
		
		local purpleFlowerCount = 0
		for k, v in pairs(owner.purpleFlowerTable) do
			if v and not v:IsNull() and v:IsAlive() then
				purpleFlowerCount = purpleFlowerCount + 1
			end
		end

		if purpleFlowerCount > maxFlowers then
			for k, f in pairs(owner.purpleFlowerTable) do
				if f and not f:IsNull() and f:IsAlive() and f ~= purpleFlower then
					f:ForceKill(false)
					break
				end
			end
        end
    end
end

function OnDestroyPurple( keys )
    local owner = keys.unit:GetOwner()
    local unit = keys.unit
    for i = 1, #owner.purpleFlowerTable do
        if owner.purpleFlowerTable[i] == unit then
            table.remove(owner.purpleFlowerTable, i)
            break
        end
    end
end

function DestroyGarden( keys )
    keys.caster:ForceKill(false)
end
