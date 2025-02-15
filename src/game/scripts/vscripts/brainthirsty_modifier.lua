Brainthirsty_modifier = Brainthirsty_modifier or class ({})

--------------------------------------------------------------------------------

function Brainthirsty_modifier:IsHidden()
    return true
end

function Brainthirsty_modifier:IsDebuff()
    return false
end

function Brainthirsty_modifier:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function Brainthirsty_modifier:OnCreated( kv )
	self.movement_speed_buff_amount = self:GetAbility():GetSpecialValueFor( "brainthirsty_movement_speed_buff_amount" )
	self.attack_speed_bonus_amount = self:GetAbility():GetSpecialValueFor( "brainthirsty_attack_speed_bonus_amount" )

	self.num_to_spawn = 1
	self.flSearchRadius = 1400

	if IsServer() then
		self:SetStackCount(0)
		self:StartIntervalThink(0.5)
	end
end

--------------------------------------------------------------------------------

function Brainthirsty_modifier:OnIntervalThink()
	local caster = self:GetCaster()
	local flDamagePerTick = caster:GetHealth() * 0.002 + ( (caster:GetLevel() * 3.5) / 5 )

	if not caster:IsAlive() then
		self:Destroy()
		return
	end

	if GameRules:IsGamePaused() then
		return
	end

    for i = 1, self.num_to_spawn do
		if not caster:IsAlive() then
			self:Destroy()
			return
		end
		self:IncrementStackCount()
	end

	if caster:IsAlive() then
		local damage = {
			victim = caster,
			attacker = caster,
			damage = flDamagePerTick,
			damage_type = DAMAGE_TYPE_PURE,
			ability = self:GetAbility()
		}

		ApplyDamage( damage )
	end

	local hEnemies = FindUnitsInRadius( caster:GetTeamNumber(), caster:GetOrigin(), nil, 1400, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
	if #hEnemies > 0 then
		self.flSearchRadius = 1400
		return
	else
		if self.flSearchRadius < 12000 then
			self.flSearchRadius = self.flSearchRadius * 2
		end

		caster:SetAcquisitionRange( self.flSearchRadius )
	end
end

--------------------------------------------------------------------------------

function Brainthirsty_modifier:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

--------------------------------------------------------------------------------

function Brainthirsty_modifier:GetModifierMoveSpeedBonus_Constant()
	return self:GetStackCount() * self.movement_speed_buff_amount
end

--------------------------------------------------------------------------------

function Brainthirsty_modifier:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount() * self.attack_speed_bonus_amount
end

