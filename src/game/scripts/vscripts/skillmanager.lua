--[[
    Skill Managing Library for swapping skills during runtime
]]

-- Load requires

local Network = require('network')
local constants = require('constants')
--local timers = require('easytimers')

-- Keeps track of what skills a given hero has
local currentSkillList = {}

-- A list of sub abilities needed to give out when we add an ability
local subAbilities = LoadKeyValues('scripts/kv/abilityDeps.kv')

-- Ability list used for multiplier
local multiplierSkills = GameRules.KVs["npc_abilities_custom"]

-- Table of player's active skills to make swapping super fast
local activeSkills = {}

local meleeMap = {
    -- Remap troll ulty
    -- troll_warlord_berserkers_rage = 'troll_warlord_berserkers_rage_melee'
}

local meleeList = {}
local heroIDToName = {}
local skillOwningHero = {}

local herolist = GameRules.KVs.herolist

for heroName, value in pairs(herolist) do
    if heroName and heroName ~= 'npc_dota_hero_base' and heroName ~= 'npc_dota_hero_target_dummy' and value == 1 then
        local heroData = GetUnitKeyValuesByName(heroName)
        if heroData.AttackCapabilities == 'DOTA_UNIT_CAP_MELEE_ATTACK' then
            meleeList[heroName] = true
        end
        -- If this hero has an ID
        if heroData.HeroID then
            -- Store the heroID lookup
            heroIDToName[heroData.HeroID] = heroName

            -- Loop over all possible slots
            for i = 1, DOTA_MAX_ABILITIES do
                -- Grab the ability
                local ab = heroData['Ability'..i]

                -- Did we actually find an ability?
                if ab and ab ~= '' and ab ~= 'special_bonus_attributes' and ab ~= 'generic_hidden' then
                    -- Yep, store this hero as the owner
                    skillOwningHero[ab] = heroData.HeroID
                end
            end
        end
    end
end

local manualActivate = {
    keeper_of_the_light_blinding_light_imba = true,
    keeper_of_the_light_recall_imba = true,
    imba_queenofpain_delightful_torment = true,
    imba_bounty_hunter_shadow_jaunt = true
}

local towerClasses = {
    npc_dota_barracks = true,
    npc_dota_building = true,
    npc_dota_fort = true,
    npc_dota_tower = true
}

-- Auto set this to max level
local autoSkill = {
    --nyx_assassin_unburrow = true,
    alchemist_transmuted_scepter = true,
    earth_spirit_stone_caller = true,
}


local ownersKV = LoadKeyValues('scripts/kv/owners.kv')
for k,v in pairs(ownersKV) do
    skillOwningHero[k] = tonumber(v)
end

-- Tells you if a given heroName is melee or not
local function isMeleeHero(heroName)
    if meleeList[heroName] then
        return true
    end

    return false
end

local function fixModifiers(hero, skill)
    -- Remove it
    hero:RemoveModifierByName('modifier_'..skill)
    hero:RemoveModifierByName('modifier_'..skill..'_aura')
end

-- Precaches a skill -- DODGY!
local alreadyCached = {}
local customSkills = GameRules.KVs["npc_abilities_custom"]

SkillManager = class({})

function SkillManager:precacheSkill(skillName, callback)
    local heroID = skillOwningHero[skillName]
    local customSkill = customSkills[skillName]

    if heroID then
        local heroName = heroIDToName[heroID]

        if heroName then
            -- Check if precached elsewhere
			for playerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
				if PlayerResource:IsValidPlayerID(playerID) and Pregame.cachedPlayerHeroes[playerID] == true then
					local h = PlayerResource:GetSelectedHeroEntity(playerID)
					if h then
						local name = h:GetUnitName()
						if name == heroName then
							alreadyCached[heroName] = true
							break
						end
					end
				end
			end

			-- Have we already cached this?
            if alreadyCached[heroName] then
                if callback ~= nil then
                    callback()
                end
                return
            end
            alreadyCached[heroName] = true

            -- Cache it
            PrecacheUnitByNameAsync(heroName, function()
                print("[SkillManager:precacheSkill] Successfully precached hero: "..heroName)
            end)
            if callback ~= nil then
                callback()
            end
        end
    end
    if customSkill then
        if alreadyCached[skillName] then
            if callback ~= nil then
                callback()
            end
            return
        end
        alreadyCached[skillName] = true
        PrecacheItemByNameAsync(skillName, function()
            print("[SkillManager:precacheSkill] Successfully precached ability: "..skillName)
            if not PRECACHER then
                PRECACHER = CreateUnitByName('npc_precache_always', Vector(-10000, -10000, 0), false, nil, nil, 0)
            end

            PRECACHER.ability_counter = PRECACHER.ability_counter or 0

            if not PRECACHER:HasAbility(skillName) then
                if PRECACHER.ability_counter < 26 then
                    PRECACHER:AddAbility(skillName)
                    PRECACHER.ability_counter = PRECACHER.ability_counter + 1
                else
                    PRECACHER = CreateUnitByName('npc_precache_always', Vector(-10000, -10000, 0), false, nil, nil, 0)
                    PRECACHER:AddAbility(skillName)
                    PRECACHER.ability_counter = 1
                end
            end
            if callback ~= nil then
               callback()
            end
        end)
    else
        -- Done
        if callback ~= nil then
            callback()
        end
    end
