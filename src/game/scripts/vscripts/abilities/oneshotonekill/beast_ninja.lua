function lang( keys )
	local caster = keys.caster
	local d = keys.duration
	local day = keys.day
	local night = keys.night
	local ability =keys.ability

	if caster.wolf then --先杀掉已有的狼
		caster.wolf:RemoveSelf()
		caster.wolf = nil
	end

	local wolf_name = "wolf"
	if caster.caidan then --是否有彩蛋
		wolf = "wolf_china"
	end

	local wolf = CreateUnitByName(wolf_name,caster:GetAbsOrigin(),true,caster,caster,caster:GetTeam())
	wolf:SetDayTimeVisionRange(day)
	wolf:SetNightTimeVisionRange(night)
	wolf:SetOwner(caster)
	wolf:SetControllableByPlayer(caster:GetPlayerID(),false)
	wolf:AddNewModifier(caster,ability,"modifier_kill",{duration = d})
	caster.wolf = wolf
end

function sight( keys )
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability

	target:AddNewModifier(caster, ability, "modifier_beast_ninja_sight", {duration = ability:GetSpecialValueFor("duration")})
end

function wang( keys )
	local target = keys.target
	local caster = keys.caster
	local duration = keys.duration
	local p = 'particles/units/heroes/hero_meepo/meepo_earthbind_model_catch.vpcf'
	local p_index = ParticleManager:CreateParticle(p,PATTACH_CUSTOMORIGIN,caster)
	ParticleManager:SetParticleControlEnt(p_index,0, target,PATTACH_POINT_FOLLOW,"attach_hitloc",target:GetAbsOrigin(), true)
	local t=0
	GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("wang"),
		function ()
			if t<duration then
				if  target:IsAlive() then
					t=t+0.03
					return 0.03
				else
					ParticleManager:DestroyParticle(p_index,true)
					return nil
				end
			else
				ParticleManager:DestroyParticle(p_index,true)
				return nil
			end

	end,0.03)
end

function benneng( keys )
	local caster = keys.caster
	local ability = keys.ability
	local caster_team = caster:GetTeam()
	local heroes = HeroList:GetAllHeroes()
	local targets = {}
	for _,hero in pairs(heroes) do
		if hero:GetTeam() ~= caster_team then
			if hero:IsAlive() then
				table.insert (targets,hero)
			end
		end
	end
	if targets[1]== nil then
		return
	end
	local enemy_num = #targets
	local n = RandomInt(1,enemy_num)
	local target = targets[n]
	local unit = CreateUnitByName("majia",target:GetAbsOrigin(),false,caster,caster,caster:GetTeam())
	unit:SetDayTimeVisionRange(150)
	unit:SetNightTimeVisionRange(150)
	ability:ApplyDataDrivenModifier(caster,unit,"bengneng_sight",nil)
	ability:ApplyDataDrivenModifier(caster,target,"benneng_beibu",nil)
	Timers:CreateTimer(0.1,function()
		if target:IsAlive() and target:HasModifier("benneng_beibu") then
			unit:SetAbsOrigin(target:GetAbsOrigin())
			return 0.1
		else
			unit:RemoveModifierByName("bengneng_sight")
			unit:RemoveSelf()
			return nil
		end
	end)
end

---------------------------------------------------------------------------------------------------

LinkLuaModifier("modifier_beast_ninja_sight", "abilities/oneshotonekill/beast_ninja.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_beast_ninja_sight_aura_effect", "abilities/oneshotonekill/beast_ninja.lua", LUA_MODIFIER_MOTION_NONE)

modifier_beast_ninja_sight = class({})

function modifier_beast_ninja_sight:IsHidden()
  return false
end

function modifier_beast_ninja_sight:IsDebuff()
  return false
end

function modifier_beast_ninja_sight:IsPurgable()
  return false
end

function modifier_beast_ninja_sight:RemoveOnDeath()
  return true
end

-- Unobstructed Vision
function modifier_beast_ninja_sight:CheckState()
  return {
    [MODIFIER_STATE_FORCED_FLYING_VISION] = true,
  }
end

-- True Sight
function modifier_beast_ninja_sight:IsAura()
  return true
end

function modifier_beast_ninja_sight:GetModifierAura()
  return "modifier_beast_ninja_sight_aura_effect"
end

function modifier_beast_ninja_sight:GetAuraSearchTeam()
  return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_beast_ninja_sight:GetAuraSearchType()
  return DOTA_UNIT_TARGET_ALL --bit.bor(DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_BASIC)
end

function modifier_beast_ninja_sight:GetAuraSearchFlags()
  return bit.bor(DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, DOTA_UNIT_TARGET_FLAG_INVULNERABLE)
end

function modifier_beast_ninja_sight:GetAuraRadius()
  return self:GetAbility():GetSpecialValueFor("true_sight_range")
end

---------------------------------------------------------------------------------------------------

modifier_beast_ninja_sight_aura_effect = class({})

function modifier_beast_ninja_sight_aura_effect:IsHidden()
  local parent = self:GetParent()
  local caster = self:GetCaster()

  -- Check if caster exists
  if not caster or caster:IsNull() then
    return true
  end

  -- Check for True Sight immunities
  if parent.HasModifier and (parent:HasModifier("modifier_slark_shadow_dance") or parent:HasModifier("modifier_slark_depth_shroud")) then
    return true
  end

  return false
end

function modifier_beast_ninja_sight_aura_effect:IsDebuff()
  return true
end

function modifier_beast_ninja_sight_aura_effect:IsPurgable()
  return false
end

function modifier_beast_ninja_sight_aura_effect:GetPriority()
  return MODIFIER_PRIORITY_SUPER_ULTRA
end

function modifier_beast_ninja_sight_aura_effect:CheckState()
  local parent = self:GetParent()
  local caster = self:GetCaster()

  -- Check if caster exists
  if not caster or caster:IsNull() then
    return {}
  end

  if parent.HasModifier and (parent:HasModifier("modifier_slark_shadow_dance") or parent:HasModifier("modifier_slark_depth_shroud")) then
    return {}
  end

  return {
    [MODIFIER_STATE_INVISIBLE] = false
  }
end
