lightning_boltblast = class({})

LinkLuaModifier("modifier_boltblast_slow","abilities/dusk/lightning_boltblast",LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_boltblast","abilities/dusk/lightning_boltblast",LUA_MODIFIER_MOTION_NONE)

function lightning_boltblast:OnSpellStart()
	local c = self:GetCaster()
	local point = self:GetCursorPosition()+Vector(0,0,100)
	local delay = self:GetSpecialValueFor("explosion_delay")

	CreateModifierThinker( c, self, "modifier_boltblast", {Duration=delay}, point, c:GetTeamNumber(), false )
end

modifier_boltblast = class({})

if IsServer() then

	function modifier_boltblast:OnCreated()
		local p = ParticleManager:CreateParticle("particles/units/heroes/hero_lightning/boltblast.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent()) --[[Returns:int
		Creates a new particle effect
		]]
		local radius = self:GetAbility():GetSpecialValueFor("radius")
		ParticleManager:SetParticleControl(p, 1, Vector(radius*0.90,0,0)) --[[Returns:void
		Set the control point data for a control on a particle effect
		]]
		self:GetParent():EmitSound("Hero_Invoker.EMP.Charge")
		self:AddParticle(p,false,false,10,false,false)
	end

	function modifier_boltblast:OnDestroy()
		local ability = self:GetAbility()
		local c = ability:GetCaster()

		local damage = ability:GetSpecialValueFor("explosion_damage")
		local radius = ability:GetSpecialValueFor("radius")
		local slow_duration = ability:GetSpecialValueFor("slow_duration")

		self:GetParent():StopSound("Hero_Invoker.EMP.Charge")

		self:GetParent():EmitSound("Hero_Invoker.EMP.Discharge")

		local en = FindEnemies(c,self:GetParent():GetAbsOrigin(),radius)
		for k,v in pairs(en) do
			InflictDamage(v,c,ability,damage,DAMAGE_TYPE_MAGICAL)
			v:AddNewModifier(c, ability, "modifier_boltblast_slow", {duration=slow_duration})
		end
	end

end

modifier_boltblast_slow = class({})

function modifier_boltblast_slow:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
	return funcs
end

function FindEnemies(caster,point,radius,targets,flags)
  local targets = targets or DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_CREEP
  local flags = flags or DOTA_UNIT_TARGET_FLAG_NONE
  return FindUnitsInRadius( caster:GetTeamNumber(),
                            point,
                            nil,
                            radius,
                            DOTA_UNIT_TARGET_TEAM_ENEMY,
                            targets,
                            flags,
                            FIND_CLOSEST,
                            false)
end

function modifier_boltblast_slow:GetModifierMoveSpeedBonus_Percentage()
	return self:GetAbility():GetSpecialValueFor("movespeed_slow")
end

function modifier_boltblast_slow:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attack_slow")
end

function InflictDamage(target,attacker,ability,damage,damage_type,flags)
	local flags = flags or 0
	ApplyDamage({
	    victim = target,
	    attacker = attacker,
	    damage = damage,
	    damage_type = damage_type,
	    damage_flags = flags,
	    ability = ability
  	})
end