end

function SkillManager:GetHeroSkills(heroClass)
    local skills = {}

    -- Build list of abilities
    local heroData = GetUnitKeyValuesByName(heroClass)
    for i = 1, DOTA_MAX_ABILITIES do
        local ab = heroData["Ability"..i]
        if ab and ab ~= '' and ab ~= 'special_bonus_attributes' then --and ab ~= 'generic_hidden' then
            table.insert(skills, ab)
        end
    end

    return skills
end

function SkillManager:BuildSkillList(hero)
    -- Check if we've touched this hero before
    if not currentSkillList[hero] then
        -- Grab the name of this hero
        local heroClass = hero:GetUnitName()

        -- Grab the skills
        local skills = self:GetHeroSkills(heroClass)

        -- Store it
        currentSkillList[hero] = skills
    end
end

function SkillManager:RemoveAllSkills(hero)
    -- Ensure the hero isn't nil
    if hero == nil then return end

    -- Remove all old skills - it actually hides them
    for k,v in pairs(currentSkillList[hero]) do
        if hero:HasAbility(v) then
            --if PlayerResource:IsFakeClient(hero:GetPlayerID()) then
                hero:FindAbilityByName(v):SetHidden(true)
           -- else
           --     if not string.find(v, string.sub(hero:GetUnitName(), 15)) then  -- npc_dota_hero_xx
            --        hero:RemoveAbility(v)
            --    end
            --end
        end
    end

    -- Build the skill list
    self:BuildSkillList(hero)
end

-- Shows the given set number - NOT USED
function SkillManager:ShowSet(hero, number)
    local playerID = hero:GetPlayerID()

    if activeSkills[playerID] then
        for k,v in pairs(activeSkills[playerID]) do
            local ab = hero:FindAbilityByName(v)
            if IsValidEntity(ab) then
                ab:SetHidden(true)
            end
        end

        local startNum = 1
        local endNum = 6

        if number == 1 then
            startNum = 7
            endNum = 12
        end

        for i=startNum,endNum do
            if activeSkills[playerID][i] ~= nil then
                local ab = hero:FindAbilityByName(activeSkills[playerID][i])
                if IsValidEntity(ab) then
                    ab:SetHidden(false)
                end
            end
        end
    end
end

-- Returns a multiplier skill name, if it exists
function SkillManager:GetMultiplierSkillName(skillName)
    local mult = OptionManager:GetOption('customSpellPower')
    local useLevel1ults = OptionManager:GetOption('useLevel1ults')

    -- Check that we are actually doing a multiplier
    if mult and mult ~= 1 then
        -- Double mult fixer
        if mult == 100 then
            mult = 'd'
        end

        if useLevel1ults then
            -- Check if the multiplier skill exists with lvl1 ult
            if multiplierSkills[skillName..'_'..mult..'_lvl1'] then
                return skillName..'_'..mult..'_lvl1'
            end
        end

        -- Check if the multiplier skill exists
        if multiplierSkills[skillName..'_'..mult] then
            return skillName..'_'..mult
        end
    end

    -- Check if the lvl1  ult skill exists
    if useLevel1ults then
        -- Check if the multiplier skill exists
        if multiplierSkills[skillName..'_lvl1'] then
            return skillName..'_lvl1'
        end
    end

    -- Doesn't exist, use the normal skill
    return skillName
