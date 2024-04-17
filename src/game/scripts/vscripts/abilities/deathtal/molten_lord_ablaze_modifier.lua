ablaze_modifier = ablaze_modifier or class({})

function ablaze_modifier:IsHidden()
	return false
end

function ablaze_modifier:IsDebuff()
	return true
end

function ablaze_modifier:IsPurgable()
	return true
end

function ablaze_modifier:RemoveOnDeath()
	return true
end

function ablaze_modifier:OnCreated()
	self.interval = 0.5
	if IsServer() then
		self:StartIntervalThink(self.interval)
	end
end

function ablaze_modifier:OnRefresh()
	if IsServer() then
		self:OnIntervalThink()
	end
end

function ablaze_modifier:OnIntervalThink()
	local caster = self:GetCaster()
	local ability = self:GetAbility()
	local parent = self:GetParent()

	local armor = caster:GetPhysicalArmorValue(false)
	local armor_damage = armor * 0.5

	parent:EmitSound("Hero_AbyssalUnderlord.Firestorm.Cast")

	local damageTable = {
		victim = parent,
		attacker = caster,
		damage = armor_damage,
		damage_type = DAMAGE_TYPE_MAGICAL,
		damage_flags = DOTA_DAMAGE_FLAG_NONE,
		ability = ability,
	}
	ApplyDamage(damageTable)
end

function ablaze_modifier:GetTexture()
	return "custom/ablaze"
end

function ablaze_modifier:GetEffectName()
	return "particles/molten_lord/ablaze_debuff.vpcf"
end

function ablaze_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function ablaze_modifier:GetStatusEffectName()
	return "particles/status_fx/status_effect_doom.vpcf"
end

function ablaze_modifier:GetStatusEffectPriority()
	return 10
end
