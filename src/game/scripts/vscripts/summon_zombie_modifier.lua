summon_zombie_modifier = summon_zombie_modifier or class ({})

--------------------------------------------------------------------------------

function summon_zombie_modifier:IsHidden()
    return true
end

function summon_zombie_modifier:IsDebuff()
    return false
end

function summon_zombie_modifier:IsPurgable()
    return false
end

function summon_zombie_modifier:RemoveOnDeath()
    return false
end

function summon_zombie_modifier:OnCreated()
	self.spawn_delay = 4
	self.num_to_spawn = 1

	if IsServer() then
		self:StartIntervalThink(self.spawn_delay)
	end
end

--------------------------------------------------------------------------------

function summon_zombie_modifier:OnIntervalThink()
	local caster = self:GetParent()

	if not caster or caster:IsNull() then
		return
	end

	if not caster:IsAlive() then
		return
	end

	if caster:IsIllusion() then
		self:Destroy()
		return
	end

	for i = 1, self.num_to_spawn do
		self:AttemptToSpawnZombie()
	end
end

--------------------------------------------------------------------------------

function summon_zombie_modifier:AttemptToSpawnZombie()
	local caster = self:GetParent()
	local ability = self:GetAbility()
	local center = caster:GetAbsOrigin()
	local level = caster:GetLevel()
	local playerid = caster:GetPlayerID()

	if util:isPlayerBot(playerid) then
		return
	end

	if RandomInt(1, 15) == 1 then
		local zombie = CreateUnitByName("custom_creature_zombie_large", center, true, caster, caster, caster:GetTeamNumber())
		zombie:SetOwner(caster:GetOwner())
		zombie:AddNewModifier(zombie, ability, "modifier_phased", {duration = 1})
		zombie:CreatureLevelUp(level)
		zombie:SetControllableByPlayer(playerid, true)
	else
		local zombie = CreateUnitByName("custom_creature_zombie", center, true, caster, caster, caster:GetTeamNumber())
		zombie:SetOwner(caster:GetOwner())
		zombie:AddNewModifier(zombie, ability, "modifier_phased", {duration = 1})
		zombie:CreatureLevelUp(level)
		zombie:SetControllableByPlayer(playerid, true)
	end
end