end

-- Precaches a build - NOT USED
function SkillManager:PrecacheBuild(build)
    for i=1,23 do
        local v = build[i]
        if v then
            -- Precache
            self:precacheSkill(v)
        end
    end
end

-- Precaches a hero - NOT USED
local realHeroCache = {}
function SkillManager:PrecacheHero(heroName, playerID)
    if realHeroCache[heroName] then return end
    realHeroCache[heroName] = true
    alreadyCached[heroName] = true

    PrecacheUnitByNameAsync(heroName, function() end, playerID)
end

local inSwap = false
function SkillManager:ApplyBuild(hero, build, autoLevelSkills)
    -- Ensure the hero isn't nil
    if hero == nil or not IsValidEntity(hero) or not hero:IsAlive() then return end

    -- If we are currently swapping a hero, ignore
    if inSwap then return end

    -- Cooldowns
    self.abilityCooldowns = self.abilityCooldowns or {}
    local cooldownInfo = {}

    -- Check if there is a new hero
    local playerID
    local isRealHero = false
    if hero:IsHero() then
        playerID = hero:GetPlayerID()

        if hero and playerID and not util:isPlayerBot(playerID) then
            for i = 0, DOTA_MAX_ABILITIES - 1 do
                local ab = hero:GetAbilityByIndex(i)
                if ab and not DONOTREMOVE[ab:GetAbilityName()] and not util:IsVanillaInnate(ab) then
                    hero:RemoveAbility(ab:GetName())
                end
            end
        end

        local realHero = PlayerResource:GetSelectedHeroEntity(playerID)

        -- Grab cooldowns
        self.abilityCooldowns[playerID] = self.abilityCooldowns[playerID] or {}
        cooldownInfo = self.abilityCooldowns[playerID]

        -- Hero check
        if hero:IsRealHero() then
            isRealHero = true
        end

        if hero:IsRealHero() and build.hero and (not realHero or realHero == hero) then
            -- Reset current skills
            currentSkillList[hero] = nil

            -- Store gold
            local ug = PlayerResource:GetUnreliableGold(playerID)
            local rg = PlayerResource:GetReliableGold(playerID)

            -- Grab HP and mana percent
            local hp = hero:GetHealthPercent()
            local mana = hero:GetManaPercent()

            -- Get their position
            local pos = hero:GetOrigin()

            -- Store items
            local items = {}
            for i = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6 do
                local item = hero:GetItemInSlot(i)

                -- Sprint is a item only for Slardar, do not replace
                if item and item:GetName() ~= "item_sprint" then
                    items[i] = {
                        name = item:GetName(),
                        charges = item:GetCurrentCharges(),
                        purchaser = item:GetPurchaser(),
                        purchaseTime = item:GetPurchaseTime(),
                    }

                    -- Check if we need to replace the purchaser
                    if item:GetPurchaser() == hero then
                        items[i].replacePurchaser = true
                    end

                    hero:RemoveItem(item)
                end
            end


            -- Handle cooldowns
            for i = 0, hero:GetAbilityCount()-1 do
                local ab = hero:GetAbilityByIndex(i)
                if IsValidEntity(ab) then
                    local timeLeft = ab:GetCooldownTimeRemaining()
                    if timeLeft > 0 then
                        cooldownInfo[ab:GetClassname()] = Time() + timeLeft
                    end
                end
            end
            -- Grab exp / level
            local currentLevel = constants.XP_PER_LEVEL_TABLE[hero:GetLevel()]

            -- Replace the hero
            inSwap = true
            --if hero:GetUnitName() ~= build.hero then
                local old = hero
                hero = PlayerResource:ReplaceHeroWith(playerID, build.hero, 0, 0)
                UTIL_Remove(old)
                if hero and playerID and not util:isPlayerBot(playerID) then
                    for i = 0, DOTA_MAX_ABILITIES - 1 do
                        local ab = hero:GetAbilityByIndex(i)
                        if ab and not DONOTREMOVE[ab:GetAbilityName()] and not util:IsVanillaInnate(ab) then
                            hero:RemoveAbility(ab:GetName())
                        end
                    end
                end
            --end
            inSwap = false

            -- Ensure swap is successful
            if not IsValidEntity(hero) then return end
            -- Level it up
            -- for i=1,currentLevel-1 do
            --    hero:HeroLevelUp(false)
            -- end
            -- Add EXP
            hero:AddExperience(currentLevel, false, false)

            -- Replace gold
            PlayerResource:SetGold(playerID, ug, false)
            PlayerResource:SetGold(playerID, rg, true)

            -- Replace HP and mana percent
            hero:SetHealth(math.ceil(hp/100 * hero:GetMaxHealth()))
            hero:SetMana(mana/100 * hero:GetMaxMana())

            -- Reset their position
            hero:SetOrigin(pos)

            -- Replace items
            local removeMe = {}
            for i = DOTA_ITEM_SLOT_1, DOTA_STASH_SLOT_6 do
                local item = items[i]

                if item then
                    local purchaser = item.purchaser
                    if item.replacePurchaser then
                        purchaser = hero
                    end

                    local newItem = CreateItem(item.name, purchaser, purchaser)
                    newItem:SetCurrentCharges(item.charges)
                    newItem:SetPurchaser(purchaser)
                    newItem:SetPurchaseTime(item.purchaseTime)

                    hero:AddItem(newItem)
                else
                    local tmpItem = CreateItem('item_branches', hero, hero)
                    hero:AddItem(tmpItem)
                    table.insert(removeMe, tmpItem)
                end
            end

            for k,v in pairs(removeMe) do
                hero:RemoveItem(v)
            end

            -- Reset current skills
            currentSkillList[hero] = nil

            -- Reset ability points
            hero:SetAbilityPoints(hero:GetLevel())

            if build.setAttr then
                local toSet = 0

                if build.setAttr == 'str' then
                    toSet = DOTA_ATTRIBUTE_STRENGTH
                elseif build.setAttr == 'agi' then
                    toSet = DOTA_ATTRIBUTE_AGILITY
                elseif build.setAttr == 'int' then
                    toSet = DOTA_ATTRIBUTE_INTELLECT
                elseif build.setAttr == 'all' then
                    toSet = DOTA_ATTRIBUTE_ALL
                end

                -- Set a timer to fix stuff up
                Timers:CreateTimer(function()
                    if IsValidEntity(hero) then
                        hero:SetPrimaryAttribute(toSet)
                    end
                end, DoUniqueString('primaryAttrFix'), 0.1)
            end
        end
    end

    hero.buildApplied = true

    -- Store the hero of this build
    build.hero = hero:GetClassname()

    -- Build the skill list
    self:BuildSkillList(hero)

    -- Remove all the skills from this hero
    self:RemoveAllSkills(hero)

    -- Table to store all the extra skills we need to give
    local extraSkills = {}

    -- Check if this hero is a melee hero
    local melee = isMeleeHero(hero:GetClassname())

    -- Devour fix
    --[[for i=1,6 do
        local v = build[i]
        if v == 'doom_bringer_devour' then
            -- We need the empty slots in 4 & 5
            build[4] = 'doom_bringer_empty1'
            build[5] = 'doom_bringer_empty2'
            break
        end
    end]]

    -- Spell steal fix
    local spellSteal = false
    for i=1,6 do
        local v = build[i]
        if v == 'rubick_spell_steal' then
            table.remove(build, i)
            spellSteal = true
        end
    end

    if spellSteal then
        build[4] = 'rubick_spell_steal'
        build[5] = nil
        build[6] = nil
    end

    -- Devour fix
    local devFix = false
    for i=1,6 do
        local v = build[i]
        if v == 'doom_bringer_devour' then
            table.remove(build, i)
            devFix = true
        end
    end

    if devFix then
        build[4] = 'doom_bringer_devour'
        build[5] = nil
        build[6] = nil
    end

    -- List of abilities we've already seen
    local seenAbilities = {}

    -- Build slot list for swapping
    --[[local slotList = {}
    local slotCount = 0
    for i=1,23 do
        local ab = hero:GetAbilityByIndex(i)
        if ab then
            slotList[i] = ab:GetClassname()
            slotCount = slotCount+1
        end
    end]]

    -- Copy
    local abs = {}
    for k,v in ipairs(currentSkillList[hero]) do
        table.insert(abs, v)
    end

    local isTower = towerClasses[hero:GetClassname()] or autoLevelSkills

    if isRealHero then
        -- Ensure this player has an active skill list
        activeSkills[playerID] = {}
    end

    -- Give all the abilities in this build
    local abNum = 0
    for i=1,23 do
        local v = build[i]
        if v then
            --slotCount = slotCount+1
            abNum=abNum+1
            -- Check if this skill has sub abilities
            if subAbilities[v] then
                local skillSplit = vlua.split(subAbilities[v], '||')

                for kk,vv in pairs(skillSplit) do
                    -- Store that we need this skill
                    extraSkills[vv] = true
                end
            end

            -- Do melee heroes need a different skill?
            if melee and meleeMap[v] then
                build[i] = meleeMap[v]
                v = meleeMap[v]
            end

            -- Precache
            SkillManager:precacheSkill(v)

            local multV = self:GetMultiplierSkillName(v)
            if isRealHero then
                -- Check for a bot
                if PlayerResource:IsFakeClient(playerID) then
                    if hero:HasAbility(v) then
                        multV = v
                    end
                end
            end

            -- Add to build
            if not seenAbilities[multV] and hero:HasAbility(multV) then
                -- Hero already has, lets hook and move it
                local oldAb = hero:FindAbilityByName(multV)

                -- Enable it
                if oldAb then
                    oldAb:SetHidden(false)
                else
                    hero:RemoveAbility(multV)
                end
            else
                local newAb = hero:AddAbility(multV)
                if newAb then
                    newAb:SetHidden(false)

                    -- Check for auto skilling
                    if autoSkill[v] then
                        newAb:SetLevel(newAb:GetMaxLevel())
                    end
                end

                -- Insert
                table.insert(abs, v)
            end
            -- If it's a tower, level it
            if isTower then
                local ab = hero:FindAbilityByName(multV)
                if ab then
                    local requiredLevel = ab:GetMaxLevel()
                    ab:SetLevel(requiredLevel)
                end
            end

            -- We need to actually add it next time
            seenAbilities[multV] = true

            currentSkillList[hero][abNum] = multV

            -- Do we need to manually activate this skill?
            if manualActivate[v] then
                local ab = hero:FindAbilityByName(multV)
                if ab then
                    ab:SetActivated(true)
                end
            end

            -- Remove auras
            if not isTower then
                fixModifiers(hero, v)
            end
        end
    end

    -- Do a nice little sort
    for i=1,23 do
        local v = build[i]
        if v then
            local inSlot = abs[i]

            -- Grab the multiplied skill
            local seekAbility = self:GetMultiplierSkillName(v)
            if isRealHero then
                -- Check for a bot
                if PlayerResource:IsFakeClient(playerID) then
                    if hero:HasAbility(v) then
                        seekAbility = v
                    end
                end
            end

            if inSlot and inSlot ~= seekAbility then
                -- Swap in dota
                hero:SwapAbilities(seekAbility, inSlot, true, true)

                -- Perform swap internally
                for j=i+1,23 do
                    if build[i] == abs[j] then
                        abs[j] = abs[i]
                        break
                    end
                end
                abs[i] = build[i]
            end

            if i > 6 and not isTower then
                local ab = hero:FindAbilityByName(seekAbility)
                if ab then
                    ab:SetHidden(true)
                end
            end

            -- Store the index
            if isRealHero then
                activeSkills[playerID][i] = seekAbility
            end
        else
            local inSlot = abs[i]

            if inSlot then
                local ab = hero:FindAbilityByName(inSlot)
                if ab and not isTower then
                    local hide = true
                    for _,buildAb in pairs(build) do
                        if buildAb == inSlot then
                            hide = false
                            break
                        end
                    end
                    if hide then
                        ab:SetHidden(true)
                    end
                end
            end
        end
    end
    -- Add missing abilities
    for k,v in pairs(extraSkills) do
        -- Do they already have this skill?
        if not hero:HasAbility(k) then
            -- Move onto the next slot
            abNum = abNum + 1

            -- Precache
            SkillManager:precacheSkill(k)

            -- Grab the real name (this was different for mult, disabled for now)
            local realAbility = k

            -- Add the ability
            hero:AddAbility(realAbility)

            -- Remove auras
            fixModifiers(hero, k)

            -- Store that we have it
            currentSkillList[hero][abNum] = realAbility

            -- Check for auto skilling
            if autoSkill[k] then
                local newAb = hero:FindAbilityByName(realAbility)
                if newAb then
                    newAb:SetLevel(newAb:GetMaxLevel())
                end
            end
        end
    end
    -- Handle cooldowns
    for i = 0, hero:GetAbilityCount() - 1 do
        local ab = hero:GetAbilityByIndex(i)
        if IsValidEntity(ab) then
            if ab:GetName() == "generic_hidden" then
                ab:SetHidden(true)
            else
                local timeLeft = (cooldownInfo[ab:GetClassname()] or 0) - Time()
                if timeLeft > 0 then
                    ab:StartCooldown(timeLeft)
                end
            end
        end
    end

    -- Remove certain modifiers
    hero:RemoveModifierByName('modifier_storm_spirit_overload_passive')
    hero:RemoveModifierByName('modifier_slark_shadow_dance_passive')
    hero:RemoveModifierByName('modifier_slark_shadow_dance_passive_regen')

    local brokenModifierCounts = {
        modifier_shadow_demon_demonic_purge_charge_counter = 3,
        modifier_bloodseeker_rupture_charge_counter = 2,
        modifier_earth_spirit_stone_caller_charge_counter = 6,
        modifier_ember_spirit_fire_remnant_charge_counter = 3
    }

    for modifierName,countNeeded in pairs(brokenModifierCounts) do
        local modifier = hero:FindModifierByName(modifierName)

        if modifier then
            modifier:SetStackCount(countNeeded)
        end
    end
