if spell_lab_ggs == nil then
	spell_lab_ggs = class({})
end

function spell_lab_ggs:OnSpellStart()
	local hCaster = self:GetCaster()
	local vPos = self:GetCursorPosition()
	local sName = "npc_spell_lab_ggs_summon"
	
	-- Remove previous instance
	if self.npc_point then
		if self.npc_point:IsAlive() then
			self.npc_point:ForceKill(false)
			self.npc_point = nil
		end
	end
	local channel_time = self:GetSpecialValueFor("channel_time")
	local hUnit = CreateUnitByName(sName, vPos, true, hCaster, hCaster,hCaster:GetTeam())
	hUnit:SetControllableByPlayer(hCaster:GetPlayerID(), true)
	FindClearSpaceForUnit(hUnit, vPos, true)
	local hAbility = hUnit:FindAbilityByName("spell_lab_ggs_passive")
	hAbility:SetLevel(self:GetLevel())
	-- Make sure the unit gets removed even if mess up somewhere
	hUnit:AddNewModifier(hCaster, self, "modifier_kill", {duration = channel_time + 1})

	self.npc_point = hUnit

	self.fThink = 0.0
	self.fInterval = self:GetSpecialValueFor("interval")
	self.fDamageMult = self:GetSpecialValueFor("damage")*self.fInterval
end

function spell_lab_ggs:OnChannelThink(fInterval)
	if not self.npc_point or self.npc_point:IsNull() then
		return
	end

	self.fThink = self.fThink + fInterval

	if self.fThink >= self.fInterval then
		self.fThink = 0
		if self.npc_point then
			if self.npc_point:IsAlive() then
				self:Explosion(self.npc_point:GetAbsOrigin())
			else
				self:EndChannel(true)
			end
		else
			self:EndChannel(true)
		end
	end
end

function spell_lab_ggs:Explosion(vPos)
    local hCaster = self:GetCaster()
    local iInt = hCaster:GetIntellect(false)
    local aoe = self:GetSpecialValueFor("radius")

	local damage = {
		attacker = self:GetCaster(),
		damage = self.fDamageMult*iInt,
		damage_type = self:GetAbilityDamageType(),
		ability = self
	}
   local enemies = FindUnitsInRadius( hCaster:GetTeamNumber(), vPos, nil, aoe, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 0, 0, false )
   if #enemies > 0 then
     for _,enemy in pairs(enemies) do
       if enemy ~= nil and ( not enemy:IsMagicImmune() ) and ( not enemy:IsInvulnerable() ) then
         damage.victim = enemy
         ApplyDamage( damage )
       end
     end
   end
   EmitSoundOnLocationWithCaster(vPos, "Spell_Lab.GGS_Hum_phased", hCaster )
end

function spell_lab_ggs:OnChannelFinish (bInterrupt)
	self.npc_point:ForceKill(false)
	self.npc_point = nil
end

---------------------------------------------------------------------------------------------------

if spell_lab_ggs_passive == nil then
	spell_lab_ggs_passive = class({})
end

LinkLuaModifier("spell_lab_ggs_passive_modifier", "abilities/spell_lab/ggs/ggs.lua", LUA_MODIFIER_MOTION_NONE)

function spell_lab_ggs_passive:GetIntrinsicModifierName() return "spell_lab_ggs_passive_modifier" end

---------------------------------------------------------------------------------------------------
if spell_lab_ggs_passive_modifier == nil then
	spell_lab_ggs_passive_modifier = class({})
end

function spell_lab_ggs_passive_modifier:AllowIllusionDuplicate ()
  return false
end
function spell_lab_ggs_passive_modifier:IsPurgable()
	return false
end
function spell_lab_ggs_passive_modifier:IsHidden()
	return true
end
function spell_lab_ggs_passive_modifier:GetAttributes()
	return MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE + MODIFIER_ATTRIBUTE_PERMANENT
end

function spell_lab_ggs_passive_modifier:CheckState()
	return {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}
end
function spell_lab_ggs_passive_modifier:OnCreated(kv)
	if IsServer() then
		self.nFXIndex = ParticleManager:CreateParticle( "particles/spell_lab/sky_beam.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
		ParticleManager:SetParticleControl(self.nFXIndex, 15, Vector(150,255,50))
		ParticleManager:SetParticleControl(self.nFXIndex, 1, Vector(self:GetAbility():GetSpecialValueFor("radius"),0,0))
		self:AddParticle( self.nFXIndex, false, false, -1, false, false )
	end
end

function spell_lab_ggs_passive_modifier:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_DEATH,
	}
end
if IsServer() then
	function spell_lab_ggs_passive_modifier:OnDeath(kv)
		if kv.unit == self:GetParent() and self.nFXIndex then
			ParticleManager:DestroyParticle(self.nFXIndex,false)
			ParticleManager:ReleaseParticleIndex(self.nFXIndex)
		end
	end
end