end

--function SkillManager:overrideHooks()
    -- Implement the get ability by slot index method
    --[[if GameRules:isSource1() then
        function CDOTA_BaseNPC:GetAbilityByIndex(index)
            if currentSkillList[self] then
                local skillName = currentSkillList[self][index]
                if skillName then
                    return self:FindAbilityByName(skillName)
                end
            end
        end
    end]]
--end

-- Grabs an object that has a new build with an ability slot changed
function SkillManager:grabNewBuild(originalBuild, slotNumber, newAbility)
    local build = {}
    for k,v in pairs(originalBuild) do
        build[k] = v
    end

    build[slotNumber] = newAbility

    return build
end

-- Checks the number of ults in a build
function SkillManager:hasTooMany(build, maxCount, checkFunction)
    -- Check stuff
    local totalSoFar = 0
    for k,v in pairs(build) do
        if checkFunction(v) and k ~= 'hero' then
            totalSoFar = totalSoFar + 1

            if totalSoFar > maxCount then
                -- Build failed
                return true
            end
        end
    end

    -- Must be a valid build
    return false
end

-- Returns true if a skill is an ultimate
function SkillManager:isUlt(name)
    if not name then
        return false
    end    
    if name == "" then
        return false
    end
    local ability_data = GetAbilityKeyValuesByName(name)
    if not ability_data then
        print("SkillManager:isUlt: Ability "..name.." does not exist!")
        return false
    end
    local ability_type = ability_data.AbilityType
    if not ability_type then
        -- If ability type is ommited it's usually a basic ability
        return false
    end
    return string.find(ability_type, "DOTA_ABILITY_TYPE_ULTIMATE")
end

-- Returns true if a skill is valid and not an ultimate
function SkillManager:isValidBasic(name)
    if not name then
        return false
    end
    if name == "" or name == 'special_bonus_attributes' or name == 'generic_hidden' or DONOTREMOVE[name] then
        return false
    end
    local ability_data = GetAbilityKeyValuesByName(name)
    if not ability_data then
        print("SkillManager:isValidBasic: Ability "..name.." does not exist!")
        return false
    end
    local ability_type = ability_data.AbilityType
    if not ability_type then
        -- If ability type is ommited it's usually a basic ability
        return true
    end
    return string.find(ability_type, "DOTA_ABILITY_TYPE_BASIC")
end

-- Returns true if a skill is a passive
function SkillManager:isPassive(name)
    if not name then
        return false
    end    
    if name == "" or name == 'special_bonus_attributes' or name == 'generic_hidden' or DONOTREMOVE[name] then
        return false
    end
    local ability_data = GetAbilityKeyValuesByName(name)
    if not ability_data then
        print("SkillManager:isPassive: Ability "..name.." does not exist!")
        return false
    end
    local behavior = ability_data.AbilityBehavior
    if not behavior then
        print("SkillManager:isPassive: Ability "..name.." does not have a behavior!")
        return
    end

    return string.find(behavior, 'DOTA_ABILITY_BEHAVIOR_PASSIVE') and not string.find(behavior, 'DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE')
end
